import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/incident.dart';

class IncidentService {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('incidents');

  Stream<List<Incident>> watchAll() {
    return _col
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Incident.fromDoc).toList());
  }

  Future<String> uploadPhoto(File file, String uid) async {
    final name = DateTime.now().millisecondsSinceEpoch;
    final ref = _storage.ref('incidents/$uid/$name.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<void> create(Incident incident) => _col.add(incident.toMap());

  Future<void> updateDetails(
    String id, {
    required String title,
    required String description,
    required String category,
    required String location,
  }) {
    return _col.doc(id).update({
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'updatedAt': Timestamp.now(),
    });
  }

  Future<void> updateStatus(String id, String status) {
    final now = Timestamp.now();
    return _col.doc(id).update({
      'status': status,
      'updatedAt': now,
      'history': FieldValue.arrayUnion([
        {'status': status, 'at': now},
      ]),
    });
  }

  Future<void> delete(Incident incident) async {
    await _col.doc(incident.id).delete();
    final url = incident.photoUrl;
    if (url != null) {
      try {
        await _storage.refFromURL(url).delete();
      } catch (_) {}
    }
  }
}
