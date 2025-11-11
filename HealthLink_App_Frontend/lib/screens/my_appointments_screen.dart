import 'package:flutter/material.dart';
import 'package:healthlink_app/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyAppointmentsScreen extends StatefulWidget {

  const MyAppointmentsScreen({
    super.key,
  });
  
  @override
  _MyAppointmentsScreenState createState() => _MyAppointmentsScreenState();
}

class _MyAppointmentsScreenState extends State<MyAppointmentsScreen> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("You must log in first")),
      );
      Navigator.pop(context);
      return;
    }

    try {
      final data = await ApiService.getUserAppointments(userId);
      setState(() {
        appointments = data;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading appointments: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> cancelAppointment(int appointmentId) async {
    final result = await ApiService.cancelAppointment(appointmentId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['message'] ?? "Appointment cancelled")),
    );
    loadAppointments(); // refresh list
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Appointments"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? Center(child: Text("No appointments yet"))
              : ListView.builder(
                  itemCount: appointments.length,
                  itemBuilder: (context, index) {
                    final appt = appointments[index];
                    return Card(
                      margin: EdgeInsets.all(10),
                      child: ListTile(
                        title: Text(appt['clinic_name'] ?? "Clinic"),
                        subtitle: Text(
                            "${appt['appointment_date']} at ${appt['appointment_time']}"),
                        trailing: appt['status'] == 'cancelled'
                            ? Text("Cancelled",
                                style: TextStyle(color: Colors.red))
                            : ElevatedButton(
                                onPressed: () =>
                                    cancelAppointment(appt['id']),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                ),
                                child: Text("Cancel"),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
