class Clinics {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;
  final String email;
  final double latitude;
  final double longitude;
  final String services;
  final Map<String, dynamic> operatingHours; 
  final DateTime dateRecorded;

  // constructor - required fields
  Clinics({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.services,
    required this.operatingHours,
    required this.dateRecorded,
  });

  // create clinics object from JSON data
  factory Clinics.fromJson(Map<String, dynamic> json) {
    return Clinics(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phoneNumber: json['phonenumber'],
      email: json['email'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      services: json['services'],
      operatingHours: json['operating_hours'] ?? {},
      dateRecorded: DateTime.parse(json['created_at']),
    );
  }

  // convert clinics object to json
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
      'created_at': dateRecorded.toIso8601String(),
    };
  }
}