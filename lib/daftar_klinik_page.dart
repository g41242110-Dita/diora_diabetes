import 'package:flutter/material.dart';
import 'detail_klinik_page.dart';

// Import halaman navigasi bottom bar Anda
import 'beranda_page.dart';
import 'skrining_page.dart';
import 'konsultasi_page.dart';
import 'artikel_page.dart';
import 'profile_screen.dart';

class DaftarKlinikPage extends StatefulWidget {
  final bool isLocationGranted;

  const DaftarKlinikPage({super.key, this.isLocationGranted = true});

  @override
  State<DaftarKlinikPage> createState() => _DaftarKlinikPageState();
}

class _DaftarKlinikPageState extends State<DaftarKlinikPage> {
  final int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  // Data klinik sesuai dengan daftar di UI Figma
  final List<Map<String, String>> _allKlinikList = [
    {
      'nama': 'Klinik Sehat Sentosa',
      'alamat': 'Jl. Merdeka No. 15',
      'jarak': '1.2 KM',
      'telp': '081296738118',
    },
    {
      'nama': 'Pratama Medika',
      'alamat': 'Jl. Cempaka No. 28',
      'jarak': '2.1 KM',
      'telp': '081234567890',
    },
    {
      'nama': 'Klinik Harmoni',
      'alamat': 'Jl. Anggrek No. 7',
      'jarak': '2.8 KM',
      'telp': '089876543210',
    },
    {
      'nama': 'Sentra Kesehatan Utama',
      'alamat': 'Jl. Diponegoro No. 42',
      'jarak': '3.4 KM',
      'telp': '081122334455',
    },
    {
      'nama': 'Klinik Bina Sehat',
      'alamat': 'Jl. Sukajadi No. 19',
      'jarak': '4.1 KM',
      'telp': '085566778899',
    },
  ];

  List<Map<String, String>> _filteredKlinikList = [];

  @override
  void initState() {
    super.initState();
    _filteredKlinikList = List.from(_allKlinikList);
  }

  void _filterKlinik(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredKlinikList = List.from(_allKlinikList);
      } else {
        _filteredKlinikList = _allKlinikList.where((klinik) {
          final nama = klinik['nama']!.toLowerCase();
          final alamat = klinik['alamat']!.toLowerCase();
          final searchLower = query.toLowerCase();
          return nama.contains(searchLower) || alamat.contains(searchLower);
        }).toList();
      }
    });
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

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // 1. Judul & Subtitle
                    const Text(
                      'Lokasi Klinik',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Temukan klinik terdekat',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Search Bar (Cari Klinik atau Area . . .)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        height: 42,
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterKlinik,
                          style: const TextStyle(fontSize: 13, color: Colors.black),
                          decoration: InputDecoration(
                            hintText: 'Cari Klinik atau Area . . .',
                            hintStyle: const TextStyle(
                              fontSize: 13,
                              color: Colors.black38,
                              fontStyle: FontStyle.italic,
                            ),
                            prefixIcon: const Icon(Icons.search, color: Color(0xFF5A75F6), size: 20),
                            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Colors.black87, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(color: Color(0xFF5A75F6), width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 3. Peta Banner / Map Header
                    Container(
                      height: 130,
                      width: double.infinity,
                      color: const Color(0xFFE2E8F0),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=800',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(color: const Color(0xFFCBD5E1));
                              },
                            ),
                          ),
                          // Pin Lokasi Hijau di Peta
                          const Center(
                            child: Icon(
                              Icons.location_on,
                              size: 36,
                              color: Color(0xFF436058),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // 4. Daftar Item Klinik
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredKlinikList.length,
                      itemBuilder: (context, index) {
                        final klinik = _filteredKlinikList[index];

                        return Column(
                          children: [
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFD1D5DB),
                            ),
                            InkWell(
                              onTap: () {
                                // Pindah ke Detail Klinik
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DetailKlinikPage(
                                      namaKlinik: klinik['nama']!,
                                      alamatKlinik: klinik['alamat']!,
                                      jarakKlinik: widget.isLocationGranted
                                          ? klinik['jarak']!
                                          : 'Jarak tidak diketahui',
                                      nomorTelepon: klinik['telp']!,
                                    ),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0,
                                  vertical: 12.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Icon Avatar Bulat Teal
                                    Container(
                                      width: 42,
                                      height: 42,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF436058),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.map_outlined,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                    const SizedBox(width: 14),

                                    // Nama dan Alamat Klinik
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            klinik['nama']!,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Text(
                                            klinik['alamat']!,
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    // Jarak Klinik
                                    Text(
                                      widget.isLocationGranted
                                          ? klinik['jarak']!
                                          : 'N/A',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFD1D5DB),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Bottom Navigation Bar Sesuai Figma
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