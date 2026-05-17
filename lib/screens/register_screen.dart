import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login_screen.dart';
import '../config.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _register() async {
    // --- 1. AMBIL TEKS DARI CONTROLLER ---
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text;

    // --- 2. GERBANG VALIDASI ---
    // A. Validasi Nama (Hanya huruf dan spasi, tidak boleh kosong)
    if (name.isEmpty || !RegExp(r'^[a-zA-Z\s]+$').hasMatch(name)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Nama tidak valid. Hanya boleh berisi huruf dan spasi.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Berhenti di sini, jangan lanjut ke bawah
    }

    // B. Validasi Email (Format standar nama@domain.com)
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Format email tidak valid (contoh: budi@gmail.com).'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Berhenti di sini
    }

    // C. Validasi Password (Minimal 8 karakter)
    if (password.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password terlalu pendek! Minimal 8 karakter.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return; // Berhenti di sini
    }
    // --- AKHIR GERBANG VALIDASI ---

    // Jika semua validasi lolos, barulah mulai proses loading dan tembak ke Golang
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': name, // Menggunakan variabel yang sudah diambil di atas
          'email': email, // Menggunakan variabel yang sudah diambil di atas
          'password': password,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['message'] ?? 'Registrasi Berhasil!'),
              backgroundColor: Colors.green,
            ),
          );
          // Kembali ke halaman Login setelah sukses mendaftar
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(data['error'] ?? 'Registrasi Gagal'),
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Buat Akun Baru',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Daftar sekarang untuk menyimpan kos favoritmu.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 48),

                // Form Nama
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: const Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

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

                // Tombol Daftar
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
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
                          'Daftar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
