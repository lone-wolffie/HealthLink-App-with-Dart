import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:healthlink_app/models/symptoms.dart';
import 'package:healthlink_app/services/api_service.dart';
import 'package:healthlink_app/widgets/custom_app_bar.dart';
import 'package:healthlink_app/widgets/loading_indicator.dart';

class SymptomHistoryScreen extends StatefulWidget {
  const SymptomHistoryScreen({super.key}); 

  @override
  State<SymptomHistoryScreen> createState() => _SymptomHistoryScreenState();
}

class _SymptomHistoryScreenState extends State<SymptomHistoryScreen> {
  Future<List<Symptoms>>? _symptomsFuture;
  String _selectedFilter = 'all';
  String? _userUuid;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      _showSnack('Session expired. Please login again.');
      return;
    }

    _userUuid = user.id;
    _loadSymptoms();
  }


  void _loadSymptoms() {
    if (_userUuid == null) return;
    setState(() {
      _symptomsFuture = ApiService.getSymptomHistory(_userUuid!);
    });
  }

  Future<void> _deleteSymptom(int id) async {
    try {
      await ApiService.deleteSymptom(id);
      _loadSymptoms();

      if (!mounted) return;
      _showSnack('Symptom removed successfully');
    } catch (error) {
      if (!mounted) return;
      _showSnack('Failed to delte symptom');
    }
  }

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
          ? const Color.fromARGB(255, 244, 29, 13)
          : const Color.fromARGB(255, 12, 185, 9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _severityIcon(String severity) {
    switch (severity.toLowerCase()) {
      case 'low':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'high':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help_outline;
    }
  }

  String _dateGroup(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final theDate = DateTime(date.year, date.month, date.day);

    if (theDate == today) return 'Today';
    if (theDate == today.subtract(const Duration(days: 1))) return 'Yesterday';

    return DateFormat('EEEE, MMM d, yyyy').format(date);
  }

  int _getSeverityCount(List<Symptoms> symptoms, String severity) {
    if (severity == 'all') return symptoms.length;
    return symptoms
      .where((symptom) => symptom.severity.toLowerCase() == severity)
      .length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_userUuid == null) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Symptom History',
        actions: [],
      ),
      body: _symptomsFuture == null
        ? const Center(child: LoadingIndicator())
        : FutureBuilder<List<Symptoms>>(
          future: _symptomsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const LoadingIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading symptom history...',
                    style: TextStyle(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
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
                      'Failed to load your symptom history',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please check your connection and try again',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () {
                        _loadSymptoms();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final allSymptoms = snapshot.data ?? [];

          if (allSymptoms.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.sick_outlined,
                        size: 64,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'No Symptoms Logged',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start tracking your symptoms to build your health history',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Filter symptoms
          final filteredSymptoms = _selectedFilter == 'all'
            ? allSymptoms
            : allSymptoms.where((symptom) => symptom.severity.toLowerCase() == _selectedFilter).toList();

          // group by date recorded
          final grouped = <String, List<Symptoms>>{};
          for (var symptom in filteredSymptoms) {
            final dateLabel = _dateGroup(symptom.dateRecorded);
            grouped.putIfAbsent(dateLabel, () => []).add(symptom);
          }

          final sortedKeys = grouped.keys.toList();

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.filter_list,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Filter by Severity',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildFilterChip(
                          'all', 
                          Icons.list, 
                          allSymptoms
                        ),
                        _buildFilterChip(
                          'low', 
                          Icons.sentiment_satisfied, 
                          allSymptoms
                        ),
                        _buildFilterChip(
                          'medium', 
                          Icons.sentiment_neutral, 
                          allSymptoms
                        ),
                        _buildFilterChip(
                          'high', 
                          Icons.sentiment_very_dissatisfied, 
                          allSymptoms
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Expanded(
                child: filteredSymptoms.isEmpty
                    ? _buildEmptyFilterState()
                    : RefreshIndicator(
                        onRefresh: () async {
                        _loadSymptoms();
                        },
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          children: [
                            for (var group in sortedKeys) ...[
                              Padding(
                                padding: const EdgeInsets.only(
                                  top: 12, 
                                  bottom: 8
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_month_outlined,
                                      size: 16,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      group,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              ...grouped[group]!.map((symptom) {
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                    side: BorderSide(
                                      color: theme.colorScheme.outline.withOpacity(0.2),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: _severityColor(symptom.severity).withOpacity(0.1),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: _severityColor(symptom.severity),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Icon(
                                                _severityIcon(symptom.severity),
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    symptom.symptom,
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                  Text(
                                                    '${symptom.severity[0].toUpperCase()}${symptom.severity.substring(1)}',
                                                    style: TextStyle(
                                                      color: _severityColor(symptom.severity),
                                                      fontWeight: FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                color: Color.fromARGB(255, 244, 29, 13),
                                              ),
                                              onPressed: () async {
                                                final confirm = await showDialog<bool>(
                                                  context: context,
                                                  builder: (_) => AlertDialog(
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(20),
                                                    ),
                                                    icon: const Icon(
                                                      Icons.delete_outline,
                                                      color: Color.fromARGB(255, 244, 29, 13),
                                                      size: 48,
                                                    ),
                                                    title: const Text(
                                                      'Delete Symptom?',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                    content: const Text(
                                                      'This action cannot be undone. Are you sure you want to delete this symptom?',
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () => Navigator.pop(context, false),
                                                        child: Text(
                                                          'Cancel',
                                                          style: TextStyle(
                                                            color: theme.colorScheme.onSurfaceVariant,
                                                          ),
                                                        ),
                                                      ),
                                                      FilledButton(
                                                        onPressed: () => Navigator.pop(context, true),
                                                        style: FilledButton.styleFrom(
                                                          backgroundColor: const Color.fromARGB(255, 244, 29, 13),
                                                        ),
                                                        child:const Text('Yes, Delete'),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                                if (confirm == true) {
                                                  await _deleteSymptom(symptom.id);
                                                }
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: 16,
                                                  color: theme.colorScheme.onSurfaceVariant,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  DateFormat('hh:mm a').format(symptom.dateRecorded),
                                                  style: TextStyle(
                                                    color: theme.colorScheme.onSurfaceVariant,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (symptom.notes.isNotEmpty) ...[
                                              const SizedBox(height: 12),
                                              Container(
                                                padding: const EdgeInsets.all(12),
                                                decoration: BoxDecoration(
                                                  color: theme.colorScheme.surfaceContainerHighest,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Row(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Icon(
                                                      Icons.note_outlined,
                                                      size: 18,
                                                      color: theme.colorScheme.onSurfaceVariant,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Notes',
                                                            style: TextStyle(
                                                              color: theme.colorScheme.onSurfaceVariant,
                                                              fontWeight: FontWeight.w600,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 4),
                                                          Text(
                                                            symptom.notes,
                                                            style: theme.textTheme.bodySmall,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
    String filter, IconData icon, List<Symptoms> allSymptoms) {
      final theme = Theme.of(context);
      final selected = _selectedFilter == filter;
      final count = _getSeverityCount(allSymptoms, filter);
      final color = filter == 'all'
        ? theme.colorScheme.primary
        : _severityColor(filter);

      return FilterChip(
        avatar: Icon(
          icon,
          size: 16,
          color: selected ? Colors.white : color,
        ),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(filter == 'all' ? 'All' : '${filter[0].toUpperCase()}${filter.substring(1)}'),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                  ? Colors.white.withOpacity(0.3)
                  : color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: selected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
        selected: selected,
        onSelected: (_) {
          setState(() {
            _selectedFilter = filter;
          });
        },
        backgroundColor: theme.colorScheme.surface,
        selectedColor: color,
        checkmarkColor: Colors.white,
        labelStyle: TextStyle(
          color: selected ? Colors.white : theme.colorScheme.onSurface,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(
            color: selected ? color : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
      );
    }
    

  Widget _buildEmptyFilterState() {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
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
                Icons.filter_list_off,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No ${_selectedFilter == 'all' ? '' : _selectedFilter} symptoms',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different severity filter',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
    
          ],
        ),
      ),
    );
  }
}
