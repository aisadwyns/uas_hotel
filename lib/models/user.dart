class User {
  String firstName;
  String lastName;
  String email;
  String password;

  User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: json['firstName'],
      lastName: json['lastName'],
      email: json['email'],
      password: '', // password tidak dikembalikan dari backend
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'roles': [],
    };
  }
}
