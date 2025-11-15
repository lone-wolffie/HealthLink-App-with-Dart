// lib/screens/add_edit_medication_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medication.dart';
import '../services/api_service.dart';
import '../services/notification_service.dart';

class AddEditMedicationScreen extends StatefulWidget {
  final int userId;
  final Medication? medication; // if provided -> edit mode

  const AddEditMedicationScreen({super.key, required this.userId, this.medication});

  @override
  State<AddEditMedicationScreen> createState() => _AddEditMedicationScreenState();
}

class _AddEditMedicationScreenState extends State<AddEditMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  List<TimeOfDay> selectedTimes = [];

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      final m = widget.medication!;
      _nameCtrl.text = m.name;
      _doseCtrl.text = m.dose;
      _notesCtrl.text = m.notes ?? '';
      selectedTimes = m.times.map((t) {
        final parts = t.split(':');
        final hh = int.tryParse(parts[0]) ?? 0;
        final mm = int.tryParse(parts[1]) ?? 0;
        return TimeOfDay(hour: hh, minute: mm);
      }).toList();
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _doseCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null) {
      setState(() => selectedTimes.add(t));
    }
  }

  void _removeTime(int index) {
    setState(() => selectedTimes.removeAt(index));
  }

  String _timeOfDayToStr(TimeOfDay t) {
    final h = t.hour.toString().padLeft(2, '0');
    final m = t.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add at least one daily time')));
      return;
    }

    setState(() => isSaving = true);

    final name = _nameCtrl.text.trim();
    final dose = _doseCtrl.text.trim();
    final notes = _notesCtrl.text.trim();
    final times = selectedTimes.map((t) => _timeOfDayToStr(t)).toList();

    // Create on server
    final success = await ApiService.createMedication(
      userId: widget.userId,
      name: name,
      dose: dose,
      times: times,
      notes: notes.isEmpty ? null : notes,
    );

    if (!success) {
      setState(() => isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to add medication'), backgroundColor: Colors.red));
      return;
    }

    // Re-fetch user meds to get created med id(s)
    final meds = await ApiService.getUserMedications(widget.userId);
    // assume newest created is first due to ORDER BY created_at DESC
    final createdMed = meds.isNotEmpty ? meds.first : null;

    if (createdMed != null && createdMed.id != null) {
      // schedule each time
      for (var i = 0; i < createdMed.times.length; i++) {
        final timeStr = createdMed.times[i];
        await NotificationService.scheduleDailyMedicationReminder(
          medId: createdMed.id!,
          index: i,
          timeStr: timeStr,
          medName: createdMed.name,
          dose: createdMed.dose,
          clinicNameOrAppName: 'HealthLink',
        );
      }
    }

    setState(() => isSaving = false);
    // Return true so list screen refreshes
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.medication != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Medication' : 'Add Medication')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(labelText: 'Medication name'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter name' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _doseCtrl,
                decoration: const InputDecoration(labelText: 'Dose (e.g. 500mg)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter dose' : null,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Daily times', style: Theme.of(context).textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ...selectedTimes.asMap().entries.map((e) {
                    final idx = e.key;
                    final t = e.value;
                    return Chip(
                      label: Text(_timeOfDayToStr(t)),
                      onDeleted: () => _removeTime(idx),
                    );
                  }),
                  ActionChip(
                    label: const Text('Add time'),
                    onPressed: _pickTime,
                    avatar: const Icon(Icons.add),
                  )
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSaving ? null : _submit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: isSaving ? const CircularProgressIndicator(color: Colors.white) : Text(isEdit ? 'Save changes' : 'Add medication'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
