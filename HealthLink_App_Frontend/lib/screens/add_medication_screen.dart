import 'package:flutter/material.dart';
import 'package:healthlink_app/models/medication.dart';
import 'package:healthlink_app/services/api_service.dart';
import 'package:healthlink_app/services/notification_service.dart';
import 'package:healthlink_app/widgets/custom_app_bar.dart';
import 'package:healthlink_app/widgets/loading_indicator.dart';

class AddMedicationScreen extends StatefulWidget {
  final int userId;
  final Medication? medication;

  const AddMedicationScreen({
    super.key, 
    required this.userId, 
    this.medication
  });

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _doseCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  List<String> selectedTimes = [];

  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.medication != null) {
      final medication = widget.medication!;
      _nameCtrl.text = medication.name;
      _doseCtrl.text = medication.dose;
      _notesCtrl.text = medication.notes ?? '';
      selectedTimes = List<String>.from(medication.times);
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
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context, 
      initialTime: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final hour = picked.hour.toString().padLeft(2, '0');
      final minute = picked.minute.toString().padLeft(2, '0');
      final timeStr = '$hour:$minute';
      
      if (selectedTimes.contains(timeStr)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('This time has already been added'),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        return;
      }
      
      setState(() {
        selectedTimes.add(timeStr);
        selectedTimes.sort();
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Please add at least one daily time')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    setState(() => isSaving = true);

    final name = _nameCtrl.text.trim();
    final dose = _doseCtrl.text.trim();
    final notes = _notesCtrl.text.trim();

    bool success = false;
    if (widget.medication == null) {
      success = await ApiService.createMedication(
        userId: widget.userId,
        name: name,
        dose: dose,
        times: selectedTimes,
        notes: notes.isEmpty ? null : notes,
      );
    }

    if (!success) {
      setState(() => isSaving = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 12),
              Expanded(child: Text('Failed to add medication')),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        )
      );
      return;
    }

    final medication = await ApiService.getUserMedication(widget.userId);
    Medication? created;

    if (widget.medication == null) {
      if (medication.isNotEmpty) {
        created = medication.firstWhere(
          (meds) => meds.name == name && meds.dose == dose,
          orElse: () => medication.first,
        );
      } else {
        created = null;
      }
    } else {
      created = medication.firstWhere(
        (meds) => meds.id == widget.medication!.id,
        orElse: () => widget.medication!,
      );
    }

    if (created!.id != null) {
      await NotificationService.cancelMedicationReminders(created.id!);

      for (int i = 0; i < selectedTimes.length; i++) {
        await NotificationService.scheduleDailyMedicationReminder(
          medicationId: created.id!, 
          index: i, 
          medicationName: created.name, 
          dose: created.dose, 
          time: selectedTimes[i]
        );
      }
    }

    setState(() => isSaving = false);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  void _removeTime(String time) {
    setState(() => selectedTimes.remove(time));
  }
    
  @override
  Widget build(BuildContext context) {
    final isEdit = widget.medication != null;
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: CustomAppBar(
        title: isEdit ? 'Edit Medication' : 'Add Medication',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medication Info Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.primaryContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.medication,
                                      color: theme.colorScheme.primary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Medication Details',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              TextFormField(
                                controller: _nameCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Medication name',
                                  prefixIcon: const Icon(Icons.local_pharmacy_outlined),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                validator: (value) => value == null || value.trim().isEmpty 
                                  ? 'Enter medication name' 
                                  : null,
                              ),
                              const SizedBox(height: 16),

                              TextFormField(
                                controller: _doseCtrl,
                                decoration: InputDecoration(
                                  labelText: 'Dose',
                                  hintText: 'e.g., 500mg, 1 tablet',
                                  prefixIcon: const Icon(Icons.straighten),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                validator: (value) => value == null || value.trim().isEmpty 
                                  ? 'Enter dose' 
                                  : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),

                      // Schedule Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.secondaryContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.access_time,
                                      color: theme.colorScheme.secondary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      'Daily Schedule',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  FilledButton.tonalIcon(
                                    onPressed: _pickTime,
                                    icon: const Icon(Icons.add, size: 20),
                                    label: const Text('Add'),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              
                              if (selectedTimes.isEmpty) ...[
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: theme.colorScheme.outline.withOpacity(0.2),
                                      style: BorderStyle.solid,
                                      width: 2,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: theme.colorScheme.onSurfaceVariant,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'No times added yet. Tap "Add" to schedule.',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else ...[
                                const SizedBox(height: 16),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: selectedTimes.map((time) {
                                    final parts = time.split(':');
                                    final hour = int.parse(parts[0]);
                                    final minute = parts[1];
                                    final period = hour >= 12 ? 'PM' : 'AM';
                                    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
                                    final displayTime = '$displayHour:$minute $period';
                                    
                                    return Chip(
                                      avatar: CircleAvatar(
                                        backgroundColor: theme.colorScheme.primaryContainer,
                                        child: Icon(
                                          Icons.schedule,
                                          size: 16,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      label: Text(
                                        displayTime,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      deleteIcon: const Icon(Icons.close, size: 18),
                                      onDeleted: () => _removeTime(time),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Notes Card
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outline.withOpacity(0.2),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.tertiaryContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.note_outlined,
                                      color: theme.colorScheme.tertiary,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Additional Notes',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              TextFormField(
                                controller: _notesCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Add instructions',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: true,
                                  fillColor: theme.colorScheme.surface,
                                ),
                                maxLines: 4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Action Button
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: isSaving ? null : _submit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isSaving 
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: LoadingIndicator(
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isEdit ? Icons.save : Icons.add_circle_outline,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isEdit ? 'Save Changes' : 'Add Medication',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}