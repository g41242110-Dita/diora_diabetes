import 'package:flutter/material.dart';

// Import file pendukung
import 'detail_artikel_page.dart';

class ArtikelPage extends StatefulWidget {
  final bool showBackButton;

  const ArtikelPage({
    super.key,
    this.showBackButton = false,
  });

  @override
  State<ArtikelPage> createState() => _ArtikelPageState();
}

class _ArtikelPageState extends State<ArtikelPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data daftar artikel (Fungsi & data asli tetap utuh 100%)
  final List<Map<String, String>> _articles = [
    {
      'title': 'Diabetes - Gejala, Penyebab, dan Pengobatan',
      'snippet': 'Diabetes adalah penyakit kronis yang ditandai dengan tingginya kadar gula di dalam darah. Glukosa atau gula adalah sumber energi utama bagi ...',
      'image': 'https://images.unsplash.com/photo-1615461066841-6116e61058f4?q=80&w=400',
      'content': 'Diabetes adalah penyakit kronis yang ditandai dengan tingginya kadar gula di dalam darah. Glukosa atau gula adalah sumber energi utama bagi tubuh. Namun, pada penderita diabetes, glukosa tidak dapat digunakan oleh tubuh dengan efektif.\n\n'
          'Kadar gula dalam darah diatur oleh hormon insulin yang diproduksi pankreas. Hormon ini membantu sel tubuh menyerap gula darah sehingga kadar gula darah tetap dalam batas normal.\n\n'
          'Pada penderita diabetes, pankreas tidak mampu memproduksi insulin, atau tubuh tidak bisa menggunakan insulin dengan optimal. Akibatnya, sel-sel tubuh tidak dapat menyerap dan mengolah glukosa menjadi energi.\n\n'
          'Glukosa yang tidak diserap sel tubuh dengan baik akan menumpuk dalam darah dan menimbulkan berbagai gangguan kesehatan. Jika tidak ditangani dengan baik, diabetes dapat menimbulkan berbagai komplikasi.',
    },
    {
      'title': 'Diabetes Ancaman Nyata Generasi Muda',
      'snippet': 'Penyebab Diabetes pada Generasi Muda: 1. Malnutrisi (mengalami masalah gizi) sejak lahir · 2. Pola makan tidak seimbang · 3. Kurangnya aktivitas ...',
      'image': 'https://images.unsplash.com/photo-1505751172876-fa1923c5c528?q=80&w=400',
      'content': 'Diabetes kini bukan hanya menyerang lansia, tetapi juga generasi muda. Perubahan gaya hidup, pola makan serba instan, dan kurangnya aktivitas fisik menjadi pemicu utama.\n\n'
          'Penyebab Diabetes pada Generasi Muda:\n'
          '1. Malnutrisi atau masalah gizi sejak dini.\n'
          '2. Pola makan tinggi gula dan lemak jenuh.\n'
          '3. Jarang berolahraga dan terlalu banyak duduk.\n\n'
          'Pencegahan sejak dini sangat penting dengan menerapkan pola hidup sehat, rajin bergerak, dan rutin memeriksakan kadar gula darah.',
    },
    {
      'title': 'diabetes melitus tipe 2 ; artikel review',
      'snippet': 'Diabetes Mellitus Tipe 2 adalah penyakit gangguan metabolik yang di tandai oleh kenaikan gula darah akibat penurunan sekresi insulin oleh sel beta pankreas ...',
      'image': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?q=80&w=400',
      'content': 'Diabetes Mellitus Tipe 2 merupakan gangguan metabolik yang paling sering ditemui. Kondisi ini ditandai dengan resistensi insulin atau penurunan produksi insulin oleh pankreas.\n\n'
          'Faktor risiko meliputi genetik, obesitas, serta gaya hidup tidak sehat. Penanganan dilakukan melalui kombinasi edukasi, terapi nutrisi medis, latihan fisik, dan konsumsi obat hipoglikemik sesuai anjuran dokter.',
    },
    {
      'title': 'Diabetes Melitus',
      'snippet': 'Diabetes melitus merupakan salah satu masalah kesehatan didunia yang patut diperhatikan. Prevalensi dari diabetes melitus setiap tahunnya selalu ...',
      'image': 'https://images.unsplash.com/photo-1584515979956-d9f6e5d09982?q=80&w=400',
      'content': 'Diabetes Melitus menjadi salah satu tantangan kesehatan global terbesar saat ini. Angka penderitanya terus meningkat setiap tahun baik di negara berkembang maupun negara maju.\n\n'
          'Edukasi publik mengenai bahaya komplikasi diabetes—seperti kerusakan ginjal, gangguan penglihatan, dan penyakit jantung—sangat diperlukan untuk menekan angka kasus baru.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredArticles = _articles.where((article) {
      final title = article['title']!.toLowerCase();
      final snippet = article['snippet']!.toLowerCase();
      return title.contains(_searchQuery.toLowerCase()) ||
          snippet.contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.showBackButton
          ? AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF6679F4)),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            )
          : null,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              
              // Header Super Estetik ala Aplikasi Modern
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Artikel',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${filteredArticles.length} Bacaan',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6679F4),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Search Bar Modern & Bersih
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6679F4).withOpacity(0.07),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Cari Artikel . . .',
                    hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13, fontWeight: FontWeight.w500),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF6679F4), size: 22),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.cancel_rounded, size: 18, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // List Artikel Estetik
              Expanded(
                child: filteredArticles.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: const BoxDecoration(
                                color: Color(0xFFEEF2FF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.search_off_rounded, size: 36, color: Color(0xFF6679F4)),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Artikel tidak ditemukan',
                              style: TextStyle(color: Color(0xFF64748B), fontSize: 13.5, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredArticles.length,
                        itemBuilder: (context, index) {
                          final article = filteredArticles[index];
                          return _buildArticleCard(
                            title: article['title']!,
                            snippet: article['snippet']!,
                            content: article['content']!,
                            imageUrl: article['image']!,
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Tampilan Kartu Artikel Berbasis Foto Asli (Super Aesthetic & Mewah)
  Widget _buildArticleCard({
    required String title,
    required String snippet,
    required String content,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DetailArtikelPage(
                  title: title,
                  content: content,
                  imageUrl: imageUrl,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Thumbnail Gambar Asli dengan Sudut Melengkung Estetik
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    imageUrl,
                    width: 78,
                    height: 78,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 78,
                      height: 78,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF2FF),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.image_not_supported_rounded, color: Color(0xFF6679F4), size: 28),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                
                // Teks Judul dan Snippet Artikel
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        snippet,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          height: 1.35,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                
                // Icon panah kecil penanda interaktif yang mempermanis visual
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}