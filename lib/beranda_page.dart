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

  // 1. DAFTAR 4 ARTIKEL TERBARU
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

    // Set posisi awal slider di tengah-tengah angka besar (1000) agar bisa di-swipe ke kiri maupun ke kanan tanpa batas
    _pageController = PageController(
      initialPage: 1000,
      viewportFraction: 0.95,
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
      const SkriningPage(),
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
        backgroundColor: Colors.white,
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
            unselectedItemColor: const Color(0xFF6679F4).withOpacity(0.4),
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
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BANNER GREETING / PROFIL
            GestureDetector(
              onTap: _bukaHalamanProfil,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E7FF),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFFFE5D9),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Halo, ${widget.namaUser}!',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(text: 'Selamat Datang di '),
                                TextSpan(
                                  text: 'Diora 👋',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF6679F4),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // GRID MENU UTAMA
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
              children: [
                _buildMenuCard(
                  title: 'Skrining\nGejala Diabetes',
                  subtitle: 'Cek risiko diabetes sejak dini dengan mudah',
                  icon: Icons.stars,
                  bgColor: const Color(0xFFECEBFF),
                  iconBgColor: const Color(0xFFC7C2FF),
                  iconColor: const Color(0xFF6679F4),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                ),
                _buildMenuCard(
                  title: 'Konsultasi',
                  subtitle:
                  'Konsultasi dengan dokter untuk hasil yang lebih akurat.',
                  icon: Icons.help_outline,
                  bgColor: const Color(0xFFFFEBF0),
                  iconBgColor: const Color(0xFFFFC2D1),
                  iconColor: const Color(0xFFE53E3E),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                ),
                _buildMenuCard(
                  title: 'Lokasi Terdekat',
                  subtitle:
                  'Temukan fasyankes terdekat yang menyediakan layanan diabetes.',
                  icon: Icons.location_on_outlined,
                  bgColor: const Color(0xFFE6F4EA),
                  iconBgColor: const Color(0xFFA8E0BA),
                  iconColor: const Color(0xFF2E7D32),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LokasiPage(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  title: 'Artikel',
                  subtitle:
                  'Baca informasi seputar diabetes, gaya hidup sehat, & pencegahannya.',
                  icon: Icons.article_outlined,
                  bgColor: const Color(0xFFE3F2FD),
                  iconBgColor: const Color(0xFFBBDEFB),
                  iconColor: const Color(0xFF1976D2),
                  onTap: () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                  },
                ),
                _buildMenuCard(
                  title: 'Hasil Tes',
                  subtitle: 'Lihat rekomendasi dan unduh hasil tes skriningmu.',
                  icon: Icons.insert_drive_file_outlined,
                  bgColor: const Color(0xFFFFE8E1),
                  iconBgColor: const Color(0xFFFFE082),
                  iconColor: const Color(0xFFF57F17),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HasilSkriningPage(),
                      ),
                    );
                  },
                ),
                _buildMenuCard(
                  title: 'Progres\nKesehatan',
                  subtitle: 'Pantau kesehatan dan risiko diabetesmu',
                  icon: Icons.show_chart,
                  bgColor: const Color(0xFFFBE9E7),
                  iconBgColor: const Color(0xFFFFCCBC),
                  iconColor: const Color(0xFFD84315),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProgresKesehatanPage(
                          username: widget.namaUser,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // JUDUL ARTIKEL TERBARU
            const Text(
              'Artikel Terbaru',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 10),

            // SLIDER INFINITE LOOP (BISA DIGESER TANPA BATAS)
            SizedBox(
              height: 110,
              child: PageView.builder(
                controller: _pageController,
                itemBuilder: (context, index) {
                  // Trik Modulo: Mengulang urutan index 0, 1, 2, 3 secara berputar tanpa henti
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
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: 70,
                              height: 70,
                              color: const Color(0xFFE2E7FF),
                              child: const Icon(
                                Icons.medical_services_outlined,
                                color: Color(0xFF6679F4),
                                size: 32,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['title']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
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
                                  maxLines: 2,
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
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color bgColor,
    required Color iconBgColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 8,
                      color: Colors.black54,
                      height: 1.1,
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