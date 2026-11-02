import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'detail_klinik_page.dart';

class DaftarKlinikPage extends StatefulWidget {
  final bool isLocationGranted;

  const DaftarKlinikPage({super.key, this.isLocationGranted = true});

  @override
  State<DaftarKlinikPage> createState() => _DaftarKlinikPageState();
}

class _DaftarKlinikPageState extends State<DaftarKlinikPage> {
  final TextEditingController _searchController = TextEditingController();

  String _lokasiTerkini = 'Mendeteksi posisi GPS...';
  bool _isLoadingLocation = false;

  final List<Map<String, String>> _allKlinikList = const [
    {
      'nama': 'Jember Klinik (RS Perkebunan)',
      'alamat': 'Jl. Bedadung No.2, Jemberlor, Patrang',
      'jarak': '1.2 KM',
      'telp': '0331487104',
      'jam': '08.00 - 20.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Pratama Rolas Medika',
      'alamat': 'Jl. Gajah Mada No.15, Kaliwates',
      'jarak': '2.1 KM',
      'telp': '081234567890',
      'jam': '07.30 - 21.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Rawat Inap dr. M. Suherman',
      'alamat': 'Jl. Karimata No.49, Sumbersari',
      'jarak': '2.8 KM',
      'telp': '0331331234',
      'jam': 'Libur hari ini',
      'status': 'Tutup',
    },
    {
      'nama': 'Klinik Pratama Polres Jember',
      'alamat': 'Jl. Letjen S. Parman, Patrang',
      'jarak': '3.4 KM',
      'telp': '081122334455',
      'jam': '24 Jam',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Bina Sehat',
      'alamat': 'Jl. Jayanegara No.7, Kaliwates',
      'jarak': '4.1 KM',
      'telp': '085566778899',
      'jam': '08.00 - 17.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik dr. Ita Jember',
      'alamat': 'Jl. Mastrip No.22, Sumbersari',
      'jarak': '5.0 KM',
      'telp': '081233445566',
      'jam': '08.00 - 21.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Pratama Al-Qodiri',
      'alamat': 'Jl. Patangpuluhan, Gebang, Patrang',
      'jarak': '6.2 KM',
      'telp': '0331712345',
      'jam': '24 Jam',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Nurul Huda Rambipuji',
      'alamat': 'Jl. Rambipuji Utama No.10, Rambipuji',
      'jarak': '9.5 KM',
      'telp': '082233445566',
      'jam': '07.00 - 15.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Sehat Tanggul',
      'alamat': 'Jl. Raya Tanggul No.88, Tanggul Kulon',
      'jarak': '25.1 KM',
      'telp': '0331553344',
      'jam': '07.30 - 20.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Medika Ambulu',
      'alamat': 'Jl. Hos Cokroaminoto No.45, Ambulu',
      'jarak': '18.4 KM',
      'telp': '0331881122',
      'jam': '08.00 - 21.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Pratama Wuluhan Sehat',
      'alamat': 'Jl. Raya Wuluhan No.12, Wuluhan',
      'jarak': '21.0 KM',
      'telp': '0331883311',
      'jam': '08.00 - 17.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Puger Husada',
      'alamat': 'Jl. Puger Kidul No.5, Puger',
      'jarak': '24.5 KM',
      'telp': '0331884455',
      'jam': '24 Jam',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Bhakti Husada Jenggawah',
      'alamat': 'Jl. Jember - Ambulu, Jenggawah',
      'jarak': '14.0 KM',
      'telp': '0331998877',
      'jam': '08.00 - 16.00',
      'status': 'Tutup',
    },
    {
      'nama': 'Klinik Ajung Medika',
      'alamat': 'Jl. Mawar No.3, Ajung',
      'jarak': '8.2 KM',
      'telp': '0331776655',
      'jam': '08.00 - 20.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Semboro Sejahtera',
      'alamat': 'Jl. Raya Semboro No.14, Semboro',
      'jarak': '22.3 KM',
      'telp': '0331557788',
      'jam': '07.00 - 21.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Annisa Pakusari',
      'alamat': 'Jl. Raya Pakusari No.12, Pakusari',
      'jarak': '7.8 KM',
      'telp': '0331432111',
      'jam': '08.00 - 22.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Kalisat Sehat',
      'alamat': 'Jl. PB Sudirman No.18, Kalisat',
      'jarak': '15.2 KM',
      'telp': '0331541234',
      'jam': '08.00 - 19.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Pratama Ledokombo',
      'alamat': 'Jl. Sumber Lesung, Ledokombo',
      'jarak': '19.8 KM',
      'telp': '0331549988',
      'jam': '07.30 - 15.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Jelbuk Medika',
      'alamat': 'Jl. Raya Jelbuk No.9, Jelbuk',
      'jarak': '16.1 KM',
      'telp': '0331531122',
      'jam': '08.00 - 17.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Mayang Husada',
      'alamat': 'Jl. Raya Mayang No.45, Mayang',
      'jarak': '13.5 KM',
      'telp': '0331521144',
      'jam': '08.00 - 20.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Mumbulsari Sehat',
      'alamat': 'Jl. Mumbulsari No.7, Mumbulsari',
      'jarak': '12.0 KM',
      'telp': '0331523322',
      'jam': '08.00 - 16.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Parmita Tempurejo',
      'alamat': 'Jl. Tempurejo No.5, Tempurejo',
      'jarak': '16.5 KM',
      'telp': '0331665544',
      'jam': '07.00 - 14.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Silo Sejahtera',
      'alamat': 'Jl. Garahan Silo No.21, Silo',
      'jarak': '23.0 KM',
      'telp': '0331512233',
      'jam': '08.00 - 18.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Jombang Medika',
      'alamat': 'Jl. Raya Jombang No.33, Jombang',
      'jarak': '20.4 KM',
      'telp': '0331561122',
      'jam': '08.00 - 21.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Sumberbaru Sehat',
      'alamat': 'Jl. Pahlawan No.10, Sumberbaru',
      'jarak': '28.5 KM',
      'telp': '0331573344',
      'jam': '07.30 - 17.00',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Kencong Husada',
      'alamat': 'Jl. Diponegoro No.55, Kencong',
      'jarak': '30.2 KM',
      'telp': '0331581133',
      'jam': '24 Jam',
      'status': 'Buka',
    },
    {
      'nama': 'Klinik Gumukmas Sejahtera',
      'alamat': 'Jl. Tembokrejo No.4, Gumukmas',
      'jarak': '26.8 KM',
      'telp': '0331592211',
      'jam': '08.00 - 20.00',
      'status': 'Buka',
    },
  ];

  late List<Map<String, String>> _filteredKlinikList;

  @override
  void initState() {
    super.initState();
    _filteredKlinikList = List.from(_allKlinikList);
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _lokasiTerkini = 'GPS tidak aktif (Jember)';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _lokasiTerkini = 'Izin lokasi ditolak (Jember)';
            _isLoadingLocation = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _lokasiTerkini = 'Izin lokasi diblokir (Jember)';
          _isLoadingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        _lokasiTerkini =
        'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)} (Jember)';
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _lokasiTerkini = 'Kabupaten Jember, Jawa Timur';
        _isLoadingLocation = false;
      });
    }
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
                    const Text(
                      'Lokasi Klinik Jember',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Daftar faskes lengkap di seluruh kecamatan Jember',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: SizedBox(
                        height: 42,
                        child: TextField(
                          controller: _searchController,
                          onChanged: _filterKlinik,
                          style: const TextStyle(
                              fontSize: 13, color: Colors.black),
                          decoration: InputDecoration(
                            hintText:
                            'Cari Klinik / Kecamatan (cth: Ambulu, Tanggul)...',
                            hintStyle: const TextStyle(
                              fontSize: 12,
                              color: Colors.black38,
                              fontStyle: FontStyle.italic,
                            ),
                            prefixIcon: const Icon(Icons.search,
                                color: Color(0xFF5A75F6), size: 20),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 0, horizontal: 16),
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  color: Colors.black87, width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: const BorderSide(
                                  color: Color(0xFF5A75F6), width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      height: 150,
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF436058), Color(0xFF5A75F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 6,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -20,
                            bottom: -20,
                            child: Icon(
                              Icons.map_rounded,
                              size: 120,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.my_location,
                                        size: 16, color: Colors.white),
                                    SizedBox(width: 6),
                                    Text(
                                      'Posisi GPS Anda Saat Ini',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isLoadingLocation
                                      ? 'Mendeteksi koordinat GPS...'
                                      : _lokasiTerkini,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _getCurrentLocation,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF436058),
                                    minimumSize: const Size(130, 32),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 0),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    elevation: 0,
                                  ),
                                  icon: const Icon(Icons.refresh, size: 14),
                                  label: const Text(
                                    'Perbarui Posisi',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
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
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
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