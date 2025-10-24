class User {
  final int id;
  final String fullname;
  final String email;
  final String phonenumber;
  final String username;
  final String password;

  // constructor - required fields
  User({
    required this.id,
    required this.fullname,
    required this.email,
    required this.phonenumber,
    required this.username,
    required this.password,
  });

  // create user object from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      fullname: json['fullname'],
      email: json['email'],
      phonenumber: json['phonenumber'],
      username: json['username'],
      password: json['password']
    );
  }

  // convert user object to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullname': fullname,
      'email': email,
      'phonenumber': phonenumber,
      'username': username,
      'password': password,
    };
  }
}