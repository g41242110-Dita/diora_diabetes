import 'package:flutter/material.dart';
import 'admin_tambah_artikel_page.dart'; // Import halaman Tambah Artikel

class AdminArtikelPage extends StatefulWidget {
  final VoidCallback? onBackToBeranda;

  const AdminArtikelPage({super.key, this.onBackToBeranda});

  @override
  State<AdminArtikelPage> createState() => _AdminArtikelPageState();
}

class _AdminArtikelPageState extends State<AdminArtikelPage> {
  final TextEditingController _searchController = TextEditingController();

  // Mengubah filter aktif menggunakan string kategori ('Draf' atau 'Dipublikasi')
  String _selectedFilter = 'Draf';

  // Status untuk berpindah antara tampilan daftar dan form tambah artikel
  bool _isTambahArtikel = false;

  final List<dynamic> _articles = [
    {
      'title': 'Diabetes dan Prediabetes',
      'description':
      'Diabetes muncul ketika tubuh tidak dapat memproduksi cukup insulin (diabetes tipe 1) atau ketika tubuh memproduksi insulin tetapi tidak dapat menggunakannya...',
      'status': 'Draf',
      'date': '24 Okt 2026',
    },
    {
      'title': 'Memahami dan menjalani hidup dengan Diabetes',
      'description':
      'Anda mungkin telah mengidap diabetes sejak lama jika muncul gejala seperti sering merasa haus, tenggorokan terasa kering, dan sudah makan teratur tetapi berat...',
      'status': 'Draf',
      'date': '20 Okt 2026',
    },
    {
      'title': '11 Cara Mencegah Diabetes yang Bisa Dimulai Hari Ini!',
      'description':
      'Penyakit diabetes melitus ditandai oleh naiknya kadar gula di dalam darah. Penyebabnya bisa berkaitan dengan faktor keturunan hingga obesitas.',
      'status': 'Dipublikasi',
      'date': '15 Okt 2026',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Jika tombol "+ Tambah Artikel" diklik, tampilkan form AdminTambahArtikelPage
    if (_isTambahArtikel) {
      return AdminTambahArtikelPage(
        onBack: () {
          setState(() {
            _isTambahArtikel = false; // Kembali ke daftar artikel
          });
        },
      );
    }

    // Filter daftar artikel secara otomatis berdasarkan status dan pencarian
    final filteredArticles = _articles.where((article) {
      final matchesFilter = article['status'] == _selectedFilter;
      final query = _searchController.text.toLowerCase();
      final matchesSearch = article['title']!.toLowerCase().contains(query) ||
          article['description']!.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna latar belakang bersih (Slate 50)
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER KURVA BERGRADIEN BIRU PENUH (ESTETIK & SERASI) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            InkWell(
                              borderRadius: BorderRadius.circular(14),
                              onTap: () {
                                if (widget.onBackToBeranda != null) {
                                  widget.onBackToBeranda!();
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Color(0xFF2563EB),
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Kelola Artikel',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 22,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                        // Tombol Tambah Artikel Estetik di Header
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _isTambahArtikel = true;
                                });
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Row(
                                  children: [
                                    Icon(Icons.add_rounded, color: Color(0xFF2563EB), size: 20),
                                    SizedBox(width: 4),
                                    Text(
                                      'Tambah',
                                      style: TextStyle(
                                        color: Color(0xFF2563EB),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Mini Banner Edukasi di Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.article_rounded, color: Color(0xFFBFDBFE), size: 22),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Kelola, sunting, dan terbitkan artikel kesehatan diabetes dengan mudah.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- KONTEN UTAMA DI BAWAH HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SEARCH BAR ESTETIK
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {}); // Memperbarui tampilan saat mencari
                        },
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          hintText: 'Cari artikel kesehatan...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2563EB), size: 22),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // TAB FILTER ESTETIK (PILIHAN DRAF & DIPUBLIKASI)
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = 'Draf';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedFilter == 'Draf' ? const Color(0xFF2563EB) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  if (_selectedFilter == 'Draf')
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                                border: Border.all(
                                  color: _selectedFilter == 'Draf' ? Colors.transparent : const Color(0xFFCBD5E1),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                'Artikel Draf',
                                style: TextStyle(
                                  color: _selectedFilter == 'Draf' ? Colors.white : const Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedFilter = 'Dipublikasi';
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 13),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: _selectedFilter == 'Dipublikasi' ? const Color(0xFF2563EB) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  if (_selectedFilter == 'Dipublikasi')
                                    BoxShadow(
                                      color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                ],
                                border: Border.all(
                                  color: _selectedFilter == 'Dipublikasi' ? Colors.transparent : const Color(0xFFCBD5E1),
                                  width: 1.2,
                                ),
                              ),
                              child: Text(
                                'Artikel Dipublikasi',
                                style: TextStyle(
                                  color: _selectedFilter == 'Dipublikasi' ? Colors.white : const Color(0xFF64748B),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.5,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // DAFTAR ARTIKEL BERDASARKAN FILTER
                    filteredArticles.isEmpty
                        ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'Tidak ada artikel pada kategori ini.',
                          style: TextStyle(color: Colors.grey[500], fontSize: 13.5),
                        ),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredArticles.length,
                      itemBuilder: (context, index) {
                        final article = filteredArticles[index];
                        final isDraft = article['status'] == 'Draf';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IMAGE PLACEHOLDER GRADIENT
                              Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.blue.shade100,
                                      Colors.indigo.shade50,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.image_outlined,
                                      color: Color(0xFF2563EB),
                                      size: 30,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 14),

                              // KONTEN ARTIKEL
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // BADGE STATUS
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isDraft
                                            ? const Color(0xFFFEF3C7)
                                            : const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        article['status']!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isDraft
                                              ? const Color(0xFFD97706)
                                              : const Color(0xFF15803D),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // JUDUL
                                    Text(
                                      article['title']!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                        height: 1.25,
                                      ),
                                    ),
                                    const SizedBox(height: 4),

                                    // DESKRIPSI
                                    Text(
                                      article['description']!,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF64748B),
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 10),

                                    // ACTION BUTTONS (EDIT & DELETE)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Material(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(10),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(10),
                                            onTap: () {
                                              // Aksi Edit Artikel
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(7.0),
                                              child: Icon(
                                                Icons.edit_outlined,
                                                size: 16,
                                                color: Color(0xFF334155),
                                              ),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Material(
                                          color: const Color(0xFFFEE2E2),
                                          borderRadius: BorderRadius.circular(10),
                                          child: InkWell(
                                            borderRadius: BorderRadius.circular(10),
                                            onTap: () {
                                              // Aksi Hapus Artikel
                                            },
                                            child: const Padding(
                                              padding: EdgeInsets.all(7.0),
                                              child: Icon(
                                                Icons.delete_outline_rounded,
                                                size: 16,
                                                color: Color(0xFFEF4444),
                                              ),
                                            ),
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
                      },
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
}