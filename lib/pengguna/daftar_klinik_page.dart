import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'detail_klinik_page.dart';

class DaftarKlinikPage extends StatefulWidget {
  final bool isLocationGranted;
  final bool isPrecise; // true = Akurat, false = Sekitar

  const DaftarKlinikPage({
    super.key,
    this.isLocationGranted = true,
    this.isPrecise = true,
  });

  @override
  State<DaftarKlinikPage> createState() => _DaftarKlinikPageState();
}

class _DaftarKlinikPageState extends State<DaftarKlinikPage> {
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  // Koordinat default awal: Pusat Kabupaten Jember
  LatLng _userLatLng = const LatLng(-8.1724, 113.7007);

  String _lokasiTerkini = 'Mendeteksi posisi...';
  String _koordinatDetail = '';
  bool _isLoadingLocation = false;
  String _searchQuery = '';

  String _selectedCategory = 'Semua';
  final List<String> _categories = const [
    'Semua',
    'Rumah Sakit',
    'Puskesmas',
    'Klinik',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isLocationGranted) {
      _getCurrentLocationAndSave();
    } else {
      _lokasiTerkini = 'Akses lokasi tidak diizinkan';
    }
  }

  Future<void> _getCurrentLocationAndSave() async {
    if (!mounted) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _lokasiTerkini = 'GPS tidak aktif';
          _koordinatDetail = '';
          _isLoadingLocation = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _lokasiTerkini = 'Izin lokasi ditolak';
          _koordinatDetail = '';
          _isLoadingLocation = false;
        });
        return;
      }

      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      try {
        final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;
        if (currentUserId != null) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .update({
            'latitude': position.latitude,
            'longitude': position.longitude,
            'lokasi_akurat': widget.isPrecise,
            'last_location_updated': FieldValue.serverTimestamp(),
          });
        }
      } catch (dbError) {
        debugPrint("Gagal memperbarui lokasi user ke database: $dbError");
      }

      if (!mounted) return;

      final LatLng posisiBaru = LatLng(position.latitude, position.longitude);

      setState(() {
        _userLatLng = posisiBaru;
        _lokasiTerkini = 'Kabupaten Jember, Jawa Timur';
        _koordinatDetail =
        '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
        _isLoadingLocation = false;
      });

      _mapController.move(posisiBaru, widget.isPrecise ? 16.0 : 14.0);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _lokasiTerkini = 'Kabupaten Jember, Jawa Timur';
        _koordinatDetail = '';
        _isLoadingLocation = false;
      });
    }
  }

  String _detectKategori(Map<String, dynamic> data) {
    final String rawCategory =
    (data['category'] ?? data['type'] ?? '').toString().toLowerCase().trim();
    final String nama = (data['name'] ?? '').toString().toLowerCase().trim();

    if (rawCategory.contains('rumah sakit') || rawCategory == 'rs') {
      return 'Rumah Sakit';
    }
    if (rawCategory.contains('puskesmas')) {
      return 'Puskesmas';
    }
    if (rawCategory.contains('klinik')) {
      return 'Klinik';
    }

    if (nama.startsWith('rs ') ||
        nama.startsWith('rsud ') ||
        nama.contains('rumah sakit') ||
        nama.contains('siloam')) {
      return 'Rumah Sakit';
    }
    if (nama.startsWith('puskesmas')) {
      return 'Puskesmas';
    }
    return 'Klinik';
  }

  // Ambil URL gambar faskes dari Firestore bila tersedia
  String? _extractImageUrl(Map<String, dynamic> data) {
    final String rawUrl = (data['imageUrl'] ??
        data['photoUrl'] ??
        data['image'] ??
        data['foto'] ??
        '')
        .toString()
        .trim();
    if (rawUrl.startsWith('http://') || rawUrl.startsWith('https://')) {
      return rawUrl;
    }
    return null;
  }

  // Visual kartu gambar per kategori (Rumah Sakit / Puskesmas / Klinik)
  Widget _buildFaskesArticleImage(
      Map<String, dynamic> data,
      String kategori,
      ) {
    final String? imageUrl = _extractImageUrl(data);

    // Warna & ikon pembeda per kategori faskes
    Color accentColor = const Color(0xFF4F6DF5);
    Color bgSoft = const Color(0xFFEEF2FF);
    IconData categoryIcon = Icons.local_hospital_rounded;

    if (kategori == 'Rumah Sakit') {
      accentColor = const Color(0xFF2563EB);
      bgSoft = const Color(0xFFDBEAFE);
      categoryIcon = Icons.apartment_rounded;
    } else if (kategori == 'Puskesmas') {
      accentColor = const Color(0xFF0D9488);
      bgSoft = const Color(0xFFCCFBF1);
      categoryIcon = Icons.health_and_safety_rounded;
    } else if (kategori == 'Klinik') {
      accentColor = const Color(0xFF6366F1);
      bgSoft = const Color(0xFFE0E7FF);
      categoryIcon = Icons.medical_services_rounded;
    }

    return SizedBox(
      width: 96,
      height: 92,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: imageUrl != null
            ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackCategoryBanner(
            kategori: kategori,
            accentColor: accentColor,
            bgSoft: bgSoft,
            categoryIcon: categoryIcon,
          ),
        )
            : _fallbackCategoryBanner(
          kategori: kategori,
          accentColor: accentColor,
          bgSoft: bgSoft,
          categoryIcon: categoryIcon,
        ),
      ),
    );
  }

  Widget _fallbackCategoryBanner({
    required String kategori,
    required Color accentColor,
    required Color bgSoft,
    required IconData categoryIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            bgSoft,
            accentColor.withValues(alpha: 0.18),
          ],
        ),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            categoryIcon,
            size: 30,
            color: accentColor,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              kategori,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: accentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 45,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF5A75F6),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              // Judul halaman
              const Text(
                'Lokasi Faskes Jember',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),

              // Badge status lokasi
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'Peta Lokasi & Faskes Terdekat',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF6679F4),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Kolom pencarian
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 42,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value.trim().toLowerCase();
                      });
                    },
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Cari Faskes / Alamat...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF5A75F6),
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Colors.black87,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: const BorderSide(
                          color: Color(0xFF5A75F6),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Filter Kategori: Semua | Rumah Sakit | Puskesmas | Klinik
              SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: _categories.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final category = _categories[index];
                    final bool isSelected = _selectedCategory == category;

                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                      selectedColor: const Color(0xFF5A75F6),
                      backgroundColor: Colors.white,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                        isSelected ? Colors.white : const Color(0xFF334155),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(
                          color: isSelected
                              ? const Color(0xFF5A75F6)
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                      showCheckmark: false,
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),

              // PETA OPENSTREETMAP
              Container(
                height: 185,
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _userLatLng,
                          initialZoom: 15.0,
                          maxZoom: 19.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.diora_diabetes',
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _userLatLng,
                                width: 92,
                                height: 65,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF0F172A),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Posisi Anda',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    const Icon(
                                      Icons.location_pin,
                                      color: Color(0xFFEF4444),
                                      size: 36,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      // Info lokasi & koordinat di kiri bawah peta
                      Positioned(
                        left: 10,
                        bottom: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.94),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.my_location,
                                size: 13,
                                color: Color(0xFF5A75F6),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _isLoadingLocation
                                    ? 'Mendeteksi...'
                                    : _koordinatDetail.isNotEmpty
                                    ? '$_lokasiTerkini ($_koordinatDetail)'
                                    : _lokasiTerkini,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Tombol refresh posisi GPS
                      if (widget.isLocationGranted)
                        Positioned(
                          right: 10,
                          bottom: 10,
                          child: InkWell(
                            onTap: _getCurrentLocationAndSave,
                            child: Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.15),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.gps_fixed_rounded,
                                size: 18,
                                color: Color(0xFF5A75F6),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // STREAM BUILDER DATA FASKES DARI FIRESTORE (TAMPILAN KARTU ARTIKEL)
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('clinics')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(30.0),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        'Terjadi kesalahan memuat data: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(30.0),
                      child: Text(
                        'Belum ada data faskes di database.',
                        style: TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final nama = (data['name'] ?? '').toString().toLowerCase();
                    final alamat =
                    (data['address'] ?? '').toString().toLowerCase();
                    final kategori = _detectKategori(data);

                    final bool matchCategory = _selectedCategory == 'Semua' ||
                        kategori == _selectedCategory;

                    final bool matchSearch = _searchQuery.isEmpty ||
                        nama.contains(_searchQuery) ||
                        alamat.contains(_searchQuery);

                    return matchCategory && matchSearch;
                  }).toList();

                  if (docs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(30.0),
                      child: Text(
                        _selectedCategory == 'Semua'
                            ? 'Faskes tidak ditemukan.'
                            : 'Belum ada data $_selectedCategory.',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final klinikData =
                      docs[index].data() as Map<String, dynamic>;

                      final String namaKlinik =
                          klinikData['name'] ?? 'Tanpa Nama';
                      final String alamatKlinik =
                          klinikData['address'] ?? 'Alamat tidak tersedia';
                      final String telpKlinik = klinikData['phone'] ?? '-';
                      final String jamOperasional =
                          klinikData['jam'] ?? '08.00 - 20.00';
                      final String statusBuka =
                          klinikData['status'] ?? 'Buka';
                      final bool isTutup = statusBuka == 'Tutup';
                      final String kategori = _detectKategori(klinikData);

                      final String displayJarak = !widget.isLocationGranted
                          ? 'Lokasi tidak aktif'
                          : (klinikData['jarak'] ?? '1.5 KM');

                      return Material(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        elevation: 2,
                        shadowColor: Colors.black.withValues(alpha: 0.06),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailKlinikPage(
                                  namaKlinik: namaKlinik,
                                  alamatKlinik: alamatKlinik,
                                  jarakKlinik: displayJarak,
                                  nomorTelepon: telpKlinik,
                                ),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Gambar faskes bergaya kartu artikel
                                _buildFaskesArticleImage(
                                  klinikData,
                                  kategori,
                                ),
                                const SizedBox(width: 12),

                                // Konten artikel faskes
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEEF2FF),
                                              borderRadius:
                                              BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              kategori,
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w700,
                                                color: Color(0xFF5A75F6),
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            displayJarak,
                                            style: TextStyle(
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.bold,
                                              color: !widget.isLocationGranted
                                                  ? Colors.grey
                                                  : const Color(0xFF0F172A),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        namaKlinik,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        alamatKlinik,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.schedule_rounded,
                                            size: 13,
                                            color: isTutup
                                                ? Colors.red.shade700
                                                : Colors.black54,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            jamOperasional,
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
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}