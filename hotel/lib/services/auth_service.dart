import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/login_request.dart';
import '../models/user.dart';
import '../models/jwt_response.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  Future<JwtResponse?> login(LoginRequest request) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(request.toJson()),
    );

    if (response.statusCode == 200) {
      final jwtResponse = JwtResponse.fromJson(jsonDecode(response.body));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', jwtResponse.token);

      return jwtResponse;
    } else {
      print('Login failed: ${response.statusCode} - ${response.body}');
      return null;
    }
  }

  Future<bool> register(User user) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register-user'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print('Register failed: ${response.statusCode} - ${response.body}');
      return false;
    }
  }
}
