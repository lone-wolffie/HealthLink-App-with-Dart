import 'package:flutter/material.dart';
import 'package:healthlink_app/models/appointment.dart';
import 'package:healthlink_app/services/api_service.dart';

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

  // @override
  // void initState() {
  //   super.initState();
  //   print("USER ID PASSED TO SCREEN: ${widget.userId}");
  //   print("CLINIC ID PASSED TO SCREEN: ${widget.clinicId}");
  // }


  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 366)),
    );

    if (date != null) {
      setState(() => selectedDate = date);
    }
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (time != null) {
      setState(() => selectedTime = time);
    }
  }

  Future<void> submitAppointment() async {
    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select date and time.")),
      );
      return;
    }

    final appointmentDate = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    ).toIso8601String(); // Convert to ISO format

    Appointment appointment = Appointment(
      userId: widget.userId,
      clinicId: widget.clinicId,
      appointmentAt: appointmentDate,
      notes: notesController.text,
    );

    final response = await ApiService.bookAppointment(appointment);

    if (!mounted) return;

    if (response["success"] == true) {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Appointment booked successfully!")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to book appointment.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Book - ${widget.clinicName}")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickDate,
              child: Text(selectedDate == null
                  ? "Pick Appointment Date"
                  : "Date: ${selectedDate!.toLocal().toString().split(' ')[0]}"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: pickTime,
              child: Text(selectedTime == null
                  ? "Pick Appointment Time"
                  : "Time: ${selectedTime!.format(context)}"),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: "Notes (optional)",
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: submitAppointment,
              child: const Text("Book Appointment"),
            ),
          ],
        ),
      ),
    );
  }
}
