import 'package:flutter/material.dart';

import '../utils/constants.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (background, text) = statusColors[status] ?? statusColors['Submitted']!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}
