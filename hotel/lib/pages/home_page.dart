import 'package:flutter/material.dart';
import 'package:hotel/pages/profil_page.dart';
import 'dart:convert';
import '../models/room_model.dart';
import '../services/room_service.dart';
import '../pages/hotel_search_widget.dart';
import '../pages/booking_page.dart'; // Import halaman booking

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final RoomService _roomService = RoomService();
  List<Room> _rooms = [];
  List<Room> _originalRooms = []; // Store original rooms for filtering
  List<Room> _filteredRooms = []; // Add filtered rooms list
  List<String> _roomTypes = [];
  bool _isLoadingRooms = true;
  bool _isLoadingRoomTypes = true;
  String _errorMessage = '';

  // Filter states - tambahan dari document kedua
  String? _selectedRoomType;
  RangeValues _selectedPriceRange = const RangeValues(100000, 1000000);
  bool _onlyAvailable = false;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _loadRoomTypes();
  }

  Future<void> _loadRoomTypes() async {
    try {
      final types = await _roomService.getRoomTypes();
      setState(() {
        _roomTypes = types;
        _isLoadingRoomTypes = false;
      });
    } catch (e) {
      debugPrint('Gagal load room types: $e');
      setState(() {
        _isLoadingRoomTypes = false;
      });
    }
  }

  Future<void> _loadRooms() async {
    try {
      setState(() {
        _isLoadingRooms = true;
        _errorMessage = '';
      });

      final rooms = await _roomService.getAllRooms();
      setState(() {
        _rooms = rooms;
        _originalRooms = List.from(rooms); // Store original rooms
        _filteredRooms = List.from(rooms); // Initialize filtered rooms
        _isLoadingRooms = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingRooms = false;
      });
    }
  }

  // Enhanced onSearch function dari document kedua
  Future<void> _onSearch(
    String? type,
    RangeValues priceRange,
    bool onlyAvailable,
  ) async {
    debugPrint(
      'Cari kamar: $type, Rp${priceRange.start} - Rp${priceRange.end}, onlyAvailable: $onlyAvailable',
    );

    setState(() {
      _selectedRoomType = type;
      _selectedPriceRange = priceRange;
      _onlyAvailable = onlyAvailable;
      _isLoadingRooms = true;
      _errorMessage = '';
    });

    try {
      // Filter from original rooms to avoid losing data
      List<Room> filtered =
          _originalRooms.where((room) {
            final matchesType =
                (type == null || type.isEmpty || type == 'Semua')
                    ? true
                    : room.roomType == type;
            final matchesPrice =
                room.roomPrice >= priceRange.start &&
                room.roomPrice <= priceRange.end;
            final matchesAvailability = !onlyAvailable || !room.isBooked;
            return matchesType && matchesPrice && matchesAvailability;
          }).toList();

      setState(() {
        _rooms = filtered;
        _filteredRooms = filtered;
        _isLoadingRooms = false;
      });

      // Setelah filter berhasil, pindah ke home tab otomatis
      setState(() {
        _currentIndex = 0;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal mencari kamar: $e';
        _isLoadingRooms = false;
      });
    }
  }

  // Reset rooms to original when returning to home
  void _resetRoomsFilter() {
    setState(() {
      _rooms = List.from(_originalRooms);
      _filteredRooms = List.from(_originalRooms);
      _selectedRoomType = null;
      _selectedPriceRange = const RangeValues(100000, 1000000);
      _onlyAvailable = false;
    });
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return RefreshIndicator(
          onRefresh: () async {
            await _loadRooms();
            await _loadRoomTypes();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  margin: const EdgeInsets.only(top: 8, bottom: 24),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.grey[850],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Eksplor pilihan kamar hotel terbaik...",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 20),
                      suffixIcon: Icon(
                        Icons.search,
                        color: Colors.amber,
                        size: 28,
                      ),
                    ),
                    style: TextStyle(color: Colors.white, fontSize: 20),
                  ),
                ),
                _buildSectionTitle("Kamar Tersedia"),
                const SizedBox(height: 24),
                _isLoadingRooms
                    ? _buildLoadingWidget()
                    : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : _buildRoomList(context),
                const SizedBox(height: 28),
                _buildSectionTitle("Jelajahi Kamar Hotel"),
                const SizedBox(height: 24),
                _isLoadingRooms
                    ? _buildExploreLoadingWidget()
                    : _errorMessage.isNotEmpty
                    ? _buildExploreErrorWidget()
                    : _buildExploreList(),
                const SizedBox(height: 28),
                _buildSectionTitle("Kamar Terbaik"),
                const SizedBox(height: 24),
                _isLoadingRooms
                    ? _buildLoadingWidget()
                    : _errorMessage.isNotEmpty
                    ? _buildErrorWidget()
                    : _buildTopRatedRooms(context),
              ],
            ),
          ),
        );
      case 1:
        return _isLoadingRoomTypes
            ? const Center(
              child: CircularProgressIndicator(color: Colors.amber),
            )
            : HotelSearchWidget(
              onSearch: _onSearch,
              roomTypesFromBackend: _roomTypes,
            );
      case 2:
        return const BookingsPage(); // Sudah dipindah ke file booking_page.dart
      case 3:
        return const ProfilePage(); // Sudah dipindah ke file profil_page.dart
      default:
        return const Center(
          child: Text('Page not found', style: TextStyle(color: Colors.white)),
        );
    }
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const Text(
          "View All",
          style: TextStyle(color: Colors.amber, fontSize: 20),
        ),
      ],
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      height: 380,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      height: 380,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              "Gagal memuat data kamar",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                await _loadRooms();
                await _loadRoomTypes();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              child: const Text("Coba Lagi"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoomList(BuildContext context) {
    if (_rooms.isEmpty) {
      return Container(
        height: 380,
        child: const Center(
          child: Text(
            "Tidak ada kamar tersedia",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return SizedBox(
      height: 380,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _rooms.length,
        itemBuilder: (context, index) {
          final room = _rooms[index];
          return GestureDetector(
            onTap: () => _showRoomDetail(context, room),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: _buildRoomImage(room.photo, 200, 280),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.roomType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          room.isBooked ? "Sudah Terbook" : "Tersedia",
                          style: TextStyle(
                            fontSize: 20,
                            color: room.isBooked ? Colors.red : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Rp ${_formatPrice(room.roomPrice)}",
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 20,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " /malam",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    room.isBooked ? Colors.red : Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                room.isBooked ? "BOOKED" : "AVAILABLE",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopRatedRooms(BuildContext context) {
    // Filter kamar yang tidak di-book untuk section "Kamar Terbaik"
    final availableRooms = _rooms.where((room) => !room.isBooked).toList();

    if (availableRooms.isEmpty) {
      return Container(
        height: 380,
        child: const Center(
          child: Text(
            "Tidak ada kamar tersedia",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      );
    }

    return SizedBox(
      height: 380,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: availableRooms.length,
        itemBuilder: (context, index) {
          final room = availableRooms[index];
          return GestureDetector(
            onTap: () => _showRoomDetail(context, room),
            child: Container(
              width: 280,
              margin: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: _buildRoomImage(room.photo, 200, 280),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room.roomType,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "Tersedia",
                          style: TextStyle(fontSize: 20, color: Colors.green),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Rp ${_formatPrice(room.roomPrice)}",
                                    style: const TextStyle(
                                      color: Colors.amber,
                                      fontSize: 20,
                                    ),
                                  ),
                                  TextSpan(
                                    text: " /malam",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.5),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.orange,
                                  size: 22,
                                ),
                                const SizedBox(width: 6),
                                const Text(
                                  "4.5",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildExploreLoadingWidget() {
    return Container(
      height: 120,
      child: const Center(
        child: CircularProgressIndicator(color: Colors.amber),
      ),
    );
  }

  Widget _buildExploreErrorWidget() {
    return Container(
      height: 120,
      child: const Center(
        child: Text(
          "Gagal memuat data",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildExploreList() {
    // Menggunakan data kamar dari backend untuk explore
    if (_rooms.isEmpty) {
      return Container(
        height: 120,
        child: const Center(
          child: Text(
            "Tidak ada data kamar",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    // Ambil maksimal 5 kamar pertama untuk explore
    final exploreRooms = _rooms.take(5).toList();

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: exploreRooms.length,
        itemBuilder: (context, index) {
          final room = exploreRooms[index];
          return GestureDetector(
            onTap: () => _showRoomDetail(context, room),
            child: Container(
              margin: const EdgeInsets.only(right: 20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[600],
                    ),
                    child: ClipOval(
                      child:
                          room.photo != null && room.photo!.isNotEmpty
                              ? Image.memory(
                                base64Decode(room.photo!),
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[600],
                                    child: const Icon(
                                      Icons.hotel,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  );
                                },
                              )
                              : Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[600],
                                child: const Icon(
                                  Icons.hotel,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      room.roomType,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoomImage(String? photoBase64, double height, double width) {
    if (photoBase64 != null && photoBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(photoBase64);
        return Image.memory(
          bytes,
          height: height,
          width: width,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage(height, width);
          },
        );
      } catch (e) {
        return _buildPlaceholderImage(height, width);
      }
    } else {
      return _buildPlaceholderImage(height, width);
    }
  }

  Widget _buildPlaceholderImage(double height, double width) {
    return Container(
      height: height,
      width: width,
      color: Colors.grey[400],
      child: const Icon(Icons.hotel, size: 50, color: Colors.grey),
    );
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return "${(price / 1000000).toStringAsFixed(1)}jt";
    } else if (price >= 1000) {
      return "${(price / 1000).toStringAsFixed(0)}k";
    } else {
      return price.toStringAsFixed(0);
    }
  }

  Widget _infoBox(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCB74),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }

  void _showRoomDetail(BuildContext context, Room room) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.95,
            maxChildSize: 0.95,
            minChildSize: 0.95,
            builder:
                (_, controller) => Container(
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    controller: controller,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(24),
                            topRight: Radius.circular(24),
                          ),
                          child: _buildRoomImage(
                            room.photo,
                            280,
                            double.infinity,
                          ),
                        ),

                        // INFO UTAMA KAMAR (background gelap)
                        Container(
                          color: const Color(0xFF2D2D2D),
                          padding: const EdgeInsets.all(20),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      room.roomType,
                                      style: const TextStyle(
                                        fontSize: 35,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        room.isBooked
                                            ? "Sudah Terbook"
                                            : "Tersedia",
                                        style: TextStyle(
                                          color:
                                              room.isBooked
                                                  ? Colors.red
                                                  : Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "Rp ${_formatPrice(room.roomPrice)}",
                                        style: const TextStyle(
                                          color: Color(0xFFFFCB74),
                                          fontSize: 35,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  _infoBox(
                                    Icons.calendar_today,
                                    "20 Aug, Sat - 21 Aug, Sun",
                                  ),
                                  const SizedBox(width: 12),
                                  _infoBox(Icons.people, "1 Guest / 1 Room"),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // DETAIL KAMAR (Putih penuh)
                        Container(
                          width: double.infinity,
                          color: const Color(0xFF2D2D2D),
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Detail Kamar",
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Color(0xFFFFCB74),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "Tipe Kamar: ${room.roomType}",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Harga: Rp ${room.roomPrice.toStringAsFixed(0)} per malam",
                                style: const TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Status: ${room.isBooked ? 'Sudah Terbook' : 'Tersedia'}",
                                style: TextStyle(
                                  fontSize: 18,
                                  color:
                                      room.isBooked ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                "Kamar ini dilengkapi dengan fasilitas modern dan suasana nyaman. Cocok untuk perjalanan bisnis maupun liburan keluarga.",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),

                              const SizedBox(height: 24),
                              const Text(
                                "Fasilitas",
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Color(0xFFFFCB74),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  Chip(
                                    label: Text(
                                      "Free Wifi",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    backgroundColor: Color(0xFFFFCB74),
                                  ),
                                  Chip(
                                    label: Text(
                                      "AC",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    backgroundColor: Color(0xFFFFCB74),
                                  ),
                                  Chip(
                                    label: Text(
                                      "TV",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    backgroundColor: Color(0xFFFFCB74),
                                  ),
                                  Chip(
                                    label: Text(
                                      "24hr Room Service",
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    backgroundColor: Color(0xFFFFCB74),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              const Text(
                                "Booking Form",
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Color(0xFFFFCB74),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                readOnly: true,
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      Duration(days: 365),
                                    ),
                                  );
                                  // Handle picked date
                                },
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Tanggal Check In',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Color(0xFFFFCD74),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                readOnly: true,
                                onTap: () async {
                                  DateTime? picked = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.now().add(
                                      Duration(days: 365),
                                    ),
                                  );
                                  // Handle picked date
                                },
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Tanggal Check Out',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.calendar_today_outlined,
                                    color: Color(0xFFFFCD74),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                keyboardType: TextInputType.name,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Nama Lengkap',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.person_outline,
                                    color: Color(0xFFFFCD74),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFFFFCD74),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Jumlah Tamu Dewasa',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.people_outline,
                                    color: Color(0xFFFFCD74),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                keyboardType: TextInputType.number,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Jumlah Tamu Anak',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.child_care_outlined,
                                    color: Color(0xFFFFCD74),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                keyboardType: TextInputType.number,
                                readOnly: true,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Total Tamu',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.people,
                                    color: Color(0xFFFFCD74),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                keyboardType: TextInputType.text,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Kode Konfirmasi',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.confirmation_number_outlined,
                                    color: Color(0xFFFFCD74),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              TextField(
                                keyboardType: TextInputType.text,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'ID Kamar',
                                  labelStyle: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                  ),
                                  prefixIcon: const Icon(
                                    Icons.hotel_outlined,
                                    color: Color(0xFFFFCD74),
                                    size: 20,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withOpacity(0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Show success notification
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              Icons.check_circle,
                                              color: Colors.white,
                                            ),
                                            SizedBox(width: 12),
                                            Text(
                                              'Booking berhasil!',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                      ),
                                    );

                                    // Navigate to booking tab after short delay
                                    Future.delayed(
                                      Duration(milliseconds: 800),
                                      () {
                                        setState(() {
                                          _currentIndex =
                                              2; // Index 2 untuk tab Booking
                                        });
                                      },
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFFFCB74),
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                  ),
                                  child: const Text(
                                    'BOOK NOW',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D2D2D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 100,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: const [
            Text(
              "Halo, User 👋",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.amber,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Selamat datang di ChillPoint Hotel",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications,
              color: Colors.amber,
              size: 32,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF2D2D2D),
        selectedItemColor: Colors.amber,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        iconSize: 36,
        selectedFontSize: 18,
        unselectedFontSize: 16,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // Reset filter when returning to home tab
            if (index == 0) {
              _resetRoomsFilter();
            }
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: "Booking",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
