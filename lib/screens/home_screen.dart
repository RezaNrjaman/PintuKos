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
  String currentType = "Semua";
  String selectedFilter = 'Semua';
  List<Map<String, dynamic>> allProperties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchDataDariGolang();
  }

  Future<void> fetchDataDariGolang({
    String? query,
    String? type,
    String? minPrice,
    String? maxPrice,
  }) async {
    try {
      // 1. Merakit URL dinamis berdasarkan filter yang dikirim
      String url = '${AppConfig.baseUrl}/api/kos?';
      if (query != null && query.isNotEmpty) url += 'search=$query&';
      if (type != null && type != 'Semua') url += 'type=$type&';
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
              Color typeColor = item['type'] == 'Putri'
                  ? AppTheme.secondaryContainer
                  : AppTheme.primaryFixedDim;
              Color typeTextColor = item['type'] == 'Putri'
                  ? AppTheme.onSecondaryContainer
                  : AppTheme.onPrimaryFixed;

              return {
                'id': item['id'],
                'name': item['name'],
                'price': item['price'],
                'type': item['type'],
                'location': item['location'],
                'description': item['description'],
                'typeColor': typeColor,
                'typeTextColor': typeTextColor,
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
    final filteredProperties = selectedFilter == 'Semua'
        ? allProperties
        : allProperties
              .where((prop) => prop['type'] == selectedFilter)
              .toList();

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
                      fetchDataDariGolang(
                        query: currentSearch,
                        type: currentType,
                      );
                    }
                  },
                  onSubmitted: (value) {
                    fetchDataDariGolang(
                      query: currentSearch,
                      type: currentType,
                    );
                  },
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _buildCategoryButton('Semua'),
                  _buildCategoryButton('Putra'),
                  _buildCategoryButton('Putri'),
                  _buildCategoryButton('Campur'),
                ],
              ),
            ),
            const SizedBox(height: 16),
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
                : filteredProperties.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text("Tidak ada kos yang sesuai dengan filter ini."),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filteredProperties.length,
                    itemBuilder: (context, index) {
                      final prop = filteredProperties[index];
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
                          price: prop['price'] as String,
                          typeColor: prop['typeColor'] as Color,
                          typeTextColor: prop['typeTextColor'] as Color,
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

  Widget _buildFilterChip(String label) {
    bool isSelected = selectedFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: GestureDetector(
        onTap: () {
          setState(() {
            currentType = "Putra"; // Ubah status kategori aktif
          });
          // Tarik data baru dari Golang dengan filter Putra (dan bawa teks pencariannya jika ada)
          fetchDataDariGolang(query: currentSearch, type: currentType);
        },
        child: Chip(
          label: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? AppTheme.onPrimary
                  : AppTheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: isSelected
              ? AppTheme.primaryContainer
              : AppTheme.surfaceContainerHigh,
          side: BorderSide(
            color: isSelected ? Colors.transparent : AppTheme.outlineVariant,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
    );
  }

  Widget _buildKosCard(
    BuildContext context, {
    required String name,
    required String price,
    required Color typeColor,
    required Color typeTextColor,
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
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: typeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    style: TextStyle(
                      color: typeTextColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
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
                    Text(
                      price,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.primaryContainer,
                      ),
                    ),
                    Text(
                      ' / bln',
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

  // Fungsi pintar pencetak tombol kategori
  Widget _buildCategoryButton(String title) {
    // Mengecek apakah tombol ini adalah kategori yang sedang dipilih
    bool isSelected = currentType == title;

    return GestureDetector(
      onTap: () {
        // 1. Ubah tulisan di memori aplikasi
        setState(() {
          currentType = title;
        });
        // 2. Tarik data baru dengan filter yang diklik
        fetchDataDariGolang(query: currentSearch, type: currentType);
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.teal
              : Colors.white, // Hijau jika aktif, putih jika tidak
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Colors.teal : Colors.grey.shade300,
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
