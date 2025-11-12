import 'package:flutter/material.dart';
import 'package:healthlink_app/services/api_service.dart';
import 'package:healthlink_app/widgets/custom_app_bar.dart';
import 'package:healthlink_app/widgets/loading_indicator.dart';

class MyAppointmentsScreen extends StatefulWidget {
  final int userId;

  const MyAppointmentsScreen({super.key, required this.userId});

  @override
  State<MyAppointmentsScreen> createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  late Future<List<Map<String, dynamic>>> _appointmentsFuture;

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

    if (response["message"] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response["message"])),
      );
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "My Appointments"),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _appointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("You have no appointments yet."));
          }

          final appointments = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appt = appointments[index];

                // Format date/time
                final dateTime = DateTime.parse(appt["appointment_at"]);
                final date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
                final time = "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";

                return Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appt["clinic_name"] ?? "Clinic #${appt["clinic_id"]}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text("📅 Date: $date"),
                        Text("⏰ Time: $time"),
                        if (appt["notes"] != null && appt["notes"] != "") ...[
                          const SizedBox(height: 8),
                          Text("📝 Notes: ${appt["notes"]}"),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Chip(
                              label: Text(appt["status"]),
                              backgroundColor: _statusColor(appt["status"]),
                            ),
                            if (appt["status"] == "booked")
                              TextButton(
                                onPressed: () => _cancelAppointment(appt["id"]),
                                child: const Text("Cancel"),
                              )
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case "booked":
        return const Color.fromARGB(255, 151, 200, 241);
      case "cancelled":
        return const Color.fromARGB(255, 253, 166, 175);
      case "completed":
        return const Color.fromARGB(255, 178, 250, 180);
      default:
        return Colors.grey.shade300;
    }
  }
}
