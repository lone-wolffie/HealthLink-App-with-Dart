import 'dart:convert'; 
import 'package:path/path.dart';
import 'package:http/http.dart' as http; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:healthlink_app/models/health_tips.dart';
import 'package:healthlink_app/models/symptoms.dart';
import 'package:healthlink_app/models/health_alerts.dart';
import 'package:healthlink_app/models/clinics.dart';
import 'package:healthlink_app/models/appointment.dart';
import 'package:healthlink_app/models/medication.dart';

class ApiService {
  // backend deployed url
  static const String baseUrl = 'https://healthlink-app-with-dart-1.onrender.com/api';
  
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
        return {
          'success': false, 
          'message': 'Failed to send reset link'
        };
      }
    } catch (error) {
      return {
        'success': false, 
        'message': 'Error sending reset link'
      };
    }
  }

  // get user profile
  static Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final response = await Supabase.instance.client
      .from('users')
      .select()
      .eq('id', userId)
      .single();

    return response;
  }

  // update user profile
  static Future<void> updateUserProfile(
    String userId, {
    required String fullname,
    required String email,
    required String phone,
    required String username,
  }) async {
    await Supabase.instance.client
      .from('users')
      .update({
        'fullname': fullname,
        'email': email,
        'phonenumber': phone,
        'username': username,
      })
      .eq('id', userId);
  }

  // upload user profile image
  static Future<bool> uploadProfileImage(
    String username,
    String imagePath,
  ) async {
    try {
      final uri = Uri.parse('${ApiService.baseUrl}/users/upload-profile/username/$username');

      final request = http.MultipartRequest('POST', uri);

      request.files.add(
        await http.MultipartFile.fromPath(
          'profileImage',
          imagePath,
          filename: basename(imagePath),
        ),
      );

      final response = await request.send();
      return response.statusCode == 200;
    } catch (error) {
      return false;
    }
  }

  // get all clinics
  static Future<List<Clinics>> getAllClinics() async {
    final supabase = Supabase.instance.client;

    try {
      final response = await supabase
        .from('clinics')
        .select()
        .order('name');

      return (response as List).map((json) => Clinics.fromJson(json)).toList();
    } catch (error) {
      rethrow;
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
    final supabase = Supabase.instance.client;

    await supabase.from('appointments').insert({
      'user_uuid': appointment.userUuid,
      'clinic_id': appointment.clinicId,
      'appointment_at': appointment.appointmentAt,
      'notes': appointment.notes,
    });

    return {
      'success': true,
      'message': 'Appointment booked successfully',
    };
  }

  // get all appointments for a specific user
  static Future<List<Map<String, dynamic>>> getUserAppointments(String userUuid) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
      .from('appointments')
      .select('''
        id,
        appointment_at,
        status,
        notes,
        clinic_id,
        clinics (name)
      ''')
      .eq('user_uuid', userUuid)
      .order('appointment_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }

  // cancel an appointment
  static Future<Map<String, dynamic>> cancelAppointment(
    int appointmentId,
  ) async {
    final supabase = Supabase.instance.client;
    
    await supabase
      .from('appointments')
      .update({'status': 'cancelled'})
      .eq('id', appointmentId);

    return {'message': 'Appointment cancelled'};
  }

  // mark appointment as completed
  static Future<Map<String, dynamic>> completeAppointment(
    int appointmentId,
  ) async {
    final supabase = Supabase.instance.client;

    await supabase
      .from('appointments')
      .update({'status': 'completed'})
      .eq('id', appointmentId);

    return {'message': 'Appointment completed'};
    
  }

  // reschedule an appointment
  static Future<Map<String, dynamic>> rescheduleAppointment(
    int appointmentId,
    String newDateTime,
  ) async {
    final supabase = Supabase.instance.client;

    await supabase
      .from('appointments')
      .update({'appointment_at': newDateTime})
      .eq('id', appointmentId);

    return {'message': 'Appointment rescheduled'};
  }

  // create a new medication
  static Future<bool> createMedication({
    required String name,
    required String dose,
    required List<String> times,
    String? notes,
  }) async {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      throw Exception('User not authenticated');
    }

    try{
      await supabase.from('medications').insert({
        'user_uuid': user.id,
        'name': name,
        'dose': dose,
        'times': times,
        'notes': notes,
      });

      return true;
    }catch (error) {
      return false;
    }
  }

  // get all medications for a specific user
  static Future<List<Medication>> getUserMedication() async {
    final supabase = Supabase.instance.client;
    final user = Supabase.instance.client.auth.currentUser!.id; 

    final response = await supabase
      .from('medications')
      .select()
      .eq('user_uuid', user)
      .order('created_at', ascending: false);

    return response
      .map<Medication>((json) => Medication.fromJson(json))
      .toList();
  }

  // get a single medication
  static Future<Medication> getMedication(int id) async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/medications/med/$id'),
    );

    if (response.statusCode == 200) {
      return Medication.fromJson(
        jsonDecode(response.body)
      );
    } else {
      throw Exception('Failed to get the specified medication');
    }
  }

  // delete medication
  static Future<bool> deleteMedication(int id) async {
  await Supabase.instance.client
    .from('medications')
    .delete()
    .eq('id', id);

  return true;
  }

  // get all health tips
  static Future<List<HealthTips>> getAllHealthTips() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
      .from('health_tips')
      .select()
      .order('created_at', ascending: false);

    return response
      .map<HealthTips>((json) => HealthTips.fromJson(json))
      .toList();
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
  static Future<List<Symptoms>> getSymptomHistory(
    String userUuid,
  ) async {
    final response = await Supabase.instance.client
      .from('symptoms_checker')
      .select()
      .eq('user_uuid', userUuid)
      .order('created_at', ascending: false);

    return response
      .map<Symptoms>((json) => Symptoms.fromJson(json))
      .toList();
  }

  // add a new symptom
  static Future<Map<String, dynamic>> addSymptom(
    String userUuid,
    String symptom,
    String severity,
    String notes,
  ) async {
    final supabase = Supabase.instance.client;

    final response = await supabase
      .from('symptoms_checker')
      .insert({
        'user_uuid': userUuid,
        'symptom': symptom,
        'severity': severity,
        'notes': notes,
      })
      .select()
      .single();

    return {
      'success': true,
      'data': response,
      'message': 'Symptom added successfully',
    };

  }

  // delete a symptom
  static Future<void> deleteSymptom(int id) async {
  await Supabase.instance.client
    .from('symptoms_checker')
    .delete()
    .eq('id', id);
  }

  // get all active health alerts
  static Future<List<HealthAlerts>> getAllActiveAlerts() async {
    final supabase = Supabase.instance.client;

    final response = await supabase
      .from('health_alerts')
      .select()
      .eq('is_active', true)
      .order('published_date', ascending: false);

    return response
      .map<HealthAlerts>((json) => HealthAlerts.fromJson(json))
      .toList();
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
