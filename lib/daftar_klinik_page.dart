import 'package:flutter/material.dart';
import 'detail_klinik_page.dart';

class DaftarKlinikPage extends StatefulWidget {
  final bool isLocationGranted;

  const DaftarKlinikPage({super.key, this.isLocationGranted = true});

  @override
  State<DaftarKlinikPage> createState() => _DaftarKlinikPageState();
}

class _DaftarKlinikPageState extends State<DaftarKlinikPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _allKlinikList = [
    {
      'nama': 'Klinik Sehat Sentosa',
      'alamat': 'Jl. Merdeka No. 15',
      'jarak': '1.2 KM',
      'telp': '081296738118',
      'jam': '08.00 - 20.00',
      'status': 'Buka',
    },
    {
      'nama': 'Pratama Medika',
      'alamat': 'Jl. Cempaka No. 28',
      'jarak': '2.1 KM',
      'telp': '081234567890',
      'jam': '07.30 - 21.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Harmoni',
      'alamat': 'Jl. Anggrek No. 7',
      'jarak': '2.8 KM',
      'telp': '089876543210',
      'jam': 'Libur hari ini',
      'status': 'Tutup',
    },
    {
      'nama': 'Sentra Kesehatan Utama',
      'alamat': 'Jl. Diponegoro No. 42',
      'jarak': '3.4 KM',
      'telp': '081122334455',
      'jam': '24 Jam',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Bina Sehat',
      'alamat': 'Jl. Sukajadi No. 19',
      'jarak': '4.1 KM',
      'telp': '085566778899',
      'jam': '08.00 - 17.00',
      'status': 'Buka',
    },
  ];

  List<Map<String, String>> _filteredKlinikList = [];

  @override
  void initState() {
    super.initState();
    _filteredKlinikList = List.from(_allKlinikList);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
                    // Header
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

                    // Search Bar
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

                    // TAMPILAN PETA GMAPS
                    Container(
                      height: 160,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5E3DF),
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1000',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: const Color(0xFFE5E3DF),
                                  child: const Center(
                                    child: Icon(Icons.map, size: 40, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              color: Colors.black.withValues(alpha: 0.05),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.my_location, size: 12, color: Color(0xFF1A73E8)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Lokasi Anda',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Icon(
                                  Icons.location_on,
                                  size: 38,
                                  color: Color(0xFFEA4335),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: 10,
                            right: 12,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  )
                                ],
                              ),
                              child: const Icon(
                                Icons.my_location,
                                color: Color(0xFF1A73E8),
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // LIST KLINIK DENGAN JAM OPERASIONAL RATA KANAN
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredKlinikList.length,
                      itemBuilder: (context, index) {
                        final klinik = _filteredKlinikList[index];
                        final isTutup = klinik['status'] == 'Tutup';

                        return Column(
                          children: [
                            const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFD1D5DB),
                            ),
                            InkWell(
                              onTap: () {
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
                                    // Icon Klinik
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
                                    const SizedBox(width: 12),

                                    // Detail Informasi Klinik (Kiri)
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
                                    const SizedBox(width: 8),

                                    // Info Jarak & Jam Pelayanan (Kanan, Tidak Mentok Tepi)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          widget.isLocationGranted
                                              ? klinik['jarak']!
                                              : 'N/A',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          klinik['jam']!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: isTutup
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: isTutup
                                                ? Colors.red.shade700
                                                : Colors.black54,
                                          ),
                                        ),
                                      ],
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
    );
  }
}