import 'dart:convert'; // to convert data between JSON and dart objects.
import 'package:flutter/foundation.dart' show kIsWeb; // web, android emulator, iOS Simulator or physical device
import 'package:healthlink_app/models/health_tips.dart';
import 'package:healthlink_app/models/symptoms.dart';
import 'package:http/http.dart' as http; // to make REST API calls to backend
import 'dart:io' show Platform; // platform type
import 'package:path/path.dart';
import '../models/health_alerts.dart';
import '../models/clinics.dart';
import '../models/appointment.dart';

class ApiService {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api'; // web
    } else if (Platform.isAndroid) {
      return 'http://10.0.2.2:3000/api'; // android emulator
    } else if (Platform.isIOS) {
      return 'http://localhost:3000/api'; // iOS Simulator
    } else {
      return 'http://192.168.0.12:3000/api'; // physical device
    }
  } 

  // signup
  static Future<Map<String, dynamic>> signup(
    String fullname, String email, String phoneNumber, 
    String username, String password ) async {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'phonenumber': phoneNumber,
          'username': username,
          'password': password
        }),
      );
    
      return jsonDecode(response.body);
  }
  
  // login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'username': username,
        'password':password
      }),
    );
    
    return jsonDecode(response.body);
  }

  // get user profile
  static Future<Map<String, dynamic>> getUserProfile(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/users/$userId')
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load profile');
    }
  }

  // update user profile
  static Future<Map<String, dynamic>> updateUserProfile(
    int userId, String fullname, String email, String phoneNumber, String username ) async {
      final response = await http.put(
        Uri.parse('${ApiService.baseUrl}/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullname': fullname,
          'email': email,
          'phonenumber': phoneNumber,
          'username': username
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
      print('Upload response: $responseBody');

      return response.statusCode == 200;
    } catch (error) {
      print('Upload error: $error');
      return false;
    }
  }

  // get all clinics
  static Future<List<Clinics>> getAllClinics() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/clinics')
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((clinic) => Clinics.fromJson(clinic)).toList();
    } else {
      throw Exception('Failed to load all the clinics');
    }
  }

  // add a new clinics
  static Future<Map<String, dynamic>> addClinic(
    String name, String address, String phoneNumber, String email, 
    double latitude, double longitude, List<String> services, Map<String, String> operatingHours ) async {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/clinics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'address':address,
          'phonenumber': phoneNumber,
          'email': email,
          'latitude': latitude,
          'longitude': longitude,
          'services': services,
          'operating_hours': operatingHours
        }),
      );
      
      return jsonDecode(response.body);
  }

  // book an appointment
  static Future<Map<String, dynamic>> bookAppointment(Appointment appointment) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/appointments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(
        appointment.toJson()
      ),
    );

    return jsonDecode(response.body);
  }

  // get all appointments for a specific user
  static Future<List<Map<String, dynamic>>> getUserAppointments(int userId) async {
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
  static Future<Map<String, dynamic>> cancelAppointment(int appointmentId) async {
    final response = await http.patch(
      Uri.parse('${ApiService.baseUrl}/appointments/$appointmentId/cancel'),
      headers: {'Content-Type': 'application/json'},
    );

    return jsonDecode(response.body);
  }

  // mark appointment as completed
  static Future<Map<String, dynamic>> completeAppointment(int appointmentId) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/appointments/$appointmentId/complete'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return {'message': 'Appointment marked as completed successfully'};
      } else {
        return {'error': 'Failed to complete appointment: ${response.body}'};
      }
    } catch (e) {
      return {'error': 'Error completing appointment: $e'};
    }
  }

  // reschedule an appointment
  static Future<Map<String, dynamic>> rescheduleAppointment(
    int appointmentId, String newDateTime) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/appointments/$appointmentId/reschedule'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'appointment_at': newDateTime}),
      );

      if (response.statusCode == 200) {
        return {'message': 'Appointment rescheduled successfully!'};
      } else {
        return {'error': 'Failed to reschedule appointment: ${response.body}'};
      }
    } catch (e) {
      return {'error': 'Error rescheduling appointment: $e'};
    }
  }
 

  // get all health tips
  static Future<List<HealthTips>> getAllHealthTips() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/tips')
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((tip) => HealthTips.fromJson(tip)).toList();
    } else {
      throw Exception('Failed to load all health tips');
    }
  }

  // add a new health tip
  static Future<Map<String, dynamic>> addHealthTip(String title, String content) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/tips'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'content': content
      }),
    );
    
    return jsonDecode(response.body);
  }

  // delete a health tip
  static Future<Map<String, dynamic>> deleteHealthTip(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/tips/$id')
    );

    return jsonDecode(response.body);
  }

  // get symptom history for specific user 
  static Future<List<Symptoms>> getSymptomHistory(int userId) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/symptoms/$userId')
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((item) => Symptoms.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load symptom history');
    }
  }

  // add a new symptom
  static Future<Map<String, dynamic>> addSymptom(int userId, String symptom, String severity, String notes) async {
    final response = await http.post(
      Uri.parse('${ApiService.baseUrl}/symptoms'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'user_id': userId,
        'symptom': symptom,
        'severity': severity,
        'notes': notes
      }),
    );
    
    return jsonDecode(response.body);
  }

  // delete a symptom
  static Future<Map<String,dynamic>> deleteSymptom(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/symptoms/$id')
    );

    return jsonDecode(response.body);
  }

  // get all active health alerts
  static Future<List<HealthAlerts>> getAllActiveAlerts() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/alerts')
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body); 
      return data.map((error) => HealthAlerts.fromJson(error)).toList();
    } else {
      throw Exception('Failed to load all health alerts');
    }
  }

  // add a new health alert
  static Future<Map<String, dynamic>> addHealthAlert(
    String title, String message, String severity, 
    String location, String alertType, String icon ) async {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/alerts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'message': message,
          'severity': severity,
          'location': location,
          'alert_type': alertType,
          'icon': icon
        }),
      );

      return jsonDecode(response.body);
  }

  // delete a health alert
  static Future<Map<String, dynamic>> deleteHealthAlert(int id) async {
    final response = await http.delete(
      Uri.parse('${ApiService.baseUrl}/alerts/$id')
    );

    return jsonDecode(response.body);
  }
}


