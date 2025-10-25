class User {
  final int id;
  final String fullname;
  final String email;
  final String phoneNumber;
  final String username;
  final String password;
  final String dateRecorded;

  // constructor - required fields
  User({
    required this.id,
    required this.fullname,
    required this.email,
    required this.phoneNumber,
    required this.username,
    required this.password,
    required this.dateRecorded,
  });

  // create user object from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullname: json['fullname'],
      email: json['email'],
      phoneNumber: json['phonenumber'],
      username: json['username'],
      password: json['password'],
      dateRecorded: json['created_at'] ?? '',
    );
  }

  // convert user object to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'email': email,
      'phonenumber': phoneNumber,
      'username': username,
      'password': password,
      'created_at': dateRecorded,
    };
  }
}