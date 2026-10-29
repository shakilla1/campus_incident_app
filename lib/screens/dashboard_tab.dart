import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';
import '../widgets/incident_card.dart';

class DashboardTab extends StatelessWidget {
  final VoidCallback onSeeAll;
  final VoidCallback onReport;

  const DashboardTab({super.key, required this.onSeeAll, required this.onReport});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user!;
    final incidents = context.watch<IncidentProvider>();
    final scope = user.isStaff ? incidents.all : incidents.mine;
    int count(String status) => scope.where((i) => i.status == status).length;
    final recent = scope.take(3).toList();

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
        children: [
          Text(
            'Hello, ${user.firstName}',
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            user.isStaff
                ? 'Review reports and keep students updated.'
                : 'Report issues and track their resolution.',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),
          if (!user.isStaff) _Banner(onReport: onReport),
          const SizedBox(height: 24),
          Text(
            user.isStaff ? 'All reports' : 'My reports',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _SummaryTile('Total', scope.length, Icons.description_outlined, brandColor),
              _SummaryTile('Submitted', count('Submitted'), Icons.error_outline, const Color(0xFFC77700)),
              _SummaryTile('In Progress', count('In Progress'), Icons.schedule, const Color(0xFF4F3BD6)),
              _SummaryTile('Resolved', count('Resolved'), Icons.check_circle_outline, const Color(0xFF1E8A4C)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent reports',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              TextButton(onPressed: onSeeAll, child: const Text('See all')),
            ],
          ),
          if (incidents.loading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (recent.isEmpty)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: Text('No reports yet.')),
            )
          else
            ...recent.map((i) => IncidentCard(incident: i)),
        ],
      ),
    );
  }
}

class _Banner extends StatelessWidget {
  final VoidCallback onReport;

  const _Banner({required this.onReport});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: brandColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'See an issue on campus?',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          const Text(
            'Report it and help improve our learning environment.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onReport,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: brandColor,
            ),
            icon: const Icon(Icons.add),
            label: const Text('Report an issue'),
          ),
        ],
      ),
    );
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _SummaryTile(this.label, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFEAE7F7)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 6),
            Text('$value', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.black54)),
          ],
        ),
      ),
    );
  }
}
