import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class BookingService {
  Future<void> submitBooking({
    required DateTime checkInDate,
    required DateTime checkOutDate,
    required String guestFullName,
    required String guestEmail,
    required int numOfAdults,
    required int numOfChildren,
    required int totalNumOfGuest,
    required String bookingConfirmationCode,
    required int roomId,
  }) async {
    final url = Uri.parse('$baseUrl/bookings/room/$roomId/booking');

    // 🔑 Ambil token dari SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Token tidak ditemukan. Silakan login terlebih dahulu.');
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // 🔥 Kirim token di header
        },
        body: jsonEncode({
          "checkInDate": checkInDate.toIso8601String(),
          "checkOutDate": checkOutDate.toIso8601String(),
          "guestFullName": guestFullName,
          "guestEmail": guestEmail,
          "numOfAdults": numOfAdults,
          "numOfChildren": numOfChildren,
          "totalNumOfGuest": totalNumOfGuest,
          "bookingConfirmationCode": bookingConfirmationCode,
          "roomId": roomId,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Booking failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
