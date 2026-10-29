import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../models/incident.dart';
import '../services/incident_service.dart';

class IncidentProvider extends ChangeNotifier {
  final IncidentService _service;
  StreamSubscription<List<Incident>>? _sub;
  String? _uid;

  List<Incident> all = [];
  bool loading = true;
  String? error;

  String search = '';
  String? category;
  String? status;
  bool mineOnly = false;

  IncidentProvider(this._service);

  void start(String uid) {
    if (_uid == uid) return;
    _uid = uid;
    loading = true;
    _sub?.cancel();
    _sub = _service.watchAll().listen(
      (list) {
        all = list;
        loading = false;
        error = null;
        notifyListeners();
      },
      onError: (_) {
        loading = false;
        error = 'Could not load reports.';
        notifyListeners();
      },
    );
  }

  void stop() {
    if (_uid == null) return;
    _sub?.cancel();
    _uid = null;
    all = [];
    search = '';
    category = null;
    status = null;
    mineOnly = false;
    loading = true;
  }

  List<Incident> get mine => all.where((i) => i.reportedBy == _uid).toList();

  List<Incident> get filtered {
    final q = search.trim().toLowerCase();
    return all.where((i) {
      if (mineOnly && i.reportedBy != _uid) return false;
      if (category != null && i.category != category) return false;
      if (status != null && i.status != status) return false;
      if (q.isNotEmpty) {
        final text = '${i.title} ${i.location} ${i.description}'.toLowerCase();
        if (!text.contains(q)) return false;
      }
      return true;
    }).toList();
  }

  Incident? byId(String id) {
    for (final i in all) {
      if (i.id == id) return i;
    }
    return null;
  }

  void setSearch(String value) {
    search = value;
    notifyListeners();
  }

  void setCategory(String? value) {
    category = value;
    notifyListeners();
  }

  void setStatus(String? value) {
    status = value;
    notifyListeners();
  }

  void setMineOnly(bool value) {
    mineOnly = value;
    notifyListeners();
  }

  Future<String?> submit({
  required AppUser user,
  required String title,
  required String description,
  required String category,
  required String location,
  File? photo,
}) {
  return _attempt('Could not submit the report. Check your connection.', () async {
    String? data;
    if (photo != null) {
      final bytes = await photo.readAsBytes();
      if (bytes.length > 600000) throw Exception('Photo too large');
      data = base64Encode(bytes);
    }
    final now = DateTime.now();
    await _service.create(Incident(
      id: '',
      title: title,
      description: description,
      category: category,
      location: location,
      status: 'Submitted',
      photoData: data,
      reportedBy: user.uid,
      reporterName: user.name,
      createdAt: now,
      history: [StatusEntry('Submitted', now)],
    ));
  });
}

  Future<String?> edit(
    String id, {
    required String title,
    required String description,
    required String category,
    required String location,
  }) {
    return _attempt('Could not save your changes.', () {
      return _service.updateDetails(
        id,
        title: title,
        description: description,
        category: category,
        location: location,
      );
    });
  }

  Future<String?> updateStatus(String id, String newStatus) {
    return _attempt('Could not update the status.', () {
      return _service.updateStatus(id, newStatus);
    });
  }

  Future<String?> delete(Incident incident) {
    return _attempt('Could not delete the report.', () {
      return _service.delete(incident);
    });
  }

  Future<String?> _attempt(String message, Future<void> Function() action) async {
    try {
      await action();
      return null;
    } catch (_) {
      return message;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
