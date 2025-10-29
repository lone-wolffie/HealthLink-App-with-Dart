import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget{
  final String title;
  final String message;
  final String severity;
  final String date;

  // constructor
  const AlertCard({
    super.key,
    required this.title,
    required this.message,
    required this.severity,
    required this.date,

  });

  Color _getSeverityColor() {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        vertical: 8,
        horizontal: 12
      ),
      
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)
      ),
      
      elevation: 3,
      child: ListTile(
        leading: Icon(
          Icons.warning,
          color: _getSeverityColor()
        ),

        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),

        subtitle: Text(message),
        trailing: Text(
          date,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey
          ),
        ),
      ),
    );
  }
}