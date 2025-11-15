// lib/screens/medications_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'add_medication_screen.dart';

class MedicationsScreen extends StatefulWidget {
  final int userId;
  const MedicationsScreen({super.key, required this.userId});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  late Future<List<Medication>> _futureMeds;

  @override
  void initState() {
    super.initState();
    NotificationService.init(); // ensure notifications are initialized
    _load();
  }

  void _load() {
    setState(() {
      _futureMeds = ApiService.getUserMedications(widget.userId);
    });
  }

  Future<void> _deleteMedication(Medication med) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete medication'),
        content: Text('Delete "${med.name}"? This will also cancel reminders.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes, delete')),
        ],
      ),
    );

    if (confirm != true) return;

    final success = await ApiService.deleteMedication(med.id!);
    if (success) {
      // cancel reminders
      await NotificationService.cancelMedicationReminders(med.id!);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Medication deleted'), backgroundColor: Colors.green));
      _load();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to delete'), backgroundColor: Colors.red));
    }
  }

  Future<void> _onAdd() async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditMedicationScreen(userId: widget.userId)),
    );
    if (changed == true) _load();
  }

  Future<void> _onEdit(Medication med) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEditMedicationScreen(userId: widget.userId, medication: med)),
    );
    if (changed == true) _load();
  }

  Widget _buildTimesRow(List<String> times) {
    return Wrap(
      spacing: 8,
      children: times.map((t) => Chip(label: Text(t))).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medications')),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Medication>>(
        future: _futureMeds,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));
          final meds = snap.data ?? [];
          if (meds.isEmpty) return const Center(child: Text('No medications yet.'));

          return RefreshIndicator(
            onRefresh: () async => _load(),
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: meds.length,
              itemBuilder: (_, i) {
                final med = meds[i];
                final created = med.createdAt != null ? DateFormat('dd/MM/yyyy').format(med.createdAt!) : '';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text('${med.name} — ${med.dose}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 6),
                        _buildTimesRow(med.times),
                        if (med.notes != null && med.notes!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Notes: ${med.notes}', style: const TextStyle(fontSize: 12, color: Colors.black54)),
                        ],
                        if (created.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text('Added: $created', style: const TextStyle(fontSize: 11, color: Colors.black45)),
                        ]
                      ],
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _onEdit(med);
                        } else if (value == 'delete') {
                          await _deleteMedication(med);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
