import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../widgets/custom_app_bar.dart';

class TipsScreen extends StatefulWidget {
  const TipsScreen({
    super.key
  });

  @override
  State<TipsScreen> createState() => _TipsScreenState();
}

class _TipsScreenState extends State<TipsScreen> {
  late Future<List<Map<String, dynamic>>> _tipsFuture;

  @override
  void initState() {
    super.initState();
    _loadTips();
  }

  void _loadTips() {
    _tipsFuture = ApiService.getAllHealthTips();
  }

  Future<void> _deleteTip(int id) async {
    try {
      await ApiService.deleteHealthTip(id);
      setState(() {
        _loadTips();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Health tip deleted')
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: "Health Tips", 
        actions: [],
      ),
      
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _tipsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}')
            );
          }

          final tips = snapshot.data ?? [];

          if (tips.isEmpty) {
            return const Center(
              child: Text("No health tips available.")
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: tips.length,
            itemBuilder: (context, index) {
              final tip = tips[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text(
                    tip['title'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(tip['content']),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.delete, 
                      color: Colors.red
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Delete this tip?'),
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
                        await _deleteTip(tip['id']);
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
          '/addTip'
        )
          .then((_) => setState(() => _loadTips())),
        tooltip: 'Add Tip',
        child: const Icon(Icons.add),
      ),
    );
  }
}
