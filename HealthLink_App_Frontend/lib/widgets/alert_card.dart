import 'package:flutter/material.dart';

class AlertCard extends StatelessWidget {
  final String title;
  final String message;
  final String severity;
  final String location;
  final String alertType;
  final IconData icon;
  final bool isActive;
  final String date;

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

  Color _severityColor() {
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
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _severityColor(),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon, 
              size: 30, 
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 17,
                        )
                      ),
                    ),
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Text(
                  message,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.symmetric(
                            horizontal: 10, 
                            vertical: 5
                          ),
                      decoration: BoxDecoration(
                        color: _severityColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        severity.toUpperCase(),
                        style:
                            const TextStyle(
                              color: Colors.white, 
                              fontSize: 12
                            ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    Icon(
                      Icons.location_on,
                      size: 16, 
                      color: Colors.grey.shade600
                    ),
                    Text(
                      location,
                      style: TextStyle(
                        fontSize: 13, 
                        color: Colors.grey.shade600
                      )
                    ),
                  ],
                ),

                const SizedBox(height: 6),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
