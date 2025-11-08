import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/health_alerts.dart';
import '../widgets/alert_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_message.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late Future<List<HealthAlerts>> alertsFuture;
  List<HealthAlerts> _allAlerts = [];
  List<HealthAlerts> _filteredAlerts = [];

  String _searchQuery = '';
  String _selectedSeverity = 'All';

  @override
  void initState() {
    super.initState();
    alertsFuture = ApiService.getAllActiveAlerts();
  }

  IconData _getIcon(String iconName) {
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
      case 'vaccination':
      case 'syringe':
        return Icons.medical_services;
      case 'water':
        return Icons.water_drop;
      case 'brain':
        return Icons.psychology;
      default:
        return Icons.info;
    }
  }

  void _applyFilters() {
    List<HealthAlerts> results = _allAlerts;

    // Filter by severity
    if (_selectedSeverity != 'All') {
      results = results
          .where(
            (alert) =>
                alert.severity.toLowerCase() == _selectedSeverity.toLowerCase(),
          )
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      results = results
          .where(
            (alert) =>
                alert.title.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ) ||
                alert.message.toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          )
          .toList();
    }

    setState(() {
      _filteredAlerts = results;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Health Alerts', actions: []),

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

          _allAlerts = snapshot.data ?? [];
          _filteredAlerts =
              _filteredAlerts.isEmpty &&
                  _searchQuery.isEmpty &&
                  _selectedSeverity == 'All'
              ? _allAlerts
              : _filteredAlerts;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search alerts...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onChanged: (value) {
                    _searchQuery = value;
                    _applyFilters();
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 10,
                  children: [
                    _buildChip('All'),
                    _buildChip('High'),
                    _buildChip('Medium'),
                    _buildChip('Low'),
                  ],
                ),
              ),

              // Alerts List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _filteredAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = _filteredAlerts[index];
                    return AlertCard(
                      title: alert.title,
                      message: alert.message,
                      severity: alert.severity,
                      location: alert.location ?? 'Unknown',
                      alertType: alert.alertType ?? 'general',
                      icon: _getIcon(alert.icon ?? ''),
                      isActive: alert.isActive,
                      date: _formatDate(alert.dateRecorded),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChip(String label) {
    final isSelected = _selectedSeverity == label;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedSeverity = label;
        });
        _applyFilters();
      },
      selectedColor: Colors.deepOrange,
      labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black),
    );
  }
}
