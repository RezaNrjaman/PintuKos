import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';

class DetailScreen extends StatefulWidget {
  final int kosId;

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
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _launchWhatsApp() async {
    if (kosData.isEmpty) return;
    String phone = kosData['wa_number'] ?? '';
    String kosName = kosData['name'] ?? '';
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

  Future<void> _checkFavoriteStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('${AppConfig.baseUrl}/api/favorites/check/${widget.kosId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() => isFavorite = data['is_favorite']);
        }
      }
    } catch (e) {
      print("Error cek favorit: $e");
    }
  }

  Future<void> _toggleFavorite() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/api/favorites/toggle/${widget.kosId}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() => isFavorite = data['is_favorite']);
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

  Future<void> _openMaps() async {
    final name = kosData['name'] ?? '';
    final location = kosData['location'] ?? '';

    final String searchQuery = Uri.encodeComponent('$name, $location');

    // Format URL Universal Google Maps yang resmi
    final Uri mapsUrl = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$searchQuery',
    );

    if (!await launchUrl(mapsUrl, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Maps')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

    if (kosData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Data kos tidak ditemukan')),
      );
    }

    List<dynamic> imageUrls = kosData['image_urls'] ?? [];
    String imageUrl = imageUrls.isNotEmpty ? imageUrls[0] : '';

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
                  imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.home_work_rounded,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Center(
                            child: Icon(
                              Icons.home_work_rounded,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
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
                  Text(
                    kosData['name'] ?? '-',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: _openMaps,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 18,
                          color: AppTheme.primaryContainer,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            kosData['location'] ?? '-',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: AppTheme.primaryContainer,
                                  decoration: TextDecoration.underline,
                                ),
                          ),
                        ),
                        const Icon(
                          Icons.open_in_new,
                          size: 14,
                          color: AppTheme.primaryContainer,
                        ),
                      ],
                    ),
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

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _openMaps,
                      icon: const Icon(Icons.map_outlined),
                      label: const Text('Lihat Lokasi di Google Maps'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryContainer,
                        side: const BorderSide(
                          color: AppTheme.primaryContainer,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ❌ PERUBAHAN: Judul 'Fasilitas' dan komponen looping Wrap/Chips untuk menampilkan
                  // fasilitas kos dari response backend lama telah dihapus sepenuhnya di sini untuk
                  // menghindari error render "null" atau penumpukan UI kosong.
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
          : const SizedBox.shrink(),
    );
  }
}
