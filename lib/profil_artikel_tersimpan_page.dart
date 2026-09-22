import 'package:flutter/material.dart';

class ArtikelTersimpanPage extends StatefulWidget {
  const ArtikelTersimpanPage({super.key});

  @override
  State<ArtikelTersimpanPage> createState() => _ArtikelTersimpanPageState();
}

class _ArtikelTersimpanPageState extends State<ArtikelTersimpanPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allArticles = [
    {
      'title': 'Diabetes - Gejala, Penyebab, dan Pengobatan',
      'desc':
      'Diabetes adalah penyakit kronis yang ditandai dengan tingginya kadar gula di dalam darah. Glukosa atau gula adalah sumber energi utama bagi ...',
      'image': 'assets/diabetes1.png',
      'content':
      'Diabetes adalah penyakit kronis yang ditandai dengan tingginya kadar gula di dalam darah. Glukosa atau gula adalah sumber energi utama bagi tubuh. Namun, pada penderita diabetes, glukosa tidak dapat digunakan oleh tubuh dengan efektif.\n\nKadar gula dalam darah diatur oleh hormon insulin yang diproduksi pankreas. Hormon ini membantu sel tubuh menyerap gula darah sehingga kadar gula darah tetap dalam batas normal.',
      'contentBottom':
      'Pada penderita diabetes, pankreas tidak mampu memproduksi insulin, atau tubuh tidak bisa menggunakan insulin dengan optimal. Akibatnya, sel-sel tubuh tidak dapat menyerap dan mengolah glukosa menjadi energi.\n\nGlukosa yang tidak diserap sel tubuh dengan baik akan menumpuk dalam darah dan menimbulkan berbagai gangguan kesehatan. Jika tidak ditangani dengan baik, diabetes dapat menimbulkan berbagai komplikasi.\n\nMeski diabetes merupakan penyakit kronis, kondisi ini sebenarnya dapat dikendalikan. Bahkan, pada sebagian penderita diabetes tipe 2, kadar gula darah dapat kembali ke kisaran normal dan stabil tanpa bantuan obat dalam jangka waktu tertentu. Kondisi ini dikenal sebagai remisi diabetes.\n\nRemisi diabetes dapat terjadi apabila penderita berhasil mengendalikan kadar gula darah melalui perubahan gaya hidup, seperti menerapkan pola makan sehat, rutin berolahraga, menjaga berat badan ideal, serta mengonsumsi obat diabetes sesuai anjuran dokter.\n\nNamun, perlu dipahami bahwa remisi bukan berarti diabetes telah hilang atau sembuh sepenuhnya. Hal ini karena risiko meningkatnya kadar gula darah tetap ada, sehingga penderita diabetes tetap perlu terus mempertahankan pola hidup sehat dan menjalani kontrol secara berkala.',
    },
    {
      'title': 'Diabetes Melitus',
      'desc':
      'Diabetes melitus merupakan salah satu masalah kesehatan didunia yang patut diperhatikan. Prevalensi dari diabetes melitus setiap tahunnya selalu ...',
      'image': 'assets/diabetes2.png',
      'content':
      'Diabetes melitus merupakan salah satu masalah kesehatan didunia yang patut diperhatikan. Prevalensi dari diabetes melitus setiap tahunnya selalu mengalami peningkatan.',
      'contentBottom':
      'Pencegahan dini melalui pola hidup sehat sangat disarankan untuk mengurangi risiko terkena diabetes melitus.',
    },
  ];

  List<Map<String, String>> _filteredArticles = [];

  @override
  void initState() {
    super.initState();
    _filteredArticles = _allArticles;
  }

  void _filterSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredArticles = _allArticles;
      } else {
        _filteredArticles = _allArticles
            .where((item) =>
        item['title']!.toLowerCase().contains(query.toLowerCase()) ||
            item['desc']!.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
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
        child: Column(
          children: [
            const Text(
              'Artikel Tersimpan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFF64748B)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: _filterSearch,
                        decoration: const InputDecoration(
                          hintText: 'Cari artikel . . .',
                          hintStyle: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontStyle: FontStyle.italic,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                itemCount: _filteredArticles.length,
                itemBuilder: (context, index) {
                  final article = _filteredArticles[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailArtikelPage(
                              title: article['title']!,
                              imagePath: article['image']!,
                              contentTop: article['content']!,
                              contentBottom: article['contentBottom']!,
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                article['image']!,
                                width: 85,
                                height: 85,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      width: 85,
                                      height: 85,
                                      color: const Color(0xFFE2E8F0),
                                      child: const Icon(
                                        Icons.medical_information,
                                        color: Color(0xFF6679F4),
                                      ),
                                    ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    article['title']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    article['desc']!,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF64748B),
                                      height: 1.3,
                                    ),
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  const Align(
                                    alignment: Alignment.bottomRight,
                                    child: Icon(
                                      Icons.bookmark_rounded,
                                      color: Color(0xFF475569),
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailArtikelPage extends StatefulWidget {
  final String title;
  final String imagePath;
  final String contentTop;
  final String contentBottom;

  const DetailArtikelPage({
    super.key,
    required this.title,
    required this.imagePath,
    required this.contentTop,
    required this.contentBottom,
  });

  @override
  State<DetailArtikelPage> createState() => _DetailArtikelPageState();
}

class _DetailArtikelPageState extends State<DetailArtikelPage> {
  double _fontSize = 12.0;
  bool _isBookmarked = true;
  int _currentIndex = 3;

  void _zoomIn() {
    setState(() {
      if (_fontSize < 18.0) _fontSize += 1.0;
    });
  }

  void _zoomOut() {
    setState(() {
      if (_fontSize > 10.0) _fontSize -= 1.0;
    });
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black87, width: 1.2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Diabetes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.contentTop,
                            style: TextStyle(
                              fontSize: _fontSize,
                              color: const Color(0xFF475569),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                widget.imagePath,
                                height: 140,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Container(
                                      height: 140,
                                      width: double.infinity,
                                      color: const Color(0xFFE2E8F0),
                                      child: const Icon(
                                        Icons.medical_information,
                                        size: 50,
                                        color: Color(0xFF6679F4),
                                      ),
                                    ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            widget.contentBottom,
                            style: TextStyle(
                              fontSize: _fontSize,
                              color: const Color(0xFF475569),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Divider(color: Colors.black87, thickness: 1),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: _zoomIn,
                                child: const Icon(
                                  Icons.zoom_in_rounded,
                                  color: Color(0xFF475569),
                                  size: 26,
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: _zoomOut,
                                child: const Icon(
                                  Icons.zoom_out_rounded,
                                  color: Color(0xFF475569),
                                  size: 26,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _isBookmarked = !_isBookmarked;
                                  });
                                },
                                child: Icon(
                                  _isBookmarked
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: const Color(0xFF334155),
                                  size: 26,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                selectedItemColor: const Color(0xFF6679F4),
                unselectedItemColor: const Color(0xFF94A3B8),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                elevation: 0,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined, size: 26),
                    activeIcon: Icon(Icons.home, size: 26),
                    label: 'Beranda',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.auto_awesome_outlined, size: 24),
                    activeIcon: Icon(Icons.auto_awesome, size: 24),
                    label: 'Fitur',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline_rounded, size: 24),
                    activeIcon: Icon(Icons.chat_bubble_rounded, size: 24),
                    label: 'Bantuan',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.article_outlined, size: 24),
                    activeIcon: Icon(Icons.article, size: 24),
                    label: 'Artikel',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline, size: 26),
                    activeIcon: Icon(Icons.person, size: 26),
                    label: 'Profil',
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