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
    const String url = 'https://api-url.com/api/alerts'; 

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load alerts. Status: ${response.statusCode}');
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
        return Icons.health_and_safety;
      case 'virus':
        return Icons.coronavirus;
      case 'alert':
        return Icons.notification_important;
      default:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Health Alerts'),

      body: FutureBuilder(
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

          final alerts = snapshot.data!;

          if (alerts.isEmpty) {
            return const Center(child: Text('No alerts available.'));
          }

          return ListView.builder(
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];

              return AlertCard(
                title: alert['title'] ?? 'No Title',
                message: alert['message'] ?? 'No Details',
                severity: alert['severity'] ?? 'Unknown',
                location: alert['location'] ?? 'Unknown Location',
                alertType: alert['alert_type'] ?? 'General',
                icon: _getIconFromString(alert['icon'] ?? 'info'),
                isActive: alert['is_active'] ?? false,
                date: alert['published_date']?.substring(0, 10) ?? 'Unknown Date',
              );
            },
          );
        },
      ),
    );
  }
}
