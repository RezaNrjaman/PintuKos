import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

// 1. Mengubah menjadi StatefulWidget
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // 2. Variabel penyimpan data
  String userName = "Memuat...";
  String userEmail = "Memuat...";

  // 3. initState: Fungsi yang otomatis jalan saat halaman dibuka
  @override
  void initState() {
    super.initState();
    _fetchProfile(); // Memanggil fungsi tarik data
  }

  // 4. Posisi Fungsi Pengambil Data diletakkan di sini, di dalam class State
  Future<void> _fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            userName = data['name'] ?? 'Pengguna';
            userEmail = data['email'] ?? '';
          });
        }
      } else {
        final errorData = json.decode(response.body);
        if (mounted) {
          setState(() {
            userName = "Gagal (Kode: ${response.statusCode})";
            userEmail = errorData['error'] ?? "Terjadi kesalahan";
          });
        }
      }
    } catch (e) {
      print("Gagal mengambil profil: $e");
    }
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: userName);
    final emailController = TextEditingController(text: userEmail);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Panggil API PUT ke backend
              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? token = prefs.getString('jwt_token');

              final response = await http.put(
                Uri.parse('${AppConfig.baseUrl}/api/profile'),
                headers: {
                  'Authorization': 'Bearer $token',
                  'Content-Type': 'application/json',
                },
                body: json.encode({
                  'name': nameController.text,
                  'email': emailController.text,
                }),
              );

              if (response.statusCode == 200) {
                Navigator.pop(context);
                _fetchProfile(); // Refresh data profil
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Profil berhasil diupdate')),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Profil',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryContainer,
            fontWeight: FontWeight.w800,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    // Biarkan foto dummy dulu jika belum ada fitur upload foto
                    backgroundImage: NetworkImage(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuDqzOel_Ll3rJq39vSTIpb-gfz1vpbQXojaUFCNLG2_694ks-5hWuQcSbEElY-D-tXiV07XVhmza--88HhPyFHAu4GfrOg5Ta568IcYDRI5-m6a_mmh-ZUyXf3IJxnMF08uWDfAAH2xGqqB6EK7rQwFHJwQYlIlEqhQRIELrB5rUGaz_cFtB3ElHGMI76oz51ahc8kBM7NAH3gME6-TQamgnpuFNVbumY-20l0xI5q6pPmypqY-jy84YM9zAu5rstTDteaWzY8f1CQ',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5. Mengganti John Doe dengan variabel userName
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 4),

                  // 6. Mengganti email dummy dengan variabel userEmail
                  Text(
                    userEmail,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: AppTheme.outline),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildProfileOption(Icons.edit_outlined, 'Edit Profil'),
                  const Divider(height: 1),
                  _buildProfileOption(Icons.security, 'Keamanan & Privasi'),
                  const Divider(height: 1),
                  _buildProfileOption(Icons.help_outline, 'Bantuan & FAQ'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: AppTheme.error),
                title: const Text(
                  'Keluar',
                  style: TextStyle(
                    color: AppTheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () async {
                  // Tambahkan penghapus token saat logout
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  await prefs.remove('jwt_token');

                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.onSurfaceVariant),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
      onTap: () {},
    );
  }
}
