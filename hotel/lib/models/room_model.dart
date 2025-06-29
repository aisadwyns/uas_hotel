import 'booking.dart';

class Room {
  final int id;
  final String roomType;
  final double roomPrice;
  final bool isBooked;
  final String? photo; // base64 encoded image string
  final List<Booking> bookings;

  Room({
    required this.id,
    required this.roomType,
    required this.roomPrice,
    required this.isBooked,
    this.photo,
    required this.bookings,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    var bookingsJson = json['bookings'] as List<dynamic>? ?? [];
    List<Booking> bookingList =
        bookingsJson.map((b) => Booking.fromJson(b)).toList();

    return Room(
      id: json['id'],
      roomType: json['roomType'],
      roomPrice: (json['roomPrice'] as num).toDouble(),
      isBooked:
          json['isBooked'] == true ||
          json['isBooked'] == 'true' ||
          json['isBooked'] == 1,
      photo: json['photo'],
      bookings: bookingList,
    );
  }
}
