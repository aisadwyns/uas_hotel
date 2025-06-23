import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/room.dart';

class RoomService {
  static const String baseUrl = 'http://localhost:8080/api/v1/room';

  static Future<List<Room>> fetchRooms() async {
    final response = await http.get(Uri.parse('$baseUrl/all'));

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => Room.fromJson(item)).toList();
    } else {
      return [];
    }
  }
}

class Room {
  final int id;
  final String name;
  // Add other fields as needed

  Room({
    required this.id,
    required this.name,
    // Add other fields as required
  });

  // Add this factory constructor for JSON deserialization
  factory Room.fromJson(Map<String, dynamic> json) {
    // Replace the following with your actual Room fields
    return Room(
      id: json['id'],
      name: json['name'],
      // ... other fields
    );
  }
}
