import 'package:flutter/material.dart';

// Import halaman-halaman yang dibutuhkan
import 'profile_screen.dart';
import 'konsultasi_page.dart';
import 'skrining_page.dart';
import 'lokasi_page.dart';
import 'progres_kesehatan_page.dart';
import 'artikel_page.dart';
import 'hasil_skrining_page.dart';
import 'detail_artikel_page.dart';

class BerandaPage extends StatefulWidget {
  final String namaUser;
  final int initialIndex;

  const BerandaPage({
    super.key,
    this.namaUser = 'Pian',
    this.initialIndex = 0,
  });

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  late int _selectedIndex;
  late PageController _pageController;

  final List<Map<String, String>> _daftarArtikel = [
    {
      'title': 'Diabetes - Gejala, Penyebab, dan Pengobatan',
      'content':
      'Diabetes adalah penyakit kronis yang ditandai dengan tingginya kadar gula di dalam darah. Glukosa atau gula adalah sumber energi utama bagi tubuh. Namun, pada penderita diabetes, glukosa tidak dapat digunakan oleh tubuh dengan efektif.\n\nKadar gula dalam darah diatur oleh hormon insulin yang diproduksi pankreas. Hormon ini membantu sel tubuh menyerap gula darah sehingga kadar gula darah tetap dalam batas normal.\n\nPada penderita diabetes, pankreas tidak mampu memproduksi insulin, atau tubuh tidak bisa menggunakan insulin dengan optimal. Akibatnya, sel-sel tubuh tidak dapat menyerap dan mengolah glukosa menjadi energi.\n\nGlukosa yang tidak diserap sel tubuh dengan baik akan menumpuk dalam darah dan menimbulkan berbagai gangguan kesehatan. Jika tidak ditangani dengan baik, diabetes dapat menimbulkan berbagai komplikasi.',
      'imageUrl': 'https://picsum.photos/400/200?random=1',
    },
    {
      'title': 'Pentingnya Olahraga Rutin Bagi Penderita Diabetes',
      'content':
      'Aktivitas fisik secara teratur dapat membantu meningkatkan sensitivitas insulin, sehingga sel-sel tubuh lebih mudah menggunakan glukosa dalam darah.\n\nJenis olahraga yang disarankan meliputi jalan cepat, bersepeda, berenang, dan senam aerobik ringan selama minimal 150 menit per minggu.',
      'imageUrl': 'https://picsum.photos/400/200?random=2',
    },
    {
      'title': 'Pola Makan Sehat Pencegah Diabetes Tipe 2',
      'content':
      'Mengatur pola makan dengan mengonsumsi makanan berindeks glikemik rendah seperti gandum, sayuran hijau, dan kacang-kacangan sangat efektif dalam menjaga kestabilan kadar gula darah.\n\nHindari konsumsi minuman manis kemasan dan kurangi karbohidrat olahan untuk mencegah risiko terkena diabetes tipe 2.',
      'imageUrl': 'https://picsum.photos/400/200?random=3',
    },
    {
      'title': 'Mengenal Pemeriksaan Kadar Gula Darah Rutin',
      'content':
      'Pemeriksaan gula darah secara mandiri maupun medis sangat penting dilakukan secara berkala. Hal ini membantu kita memantau pola lonjakan gula darah dan mengevaluasi efektivitas terapi atau diet harian yang sedang dijalankan.',
      'imageUrl': 'https://picsum.photos/400/200?random=4',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _pageController = PageController(
      initialPage: 1000,
      viewportFraction: 0.82,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _bukaHalamanProfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          namaUser: widget.namaUser,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildBerandaContent(),
      // PERBAIKAN DI SINI: Kirimkan fungsi onBackToHome agar tab kembali ke Beranda (index 0)
      SkriningPage(
        onBackToHome: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      KonsultasiPage(namaUser: widget.namaUser),
      const ArtikelPage(),
      ProfileScreen(namaUser: widget.namaUser),
    ];

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: pages[_selectedIndex],
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF6679F4),
            unselectedItemColor: const Color(0xFF6679F4).withValues(alpha: 0.4),
            showSelectedLabels: false,
            showUnselectedLabels: false,
            backgroundColor: Colors.white,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.stars_outlined),
                activeIcon: Icon(Icons.stars_rounded),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.help_outline),
                activeIcon: Icon(Icons.help),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.article_outlined),
                activeIcon: Icon(Icons.article),
                label: '',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBerandaContent() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. CURVED HEADER DENGAN GRADIENT
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 180,
                padding: const EdgeInsets.only(top: 50, left: 24, right: 24),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6679F4), Color(0xFF8DA0FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: _bukaHalamanProfil,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const CircleAvatar(
                              radius: 22,
                              backgroundColor: Color(0xFFFFE5D9),
                              child: Icon(Icons.person, color: Colors.orange, size: 28),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Halo, ${widget.namaUser} 👋',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const Text(
                                'Selamat Datang di Diora',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              // 2. HERO CARD (SKRINING GEJALA DIABETES)
              Positioned(
                top: 125,
                left: 20,
                right: 20,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 15,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFECEBFF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'FITUR UTAMA',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6679F4),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Skrining Gejala Diabetes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Cek potensi risiko kesehatanmu dalam beberapa langkah mudah.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6679F4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 100),

          // 3. QUICK ACTION LAUNCHER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Layanan & Menu',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildQuickActionItem(
                      icon: Icons.chat_outlined,
                      label: 'Konsultasi',
                      color: const Color(0xFFFF5252),
                      bgColor: const Color(0xFFFFEBEE),
                      onTap: () {
                        setState(() {
                          _selectedIndex = 2;
                        });
                      },
                    ),
                    _buildQuickActionItem(
                      icon: Icons.location_on_outlined,
                      label: 'Lokasi',
                      color: const Color(0xFF2E7D32),
                      bgColor: const Color(0xFFE8F5E9),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LokasiPage()),
                        );
                      },
                    ),
                    _buildQuickActionItem(
                      icon: Icons.article_outlined,
                      label: 'Artikel',
                      color: const Color(0xFF1976D2),
                      bgColor: const Color(0xFFE3F2FD),
                      onTap: () {
                        setState(() {
                          _selectedIndex = 3;
                        });
                      },
                    ),
                    _buildQuickActionItem(
                      icon: Icons.assignment_outlined,
                      label: 'Hasil Tes',
                      color: const Color(0xFFF57F17),
                      bgColor: const Color(0xFFFFF8E1),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const HasilSkriningPage()),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 4. STATS CARD (PROGRES KESEHATAN)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProgresKesehatanPage(username: widget.namaUser),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.show_chart_rounded, color: Color(0xFFE65100), size: 24),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progres Kesehatan',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pantau catatan dan tren grafik kesehatanmu.',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.black45),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // 5. ARTIKEL TERBARU
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Artikel Terbaru',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6679F4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          SizedBox(
            height: 190,
            child: PageView.builder(
              controller: _pageController,
              itemBuilder: (context, index) {
                final actualIndex = index % _daftarArtikel.length;
                final item = _daftarArtikel[actualIndex];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailArtikelPage(
                          title: item['title']!,
                          content: item['content']!,
                          imageUrl: item['imageUrl']!,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Image.network(
                            item['imageUrl']!,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 100,
                              color: const Color(0xFFE2E7FF),
                              child: const Icon(Icons.article_outlined, color: Color(0xFF6679F4), size: 30),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['content']!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
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

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}