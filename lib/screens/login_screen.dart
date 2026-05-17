import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_nav_screen.dart';
import 'register_screen.dart';
import '../config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    // --- 1. AMBIL TEKS DARI CONTROLLER ---
    String email = _emailController.text
        .trim(); // Sesuaikan nama controllernya jika beda
    String password = _passwordController.text;

    // --- 2. GERBANG VALIDASI ---
    // Validasi Email (Format standar nama@domain.com)
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Hentikan fungsi jika salah
    }

    // Validasi Password (Minimal 8 karakter)
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password minimal 8 karakter.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Hentikan fungsi jika salah
    }
    setState(() {
      _isLoading = true;
    });

    try {
      // Mengirim data ke API Golang
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': _emailController.text,
          'password': _passwordController.text,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // Jika sukses, simpan Token ke memori HP
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', data['token']);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Login Berhasil! 🎉',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Pindah ke halaman Home
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainNavScreen()),
          );
        }
      } else {
        // Jika gagal (password/email salah)
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['error'] ?? 'Login Gagal'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat terhubung ke server'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                //==========================LOGO=====================================
                const Icon(
                  Icons.home_work_rounded,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                //==========================LOGO=====================================
                const SizedBox(height: 24),
                const Text(
                  'Masuk ke PintuKos',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Silakan masuk untuk melanjutkan pencarian kos idamanmu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 48),

                // Form Email
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Form Password
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Login
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(height: 16),

                // Tombol Pindah ke Register
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Belum punya akun? Daftar sekarang',
                    style: TextStyle(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
