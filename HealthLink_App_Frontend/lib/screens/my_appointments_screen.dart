import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:healthlink_app/services/notification_service.dart';
import 'package:healthlink_app/services/api_service.dart';
import 'package:healthlink_app/widgets/custom_app_bar.dart';
import 'package:healthlink_app/widgets/loading_indicator.dart';

class MyAppointmentsScreen extends StatefulWidget {
  final int userId;

  const MyAppointmentsScreen({
    super.key, 
    required this.
    userId
  });

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  late Future<List<Map<String, dynamic>>> _appointmentsFuture;
  String _selectedFilter = 'all';

  @override
  void initState() {
    super.initState();
    _appointmentsFuture = ApiService.getUserAppointments(widget.userId);
  }

  Future<void> _refresh() async {
    setState(() {
      _appointmentsFuture = ApiService.getUserAppointments(widget.userId);
    });
  }

  Future<void> _cancelAppointment(int appointmentId) async {
    final response = await ApiService.cancelAppointment(appointmentId);

    if (!mounted) return;

    if (response.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:  Text('Failed to cancel appointment'),
          backgroundColor: Color.fromARGB(255, 244, 29, 13),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }

    if (response.containsKey('message')) {
      await NotificationService.cancelAppointmentReminder(appointmentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment cancelled successfully'),
          backgroundColor: Color.fromARGB(255, 12, 185, 9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      _refresh();
    }
  }

  Future<void> _showCancelConfirmationDialog(int appointmentId) async {
    final theme = Theme.of(context);
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        icon: Icon(
          Icons.warning_amber_rounded,
          color: Colors.orange.shade700,
          size: 48,
        ),
        title: const Text(
          'Cancel Appointment?',
          style: TextStyle(
            fontWeight: FontWeight.bold
          ),
        ),
        content: const Text(
          'Are you sure you want to cancel this appointment? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Keep It',
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Color.fromARGB(255, 244, 29, 13),
            ),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _cancelAppointment(appointmentId);
    }
  }

  Future<void> _markCompleted(int appointmentId) async {
    final response = await ApiService.completeAppointment(appointmentId);

    if (!mounted) return;

    if (response.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark appointment as completed'),
          backgroundColor: Color.fromARGB(255, 244, 29, 13),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      return;
    }

    if (response.containsKey('message')) {
      await NotificationService.cancelAppointmentReminder(appointmentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment marked as completed'),
          backgroundColor: Color.fromARGB(255, 12, 185, 9),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
      _refresh();
    }
  }

Future<void> _rescheduleAppointment(Map<String, dynamic> appt) async {
  DateTime selectedDate = DateTime.parse(appt['appointment_at']);
  TimeOfDay selectedTime = TimeOfDay.fromDateTime(selectedDate);

  // pick a new date
  final newDate = await showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF1C1B1F),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),

    builder: (context) {
      DateTime tempDate = selectedDate;

      return Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF833775),
            surface: Color(0xFF1C1B1F),
            onSurface: Colors.white70,
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: Color(0xFFBB86FC)
            ),
          ),
        ),
        child: Container(
          height: 420,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Select New Appointment Date',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: CalendarDatePicker(
                  initialDate: tempDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(
                    const Duration(days: 366)
                  ),
                  onDateChanged: (day) => tempDate = day,
                ),
              ),
              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context, tempDate),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF833775),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (newDate == null) return;

  // pick a new time
  final newTime = await showTimePicker(
    context: context,
    initialTime: selectedTime,
    helpText: 'Select New Time',
    builder: (context, child) {
      return Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF833775),
            onPrimary: Colors.white,
            surface: Color(0xFF1C1B1F),
            onSurface: Colors.white70,
          ),
          timePickerTheme: const TimePickerThemeData(
            backgroundColor: Color(0xFF1C1B1F),
            hourMinuteTextColor: Colors.white,
            dialHandColor: Color(0xFF833775),
            dialBackgroundColor: Color(0xFF2C2C2C),
          ),
        ),
        child: child!,
      );
    },
  );
  if (newTime == null) return;

  final newDateTime = DateTime(
    newDate.year,
    newDate.month,
    newDate.day,
    newTime.hour,
    newTime.minute,
  ).toUtc().toIso8601String();

  final response = await ApiService.rescheduleAppointment(
    appt['id'],
    newDateTime,
  );

  if (response.containsKey('error')) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to reschedule the appointment'),
        backgroundColor: Color.fromARGB(255, 244, 29, 13),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  if (response.containsKey('message')) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Appointment rescheduled successfully'),
        backgroundColor: Color.fromARGB(255, 12, 185, 9),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
    _refresh();
  }
}

  String _getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final appointmentDay = DateTime(date.year, date.month, date.day);

    if (appointmentDay == today) {
      return 'Today';
    } else if (appointmentDay == tomorrow) {
      return 'Tomorrow';
    } else {
      return DateFormat('EEE, MMM dd').format(date);
    }
  }

  int _getStatusCount(List<Map<String, dynamic>> appointments, String status) {
    if (status == 'all') return appointments.length;
    return appointments.where((appt) => appt['status'] == status).length;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'My Appointments'
      ),
      body: Column(
        children: [
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _appointmentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SizedBox.shrink();
              }

              final appointments = snapshot.data ?? [];

              return Container(
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
                            Icons.calendar_month,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Filter Appointments',
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
                          appointments
                        ),
                        _buildFilterChip(
                          'booked', 
                          Icons.event_available, 
                          appointments
                        ),
                        _buildFilterChip(
                          'completed', 
                          Icons.check_circle, 
                          appointments
                        ),
                        _buildFilterChip(
                          'cancelled', 
                          Icons.cancel, 
                          appointments
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _appointmentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: LoadingIndicator()
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState();
                }

                final filteredAppointments = _selectedFilter == 'all'
                  ? snapshot.data!
                  : snapshot.data!
                    .where((appt) => appt['status'] == _selectedFilter)
                    .toList();

                if (filteredAppointments.isEmpty) {
                  return _buildEmptyFilterState();
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appt = filteredAppointments[index];
                      final dateTime = DateTime.parse(appt['appointment_at']);
                      final localDateTime = dateTime.toLocal();
                      final time = DateFormat('hh:mm a').format(localDateTime);

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: const Color.fromARGB(255, 84, 166, 234),
                          ),
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: _statusColor(appt['status']).withOpacity(0.1),
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
                                      color: _statusColor(appt['status']),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _statusIcon(appt['status']),
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
                                          appt['clinic_name'] ?? 'Clinic #${appt['clinic_id']}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          appt['status'].toUpperCase(),
                                          style: theme.textTheme.labelSmall?.copyWith(
                                            color: _statusColor(appt['status']),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // appointment details
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildInfoRow(
                                          Icons.calendar_today,
                                          'Date',
                                          _getRelativeDate(localDateTime),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: _buildInfoRow(
                                          Icons.access_time,
                                          'Time',
                                          time,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (appt['notes'] != null && appt['notes'] != "") ...[
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
                                                const SizedBox(height: 2),
                                                Text(
                                                  appt['notes'],
                                                  style: theme.textTheme.bodySmall,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  if (appt['status'] == 'booked') ...[
                                    const SizedBox(height: 16),
                                    const Divider(height: 1),
                                    const SizedBox(height: 8),
                                    _buildActionButtons(appt),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String filter, IconData icon, List<Map<String, dynamic>> appointments) {
    final theme = Theme.of(context);
    final selected = _selectedFilter == filter;
    final count = _getStatusCount(appointments, filter);
    final color = _statusColor(filter);

    return FilterChip(
      avatar: Icon(
        icon,
        size: 16,
        color: selected ? Colors.white : color,
      ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(filter.toUpperCase()),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 6, 
              vertical: 2
            ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> appt) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      children: [
        FilledButton.tonalIcon(
          onPressed: () => _rescheduleAppointment(appt),
          icon: const Icon(
            Icons.edit_calendar, 
            size: 18
          ),
          label: const Text('Reschedule'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.orange.shade100,
            foregroundColor: Colors.orange.shade800,
          ),
        ),
        FilledButton.icon(
          onPressed: () => _markCompleted(appt['id']),
          icon: const Icon(Icons.check_circle, size: 18),
          label: const Text('Complete'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green.shade600,
          ),
        ),
        FilledButton.icon(
          onPressed: () => _showCancelConfirmationDialog(appt['id']),
          icon: const Icon(Icons.cancel, size: 18),
          label: const Text('Cancel'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.red.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
                color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.calendar_today,
                size: 64,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Appointments Yet',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Book your first appointment with a clinic to get started',
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
              'No $_selectedFilter Appointments',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different filter',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'all';
                });
              },
              icon: const Icon(Icons.clear_all),
              label: const Text('Show All'),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
      case 'all':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'booked':
        return Icons.event_available;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.check_circle;
      default:
        return Icons.event;
    }
  }
}