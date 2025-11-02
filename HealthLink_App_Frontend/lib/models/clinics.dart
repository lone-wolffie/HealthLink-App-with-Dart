class Clinics {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final double? latitude;
  final double? longitude;
  final List<String> services;
  final Map<String, dynamic> operatingHours; 
  final DateTime? dateRecorded;

  // constructor - required fields
  Clinics({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    this.latitude,
    this.longitude,
    required this.services,
    required this.operatingHours,
    this.dateRecorded,
  });

    factory Clinics.fromJson(Map<String, dynamic> json) {
    // latitude & longitude parsing
    double? toDouble(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }

    return Clinics(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phonenumber'],
      email: json['email'],
      latitude: toDouble(json['latitude']),
      longitude: toDouble(json['longitude']),
      services: List<String>.from(json['services'] ?? []),
      operatingHours: json['operating_hours'] ?? {},
      dateRecorded: parseDate(json['created_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phonenumber': phoneNumber,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'services': services,
      'operating_hours': operatingHours,
      'created_at': dateRecorded?.toIso8601String(),
    };
  }
}