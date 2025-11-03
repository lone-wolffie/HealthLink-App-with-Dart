import 'package:flutter/material.dart';
import '../models/symptoms.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';

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
      setState(() {
        _loadSymptoms();
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Symptom deleted'),
        ),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $error'),
        ),
      );
    }
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
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Error: ${snapshot.error}'),

                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() => _loadSymptoms()),
                    child: const Text('Retry'),
                  )
                ],
              ),
            );
          }

          final symptoms = snapshot.data ?? [];

          if (symptoms.isEmpty) {
            return const Center(
              child: Text('No symptoms logged yet.')
            );
          }

          return ListView.builder(
            itemCount: symptoms.length,
            padding: const EdgeInsets.all(12),
            itemBuilder: (context, index) {
              final symptom = symptoms[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(symptom.symptom),
                  subtitle: Text('Severity: ${symptom.severity}\nNotes: ${symptom.notes}'),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete, 
                      color: Colors.red
                    ),

                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete symptom?'),
                          content: const Text('This will permanently remove the entry.'),
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
                ),
              );
            },
          );
        },
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(
          context,
          '/addSymptom',
          arguments: widget.userId,
        ).then((_) => setState(() => _loadSymptoms())),
        tooltip: 'Add symptom',
        child: const Icon(Icons.add),
      ),
    );
  }
}
