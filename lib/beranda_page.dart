import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'konsultasi_page.dart';
import 'skrining_page.dart';
import 'lokasi_page.dart';
import 'progres_kesehatan_page.dart';
import 'artikel_page.dart';
import 'hasil_skrining_page.dart';

class BerandaPage extends StatefulWidget {
  final String namaUser;

  const BerandaPage({super.key, this.namaUser = 'Pian'});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  int _selectedIndex = 0;

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BANNER SALAM / GREETING
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
                        child: Icon(Icons.person, size: 40, color: Colors.orange),
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
                                style: TextStyle(fontSize: 13, color: Colors.black87),
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

              // GRID MENU UTAMA (2 KOLOM)
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SkriningPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'Konsultasi',
                    subtitle: 'Konsultasi dengan dokter untuk hasil yang lebih akurat.',
                    icon: Icons.help_outline,
                    bgColor: const Color(0xFFFFEBF0),
                    iconBgColor: const Color(0xFFFFC2D1),
                    iconColor: const Color(0xFFE53E3E),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const KonsultasiPage(),
                        ),
                      );
                    },
                  ),
                  _buildMenuCard(
                    title: 'Lokasi Terdekat',
                    subtitle: 'Temukan fasyankes terdekat yang menyediakan layanan diabetes.',
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
                    subtitle: 'Baca informasi seputar diabetes, gaya hidup sehat, & pencegahannya.',
                    icon: Icons.article_outlined,
                    bgColor: const Color(0xFFE3F2FD),
                    iconBgColor: const Color(0xFFBBDEFB),
                    iconColor: const Color(0xFF1976D2),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ArtikelPage(),
                        ),
                      );
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
                          builder: (context) => const HasilSkriningPage(), // <--- Ganti jadi HasilSkriningPage()
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
                          builder: (context) => const ProgresKesehatanPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // SEKSI ARTIKEL TERBARU
              const Text(
                'Artikel Terbaru',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),

              // CARD ARTIKEL
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
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
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.medical_services, color: Colors.blue),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Diabetes - Gejala, Penyebab, dan Pengobatan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Diabetes adalah penyakit kronis yang ditandai dengan tingginya kadar gula di dalam darah. Glukosa atau gula adalah sumber energi utama bagi ...',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black54,
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
            ],
          ),
        ),
      ),

      // BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF6679F4), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });

            if (index == 4) {
              _bukaHalamanProfil();
            }
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF6679F4),
          unselectedItemColor: Colors.blue.shade200,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.stars_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
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
              child: Icon(icon, size: 18, color: iconColor),
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