import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../models/health_alerts.dart';

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
  late Future<List<HealthAlerts>> alertsFuture;

  @override
  void initState() {
    super.initState();
    alertsFuture = ApiService.getAllActiveAlerts();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Health Alerts'),
      body: FutureBuilder<List<HealthAlerts>>(
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
                  alertsFuture = ApiService.getAllActiveAlerts();
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
              final alert = alerts[index];

              return AlertCard(
                title: alert.title,
                message: alert.message,
                severity: alert.severity,
                location: alert.location ?? 'Unknown',
                alertType: alert.alertType ?? 'general',
                icon: _getIconFromString(alert.icon ?? ''),
                isActive: alert.isActive,
                date: alert.dateRecorded.toString().substring(0, 10),
              );
            },
          );
        },
      ),
    );
  }
}
