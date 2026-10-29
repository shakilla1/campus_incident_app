import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';
import '../widgets/incident_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<IncidentProvider>();
    final isStaff = context.watch<AuthProvider>().user!.isStaff;
    final list = p.filtered;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Text(
              'Reports',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: p.setSearch,
              decoration: const InputDecoration(
                hintText: 'Search by title, location or details',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _ChipRow(
            children: [
              if (!isStaff)
                FilterChip(
                  label: const Text('Mine'),
                  selected: p.mineOnly,
                  onSelected: p.setMineOnly,
                ),
              ChoiceChip(
                label: const Text('All status'),
                selected: p.status == null,
                onSelected: (_) => p.setStatus(null),
              ),
              ...statuses.map(
                (s) => ChoiceChip(
                  label: Text(s),
                  selected: p.status == s,
                  onSelected: (_) => p.setStatus(s),
                ),
              ),
            ],
          ),
          _ChipRow(
            children: [
              ChoiceChip(
                label: const Text('All categories'),
                selected: p.category == null,
                onSelected: (_) => p.setCategory(null),
              ),
              ...categories.map(
                (c) => ChoiceChip(
                  label: Text(c),
                  selected: p.category == c,
                  onSelected: (_) => p.setCategory(c),
                ),
              ),
            ],
          ),
          Expanded(child: _body(p, list)),
        ],
      ),
    );
  }

  Widget _body(IncidentProvider p, List<Incident> list) {
    if (p.loading) return const Center(child: CircularProgressIndicator());
    if (p.error != null) return Center(child: Text(p.error!));
    if (list.isEmpty) {
      return const Center(child: Text('No reports match your filters.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 90),
      itemCount: list.length,
      itemBuilder: (_, i) => IncidentCard(incident: list[i]),
    );
  }
}

class _ChipRow extends StatelessWidget {
  final List<Widget> children;

  const _ChipRow({required this.children});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          for (final c in children)
            Padding(padding: const EdgeInsets.only(right: 8), child: c),
        ],
      ),
    );
  }
}
