import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../theme/app_theme.dart';
import 'detail_screen.dart';
import '../config.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String currentSearch = "";
  List<Map<String, dynamic>> allProperties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataDariGolang();
  }

  Future<void> fetchDataDariGolang({
    String? query,
    String? minPrice,
    String? maxPrice,
  }) async {
    try {
      // 1. Merakit URL dinamis berdasarkan filter yang dikirim
      String url = '${AppConfig.baseUrl}/api/kos?';
      if (query != null && query.isNotEmpty) url += 'search=$query&';
      if (minPrice != null && minPrice.isNotEmpty)
        url += 'min_price=$minPrice&';
      if (maxPrice != null && maxPrice.isNotEmpty)
        url += 'max_price=$maxPrice&';

      // 2. Menembak ke backend Golang
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);

        if (mounted) {
          setState(() {
            // 3. Memasukkan data ke dalam variabel allProperties seperti kodemu sebelumnya
            allProperties = jsonData.map((item) {
              return {
                'id': item['id'],
                'name': item['name'],
                'rating': item['rating'] ?? 0.0,
                'location': item['location'],
                'description': item['description'],
              };
            }).toList();
            isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error fetching data: $e");
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png', // Sesuaikan dengan nama file logomu
              width: 32, // Sesuaikan ukurannya agar pas
              height: 32,
            ),
            const SizedBox(width: 8),
            Text(
              'PintuKos',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.primaryContainer,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottomOpacity: 0.0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.outlineVariant),
                ),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Cari area Setiabudi...',
                    prefixIcon: Icon(Icons.search, color: AppTheme.outline),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),

                  onChanged: (value) {
                    currentSearch = value;
                    if (value.isEmpty) {
                      fetchDataDariGolang(query: currentSearch);
                    }
                  },
                  onSubmitted: (value) {
                    fetchDataDariGolang(query: currentSearch);
                  },
                ),
              ),
            ),

            isLoading
                ? const Padding(
                    padding: EdgeInsets.all(48.0),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryContainer,
                        ),
                      ),
                    ),
                  )
                : allProperties.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text("Tidak ada kos yang sesuai dengan filter ini."),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: allProperties.length,
                    itemBuilder: (context, index) {
                      final prop = allProperties[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  DetailScreen(kosId: prop['id'] as int),
                            ),
                          );
                        },
                        child: _buildKosCard(
                          context,
                          name: prop['name'] as String,
                          rating: prop['rating'] as double,
                          imageUrl: prop['image']?.toString() ?? '',
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildKosCard(
    BuildContext context, {
    required String name,
    required double rating,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryContainer.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child:
                    imageUrl
                        .isNotEmpty // 1. Cek apakah string URL-nya tidak kosong
                    ? Image.network(
                        // JIKA TIDAK KOSONG, munculkan gambar seperti biasa
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        // JIKA KOSONG, munculkan kotak pengganti
                        height: 200,
                        width: double.infinity,
                        color:
                            Colors.grey.shade200, // Warna latar abu-abu lembut
                        child: const Center(
                          child: Icon(
                            Icons
                                .home_work_rounded, // Ikon rumah bawaan Flutter
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                      ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(Google Maps)',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Bandung',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildFacilityChip(Icons.wifi, 'Wifi'),
                    const SizedBox(width: 8),
                    _buildFacilityChip(Icons.ac_unit, 'AC'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.outlineVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              color: AppTheme.outlineVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
