import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ArtikelTersimpanPage(),
    );
  }
}

class ArtikelTersimpanPage extends StatefulWidget {
  const ArtikelTersimpanPage({super.key});

  @override
  State<ArtikelTersimpanPage> createState() => _ArtikelTersimpanPageState();
}

class _ArtikelTersimpanPageState extends State<ArtikelTersimpanPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _allArticles = [
    {
      'title': 'Diabetes - Gejala, Penyebab, dan Pengobatan',
      'desc':
          'Diabetes adalah penyakit kronis yang ditandai dengan tingginya kadar gula di dalam darah. Glukosa atau gula adalah sumber energi utama bagi ...',
      'image': 'assets/diabetes1.png',
      'isBookmarked': true,
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
      'isBookmarked': true,
      'content':
          'Diabetes melitus merupakan salah satu masalah kesehatan didunia yang patut diperhatikan. Prevalensi dari diabetes melitus setiap tahunnya selalu mengalami peningkatan.',
      'contentBottom':
          'Pencegahan dini melalui pola hidup sehat sangat disarankan untuk mengurangi risiko terkena diabetes melitus.',
    },
  ];

  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    // Menyaring artikel yang aktif berstatus bookmarked dan sesuai dengan pencarian
    final currentArticles = _allArticles.where((article) {
      final isBookmarked = article['isBookmarked'] == true;
      final matchesSearch = article['title']!
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          article['desc']!.toLowerCase().contains(_searchQuery.toLowerCase());
      return isBookmarked && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Artikel Tersimpan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
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
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: const InputDecoration(
                          hintText: 'Cari topik atau judul artikel...',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daftar Bacaan Anda',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Text(
                    '${currentArticles.length} Artikel',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6679F4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: currentArticles.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada artikel tersimpan.',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      itemCount: currentArticles.length,
                      itemBuilder: (context, index) {
                        final article = currentArticles[index];
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
                            onTap: () async {
                              // Menangkap hasil kembalian (true/false) dari halaman detail
                              final updatedBookmarkStatus = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailArtikelPage(
                                    title: article['title'],
                                    imagePath: article['image'],
                                    contentTop: article['content'],
                                    contentBottom: article['contentBottom'],
                                    initialBookmarked: article['isBookmarked'],
                                  ),
                                ),
                              );

                              // Jika halaman detail ditutup, perbarui status berdasarkan nilai terakhir
                              if (updatedBookmarkStatus != null) {
                                setState(() {
                                  article['isBookmarked'] = updatedBookmarkStatus;
                                });
                              }
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 120,
                                  width: double.infinity,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    child: Image.asset(
                                      article['image'],
                                      width: double.infinity,
                                      height: 120,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Container(
                                        color: const Color(0xFFE2E8F0),
                                        child: const Center(
                                          child: Icon(
                                            Icons.medical_information,
                                            size: 40,
                                            color: Color(0xFF6679F4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        article['title'],
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        article['desc'],
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                          height: 1.3,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: InkWell(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          onTap: () {
                                            setState(() {
                                              article['isBookmarked'] = false;
                                            });
                                          },
                                          child: const Padding(
                                            padding: EdgeInsets.all(4.0),
                                            child: Icon(
                                              Icons.bookmark_rounded,
                                              color: Color(0xFF6679F4),
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
  final bool initialBookmarked;

  const DetailArtikelPage({
    super.key,
    required this.title,
    required this.imagePath,
    required this.contentTop,
    required this.contentBottom,
    required this.initialBookmarked,
  });

  @override
  State<DetailArtikelPage> createState() => _DetailArtikelPageState();
}

class _DetailArtikelPageState extends State<DetailArtikelPage> {
  double _fontSize = 12.0;
  late bool _isBookmarked;

  @override
  void initState() {
    super.initState();
    _isBookmarked = widget.initialBookmarked;
  }

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
    // Membungkus dengan PopScope agar tombol back fisik/gesture HP mengirimkan status bookmark terbaru
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
            onPressed: () {
              // Mengembalikan nilai _isBookmarked saat tombol back di AppBar diklik
              Navigator.pop(context, _isBookmarked);
            },
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
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
                              // Mengirimkan nilai baru secara langsung saat ikon diklik
                              Navigator.pop(context, _isBookmarked);
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
      ),
    );
  }
}