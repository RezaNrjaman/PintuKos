import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class DetailScreen extends StatefulWidget {
  final int kosId; // Variabel untuk menerima ID dari Home

  const DetailScreen({super.key, required this.kosId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool isFavorite = false;
  bool isLoading = true;
  Map<String, dynamic> kosData = {};

  @override
  void initState() {
    super.initState();
    fetchDetailKos();
    _checkFavoriteStatus();
  }

  // Mengambil data detail dari Golang berdasarkan ID
  Future<void> fetchDetailKos() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/kos/${widget.kosId}'),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            kosData = json.decode(response.body);
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error mengambil detail: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  // Fungsi WhatsApp Dinamis
  Future<void> _launchWhatsApp() async {
    if (kosData.isEmpty) return;

    String phone = kosData['wa_number'] ?? '';
    String kosName = kosData['name'] ?? '';

    // Template pesan otomatis
    String text =
        'Halo, saya melihat info $kosName di PintuKos. Apakah masih ada kamar kosong?';

    final Uri waUrl = Uri.parse(
      'https://wa.me/$phone?text=${Uri.encodeComponent(text)}',
    );

    if (!await launchUrl(waUrl, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka WhatsApp')),
        );
      }
    }
  }

  // Mengecek warna awal hati saat halaman detail dibuka
  Future<void> _checkFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/favorites/check/${widget.kosId}'),
        headers: {'Authorization': 'Bearer $token'}, // Kirim surat izin (Token)
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            isFavorite = data['is_favorite'];
          });
        }
      }
    } catch (e) {
      print("Error cek favorit: $e");
    }
  }

  // Mengirim perintah saat tombol hati ditekan
  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/favorites/toggle/${widget.kosId}'),
        headers: {'Authorization': 'Bearer $token'}, // Kirim surat izin (Token)
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            isFavorite = data['is_favorite']; // Ubah warna hati otomatis
          });
          // Tampilkan notifikasi pop-up
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(data['message']),
                ],
              ),
              backgroundColor: isFavorite ? Colors.pink : Colors.grey,
              duration: const Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      print("Error tekan favorit: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // Tampilan saat loading
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.primaryContainer,
            ),
          ),
        ),
      );
    }

    // Tampilan jika data gagal dimuat
    if (kosData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Data kos tidak ditemukan')),
      );
    }

    // Mengamankan data fasilitas
    List<dynamic> facilities = kosData['facilities'] ?? [];
    Color typeColor = kosData['type'] == 'Putri'
        ? AppTheme.secondaryContainer
        : AppTheme.primaryFixedDim;
    Color typeTextColor = kosData['type'] == 'Putri'
        ? AppTheme.onSecondaryContainer
        : AppTheme.onPrimaryFixed;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.primaryContainer,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    'https://picsum.photos/seed/kos${kosData['name'].length}/600/400', // Gambar dinamis sementara
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.4),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.redAccent : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      kosData['type'] ?? '-',
                      style: TextStyle(
                        color: typeTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    kosData['name'] ?? '-',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 18,
                        color: AppTheme.outline,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          kosData['location'] ?? '-',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppTheme.outline),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: Colors.amber,
                        size: 28,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        kosData['rating']?.toString() ?? '0.0',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(color: AppTheme.primaryContainer),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Rating Google Maps',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.outline,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Fasilitas',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: facilities
                        .map(
                          (fac) => _buildFacilityItem(
                            Icons.check_circle_outline,
                            fac.toString(),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Deskripsi',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    kosData['description'] ?? '-',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar:
          (kosData['wa_number'] != null &&
              kosData['wa_number'].toString().isNotEmpty)
          ? Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.surfaceContainerLowest,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _launchWhatsApp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryContainer,
                  foregroundColor: AppTheme.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat),
                    SizedBox(width: 8),
                    Text(
                      'Tanya via WhatsApp',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const SizedBox.shrink(), // Menyembunyikan bagian bawah jika tidak ada nomor HP
    );
  }

  Widget _buildFacilityItem(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppTheme.primaryContainer, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
