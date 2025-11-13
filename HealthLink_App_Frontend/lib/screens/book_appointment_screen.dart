import 'package:flutter/material.dart';
import 'package:healthlink_app/services/notification_service.dart';
import 'package:intl/intl.dart';
import 'package:healthlink_app/models/appointment.dart';
import 'package:healthlink_app/services/api_service.dart';
import 'package:healthlink_app/widgets/custom_app_bar.dart';
import 'package:healthlink_app/widgets/loading_indicator.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/data/latest.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;

class BookAppointmentScreen extends StatefulWidget {
  final int userId;
  final int clinicId;
  final String clinicName;

  const BookAppointmentScreen({
    super.key,
    required this.userId,
    required this.clinicId,
    required this.clinicName,
  });

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController notesController = TextEditingController();
  bool isLoading = false;

  
  // Format selected date
  String get formattedDate =>
      selectedDate != null ? DateFormat('dd/MM/yyyy').format(selectedDate!) : 'Pick Appointment Date';

  Future<void> pickDate() async {
    final date = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: const Color(0xFF1C1B1F),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        DateTime tempDate = DateTime.now();

        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF833775),
              surface: Color(0xFF1C1B1F),
              onSurface: Colors.white70,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFFBB86FC),
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
                    'Select Appointment Date',
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

    if (date != null) setState(() => selectedDate = date);
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      helpText: 'Select Appointment Time',
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (time != null) setState(() => selectedTime = time);
  }

  // Future<void> _scheduleReminder(DateTime appointmentDateTime) async {
  //   final reminderTime = appointmentDateTime.subtract(const Duration(hours: 24));
  //   if (reminderTime.isBefore(DateTime.now())) return;

  //   await flutterLocalNotificationsPlugin.zonedSchedule(
  //     appointmentDateTime.millisecondsSinceEpoch ~/ 1000,
  //     'Upcoming Appointment Reminder',
  //     'You have an appointment at ${widget.clinicName} in 24 hours.',
  //     tz.TZDateTime.from(reminderTime, tz.local),
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'appointment_channel',
  //         'Appointment Reminders',
  //         channelDescription: 'Reminds users 24 hours before appointment',
  //         importance: Importance.high,
  //         priority: Priority.high,
  //         icon: '@mipmap/ic_launcher',
  //       ),
  //     ),
  //     androidAllowWhileIdle: true,
  //     uiLocalNotificationDateInterpretation:
  //         UILocalNotificationDateInterpretation.absoluteTime,
  //     matchDateTimeComponents: DateTimeComponents.dateAndTime,
  //   );
  // }

  Future<void> submitAppointment() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select date and time.'),
          backgroundColor: Color.fromARGB(255, 244, 29, 13),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    final localDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
    final appointmentDate = localDateTime.toUtc().toIso8601String();

    Appointment appointment = Appointment(
      userId: widget.userId,
      clinicId: widget.clinicId,
      appointmentAt: appointmentDate,
      notes: notesController.text,
    );

    final response = await ApiService.bookAppointment(appointment);

    if (!mounted) return;

    setState(() => isLoading = false);

    if (response.containsKey('appointment')) {
      final appointmentId = response['appointment']?['id'] ?? 
                             response['data']?['id'] ?? 
                             localDateTime.millisecondsSinceEpoch;
      
      await NotificationService.scheduleAppointmentReminder(
          appointmentId: appointmentId,
          appointmentDateTime: localDateTime,
          clinicName: widget.clinicName,
      );

      if (!mounted) return; 
      
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment booked successfully! Reminder set for 24 hours before.'),
          backgroundColor: Color.fromARGB(255, 12, 185, 9),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to book appointment.'),
          backgroundColor: Color.fromARGB(255, 244, 29, 13),
        ),
      );
    }
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Book Appointment - ${widget.clinicName}'),
      body: isLoading
          ? const LoadingIndicator()
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Date & Time', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 16),
                  _buildSelectionTile(
                    label: formattedDate,
                    icon: Icons.calendar_today,
                    onTap: pickDate,
                  ),
                  const SizedBox(height: 12),
                  _buildSelectionTile(
                    label: selectedTime == null ? 'Pick Appointment Time' : selectedTime!.format(context),
                    icon: Icons.access_time,
                    onTap: pickTime,
                  ),
                  const SizedBox(height: 24),
                  Text('Notes (optional)', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  TextField(
                    controller: notesController,
                    maxLines: 5,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submitAppointment,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: Color.fromARGB(255, 12, 185, 9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Book Appointment',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSelectionTile({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
          border: Border.all(color: const Color(0xFF833775), width: 1.2),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 6, offset: const Offset(0, 3)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
              ),
            ),
            Icon(icon, color: const Color(0xFF833775), size: 22),
          ],
        ),
      ),
    );
  }
}
