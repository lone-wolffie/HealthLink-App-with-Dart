import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class SymptomsScreen extends StatelessWidget {
  const SymptomsScreen({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Common Symptoms',
        showBackButton: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'Here are some common symptoms to look out for:',
            style: TextStyle(
              fontSize: 16, 
              fontWeight: FontWeight.bold
            ),
          ),

          SizedBox(height: 20),
          ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Fever or high temperature'),
          ),

          ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Persistent cough'),
          ),

          ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Headache or migraine'),
          ),

          ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Fatigue or tiredness'),
          ),

          ListTile(
            leading: Icon(Icons.check_circle),
            title: Text('Shortness of breath'),
          ),
        ],
      ),
    );
  }
}
