import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:healthlink_app/services/api_service.dart';
import 'package:healthlink_app/models/health_alerts.dart';
import 'package:healthlink_app/widgets/alert_card.dart';
import 'package:healthlink_app/widgets/custom_app_bar.dart';
import 'package:healthlink_app/widgets/loading_indicator.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({
    super.key
  });

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  late Future<List<HealthAlerts>> alertsFuture;
  List<HealthAlerts> _allAlerts = [];
  List<HealthAlerts> _filteredAlerts = [];

  String _searchQuery = '';
  String _selectedSeverity = 'All';
  bool _showFilters = false;

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

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _applyFilters() {
    List<HealthAlerts> results = _allAlerts;

    // filter by severity
    if (_selectedSeverity != 'All') {
      results = results.where(
        (alert) => alert.severity.toLowerCase() == _selectedSeverity.toLowerCase(),
      ).toList();
    }

    if (_searchQuery.isNotEmpty) {
      results = results.where(
        (alert) => alert.title.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        ) || alert.message.toLowerCase().contains(
          _searchQuery.toLowerCase(),
        ),
      ).toList();
    }

    setState(() {
      _filteredAlerts = results;
    });
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Unknown';
    }
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  int _getSeverityCount(String severity) {
    if (severity == 'All') return _allAlerts.length;
    return _allAlerts.where((alert) => alert.severity.toLowerCase() == severity.toLowerCase()).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Health Alerts', 
        actions: []
      ),
      body: FutureBuilder<List<HealthAlerts>>(
        future: alertsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingIndicator(message: 'Loading alerts...');
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.error_outline,
                        size: 64,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Failed to load alerts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your connection and try again',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        setState(() {
                          alertsFuture = ApiService.getAllActiveAlerts();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          _allAlerts = snapshot.data ?? [];
          _filteredAlerts = _filteredAlerts.isEmpty && _searchQuery.isEmpty && _selectedSeverity == 'All'
            ? _allAlerts : _filteredAlerts;

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(255, 185, 185, 185),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: 'Search alerts...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: theme.colorScheme.primary,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _searchQuery = '';
                                });
                                _applyFilters();
                              },
                            )
                          : IconButton(
                              icon: Icon(
                                _showFilters ? Icons.filter_list : Icons.filter_list_outlined,
                              ),
                              onPressed: () {
                                setState(() {
                                  _showFilters = !_showFilters;
                                });
                              },
                            ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ), 
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                        _applyFilters();
                      },
                    ),

                    // filter chips
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      height: _showFilters ? null : 0,
                      child: _showFilters
                        ? Column(
                          children: [
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.tune,
                                  size: 18,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Filter by severity',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildFilterChip('All', Icons.list),
                                _buildFilterChip('High', Icons.priority_high),
                                _buildFilterChip('Medium', Icons.warning_amber),
                                _buildFilterChip('Low', Icons.info_outline),
                              ],
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),

              if (_showFilters)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16, 
                    vertical: 12
                  ),
                  child: Row(
                    children: [
                      _buildStatChip(
                        'High',
                        _getSeverityCount('High'),
                        Colors.red,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        'Medium',
                        _getSeverityCount('Medium'),
                        Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      _buildStatChip(
                        'Low',
                        _getSeverityCount('Low'),
                        Colors.green,
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Row(
                  children: [
                    Text(
                      '${_filteredAlerts.length} ${_filteredAlerts.length == 1 ? 'Alert' : 'Alerts'}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedSeverity != 'All') ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(_selectedSeverity).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _selectedSeverity,
                          style: TextStyle(
                            color: _getSeverityColor(_selectedSeverity),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              Expanded(
                child: _filteredAlerts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: _filteredAlerts.length,
                      itemBuilder: (context, index) {
                        final alert = _filteredAlerts[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: AlertCard(
                            title: alert.title,
                            message: alert.message,
                            severity: alert.severity,
                            location: alert.location ?? 'Unknown',
                            alertType: alert.alertType ?? 'general',
                            icon: _getIcon(alert.icon ?? ''),
                            isActive: alert.isActive,
                            date: _formatDate(alert.dateRecorded),
                          ),
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

  Widget _buildFilterChip(String label, IconData icon) {
    final theme = Theme.of(context);
    final isSelected = _selectedSeverity == label;
    final count = _getSeverityCount(label);
    final color = label == 'All'
      ? theme.colorScheme.primary
      : _getSeverityColor(label);

    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected ? Colors.white : color,
          ),
          const SizedBox(width: 6),
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6, 
              vertical: 2
            ),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.3) : color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ),
        ],
      ),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedSeverity = label;
        });
        _applyFilters();
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: color,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : theme.colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? color : theme.colorScheme.outline.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildStatChip(String label, int count, Color color) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 8, 
          horizontal: 12
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Text(
              count.toString(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.notifications_off_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isNotEmpty ? 'No alerts found' : 'No alerts available',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 48),
            child: Text(
              _searchQuery.isNotEmpty ? 'Try adjusting your search or filters' : "You're all caught up! Check back later for updates.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty || _selectedSeverity != 'All') ...[
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _searchQuery = '';
                  _selectedSeverity = 'All';
                });
                _applyFilters();
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Clear filters'),
            ),
          ],
        ],
      ),
    );
  }
}