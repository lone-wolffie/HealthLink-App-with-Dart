import 'package:flutter/material.dart';
import 'package:healthlink_app/services/api_service.dart';
import 'package:healthlink_app/widgets/custom_app_bar.dart';
import 'package:healthlink_app/widgets/loading_indicator.dart';

class MyAppointmentsScreen extends StatefulWidget {
  final int userId;

  const MyAppointmentsScreen({
    super.key, 
    required this.userId
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

  // cancel an appointment after confirmation
  Future<void> _cancelAppointment(int appointmentId) async {
    final response = await ApiService.cancelAppointment(appointmentId);

    if (!mounted) return;

    if (response.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to cancel appointment'),
          backgroundColor: Color.fromARGB(255, 244, 29, 13),
        ),
      );
    } else if (response.containsKey('message')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment cancelled successfully'),
          backgroundColor: Color.fromARGB(255, 12, 185, 9),
        ),
      );
      _refresh();
    }
  }

  // confirm before cancelling
  Future<void> _showCancelConfirmationDialog(int appointmentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Appointment'),
        content: const Text('Are you sure you want to cancel this appointment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _cancelAppointment(appointmentId);
    }
  }

  // mark appointment as completed
  Future<void> _markCompleted(int appointmentId) async {
    final response = await ApiService.completeAppointment(appointmentId);

    if (!mounted) return;

    if (response.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark as completed'),
          backgroundColor: Color.fromARGB(255, 244, 29, 13),
        ),
      );
      return;
    }

    // If success message exists
    if (response.containsKey('message')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment marked as completed'),
          backgroundColor: Color.fromARGB(255, 12, 185, 9),
          duration: Duration(seconds: 3),
        ),
      );
      _refresh();
    }
  }

  // reschedule appointment
  Future<void> _rescheduleAppointment(Map<String, dynamic> appt) async {
    DateTime selectedDate = DateTime.parse(appt["appointment_at"]);
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
                    lastDate: DateTime.now().add(const Duration(days: 366)),
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
                      style: TextStyle(
                        color: Colors.white
                      ),
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
              surface: Color(0xFF2A2A2A),
              onSurface: Colors.white,
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
    ).toIso8601String();

    final response =
        await ApiService.rescheduleAppointment(appt["id"], newDateTime);

    if (response.containsKey('error')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to reschedule the appointment'),
            backgroundColor: Color.fromARGB(255, 244, 29, 13),
          ),
      );
    } 
    
    if (response.containsKey('message')) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Appointment rescheduled successfully'),
          backgroundColor: Color.fromARGB(255, 12, 185, 9),
        ),
      );
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'My Appointments'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF833775),
        onPressed: _refresh,
        child: const Icon(
          Icons.refresh, 
          color: Colors.white
        ),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _appointmentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text('You have no appointments yet.')
                    );
                }

                final filteredAppointments = _selectedFilter == 'all'
                    ? snapshot.data!
                    : snapshot.data!
                        .where((appt) => appt['status'] == _selectedFilter)
                        .toList();

                if (filteredAppointments.isEmpty) {
                  return Center(
                      child: Text('No $_selectedFilter appointments.')
                    );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appt = filteredAppointments[index];
                      final dateTime = DateTime.parse(appt['appointment_at']);
                      final date = '${dateTime.year}-${dateTime.month}-${dateTime.day}';
                      final time = '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)
                          ),
                        elevation: 4,
                        margin: const EdgeInsets.only(bottom: 14),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      appt['clinic_name'] ?? 'Clinic #${appt['clinic_id']}',
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Chip(
                                    label: Text(
                                      appt['status'].toUpperCase(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    backgroundColor: _statusColor(appt['status']),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today,
                                    size: 16, 
                                    color: Colors.grey
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Date: $date',
                                    style: const TextStyle(
                                        color: Colors.black87
                                      )
                                    ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    size: 16, 
                                    color: Colors.grey
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Time: $time',
                                      style: const TextStyle(
                                        color: Colors.black87
                                      )
                                    ),
                                ],
                              ),
                              if (appt['notes'] != null && appt['notes'] != "") ...[
                                const SizedBox(height: 8),
                                Text(
                                  'Notes: ${appt['notes']}',
                                  style: const TextStyle(
                                      color: Colors.black54
                                    )
                                  ),
                              ],
                              const SizedBox(height: 12),
                              _buildActionButtons(appt),
                            ],
                          ),
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

  Widget _buildFilterChips() {
    final filters = ['all', 'booked', 'cancelled', 'completed'];

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 12, 
        vertical: 8
      ),
      child: Wrap(
        spacing: 8,
        children: filters.map((filter) {
          final selected = _selectedFilter == filter;
          return FilterChip(
            label: Text(filter.toUpperCase()),
            selected: selected,
            selectedColor: const Color(0xFF833775),
            backgroundColor: Colors.grey.shade200,
            labelStyle: TextStyle(
              color: selected ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w500,
            ),
            onSelected: (_) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> appt) {
    if (appt['status'] == 'booked') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton.icon(
            icon: const Icon(
              Icons.edit_calendar, 
              color: Colors.orange
            ),
            label: const Text('Reschedule'),
            onPressed: () => _rescheduleAppointment(appt),
          ),
          const SizedBox(width: 6),
          TextButton.icon(
            icon: const Icon(
              Icons.check_circle, 
              color: Colors.green
            ),
            label: const Text('Completed'),
            onPressed: () => _markCompleted(appt['id']),
          ),
          const SizedBox(width: 6),
          TextButton.icon(
            icon: const Icon(
              Icons.cancel, 
              color: Colors.red
            ),
            label: const Text('Cancel'),
            onPressed: () => _showCancelConfirmationDialog(appt['id']),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'booked':
        return Colors.blueAccent;
      case 'cancelled':
        return Colors.redAccent;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
