import 'package:flutter/material.dart';

class HotelSearchWidget extends StatefulWidget {
  final Function(String? type, RangeValues priceRange, bool onlyAvailable)
  onSearch;
  final List<String>? roomTypesFromBackend;

  const HotelSearchWidget({
    super.key,
    required this.onSearch,
    this.roomTypesFromBackend,
  });

  @override
  State<HotelSearchWidget> createState() => _HotelSearchWidgetState();
}

class _HotelSearchWidgetState extends State<HotelSearchWidget> {
  String? selectedRoomType;
  RangeValues priceRange = const RangeValues(100000, 1000000);
  bool onlyAvailable = false;

  List<String> get roomTypes {
    final types = widget.roomTypesFromBackend;
    if (types != null && types.isNotEmpty) {
      return ['Semua', ...types];
    }
    return ['Semua', 'Single', 'Double', 'Suite'];
  }

  @override
  void initState() {
    super.initState();
    selectedRoomType = null; // Default ke 'Semua' (null)
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Cari Kamar",
            style: TextStyle(
              fontSize: 22,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Dropdown Tipe Kamar
          DropdownButtonFormField<String>(
            value: selectedRoomType,
            hint: const Text(
              "Tipe Kamar",
              style: TextStyle(color: Colors.white70),
            ),
            dropdownColor: Colors.grey[800],
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.black12,
            ),
            items:
                roomTypes.map((type) {
                  final value = type == 'Semua' ? null : type;
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      type,
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }).toList(),
            onChanged: (value) => setState(() => selectedRoomType = value),
          ),

          const SizedBox(height: 16),

          // Rentang Harga
          const Text("Harga per malam", style: TextStyle(color: Colors.white)),
          RangeSlider(
            values: priceRange,
            min: 50000,
            max: 2000000,
            divisions: 39,
            labels: RangeLabels(
              'Rp${priceRange.start.round()}',
              'Rp${priceRange.end.round()}',
            ),
            onChanged: (range) => setState(() => priceRange = range),
          ),

          const SizedBox(height: 16),

          // Switch Hanya yang Tersedia
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tampilkan hanya yang tersedia",
                style: TextStyle(color: Colors.white),
              ),
              Switch(
                value: onlyAvailable,
                onChanged: (val) => setState(() => onlyAvailable = val),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Tombol Cari
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                widget.onSearch(selectedRoomType, priceRange, onlyAvailable);
              },
              child: const Text(
                "Cari Kamar",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
