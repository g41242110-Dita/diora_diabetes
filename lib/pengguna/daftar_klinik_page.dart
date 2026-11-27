import 'dart:ui' as ui;
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

  static const Color _primaryIndigo = Color(0xFF4F6DF5);
  static const Color _headerStart = Color(0xFF364FC7);
  static const Color _headerMid = Color(0xFF4C6EF5);
  static const Color _headerEnd = Color(0xFF6B84FF);
  static const Color _surfaceBg = Color(0xFFF5F7FC);
  static const Color _textDark = Color(0xFF0F172A);
  static const Color _textMuted = Color(0xFF64748B);

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

  double? _extractDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().trim());
  }

  LatLng? _extractClinicLatLng(Map<String, dynamic> data) {
    final double? lat = _extractDouble(data['latitude'] ?? data['lat']);
    final double? lng =
    _extractDouble(data['longitude'] ?? data['lng'] ?? data['lon']);
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  // Menghitung jarak asli (dalam KM) dari lokasi pengguna ke faskes
  double? _hitungJarakKm(Map<String, dynamic> data) {
    if (!widget.isLocationGranted) return null;
    final LatLng? clinicLatLng = _extractClinicLatLng(data);
    if (clinicLatLng == null) return null;

    final double meter = Geolocator.distanceBetween(
      _userLatLng.latitude,
      _userLatLng.longitude,
      clinicLatLng.latitude,
      clinicLatLng.longitude,
    );
    return meter / 1000.0;
  }

  String _formatJarak(double? jarakKm, Map<String, dynamic> data) {
    if (!widget.isLocationGranted) return 'Lokasi nonaktif';
    if (jarakKm != null) {
      return jarakKm < 1
          ? '${(jarakKm * 1000).round()} M'
          : '${jarakKm.toStringAsFixed(1)} KM';
    }
    return (data['jarak'] ?? '1.5 KM').toString();
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

  _CategoryStyle _categoryStyle(String kategori) {
    switch (kategori) {
      case 'Rumah Sakit':
        return const _CategoryStyle(
          accent: Color(0xFF2563EB),
          softBg: Color(0xFFDBEAFE),
          icon: Icons.apartment_rounded,
        );
      case 'Puskesmas':
        return const _CategoryStyle(
          accent: Color(0xFF0D9488),
          softBg: Color(0xFFCCFBF1),
          icon: Icons.health_and_safety_rounded,
        );
      case 'Klinik':
      default:
        return const _CategoryStyle(
          accent: Color(0xFF4F6DF5),
          softBg: Color(0xFFE0E7FF),
          icon: Icons.medical_services_rounded,
        );
    }
  }

  Widget _buildWaveHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top;

    return ClipPath(
      clipper: _CurvedHeaderClipper(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(12, topPadding + 10, 20, 34),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _headerStart,
              _headerMid,
              _headerEnd,
            ],
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'Lokasi Faskes Jember',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 48),
              ],
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 13,
                    color: Colors.white,
                  ),
                  SizedBox(width: 5),
                  Text(
                    'Peta Lokasi & Faskes Terdekat',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaskesArticleImage(
      Map<String, dynamic> data,
      String kategori,
      ) {
    final String? imageUrl = _extractImageUrl(data);
    final style = _categoryStyle(kategori);

    return Container(
      width: 94,
      height: 94,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: style.accent.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: imageUrl != null
            ? Image.network(
          imageUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return _fallbackCategoryBanner(
              kategori: kategori,
              style: style,
            );
          },
          errorBuilder: (_, __, ___) => _fallbackCategoryBanner(
            kategori: kategori,
            style: style,
          ),
        )
            : _fallbackCategoryBanner(
          kategori: kategori,
          style: style,
        ),
      ),
    );
  }

  Widget _fallbackCategoryBanner({
    required String kategori,
    required _CategoryStyle style,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            style.softBg,
            style.accent.withValues(alpha: 0.16),
          ],
        ),
        border: Border.all(
          color: style.accent.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              shape: BoxShape.circle,
            ),
            child: Icon(
              style.icon,
              size: 22,
              color: style.accent,
            ),
          ),
          const SizedBox(height: 5),
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
                color: style.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> _buildMapMarkers(List<_ClinicWithDistance> items) {
    final List<Marker> markers = [
      Marker(
        point: _userLatLng,
        width: 100,
        height: 68,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: _textDark,
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: const Text(
                'Posisi Anda',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
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
    ];

    for (final item in items) {
      final LatLng? point = _extractClinicLatLng(item.data);
      if (point == null) continue;
      final style = _categoryStyle(item.kategori);
      markers.add(
        Marker(
          point: point,
          width: 34,
          height: 34,
          child: GestureDetector(
            onTap: () => _mapController.move(point, 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: style.accent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                style.icon,
                size: 17,
                color: style.accent,
              ),
            ),
          ),
        ),
      );
    }

    return markers;
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
      backgroundColor: _surfaceBg,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('clinics').snapshots(),
        builder: (context, snapshot) {
          List<_ClinicWithDistance> processedItems = [];

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            for (final doc in snapshot.data!.docs) {
              final Map<String, dynamic> data =
              Map<String, dynamic>.from(doc.data() as Map<String, dynamic>);
              final String nama = (data['name'] ?? '').toString().toLowerCase();
              final String alamat =
              (data['address'] ?? '').toString().toLowerCase();
              final String kategori = _detectKategori(data);

              final bool matchCategory =
                  _selectedCategory == 'Semua' || kategori == _selectedCategory;
              final bool matchSearch = _searchQuery.isEmpty ||
                  nama.contains(_searchQuery) ||
                  alamat.contains(_searchQuery);

              if (matchCategory && matchSearch) {
                final double? jarakKm = _hitungJarakKm(data);
                processedItems.add(
                  _ClinicWithDistance(
                    data: data,
                    kategori: kategori,
                    jarakKm: jarakKm,
                    displayJarak: _formatJarak(jarakKm, data),
                  ),
                );
              }
            }

            // Urutkan dari jarak paling dekat ke paling jauh saat lokasi aktif
            if (widget.isLocationGranted) {
              processedItems.sort((a, b) {
                if (a.jarakKm == null && b.jarakKm == null) return 0;
                if (a.jarakKm == null) return 1;
                if (b.jarakKm == null) return -1;
                return a.jarakKm!.compareTo(b.jarakKm!);
              });
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              children: [
                // HEADER GRADIEN MELENGKUNG ATAS
                _buildWaveHeader(context),
                const SizedBox(height: 4),

                // Kolom pencarian modern
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value.trim().toLowerCase();
                        });
                      },
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: _textDark,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 11,
                          horizontal: 14,
                        ),
                        hintText: 'Cari nama faskes atau alamat...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.normal,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: _primaryIndigo,
                          size: 20,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: _textMuted,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                        )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide:
                          const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide:
                          const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(22),
                          borderSide: const BorderSide(
                            color: _primaryIndigo,
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
                        selectedColor: _primaryIndigo,
                        backgroundColor: Colors.white,
                        elevation: isSelected ? 2 : 0,
                        pressElevation: 0,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color:
                          isSelected ? Colors.white : const Color(0xFF334155),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                          side: BorderSide(
                            color: isSelected
                                ? _primaryIndigo
                                : const Color(0xFFE2E8F0),
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
                  height: 192,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(18),
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
                              markers: _buildMapMarkers(processedItems),
                            ),
                          ],
                        ),

                        // Badge mode akurasi di pojok kanan atas peta
                        if (widget.isLocationGranted)
                          Positioned(
                            top: 10,
                            right: 10,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFFE2E8F0),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: widget.isPrecise
                                          ? const Color(0xFF10B981)
                                          : _primaryIndigo,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.isPrecise ? 'Akurat' : 'Sekitar',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Info lokasi & koordinat di kiri bawah peta
                        Positioned(
                          left: 10,
                          bottom: 10,
                          right: 54,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.96),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFE2E8F0),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.my_location_rounded,
                                  size: 13,
                                  color: _primaryIndigo,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    _isLoadingLocation
                                        ? 'Mendeteksi lokasi...'
                                        : _koordinatDetail.isNotEmpty
                                        ? '$_lokasiTerkini ($_koordinatDetail)'
                                        : _lokasiTerkini,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: _textDark,
                                    ),
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
                            child: Material(
                              color: Colors.white,
                              shape: const CircleBorder(),
                              elevation: 3,
                              shadowColor: Colors.black.withValues(alpha: 0.16),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: _isLoadingLocation
                                    ? null
                                    : _getCurrentLocationAndSave,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: _isLoadingLocation
                                      ? const SizedBox(
                                    width: 17,
                                    height: 17,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _primaryIndigo,
                                    ),
                                  )
                                      : const Icon(
                                    Icons.gps_fixed_rounded,
                                    size: 18,
                                    color: _primaryIndigo,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // KONTEN DAFTAR FASKES DARI FIRESTORE
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(36.0),
                    child: CircularProgressIndicator(color: _primaryIndigo),
                  )
                else if (snapshot.hasError)
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(
                        'Terjadi kesalahan memuat data: ${snapshot.error}',
                        style: const TextStyle(
                          color: Color(0xFFDC2626),
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  )
                else if (!snapshot.hasData || snapshot.data!.docs.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text(
                        'Belum ada data faskes di database.',
                        style: TextStyle(color: _textMuted, fontSize: 13),
                      ),
                    )
                  else if (processedItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 36,
                              color: _textMuted.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _selectedCategory == 'Semua'
                                  ? 'Faskes tidak ditemukan.'
                                  : 'Belum ada data $_selectedCategory.',
                              style: const TextStyle(
                                color: _textMuted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: processedItems.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = processedItems[index];
                          final Map<String, dynamic> klinikData = item.data;

                          final String namaKlinik =
                              klinikData['name'] ?? 'Tanpa Nama';
                          final String alamatKlinik =
                              klinikData['address'] ?? 'Alamat tidak tersedia';
                          final String telpKlinik = klinikData['phone'] ?? '-';
                          final String jamOperasional =
                              klinikData['jam'] ?? '08.00 - 20.00';
                          final String statusBuka = klinikData['status'] ?? 'Buka';
                          final bool isTutup =
                              statusBuka.toLowerCase().trim() == 'tutup';
                          final String kategori = item.kategori;
                          final style = _categoryStyle(kategori);
                          final String displayJarak = item.displayJarak;

                          // Tandai faskes terdekat sebagai rekomendasi
                          final bool isRekomendasi = widget.isLocationGranted &&
                              item.jarakKm != null &&
                              index == 0;

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: isRekomendasi
                                    ? _primaryIndigo.withValues(alpha: 0.45)
                                    : const Color(0xFFE8EEF8),
                                width: isRekomendasi ? 1.3 : 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.045),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
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
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      _buildFaskesArticleImage(
                                        klinikData,
                                        kategori,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2.5,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: style.softBg,
                                                    borderRadius:
                                                    BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    kategori,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.w700,
                                                      color: style.accent,
                                                    ),
                                                  ),
                                                ),
                                                if (isRekomendasi) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 7,
                                                      vertical: 2.5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFECFDF5),
                                                      borderRadius:
                                                      BorderRadius.circular(8),
                                                    ),
                                                    child: const Text(
                                                      'Terdekat',
                                                      style: TextStyle(
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFF059669),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                                const Spacer(),
                                                Container(
                                                  padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 7,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: !widget.isLocationGranted
                                                        ? const Color(0xFFF1F5F9)
                                                        : const Color(0xFFEEF2FF),
                                                    borderRadius:
                                                    BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    displayJarak,
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      fontWeight: FontWeight.w700,
                                                      color: !widget.isLocationGranted
                                                          ? _textMuted
                                                          : _primaryIndigo,
                                                    ),
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
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                height: 1.25,
                                                color: _textDark,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              alamatKlinik,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11.5,
                                                height: 1.3,
                                                color: _textMuted,
                                              ),
                                            ),
                                            const SizedBox(height: 7),
                                            Row(
                                              children: [
                                                Icon(
                                                  Icons.schedule_rounded,
                                                  size: 13,
                                                  color: isTutup
                                                      ? const Color(0xFFDC2626)
                                                      : const Color(0xFF10B981),
                                                ),
                                                const SizedBox(width: 4),
                                                Flexible(
                                                  child: Text(
                                                    jamOperasional,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w600,
                                                      color: isTutup
                                                          ? const Color(0xFFDC2626)
                                                          : const Color(0xFF475569),
                                                    ),
                                                  ),
                                                ),
                                                if (isTutup) ...[
                                                  const SizedBox(width: 6),
                                                  Container(
                                                    padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 6,
                                                      vertical: 1.5,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xFFFEF2F2),
                                                      borderRadius:
                                                      BorderRadius.circular(6),
                                                    ),
                                                    child: const Text(
                                                      'Tutup',
                                                      style: TextStyle(
                                                        fontSize: 9.5,
                                                        fontWeight: FontWeight.w700,
                                                        color: Color(0xFFDC2626),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ClinicWithDistance {
  final Map<String, dynamic> data;
  final String kategori;
  final double? jarakKm;
  final String displayJarak;

  const _ClinicWithDistance({
    required this.data,
    required this.kategori,
    required this.jarakKm,
    required this.displayJarak,
  });
}

class _CurvedHeaderClipper extends CustomClipper<ui.Path> {
  @override
  ui.Path getClip(Size size) {
    final ui.Path path = ui.Path();
    path.lineTo(0, size.height - 22);

    path.quadraticBezierTo(
      size.width * 0.25,
      size.height - 34,
      size.width * 0.5,
      size.height - 16,
    );

    path.quadraticBezierTo(
      size.width * 0.78,
      size.height + 4,
      size.width,
      size.height - 18,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<ui.Path> oldClipper) => false;
}

class _CategoryStyle {
  final Color accent;
  final Color softBg;
  final IconData icon;

  const _CategoryStyle({
    required this.accent,
    required this.softBg,
    required this.icon,
  });
}