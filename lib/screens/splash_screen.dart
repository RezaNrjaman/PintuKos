import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

import 'login_screen.dart';
import 'main_nav_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Langsung jalankan pengecekan saat layar terbuka
  }

  Future<void> _checkLoginStatus() async {
    // 1. Berikan efek jeda (loading) selama 2 detik agar logo terlihat
    await Future.delayed(const Duration(seconds: 2));

    // 2. Bongkar memori HP untuk mencari Token JWT
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    // 3. Pastikan aplikasi masih menyala (mounted) sebelum pindah halaman
    if (!mounted) return;

    // 4. Logika Pintu Otomatis
    if (token != null && token.isNotEmpty) {
      // Punya Token -> Langsung masuk Beranda!
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavScreen()),
      );
    } else {
      // Tidak punya Token -> Silakan Login dulu
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: 150, height: 150),

            const SizedBox(height: 24),

            const SizedBox(height: 40),

            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blueAccent),
            ),
          ],
        ),
      ),
    );
  }
}
