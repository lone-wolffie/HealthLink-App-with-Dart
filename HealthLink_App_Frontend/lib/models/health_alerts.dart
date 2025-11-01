import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HealthAlerts {
  final int id;
  final String title;
  final String message;
  final String severity;
  final String? location;  // have value or be null
  final String? alertType;
  final String? icon;
  final bool isActive;
  final DateTime dateRecorded;

  // constructor - required fields
  HealthAlerts({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    this.location,
    this.alertType,
    this.icon,
    required this.isActive,
    required this.dateRecorded,
  });

  IconData get iconData {
    switch ((icon ?? '').toLowerCase()) {
      case 'warning':
        return Icons.warning;
      case 'virus':
        return Icons.coronavirus;
      case 'hospital':
      case 'health':
        return Icons.local_hospital;
      case 'water':
        return Icons.water_drop;
      case 'info':
        return Icons.info;
      default:
        return Icons.campaign;
    }
  }

  String get formattedDate {
    return DateFormat('d MMM yyyy').format(dateRecorded);
  }

  // create health alerts object from JSON data
  factory HealthAlerts.fromJson(Map<String, dynamic> json) {
    return HealthAlerts(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      severity: json['severity'],
      location: json['location'],
      alertType: json['alert_type'],
      icon: json['icon'],
      isActive: json['is_active'] ?? true,
      dateRecorded: DateTime.parse(json['published_date']),
    );
  }

  // convert health alerts object to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'severity': severity,
      'location': location,
      'alert_type': alertType,
      'icon': icon,
      'is_active': isActive,
      'published_date': dateRecorded.toIso8601String(),
    };
  }
}
