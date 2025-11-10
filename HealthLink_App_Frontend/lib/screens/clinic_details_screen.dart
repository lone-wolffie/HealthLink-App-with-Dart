import 'package:flutter/material.dart';
import '../screens/book_appointment_screen.dart';

class ClinicDetailsScreen extends StatelessWidget {
  const ClinicDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final clinic = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      appBar: AppBar(title: Text(clinic['name'])),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(clinic['address'], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 6),
            Text("📞 ${clinic['phone']}"),
            Text("📧 ${clinic['email']}"),
            const SizedBox(height: 20),

            const Text("Services", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: (clinic['services'] as List<dynamic>).map((s) => Chip(
                label: Text(s),
              )).toList(),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    builder: (_) => BookAppointmentScreen(clinic: clinic),
                  );
                },
                child: const Text("Book Appointment"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
