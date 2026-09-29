import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Import file halaman navigasi bottom bar Anda
import 'beranda_page.dart';
import 'skrining_page.dart';
import 'konsultasi_page.dart';
import 'artikel_page.dart';
import 'profile_screen.dart';

class DetailKlinikPage extends StatefulWidget {
  final String namaKlinik;
  final String alamatKlinik;
  final String jarakKlinik;
  final String nomorTelepon;

  const DetailKlinikPage({
    super.key,
    required this.namaKlinik,
    required this.alamatKlinik,
    required this.jarakKlinik,
    this.nomorTelepon = '081296738118',
  });

  @override
  State<DetailKlinikPage> createState() => _DetailKlinikPageState();
}

class _DetailKlinikPageState extends State<DetailKlinikPage> {
  final int _selectedIndex = 0;

  final List<Map<String, String>> _dokterList = [
    {
      'nama': 'dr. Muhammad Iqbal, Sp. DV',
      'spesialis': 'Dokter Spesialis Penyakit Dalam',
    },
    {
      'nama': 'dr. Putri Amelia, Sp. DV',
      'spesialis': 'Dokter Spesialis Penyakit Dalam',
    },
    {
      'nama': 'dr. Jessica Nathania, Sp. DV',
      'spesialis': 'Dokter Spesialis Penyakit Dalam',
    },
  ];

  Future<void> _openGoogleMaps() async {
    final String query = Uri.encodeComponent('${widget.namaKlinik}, ${widget.alamatKlinik}');
    final Uri googleMapsUrl = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');

    try {
      bool launched = await launchUrl(
        googleMapsUrl,
        mode: LaunchMode.externalApplication,
      );

      if (!launched) {
        launched = await launchUrl(googleMapsUrl, mode: LaunchMode.platformDefault);
      }

      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka Google Maps')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _openDialer() async {
    final String cleanPhone = widget.nomorTelepon.replaceAll(RegExp(r'[^\d+]'), '');
    final Uri phoneUrl = Uri(scheme: 'tel', path: cleanPhone);

    try {
      bool launched = await launchUrl(phoneUrl);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal membuka aplikasi Telepon')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _onBottomNavTapped(int index) {
    if (index == _selectedIndex) return;

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const BerandaPage();
        break;
      case 1:
        targetPage = const SkriningPage();
        break;
      case 2:
        targetPage = const KonsultasiPage();
        break;
      case 3:
        targetPage = const ArtikelPage();
        break;
      case 4:
        targetPage = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 45,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5A75F6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.black87, width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Nama Klinik
                Text(
                  widget.namaKlinik,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),

                // Foto Klinik
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 165,
                    width: double.infinity,
                    color: const Color(0xFFE2E8F0),
                    child: Image.network(
                      'https://images.unsplash.com/photo-1629909613654-28e377c37b09?q=80&w=800',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Center(
                          child: Icon(Icons.business_rounded, size: 48, color: Colors.grey),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Jarak Klinik
                Text(
                  '${widget.jarakKlinik} dari lokasi Anda',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 14),

                // Tombol Rute & Telp
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 125,
                      height: 38,
                      child: ElevatedButton.icon(
                        onPressed: _openGoogleMaps,
                        icon: const Icon(Icons.near_me_outlined, size: 16, color: Colors.white),
                        label: const Text(
                          'Rute',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF436058),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    SizedBox(
                      width: 125,
                      height: 38,
                      child: OutlinedButton.icon(
                        onPressed: _openDialer,
                        icon: const Icon(Icons.call_outlined, size: 16, color: Colors.black87),
                        label: const Text(
                          'Telp',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFEEEEEE),
                          side: const BorderSide(color: Colors.black87, width: 1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Alamat
                const Divider(height: 1, thickness: 1, color: Color(0xFFB0BEC5)),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Alamat',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    widget.alamatKlinik,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Jam Pelayanan (Teks Libur Rata Kiri Sejajar Jam)
                const Divider(height: 1, thickness: 1, color: Color(0xFFB0BEC5)),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Jam Pelayanan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Row(
                  children: [
                    SizedBox(
                      width: 130,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Senin - Kamis', style: TextStyle(fontSize: 12, color: Colors.black87)),
                          SizedBox(height: 4),
                          Text('Jumat - Sabtu', style: TextStyle(fontSize: 12, color: Colors.black87)),
                          SizedBox(height: 4),
                          Text('Minggu', style: TextStyle(fontSize: 12, color: Colors.black87)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('08.00 - 14.00 WIB', style: TextStyle(fontSize: 12, color: Colors.black87)),
                          SizedBox(height: 4),
                          Text('07.00 - 13.00 WIB', style: TextStyle(fontSize: 12, color: Colors.black87)),
                          SizedBox(height: 4),
                          Text('Libur', style: TextStyle(fontSize: 12, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Dokter Tersedia
                const Divider(height: 1, thickness: 1, color: Color(0xFFB0BEC5)),
                const SizedBox(height: 12),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Dokter Tersedia',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _dokterList.length,
                  itemBuilder: (context, index) {
                    final dokter = _dokterList[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFE8D6),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Color(0xFFC07A50),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                dokter['nama']!,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                dokter['spesialis']!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
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
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color(0xFFF8FAFC),
          selectedItemColor: const Color(0xFF6679F4),
          unselectedItemColor: const Color(0xFF6679F4),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onBottomNavTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              label: 'Skrining',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              label: 'Konsultasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.article_outlined),
              label: 'Artikel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}