import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';
import '../utils/format.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_chip.dart';
import 'report_form_screen.dart';

class IncidentDetailScreen extends StatefulWidget {
  final String incidentId;

  const IncidentDetailScreen({super.key, required this.incidentId});

  @override
  State<IncidentDetailScreen> createState() => _IncidentDetailScreenState();
}

class _IncidentDetailScreenState extends State<IncidentDetailScreen> {
  String? _selectedStatus;
  bool _saving = false;

  Future<void> _saveStatus(Incident incident) async {
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    final error = await context
        .read<IncidentProvider>()
        .updateStatus(incident.id, _selectedStatus!);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (error == null) _selectedStatus = null;
    });
    messenger.showSnackBar(SnackBar(content: Text(error ?? 'Status updated.')));
  }

  Future<void> _delete(Incident incident) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this report?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final error = await context.read<IncidentProvider>().delete(incident);
    if (error == null) {
      navigator.pop();
      messenger.showSnackBar(const SnackBar(content: Text('Report deleted.')));
    } else {
      messenger.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  void _edit(Incident incident) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReportFormScreen(editing: incident)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incident = context.watch<IncidentProvider>().byId(widget.incidentId);
    final user = context.watch<AuthProvider>().user!;

    if (incident == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('This report is no longer available.')),
      );
    }

    final canModify = incident.reportedBy == user.uid && incident.status == 'Submitted';
    final photo = incident.photoData;
    final current = _selectedStatus ?? incident.status;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Incident details'),
        actions: [
          if (canModify)
            PopupMenuButton<String>(
              onSelected: (value) =>
                  value == 'edit' ? _edit(incident) : _delete(incident),
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (photo != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.memory(
                  base64Decode(photo),
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 120,
                    color: const Color(0xFFEFEBFF),
                    child: const Center(child: Text('Photo could not be loaded')),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                Expanded(
                  child: Text(
                    incident.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                StatusChip(incident.status),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(categoryIcons[incident.category] ?? Icons.category_outlined, incident.category),
            _InfoRow(Icons.location_on_outlined, incident.location),
            _InfoRow(Icons.calendar_today_outlined, 'Submitted on ${formatDateTime(incident.createdAt)}'),
            _InfoRow(Icons.person_outline, 'Reported by ${incident.reporterName}'),
            const SizedBox(height: 24),
            const Text('Status timeline', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _Timeline(incident),
            const SizedBox(height: 24),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(incident.description, style: const TextStyle(height: 1.4)),
            if (user.isStaff) ...[
              const SizedBox(height: 28),
              const Text('Update status', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: statuses.map((s) {
                  return ChoiceChip(
                    label: Text(s),
                    selected: current == s,
                    onSelected: (_) => setState(() => _selectedStatus = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              PrimaryButton(
                label: 'Save status',
                loading: _saving,
                onPressed: current == incident.status ? null : () => _saveStatus(incident),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(color: Colors.black87))),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  final Incident incident;

  const _Timeline(this.incident);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: statuses.map((s) {
        final at = incident.reachedAt(s);
        final reached = at != null;
        return Expanded(
          child: Column(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: reached ? brandColor : const Color(0xFFE3E0EF),
                child: Icon(
                  reached ? Icons.check : Icons.more_horiz,
                  size: 16,
                  color: reached ? Colors.white : Colors.black45,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                s,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: reached ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              Text(
                reached ? shortDate(at) : 'Pending',
                style: const TextStyle(fontSize: 11, color: Colors.black45),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
