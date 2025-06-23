import 'package:flutter/material.dart';
import '../models/room.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Room> _hotels = [
    Room(
      id: '1',
      name: 'Grand Luxe Hotel',
      location: 'Paris, France',
      price: 450,
      rating: 4.8,
      description:
          'Experience the epitome of luxury in the heart of Paris. This stunning hotel offers breathtaking views of the Eiffel Tower and unparalleled service that will make your stay unforgettable.',
      amenities: ['WiFi', 'Pool', 'Spa', 'Restaurant', 'Gym', 'Concierge'],
      images: ['image1.jpg', 'image2.jpg', 'image3.jpg'],
      maxGuests: 4,
      type: 'Luxury Suite',
    ),
    Room(
      id: '2',
      name: 'Ocean View Resort',
      location: 'Maldives',
      price: 650,
      rating: 4.9,
      description:
          'Escape to paradise with our overwater bungalows featuring crystal-clear lagoon views. Perfect for a romantic getaway or peaceful retreat.',
      amenities: [
        'WiFi',
        'Private Beach',
        'Spa',
        'Water Sports',
        'Restaurant',
        'Bar',
      ],
      images: ['image4.jpg', 'image5.jpg', 'image6.jpg'],
      maxGuests: 2,
      type: 'Overwater Bungalow',
    ),
    Room(
      id: '3',
      name: 'Mountain Retreat',
      location: 'Swiss Alps',
      price: 380,
      rating: 4.7,
      description:
          'Nestled in the pristine Swiss Alps, this cozy retreat offers stunning mountain views and easy access to world-class skiing and hiking.',
      amenities: [
        'WiFi',
        'Fireplace',
        'Ski Storage',
        'Restaurant',
        'Spa',
        'Mountain Guides',
      ],
      images: ['image7.jpg', 'image8.jpg', 'image9.jpg'],
      maxGuests: 6,
      type: 'Mountain Chalet',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F0F23), Color(0xFF1A1A3A)],
          ),
        ),
        child: SafeArea(
          child: PageView(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            children: [
              _buildHomePage(),
              _buildSearchPage(),
              _buildFavoritesPage(),
              _buildProfilePage(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F23),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            _pageController.animateToPage(
              index,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: const Color(0xFFFFD700),
          unselectedItemColor: Colors.white.withOpacity(0.6),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search_outlined),
              activeIcon: Icon(Icons.search),
              label: 'Search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomePage() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  Text(
                    'Find your perfect stay',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              CircleAvatar(
                backgroundColor: const Color(0xFFFFD700),
                child: Icon(
                  Icons.notifications_outlined,
                  color: const Color(0xFF0F0F23),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.search, color: Colors.white.withOpacity(0.7)),
                const SizedBox(width: 12),
                Text(
                  'Where do you want to stay?',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          // Featured Hotels
          const Text(
            'Featured Hotels',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _hotels.length,
              itemBuilder: (context, index) {
                final hotel = _hotels[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: const Color(0xFFFFD700).withOpacity(0.3),
                          ),
                          child: const Icon(
                            Icons.hotel,
                            color: Color(0xFFFFD700),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hotel.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hotel.location,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Color(0xFFFFD700),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    hotel.rating.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    '${hotel.price}/night',
                                    style: const TextStyle(
                                      color: Color(0xFFFFD700),
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
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
          ),
        ],
      ),
    );
  }

  Widget _buildSearchPage() {
    return const Center(
      child: Text(
        'Search Page',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildFavoritesPage() {
    return const Center(
      child: Text(
        'Favorites Page',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  Widget _buildProfilePage() {
    return const Center(
      child: Text(
        'Profile Page',
        style: TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
