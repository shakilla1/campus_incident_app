import 'package:cloud_firestore/cloud_firestore.dart';

class StatusEntry {
  final String status;
  final DateTime at;

  const StatusEntry(this.status, this.at);
}

class Incident {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String status;
  final String? photoUrl;
  final String? photoData;
  final String reportedBy;
  final String reporterName;
  final DateTime createdAt;
  final List<StatusEntry> history;

  const Incident({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.status,
    required this.reportedBy,
    required this.reporterName,
    required this.createdAt,
    required this.history,
    this.photoUrl,
    this.photoData,
  });

  factory Incident.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    final rawHistory = (d['history'] as List?) ?? [];
    return Incident(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      category: d['category'] ?? '',
      location: d['location'] ?? '',
      status: d['status'] ?? 'Submitted',
      photoUrl: d['photoUrl'],
      photoData: d['photoData'],
      reportedBy: d['reportedBy'] ?? '',
      reporterName: d['reporterName'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      history: rawHistory
          .map((e) => StatusEntry(e['status'], (e['at'] as Timestamp).toDate()))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'status': status,
      'photoUrl': photoUrl,
      'photoData': photoData,
      'reportedBy': reportedBy,
      'reporterName': reporterName,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(createdAt),
      'history': history
          .map((h) => {'status': h.status, 'at': Timestamp.fromDate(h.at)})
          .toList(),
    };
  }

  DateTime? reachedAt(String s) {
    DateTime? found;
    for (final h in history) {
      if (h.status == s) found = h.at;
    }
    return found;
  }
}
