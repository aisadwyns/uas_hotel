class Booking {
  final int id;
  final String checkInDate; // format "yyyy-MM-dd"
  final String checkOutDate;
  final String? guestName;
  final String? guestEmail;
  final int? numOfAdults;
  final int? numOfChildren;
  final int? totalNumOfGuests;
  final String bookingConfirmationCode;
  // Omitting nested room here to avoid circular ref, use only if needed

  Booking({
    required this.id,
    required this.checkInDate,
    required this.checkOutDate,
    this.guestName,
    this.guestEmail,
    this.numOfAdults,
    this.numOfChildren,
    this.totalNumOfGuests,
    required this.bookingConfirmationCode,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      checkInDate: json['checkInDate'],
      checkOutDate: json['checkOutDate'],
      guestName: json['guestName'],
      guestEmail: json['guestEmail'],
      numOfAdults: json['numOfAdults'],
      numOfChildren: json['numOfChildren'],
      totalNumOfGuests: json['totalNumOfGuests'],
      bookingConfirmationCode: json['bookingConfirmationCode'],
    );
  }
}
