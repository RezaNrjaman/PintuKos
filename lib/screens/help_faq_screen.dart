import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HelpFaqScreen extends StatelessWidget {
  const HelpFaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          'Bantuan & FAQ',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppTheme.primaryContainer),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER KONTAK ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryContainer,
                    AppTheme.primaryContainer.withValues(alpha: 0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryContainer.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.support_agent,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Butuh Bantuan Langsung?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Tim PintuKos siap membantu Anda 24/7.',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // --- DAFTAR FAQ ---
            const Text(
              'Pertanyaan yang Sering Diajukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildFaqItem(
                    question: 'Bagaimana cara menghubungi pemilik kos?',
                    answer:
                        'Anda dapat menekan tombol "Hubungi Pemilik" pada halaman detail kos. Aplikasi akan otomatis mengarahkan Anda ke WhatsApp pemilik menggunakan nomor yang sudah terverifikasi dari data Google Maps.',
                  ),
                  // ✅ PERBAIKAN: Mengganti warna ke outlineVariant dan menghapus const
                  Divider(height: 1, color: AppTheme.outlineVariant),

                  _buildFaqItem(
                    question: 'Apakah titik lokasi kos akurat?',
                    answer:
                        'Ya, seluruh data titik koordinat kos kami terintegrasi dan disinkronisasi secara otomatis dari sistem Google Maps untuk memastikan keakuratan rute di area Setiabudi.',
                  ),
                  Divider(
                    height: 1,
                    color: AppTheme.outlineVariant,
                  ), // ✅ PERBAIKAN

                  _buildFaqItem(
                    question:
                        'Bagaimana cara menyimpan kos untuk dilihat nanti?',
                    answer:
                        'Anda dapat menekan ikon hati (favorit) di pojok kanan atas pada gambar kos. Daftar kos yang Anda simpan dapat dilihat kembali melalui menu "Kos Favorit Saya" di halaman Profil.',
                  ),
                  Divider(
                    height: 1,
                    color: AppTheme.outlineVariant,
                  ), // ✅ PERBAIKAN

                  _buildFaqItem(
                    question:
                        'Apakah saya bisa membayar kos langsung dari aplikasi?',
                    answer:
                        'Saat ini aplikasi kami berfokus untuk memudahkan proses pencarian dan survei. Transaksi pembayaran harus dilakukan langsung dengan pihak pengelola kos.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqItem({required String question, required String answer}) {
    return Theme(
      data: ThemeData().copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        iconColor: AppTheme.primaryContainer,
        collapsedIconColor: AppTheme.outline,
        title: Text(
          question,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppTheme.onSurface,
          ),
        ),
        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        children: [
          Text(
            answer,
            style: const TextStyle(
              color: AppTheme.outline,
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
