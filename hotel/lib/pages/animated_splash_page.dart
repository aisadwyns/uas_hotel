import 'package:flutter/material.dart';
import '../models/login_request.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

class AnimatedSplashPage extends StatefulWidget {
  const AnimatedSplashPage({Key? key}) : super(key: key);

  @override
  State<AnimatedSplashPage> createState() => _AnimatedSplashPageState();
}

class _AnimatedSplashPageState extends State<AnimatedSplashPage>
    with TickerProviderStateMixin {
  // State untuk menampilkan login / register
  bool _showLogin = false;
  bool _showRegister = false;
  bool _isAnimating = false;
  bool _agreedToTerms = false;
  bool _obscurePassword = true;

  // Controller input login
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Controller input registrasi
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Fungsi login
  void _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showAlertDialog(
        title: 'Input Kosong',
        message: 'Email dan password harus diisi.',
        icon: Icons.warning_amber_outlined,
        color: Colors.orange,
      );
      return;
    }

    final loginRequest = LoginRequest(email: email, password: password);

    // Tampilkan loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const Center(
            child: CircularProgressIndicator(color: Color(0xFFFFCD74)),
          ),
    );

    try {
      final jwtResponse = await AuthService().login(loginRequest);

      Navigator.of(context).pop(); // Tutup loading dialog

      if (jwtResponse != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login berhasil!'),
            backgroundColor: const Color(0xFF4CAF50), // Hijau sukses
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 800));
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showAlertDialog(
          title: 'Login Gagal',
          message: 'Periksa kembali email dan password kamu.',
          icon: Icons.error_outline,
          color: Colors.redAccent,
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Tutup loading dialog kalau error

      _showAlertDialog(
        title: 'Terjadi Kesalahan',
        message: 'Gagal terhubung ke server: $e',
        icon: Icons.cloud_off,
        color: Colors.grey,
      );
    }
  }

  //style alert
  void _showAlertDialog({
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            backgroundColor: const Color(0xFF222222),
            title: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 10),
                Text(title, style: const TextStyle(color: Colors.white)),
              ],
            ),
            content: Text(
              message,
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(foregroundColor: color),
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  //fungsi register
  void _register() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (firstName.isEmpty ||
        lastName.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      _showAlertDialog(
        title: 'Field Kosong',
        message: 'Semua kolom wajib diisi.',
        icon: Icons.warning_amber_outlined,
        color: Colors.orange,
      );
      return;
    }

    User newUser = User(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
    );

    try {
      bool success = await AuthService().register(newUser);

      if (success) {
        _showAlertDialog(
          title: 'Registrasi Berhasil',
          message: 'Akun berhasil dibuat. Silakan login sekarang.',
          icon: Icons.check_circle_outline,
          color: Colors.greenAccent,
        );
        _showLoginPage();
      } else {
        _showAlertDialog(
          title: 'Registrasi Gagal',
          message: 'Email mungkin sudah digunakan. Coba lagi.',
          icon: Icons.error_outline,
          color: Colors.redAccent,
        );
      }
    } catch (e) {
      _showAlertDialog(
        title: 'Terjadi Kesalahan',
        message: 'Tidak dapat menghubungi server: $e',
        icon: Icons.cloud_off,
        color: Colors.grey,
      );
    }
  }

  // Contoh fungsi switch halaman (harus ada implementasi _showLoginPage dan _showRegisterPage)
  void _showLoginPage() {
    setState(() {
      _showLogin = true;
      _showRegister = false;
    });
  }

  void _showRegisterPage() {
    setState(() {
      _showLogin = false;
      _showRegister = true;
    });
  }

  late AnimationController _slideController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _splashSlideAnimation;

  @override
  void initState() {
    super.initState();

    @override
    void dispose() {
      emailController.dispose();
      passwordController.dispose();
      _slideController.dispose();
      _fadeController.dispose();
      super.dispose();
    }

    // Controller untuk animasi slide up
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Controller untuk fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Animasi slide up untuk login popup
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    // Animasi fade untuk overlay
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 0.6,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Animasi scale untuk button
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeInOut),
    );

    // Animasi untuk splash screen slide ke atas setengah
    _splashSlideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.0, -0.5), // Slide ke atas setengah screen
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  void _startTransition() async {
    if (_isAnimating) return;

    setState(() {
      _isAnimating = true;
      _showLogin = true;
    });

    // Start animations simultaneously
    _fadeController.forward();
    await _slideController.forward();

    setState(() {
      _isAnimating = false;
    });
  }

  void _hideLogin() async {
    setState(() {
      _isAnimating = true;
    });

    await _slideController.reverse();
    await _fadeController.reverse();

    setState(() {
      _showLogin = false;
      _isAnimating = false;
    });
  }

  // void _showRegisterPage() async {
  //   setState(() {
  //     _isAnimating = true;
  //   });

  //   await _slideController.reverse();

  //   setState(() {
  //     _showLogin = false;
  //     _showRegister = true;
  //   });

  //   await _slideController.forward();

  //   setState(() {
  //     _isAnimating = false;
  //   });
  // }

  // void _showLoginPage() async {
  //   setState(() {
  //     _isAnimating = true;
  //   });

  //   await _slideController.reverse();

  //   setState(() {
  //     _showRegister = false;
  //     _showLogin = true;
  //   });

  //   await _slideController.forward();

  //   setState(() {
  //     _isAnimating = false;
  //   });
  // }

  void _hideRegister() async {
    setState(() {
      _isAnimating = true;
    });

    await _slideController.reverse();
    await _fadeController.reverse();

    setState(() {
      _showRegister = false;
      _isAnimating = false;
    });
  }

  // @override
  // void dispose() {
  //   _slideController.dispose();
  //   _fadeController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Splash dengan animasi slide ke atas
          AnimatedBuilder(
            animation: _splashSlideAnimation,
            builder: (context, child) {
              return SlideTransition(
                position: _splashSlideAnimation,
                child: _buildSplashBackground(),
              );
            },
          ),

          // Overlay gelap saat login atau register muncul
          if (_showLogin || _showRegister)
            AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Container(
                  color: Colors.black.withOpacity(_fadeAnimation.value),
                  child: GestureDetector(
                    onTap: _showLogin ? _hideLogin : _hideRegister,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.transparent,
                    ),
                  ),
                );
              },
            ),

          // Login Popup dari bawah
          if (_showLogin)
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: _buildLoginPopup(),
                );
              },
            ),

          // Register Popup dari bawah
          if (_showRegister)
            AnimatedBuilder(
              animation: _slideAnimation,
              builder: (context, child) {
                return SlideTransition(
                  position: _slideAnimation,
                  child: _buildRegisterPopup(),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildSplashBackground() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/hotel.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.black.withOpacity(0.5),
              Colors.black.withOpacity(0.8),
            ],
            stops: const [0.0, 0.6, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                // Logo
                Row(
                  children: [
                    Icon(Icons.flight_takeoff, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'ChillPoint Hotel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                // Main Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Main Title
                    const Text(
                      'Selamat Datang\nDi Hotel Kami',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Subtitle
                    const Text(
                      'Pesan kamar nyaman dan fasilitas terbaik\nuntuk pengalaman menginap yang tak terlupakan.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        height: 1.4,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 50),
                    // Get Started Button
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isAnimating ? null : _startTransition,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFFCD74),
                                foregroundColor: Colors.black,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child:
                                  _isAnimating
                                      ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.black,
                                              ),
                                        ),
                                      )
                                      : const Text(
                                        'Get Started',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.3,
                                        ),
                                      ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 56),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //login
  Widget _buildLoginPopup() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.75,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF111111), Color(0xFF303030), Color(0xFF111111)],
          ), // Warna background baru
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and Title
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.hotel_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sign in untuk melihat hotel terbaik',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Email Field
                    TextField(
                      controller: emailController,
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

                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outlined,
                          color: Color(0xFFFFCD74),
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
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
                    const SizedBox(height: 12),

                    // Forgot Password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                            color: Color(0xFFFFCD74),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Login Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _login, // <-- panggil fungsi login yang kamu buat
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCD74),
                          foregroundColor: const Color(0xFF0F0F23),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Sign In',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sign Up Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Don\'t have an account? ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: _showRegisterPage,
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: Color(0xFFFFCD74),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //register
  Widget _buildRegisterPopup() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF111111), Color(0xFF303030), Color(0xFF111111)],
          ),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo and Title
                    Center(
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                              ),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.person_add_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join us and start your journey',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // First Name
                    TextField(
                      controller: _firstNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'First Name',
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
                    const SizedBox(height: 16),

                    // Last Name
                    TextField(
                      controller: _lastNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Last Name',
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
                    const SizedBox(height: 16),

                    // Email
                    TextField(
                      controller: _emailController,
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
                    const SizedBox(height: 16),

                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_outlined,
                          color: Color(0xFFFFCD74),
                          size: 20,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.white.withOpacity(0.7),
                            size: 20,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
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

                    // Terms and Conditions
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                          activeColor: const Color(0xFFFFCD74),
                          checkColor: const Color(0xFF0F0F23),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text.rich(
                              TextSpan(
                                text: 'I agree to the ',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: const TextStyle(
                                      color: Color(0xFFFFCD74),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: const TextStyle(
                                      color: Color(0xFFFFCD74),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Register Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_agreedToTerms) {
                            _register();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Anda harus menyetujui syarat & ketentuan',
                                ),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFCD74),
                          foregroundColor: const Color(0xFF0F0F23),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Sign In Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                        TextButton(
                          onPressed: _showLoginPage,
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color: Color(0xFFFFCD74),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
