import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class SymptomsScreen extends StatelessWidget {
  final int userId;

  const SymptomsScreen({
    super.key,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Common Symptoms',
        showBackButton: true, actions: [],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Here are some common symptoms to look out for:',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold
            ),
          ),
          const SizedBox(height: 20),

          const ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Fever or high temperature'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Persistent cough'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Headache or migraine'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Fatigue or tiredness'),
          ),

          const ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Shortness of breath'),
          ),

          const SizedBox(height: 24),

          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/symptomHistory',
                arguments: userId, 
              );
            },
            child: const Text('View My Logged Symptoms'),
          ),

          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/addSymptom',
                arguments: userId, 
              );
            },
            child: const Text('Add New Symptom'),
          ),
        ],
      ),
    );
  }
}
