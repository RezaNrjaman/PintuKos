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

  Future<void> fetchDataDariGolang({String? query}) async {
    try {
      String url = '${AppConfig.baseUrl}/api/kos?';
      if (query != null && query.isNotEmpty) url += 'search=$query&';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        if (mounted) {
          setState(() {
            allProperties = jsonData.map((item) {
              final imageUrls = item['image_urls'] as List<dynamic>? ?? [];
              return {
                'id': item['id'],
                'name': item['name'] ?? '',
                'rating': (item['rating'] ?? 0.0).toDouble(),
                'location': item['location'] ?? '',
                'description': item['description'] ?? '',
                'image': imageUrls.isNotEmpty ? imageUrls[0] : '',
                'latitude': item['latitude'] ?? 0.0,
                'longitude': item['longitude'] ?? 0.0,
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
            Image.asset('assets/logo.png', width: 32, height: 32),
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
                          location: prop['location'] as String,
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
    required String location,
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
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 200,
                            width: double.infinity,
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
                        height: 200,
                        width: double.infinity,
                        color: Colors.grey.shade200,
                        child: const Center(
                          child: Icon(
                            Icons.home_work_rounded,
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
                      rating.toStringAsFixed(1),
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
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.outline,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: Theme.of(context).textTheme.labelSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
