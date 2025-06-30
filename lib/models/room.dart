class Room {
  final String id;
  final String name;
  final String location;
  final double price;
  final double rating;
  final String description;
  final List<String> amenities;
  final List<String> images;
  final int maxGuests;
  final String type;

  Room({
    required this.id,
    required this.name,
    required this.location,
    required this.price,
    required this.rating,
    required this.description,
    required this.amenities,
    required this.images,
    required this.maxGuests,
    required this.type,
  });
}

// models/booking.dart
class Booking {
  final String id;
  final String roomId;
  final String userId;
  final DateTime checkIn;
  final DateTime checkOut;
  final int guests;
  final double totalPrice;
  final String status;

  Booking({
    required this.id,
    required this.roomId,
    required this.userId,
    required this.checkIn,
    required this.checkOut,
    required this.guests,
    required this.totalPrice,
    required this.status,
  });
}
