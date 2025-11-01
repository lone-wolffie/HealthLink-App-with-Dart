import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget{
  final String title;
  final String message;
  final String severity;
  final String location;
  final String alertType;
  final IconData icon;        
  final bool isActive;
  final String date;

  // constructor
  const AlertCard({
    super.key,
    required this.title,
    required this.message,
    required this.severity,
    required this.location,
    required this.alertType,
    required this.icon,
    required this.isActive,
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
          icon,
          color: _getSeverityColor(),
          size: 32,
        ),

        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold)
        ),

        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(message),

            const SizedBox(height: 4),
            Text('Location: $location'),
            Text('Type: $alertType'),
            Text(
              isActive ? 'Status: Active' : 'Status: Cleared',
              style: TextStyle(
                color: isActive ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
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