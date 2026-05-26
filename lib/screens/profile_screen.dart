import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Variabel penyimpan data
  String userName = "Memuat...";
  String userEmail = "Memuat...";

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // Fungsi Pengambil Data yang sudah dilengkapi pengaman Null
  Future<void> _fetchProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      _logout(showDialog: false);
      return;
    }

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
        if (mounted && data is Map<String, dynamic>) {
          setState(() {
            userName = data['name']?.toString() ?? 'Pengguna';
            userEmail = data['email']?.toString() ?? '';
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
      if (mounted) {
        setState(() {
          userName = "Terjadi Kesalahan Jaringan";
        });
      }
    }
  }

  // INI ADALAH FUNGSI LOGOUT
  Future<void> _logout({bool showDialog = true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token'); // Hapus token

    if (mounted) {
      // Tendang ke halaman login dan hapus riwayat halaman
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  // SESUAI REQUEST: Logika Edit Profil HANYA Nama & Otomatis Update UI secara Instan
  void _showEditProfileDialog() {
    // SESUAI REQUEST: emailController dihapus karena email tidak boleh diubah
    final nameController = TextEditingController(text: userName);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Profil'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nama Lengkap'),
            ),
            // SESUAI REQUEST: TextField 'Email Baru' telah dihapus sepenuhnya dari dialog
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: AppTheme.outline),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              String inputName = nameController.text.trim();
              if (inputName.isEmpty) return;

              SharedPreferences prefs = await SharedPreferences.getInstance();
              String? token = prefs.getString('jwt_token');

              try {
                final response = await http.put(
                  Uri.parse('${AppConfig.baseUrl}/api/profile'),
                  headers: {
                    'Authorization': 'Bearer $token',
                    'Content-Type': 'application/json',
                  },
                  // HANYA mengirimkan 'name' ke backend sesuai dengan model UpdateProfileInput Go
                  body: json.encode({'name': inputName}),
                );

                if (response.statusCode == 200) {
                  if (mounted) {
                    // PERUBAHAN UTAMA: Langsung perbarui nilai state di UI secara instan!
                    setState(() {
                      userName = inputName;
                    });

                    Navigator.pop(context); // Tutup dialog

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profil berhasil diupdate')),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Gagal mengupdate profil')),
                    );
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Terjadi kesalahan koneksi')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryContainer,
              foregroundColor: Colors.white,
            ),
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
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppTheme.primaryContainer.withOpacity(0.1),
                    child: Text(
                      userName.isNotEmpty && userName != "Memuat..."
                          ? userName[0].toUpperCase()
                          : 'P',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 4),
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
                  _buildProfileOption(
                    Icons.edit_outlined,
                    'Edit Profil',
                    _showEditProfileDialog,
                  ),
                  const Divider(height: 1),
                  _buildProfileOption(Icons.security, 'Keamanan & Privasi', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Segera hadir!')),
                    );
                  }),
                  const Divider(height: 1),
                  _buildProfileOption(Icons.help_outline, 'Bantuan & FAQ', () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Segera hadir!')),
                    );
                  }),
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
                onTap: () => _logout(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.onSurfaceVariant),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, color: AppTheme.outlineVariant),
      onTap: onTap,
    );
  }
}
