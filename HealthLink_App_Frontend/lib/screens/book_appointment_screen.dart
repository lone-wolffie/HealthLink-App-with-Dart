import 'package:flutter/material.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key, required Map clinic});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedService;
  final TextEditingController notes = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final clinic = ModalRoute.of(context)!.settings.arguments as Map;
    final services = clinic['services'] as List<String>;

    return Scaffold(
      appBar: AppBar(title: const Text("Book Appointment")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            DropdownButtonFormField(
              decoration: const InputDecoration(labelText: "Select Service"),
              items: services.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => selectedService = v,
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 30)),
                  initialDate: DateTime.now(),
                );
                if (date != null) setState(() => selectedDate = date);
              },
              child: Text(selectedDate == null ? "Select Date" : selectedDate!.toString().split(" ")[0]),
            ),

            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () async {
                final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (time != null) setState(() => selectedTime = time);
              },
              child: Text(selectedTime == null ? "Select Time" : selectedTime!.format(context)),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: notes,
              decoration: const InputDecoration(
                labelText: "Notes (Optional)",
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: () {
                // TODO: Send to backend + trigger notifications
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 48)),
              child: const Text("Confirm Appointment"),
            ),
          ],
        ),
      ),
    );
  }
}
