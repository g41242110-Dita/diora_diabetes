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

  // Data daftar artikel
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
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: widget.showBackButton
          ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
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

              Expanded(
                child: ListView.builder(
                  itemCount: _articles.length,
                  itemBuilder: (context, index) {
                    final article = _articles[index];
                    return _buildArticleCard(
                      title: article['title']!,
                      snippet: article['snippet']!,
                      content: article['content']!,
                      imageUrl: article['image']!,
                      iconData: Icons.bloodtype_outlined,
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

  Widget _buildArticleCard({
    required String title,
    required String snippet,
    required String content,
    required String imageUrl,
    required IconData iconData,
  }) {
    return GestureDetector(
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
      child: Container(
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
      ),
    );
  }
}