import 'dart:convert'; // to convert data between JSON and dart objects.
import 'package:http/http.dart' as http; // to make REST API calls to backend

class ApiService {
  static const String baseUrl = 'http://10.0.2.2:5000/api'; // android, web=localhost

  // signup
  static Future<Map<String, dynamic>> signup(
    String fullname, String email, String phonenumber, 
    String username, String password ) async {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "fullname": fullname,
          "email": email,
          "phonenumber": phonenumber,
          "username": username,
          "password": password
        }),
      );
    
      return jsonDecode(response.body);
  }
  
  // login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "username": username,
        "password":password
      }),
    );
    
    return jsonDecode(response.body);
  }

  // get all clinics
  static Future<List<Map<String, dynamic>>> getAllClinics() async {
    final response = await http.get(
      Uri.parse('$baseUrl/clinics')
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load all the clinics');
    }
  }

  // add a new clinics
  static Future<Map<String, dynamic>> addClinic(
    String name, String address, String phonenumber, String email, 
    double latitude, double longitude, List<String> services, Map<String, String> operatingHours ) async {
      final response = await http.post(
        Uri.parse('$baseUrl/clinics'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "name": name,
          "address":address,
          "phonenumber": phonenumber,
          "email": email,
          "latitude": latitude,
          "longitude": longitude,
          "services": services,
          "operating_hours": operatingHours
        }),
      );
      
      return jsonDecode(response.body);
  }

  // get all health tips
  static Future<List<Map<String, dynamic>>> getAllHealthTips() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tips')
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load all health tips');
    }
  }

  // add a new health tip
  static Future<Map<String, dynamic>> addHealthTip(String title, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tips'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "title": title,
        "content": content
      }),
    );
    
    return jsonDecode(response.body);
  }

  // delete a health tip
  static Future<Map<String, dynamic>> deleteHealthTip(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/tips/$id')
    );

    return jsonDecode(response.body);
  }

  // get symptom history for specific user 
  static Future<List<Map<String, dynamic>>> getSymptomHistory(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/symptoms/$userId')
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load symptom history');
    }
  }

  // add a new symptom
  static Future<Map<String, dynamic>> addSymptom(int userId, String symptom, String severity, String notes) async {
    final response = await http.post(
      Uri.parse('$baseUrl/symptoms'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "user_id": userId,
        "symptom": symptom,
        "severity": severity,
        "notes": notes
      }),
    );
    
    return jsonDecode(response.body);
  }

  // delete a symptom
  static Future<Map<String,dynamic>> deleteSymptom(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/symptoms/$id')
    );

    return jsonDecode(response.body);
  }

  // get all active health alerts
  static Future<List<Map<String, dynamic>>> getAllActiveAlerts() async {
    final response = await http.get(
      Uri.parse('$baseUrl/alerts')
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body); 
    } else {
      throw Exception('Failed to load all health alerts');
    }
  }

  // add a new health alert
  static Future<Map<String, dynamic>> addHealthAlert(
    String title, String message, String severity, 
    String location, String alertType, String icon ) async {
      final response = await http.post(
        Uri.parse('$baseUrl/alerts'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          "title": title,
          "message": message,
          "severity": severity,
          "location": location,
          "alert_type": alertType,
          "icon": icon
        }),
      );

      return jsonDecode(response.body);
  }

  // delete a health alert
  static Future<Map<String, dynamic>> deleteHealthAlert(int id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/alerts/$id')
    );

    return jsonDecode(response.body);
  }
}


