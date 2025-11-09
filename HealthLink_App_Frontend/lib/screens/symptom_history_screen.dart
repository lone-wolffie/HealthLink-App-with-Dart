import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/symptoms.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_indicator.dart';

class SymptomHistoryScreen extends StatefulWidget {
  final int userId;

  const SymptomHistoryScreen({
    super.key,
    required this.userId,
  });

  @override
  State<SymptomHistoryScreen> createState() => _SymptomHistoryScreenState();
}

class _SymptomHistoryScreenState extends State<SymptomHistoryScreen> {
  late Future<List<Symptoms>> _symptomsFuture;

  @override
  void initState() {
    super.initState();
    _loadSymptoms();
  }

  void _loadSymptoms() {
    _symptomsFuture = ApiService.getSymptomHistory(widget.userId);
  }

  Future<void> _deleteSymptom(int id) async {
    try {
      await ApiService.deleteSymptom(id);
      setState(() => _loadSymptoms());

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Symptom removed')
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $error')
        ),
      );
    }
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _dateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final theDate = DateTime(date.year, date.month, date.day);

    if (theDate == today) return 'Today';
    if (theDate == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Symptom History',
        actions: [],
      ),

      body: FutureBuilder<List<Symptoms>>(
        future: _symptomsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: LoadingIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Something went wrong.'),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () => setState(_loadSymptoms),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final symptoms = snapshot.data ?? [];

          if (symptoms.isEmpty) {
            return Center(
              child: Text(
                'No symptoms logged yet.',
                style: TextStyle(
                  fontSize: 16, 
                  color: Colors.grey.shade600
                ),
              ),
            );
          }

          final grouped = <String, List<Symptoms>>{};
          for (var symptom in symptoms) {
            final dateLabel = _dateGroup(symptom.dateRecorded);
            grouped.putIfAbsent(dateLabel, () => []).add(symptom);
          }

          final sortedKeys = grouped.keys.toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              for (var group in sortedKeys) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10, 
                    bottom: 6
                  ),
                  child: Text(
                    group,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color.fromARGB(255, 33, 44, 243),
                    ),
                  ),
                ),

                ...grouped[group]!.map((symptom) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color.fromARGB(173, 0, 0, 0),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                symptom.symptom,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete, 
                                color: Colors.red
                              ),
                              onPressed: () async {
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('Delete symptom?'),
                                    content: const Text('This action cannot be undone.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: const Text('Delete'),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirm == true) {
                                  await _deleteSymptom(symptom.id);
                                }
                              },
                            ),
                          ],
                        ),

                        Text(
                          DateFormat('hh:mm a').format(symptom.dateRecorded),
                          style: TextStyle(
                            fontSize: 13, 
                            color: Colors.grey.shade600
                          ),
                        ),

                        const SizedBox(height: 10),

                        Chip(
                          label: Text(
                            symptom.severity[0].toUpperCase() + symptom.severity.substring(1),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _severityColor(symptom.severity),
                        ),

                        if (symptom.notes.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color.fromARGB(255, 173, 171, 171)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.notes, 
                                  color: Colors.grey.shade600, 
                                  size: 20
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    symptom.notes,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade800,
                                      height: 1.5,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                }),
              ]
            ],
          );
        },
      ),
    );
  }
}
