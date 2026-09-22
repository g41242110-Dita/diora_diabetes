import 'package:flutter/material.dart';

// Import file halaman daftar klinik
import 'daftar_klinik_page.dart';

class LokasiPage extends StatefulWidget {
  const LokasiPage({super.key});

  @override
  State<LokasiPage> createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  bool _isPrecise = true; // State pilihan Lokasi Akurat vs Sekitar

  // Fungsi navigasi ke halaman Daftar Klinik setelah memilih izin
  void _navigateToDaftarKlinik(bool isGranted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DaftarKlinikPage(isLocationGranted: isGranted),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5A75F6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFC8E6C9), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 28),
                  const Icon(
                    Icons.location_on_outlined,
                    size: 38,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),

                  // Teks Deskripsi (Aplikasi Diora)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: 'Izinkan '),
                          TextSpan(
                            text: 'Diora',
                            style: TextStyle(
                              color: Color(0xFFE57373),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text:
                            ' mengakses lokasi kamu untuk menemukan klinik terdekat.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Pilihan Opsi Lokasi Akurat & Sekitar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Lokasi Akurat
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPrecise = true;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE8F0FE),
                                border: Border.all(
                                  color: _isPrecise
                                      ? const Color(0xFF3B82F6)
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 44,
                                  height: 44,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFD0E2FF),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF2563EB),
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Lokasi Akurat',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Lokasi Sekitar
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isPrecise = false;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFF7ED),
                                border: Border.all(
                                  color: !_isPrecise
                                      ? const Color(0xFF3B82F6)
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.map_outlined,
                                  color: Colors.orange,
                                  size: 40,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Lokasi Sekitar',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Tombol Opsi Izin
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                  _buildOptionButton(
                    text: 'Izinkan',
                    onTap: () => _navigateToDaftarKlinik(true),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                  _buildOptionButton(
                    text: 'Izinkan saat aplikasi digunakan',
                    onTap: () => _navigateToDaftarKlinik(true),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFE0E0E0)),
                  _buildOptionButton(
                    text: 'Jangan izinkan',
                    onTap: () => _navigateToDaftarKlinik(false),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      // Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF6679F4), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFF8FAFC),
          selectedItemColor: const Color(0xFF6679F4),
          unselectedItemColor: const Color(0xFF6679F4),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: '',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required String text,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}