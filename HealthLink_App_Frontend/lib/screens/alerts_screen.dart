import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/alert_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({
    super.key
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late Future<List<dynamic>> alertsFuture;

  @override
  void initState() {
    super.initState();
    alertsFuture = fetchAlerts();
  }

  Future<List<dynamic>> fetchAlerts() async {
    const String url = 'http://localhost:3000/api/alerts'; // <-- update; 

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load alerts: ${response.statusCode}');
      }
    } catch (error) {
      throw Exception('Network error: $error');
    }
  }

  IconData _getIconFromString(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'warning':
        return Icons.warning;
      case 'health':
      case 'hospital':
        return Icons.health_and_safety;
      case 'virus':
        return Icons.coronavirus;
      case 'alert':
        return Icons.notification_important;
      case 'syringe':
      case 'vaccination':
        return Icons.medical_services;
      case 'water':
        return Icons.water_drop;
      case 'brain':
        return Icons.psychology;
      default:
        return Icons.info;
    }
  }

  String _formatDate(String? raw) {
    if (raw == null) return 'Unknown Date';
    // If backend gives ISO string, return first 10 chars yyyy-mm-dd
    if (raw.length >= 10) return raw.substring(0, 10);
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Health Alerts'),
      body: FutureBuilder<List<dynamic>>(
        future: alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading alerts...');
          }

          if (snapshot.hasError) {
            return ErrorMessage(
              message: snapshot.error.toString(),
              onClick: () {
                setState(() {
                  alertsFuture = fetchAlerts();
                });
              },
            );
          }

          final alerts = snapshot.data ?? [];
          if (alerts.isEmpty) {
            return const Center(
              child: Text('No alerts available.')
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index] as Map<String, dynamic>;

              return AlertCard(
                title: alert['title'] ?? 'No Title',
                message: alert['message'] ?? 'No message',
                severity: alert['severity'] ?? 'low',
                location: alert['location'] ?? 'Unknown',
                alertType: alert['alert_type'] ?? 'general',
                icon: _getIconFromString(alert['icon'] as String),
                isActive: (alert['is_active'] == null) ? true : (alert['is_active'] as bool),
                date: _formatDate(alert['published_date'] as String?),
              );
            },
          );
        },
      ),
    );
  }
}
