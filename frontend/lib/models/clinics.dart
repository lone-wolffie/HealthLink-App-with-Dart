class Clinics {
  final int id;
  final String name;
  final String address;
  final String phonenumber;
  final String email;
  final double latitude;
  final double longitude;
  final String services;
  final Map<String, dynamic> operatingHours;

  // constructor - required fields
  Clinics({
    required this.id,
    required this.name,
    required this.address,
    required this.phonenumber,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.services,
    required this.operatingHours,
  });

  // create clinics object from JSON data
  factory Clinics.fromJson(Map<String, dynamic> json) {
    return Clinics(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phonenumber: json['phonenumber'],
      email: json['email'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      services: json['services'],
      operatingHours: json['operating_hours'] ?? {},
    );
  }

  // convert clinics object to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name, 
      'address': address,
      'phonenumber': phonenumber, 
      'email': email, 
      'latitude': latitude, 
      'longitude': longitude, 
      'services': services,
      'operating_hours': operatingHours,
    };
  }
}