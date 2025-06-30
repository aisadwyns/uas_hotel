import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/room_model.dart';
import '../config/api_config.dart';

class RoomService {
  /// Ambil semua kamar dari backend
  Future<List<Room>> getAllRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final url = Uri.parse('${ApiConfig.baseUrl}/rooms/all-rooms');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> roomsJson = json.decode(response.body);
      return roomsJson.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception(
        'Gagal memuat data kamar, status code: ${response.statusCode}',
      );
    }
  }

  /// Ambil 1 kamar berdasarkan ID
  Future<Room> getRoomById(int id) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/rooms/room/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final Map<String, dynamic> roomJson = json.decode(response.body);
      return Room.fromJson(roomJson);
    } else {
      throw Exception('Gagal mengambil detail kamar');
    }
  }

  /// Ambil semua jenis kamar (tipe kamar) dari backend
  Future<List<String>> getRoomTypes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    final url = Uri.parse('${ApiConfig.baseUrl}/rooms/room/types');
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> typesJson = json.decode(response.body);
      return typesJson.cast<String>();
    } else {
      throw Exception(
        'Gagal memuat tipe kamar, status code: ${response.statusCode}',
      );
    }
  }
}
