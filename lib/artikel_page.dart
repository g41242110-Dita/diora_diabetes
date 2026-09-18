import 'package:flutter/material.dart';

class ArtikelPage extends StatefulWidget {
  const ArtikelPage({super.key});

  @override
  State<ArtikelPage> createState() => _ArtikelPageState();
}

class _ArtikelPageState extends State<ArtikelPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Utama
              const Center(
                child: Text(
                  'Artikel',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Artikel . . .',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF6679F4)),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Daftar Artikel
              Expanded(
                child: ListView(
                  children: [
                    _buildArticleCard(
                      title: 'Diabetes - Gejala, Penyebab, dan Pengobatan',
                      snippet:
                      'Diabetes adalah penyakit kronis yang ditandai dengan tingginya kadar gula di dalam darah. Glukosa atau gula adalah sumber energi utama bagi ...',
                      iconData: Icons.bloodtype_outlined,
                    ),
                    _buildArticleCard(
                      title: 'Diabetes Ancaman Nyata Generasi Muda',
                      snippet:
                      'Penyebab Diabetes pada Generasi Muda: 1. Malnutrisi (mengalami masalah gizi) sejak lahir · 2. Pola makan tidak seimbang · 3. Kurangnya aktivitas ...',
                      iconData: Icons.medication_liquid_outlined,
                    ),
                    _buildArticleCard(
                      title: 'diabetes melitus tipe 2 ; artikel review',
                      snippet:
                      'Diabetes Mellitus Tipe 2 adalah penyakit gangguan metabolik yang di tandai oleh kenaikan gula darah akibat penurunan sekresi insulin oleh sel beta pankreas ...',
                      iconData: Icons.personal_injury_outlined,
                    ),
                    _buildArticleCard(
                      title: 'Diabetes Melitus',
                      snippet:
                      'Diabetes melitus merupakan salah satu masalah kesehatan didunia yang patut diperhatikan. Prevalensi dari diabetes melitus setiap tahunnya selalu ...',
                      iconData: Icons.health_and_safety_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Kartu Artikel
  Widget _buildArticleCard({
    required String title,
    required String snippet,
    required IconData iconData,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gambar / Icon Ilustrasi Artikel
          Container(
            width: 75,
            height: 75,
            decoration: BoxDecoration(
              color: const Color(0xFFEBF3FE),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              size: 36,
              color: const Color(0xFF6679F4),
            ),
          ),
          const SizedBox(width: 12),

          // Judul dan Ringkasan Teks
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  snippet,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.grey.shade600,
                    height: 1.3,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}