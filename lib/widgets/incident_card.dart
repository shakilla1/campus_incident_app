import 'package:flutter/material.dart';
import 'dart:convert';

import '../models/incident.dart';
import '../screens/incident_detail_screen.dart';
import '../utils/constants.dart';
import '../utils/format.dart';
import 'status_chip.dart';

class IncidentCard extends StatelessWidget {
  final Incident incident;

  const IncidentCard({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: const BorderSide(color: Color(0xFFEAE7F7)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => IncidentDetailScreen(incidentId: incident.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _Thumbnail(incident),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      incident.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      incident.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54, fontSize: 13),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      timeAgo(incident.createdAt),
                      style: const TextStyle(color: Colors.black45, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusChip(incident.status),
            ],
          ),
        ),
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final Incident incident;

  const _Thumbnail(this.incident);

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      width: 60,
      height: 60,
      color: const Color(0xFFEFEBFF),
      child: Icon(
        categoryIcons[incident.category] ?? Icons.report_outlined,
        color: brandColor,
      ),
    );
    final data = incident.photoData;
return ClipRRect(
  borderRadius: BorderRadius.circular(10),
  child: data == null
      ? placeholder
      : Image.memory(
          base64Decode(data),
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
);
  }
}