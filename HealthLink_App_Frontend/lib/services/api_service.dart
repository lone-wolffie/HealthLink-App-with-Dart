import 'dart:convert'; // to convert data between JSON and dart objects.
import 'dart:io' show Platform; // platform type
import 'package:path/path.dart';
import 'package:flutter/foundation.dart'
    show
        kIsWeb,
        debugPrint; // web, android emulator, iOS Simulator or physical device
import 'package:http/http.dart' as http; // to make REST API calls to backend
import 'package:healthlink_app/models/health_tips.dart';
import 'package:healthlink_app/models/symptoms.dart';
import 'package:healthlink_app/models/health_alerts.dart';
import 'package:healthlink_app/models/clinics.dart';
import 'package:healthlink_app/models/appointment.dart';
import 'package:healthlink_app/models/medication.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'https://healthlink-app-with-dart-1.onrender.com/api'; // web
    } else if (Platform.isAndroid) {
      return 'https://healthlink-app-with-dart-1.onrender.com/api'; // physical device
    } else if (Platform.isIOS) {
      return 'https://healthlink-app-with-dart-1.onrender.com/api'; // iOS Simulator
    } else {
      return 'https://healthlink-app-with-dart-1.onrender.com/api'; // android emulator
    }
  }

  // signup
  static Future<Map<String, dynamic>> signup(
    String fullname,
    String email,
    String phoneNumber,
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullname': fullname,
        'email': email,
        'phonenumber': phoneNumber,
        'username': username,
        'password': password,
      }),
    );

    return jsonDecode(response.body);
  }

  // login
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    return jsonDecode(response.body);
  }

  // reset password if forgotten
  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'success': false, 'message': 'Failed to send reset link'};
      }
    } catch (error) {
      return {'success': false, 'message': 'Error sending reset link'};
    }
  }

  // get user profile
  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/users/$userId'),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // update user profile
  static Future<Map<String, dynamic>> updateUserProfile(
    int userId,
    String fullname,
    String email,
    String phoneNumber,
    String username,
  ) async {
    final response = await http.put(
      Uri.parse('${ApiService.baseUrl}/users/$userId'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullname': fullname,
        'email': email,
        'phonenumber': phoneNumber,
        'username': username,
      }),
    );

    return jsonDecode(response.body);
  }

  // upload user profile image
  static Future<bool> uploadProfileImage(int userId, String imagePath) async {
    try {
      var uri = Uri.parse('${ApiService.baseUrl}/users/upload-profile/$userId');
      var request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage',
          imagePath,
          filename: basename(imagePath),
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      debugPrint('Upload response: $responseBody');

      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
  }

  // get all clinics
  static Future<List<Clinics>> getAllClinics() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/clinics'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((clinic) => Clinics.fromJson(clinic)).toList();
    } else {
      throw Exception('Failed to load all the clinics');
    }
  }

  // add a new clinic
  static Future<Map<String, dynamic>> addClinic(
    String name,
    String address,
    String phoneNumber,
    String email,
    double latitude,
    double longitude,
    List<String> services,
    Map<String, String> operatingHours,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/clinics'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'address': address,
        'phonenumber': phoneNumber,
        'email': email,
        'latitude': latitude,
        'longitude': longitude,
        'services': services,
        'operating_hours': operatingHours,
      }),
    );

    return jsonDecode(response.body);
  }

  // book an appointment
  static Future<Map<String, dynamic>> bookAppointment(
    Appointment appointment,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(appointment.toJson()),
    );

    return jsonDecode(response.body);
  }

  // get all appointments for a specific user
  static Future<List<Map<String, dynamic>>> getUserAppointments(
    int userId,
  ) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/appointments/$userId'),
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load user appointments');
    }
  }

  // cancel an appointment
  static Future<Map<String, dynamic>> cancelAppointment(
    int appointmentId,
  ) async {
    final response = await http.patch(
      Uri.parse('${ApiService.baseUrl}/appointments/$appointmentId/cancel'),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  // mark appointment as completed
  static Future<Map<String, dynamic>> completeAppointment(
    int appointmentId,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/appointments/$appointmentId/complete'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'message': 'Appointment marked as completed successfully'};
      } else {
        return {'error': 'Failed to complete appointment: ${response.body}'};
      }
    } catch (error) {
      return {'error': 'Error completing appointment: $error'};
    }
  }

  // reschedule an appointment
  static Future<Map<String, dynamic>> rescheduleAppointment(
    int appointmentId,
    String newDateTime,
  ) async {
    try {
      final response = await http.put(
        Uri.parse(
          '${ApiService.baseUrl}/appointments/$appointmentId/reschedule',
        ),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'appointment_at': newDateTime}),
      );

      if (response.statusCode == 200) {
        return {'message': 'Appointment rescheduled successfully!'};
      } else {
        return {'error': 'Failed to reschedule appointment: ${response.body}'};
      }
    } catch (error) {
      return {'error': 'Error rescheduling appointment: $error'};
    }
  }

  // create a new medication
  static Future<bool> createMedication({
    required int userId,
    required String name,
    required String dose,
    required List<String> times,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/medications'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'name': name,
        'dose': dose,
        'times': times,
        'notes': notes,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return true;
    } else {
      return false;
    }
  }

  // get all medications for a specific user
  static Future<List<Medication>> getUserMedication(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/medications/$userId'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((error) => Medication.fromJson(error)).toList();
    } else {
      throw Exception('Failed to get all the medications');
    }
  }

  // get a single medication
  static Future<Medication> getMedication(int id) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/medications/med/$id'),
    );

    if (response.statusCode == 200) {
      return Medication.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to get the specified medication');
    }
  }

  // delete medication
  static Future<bool> deleteMedication(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/medications/$id'),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      return false;
    }
  }

  // get all health tips
  static Future<List<HealthTips>> getAllHealthTips() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/tips'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((tip) => HealthTips.fromJson(tip)).toList();
    } else {
      throw Exception('Failed to load all health tips');
    }
  }

  // add a new health tip
  static Future<Map<String, dynamic>> addHealthTip(
    String title,
    String content,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/tips'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'content': content}),
    );

    return jsonDecode(response.body);
  }

  // delete a health tip
  static Future<Map<String, dynamic>> deleteHealthTip(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/tips/$id'),
    );

    return jsonDecode(response.body);
  }

  // get symptom history for specific user
  static Future<List<Symptoms>> getSymptomHistory(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/symptoms/$userId'),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Symptoms.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load symptom history');
    }
  }

  // add a new symptom
  static Future<Map<String, dynamic>> addSymptom(
    int userId,
    String symptom,
    String severity,
    String notes,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/symptoms'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'symptom': symptom,
        'severity': severity,
        'notes': notes,
      }),
    );

    return jsonDecode(response.body);
  }

  // delete a symptom
  static Future<Map<String, dynamic>> deleteSymptom(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/symptoms/$id'),
    );

    return jsonDecode(response.body);
  }

  // get all active health alerts
  static Future<List<HealthAlerts>> getAllActiveAlerts() async {
    final response = await http.get(Uri.parse('${ApiService.baseUrl}/alerts'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((error) => HealthAlerts.fromJson(error)).toList();
    } else {
      throw Exception('Failed to load all health alerts');
    }
  }

  // add a new health alert
  static Future<Map<String, dynamic>> addHealthAlert(
    String title,
    String message,
    String severity,
    String location,
    String alertType,
    String icon,
  ) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/alerts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'message': message,
        'severity': severity,
        'location': location,
        'alert_type': alertType,
        'icon': icon,
      }),
    );

    return jsonDecode(response.body);
  }

  // delete a health alert
  static Future<Map<String, dynamic>> deleteHealthAlert(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/alerts/$id'),
    );

    return jsonDecode(response.body);
  }
}
