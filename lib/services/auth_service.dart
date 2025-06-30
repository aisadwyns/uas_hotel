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
      await prefs.setString('user_email', request.email);

      // Ambil data user lengkap pakai email dan token yang baru
      final user = await getUserByEmail(request.email);
      if (user != null) {
        await prefs.setString('user_firstName', user.firstName);
        await prefs.setString('user_lastName', user.lastName);
      }

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

  Future<User?> getUserByEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      print('Token belum ada, harus login dulu');
      return null;
    }

    final response = await http.get(
      Uri.parse('$baseUrl/users/$email'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      print('Failed to get user: ${response.statusCode} - ${response.body}');
      return null;
    }
  }
}
