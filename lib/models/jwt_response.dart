class JwtResponse {
  final int id;
  final String email;
  final String token;
  final String type;
  final List<String> roles;

  JwtResponse({
    required this.id,
    required this.email,
    required this.token,
    required this.type,
    required this.roles,
  });

  factory JwtResponse.fromJson(Map<String, dynamic> json) {
    return JwtResponse(
      id: json['id'],
      email: json['email'],
      token: json['token'],
      type: json['type'] ?? 'Bearer',
      roles: List<String>.from(json['roles']),
    );
  }
}
