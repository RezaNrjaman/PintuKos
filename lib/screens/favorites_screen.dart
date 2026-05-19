import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'detail_screen.dart';
import '../config.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<dynamic> favoriteKos = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  // Menarik data favorit asli dari Golang
  Future<void> _fetchFavorites() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      setState(() => isLoading = false);
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/favorites'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            favoriteKos = json.decode(response.body);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error ambil favorit: $e");
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  // Menghapus favorit langsung dari halaman ini
  Future<void> _removeFavorite(int kosId, int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/favorites/toggle/$kosId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        setState(() {
          favoriteKos.removeAt(index); // Hapus dari layar secara visual
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text('Dihapus dari Favorit'),
                ],
              ),
              backgroundColor: Colors.grey,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      print("Error hapus favorit: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Favorit Saya',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blueAccent),
            )
          : favoriteKos.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteKos.length,
              itemBuilder: (context, index) {
                final kos = favoriteKos[index];
                return _buildFavoriteCard(kos, index);
              },
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Belum ada kos favorit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Kos yang kamu sukai akan muncul di sini.',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteCard(dynamic kos, int index) {
    return GestureDetector(
      onTap: () {
        // Navigasi ke halaman detail dengan membawa ID yang benar
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailScreen(kosId: kos['id']),
          ),
        ).then(
          (_) => _fetchFavorites(),
        ); // Refresh data saat kembali dari layar detail
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Gambar Thumbnail Sementara
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'https://picsum.photos/seed/kos${kos['name'].length}/100/100',
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      kos['type'] ?? '-',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    kos['name'] ?? '-',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    kos['price'] ?? '-',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.teal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Tombol Hapus Favorit langsung dari daftar
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.redAccent),
              onPressed: () => _removeFavorite(kos['id'], index),
            ),
          ],
        ),
      ),
    );
  }
}
