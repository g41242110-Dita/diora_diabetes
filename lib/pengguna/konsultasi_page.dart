import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_model.dart';
import 'detail_dokter_page.dart';

class KonsultasiPage extends StatefulWidget {
  final String namaUser;

  const KonsultasiPage({super.key, this.namaUser = 'Pengguna'});

  @override
  State<KonsultasiPage> createState() => _KonsultasiPageState();
}

class _KonsultasiPageState extends State<KonsultasiPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final Set<String> _favoriteDoctorIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatShiftText(Doctor doctor) {
    if (!doctor.isShiftActiveToday ||
        (doctor.jamMulai == 0 && doctor.jamSelesai == 0)) {
      return 'Libur / Jadwal Tutup';
    }

    final start = doctor.jamMulai.toString().padLeft(2, '0');
    final end = doctor.jamSelesai.toString().padLeft(2, '0');
    final namaShift = doctor.namaShiftHariIni.trim().isNotEmpty
        ? doctor.namaShiftHariIni.trim()
        : 'Jadwal Praktik';

    return '$namaShift ($start.00-$end.00)';
  }

  String? _extractPhotoUrl(Map<String, dynamic>? rawData) {
    if (rawData == null) return null;
    for (final key in ['fotoUrl', 'photoUrl', 'foto_url', 'avatarUrl', 'foto']) {
      final value = rawData[key];
      if (value != null) {
        final str = value.toString().trim();
        if (str.startsWith('http://') || str.startsWith('https://')) {
          return str;
        }
      }
    }
    return null;
  }

  String _formatRating(dynamic ratingValue) {
    if (ratingValue == null) return '4.8';
    if (ratingValue is num) return ratingValue.toStringAsFixed(1);
    final parsed = double.tryParse(ratingValue.toString());
    return parsed != null ? parsed.toStringAsFixed(1) : ratingValue.toString();
  }

  IconData _spesialisIcon(String spesialis) {
    final lower = spesialis.toLowerCase();
    if (lower.contains('jantung') || lower.contains('cardio')) {
      return Icons.favorite_rounded;
    }
    if (lower.contains('anak') || lower.contains('pedia')) {
      return Icons.child_care_rounded;
    }
    if (lower.contains('saraf') || lower.contains('neuro')) {
      return Icons.psychology_rounded;
    }
    if (lower.contains('gizi')) {
      return Icons.restaurant_menu_rounded;
    }
    if (lower.contains('dalam')) {
      return Icons.medical_information_rounded;
    }
    return Icons.medical_services_rounded;
  }

  Widget _buildDoctorPhoto(String? fotoUrl) {
    final bool hasPhoto = fotoUrl != null && fotoUrl.isNotEmpty;

    if (!hasPhoto) {
      return Container(
        color: const Color(0xFFEEF2FF),
        child: const Center(
          child: Icon(
            Icons.person_rounded,
            size: 64,
            color: Color(0xFF4F46E5),
          ),
        ),
      );
    }

    return Image.network(
      fotoUrl,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: const Color(0xFFEEF2FF),
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: Color(0xFF5B4AF4),
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFEEF2FF),
          child: const Center(
            child: Icon(
              Icons.person_rounded,
              size: 64,
              color: Color(0xFF4F46E5),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF1F6FC),
      body: Column(
        children: [
          // HEADER GRADIENT DENGAN EFEK LIQUID/WAVE
          ClipPath(
            clipper: LiquidHeaderClipper(),
            child: Container(
              padding: EdgeInsets.fromLTRB(16, topPadding, 16, 52),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3B0066),
                    Color(0xFF5B4AF4),
                    Color(0xFF388BFF),
                  ],
                  stops: [0.0, 0.5, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 36,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.maybePop(context),
                          ),
                        ),
                        const Text(
                          'Konsultasi',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // SEARCH BAR
                  Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(21),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000000).withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: const Color(0xFF5B4AF4).withValues(alpha: 0.08),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.trim().toLowerCase();
                        });
                      },
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Cari Dokter atau Spesialis ...',
                        hintStyle: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF94A3B8),
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          size: 19,
                          color: Color(0xFF5B4AF4),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 38,
                          minHeight: 42,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          icon: const Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 11,
                          horizontal: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // GRID DOKTER REAL-TIME DARI FIREBASE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
              FirebaseFirestore.instance.collection('doctors').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF5B4AF4)),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada data dokter di Firestore.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                  );
                }

                final rawDocs = snapshot.data!.docs;
                final List<_DoctorGridItem> items = rawDocs.map((doc) {
                  final map = doc.data() as Map<String, dynamic>;
                  return _DoctorGridItem(
                    doctor: Doctor.fromFirestore(map, doc.id),
                    fotoUrl: _extractPhotoUrl(map),
                  );
                }).toList();

                items.sort((a, b) {
                  if (a.doctor.isShiftActiveToday ==
                      b.doctor.isShiftActiveToday) {
                    return a.doctor.id.compareTo(b.doctor.id);
                  }
                  return a.doctor.isShiftActiveToday ? -1 : 1;
                });

                final filteredItems = _searchQuery.isEmpty
                    ? items
                    : items.where((item) {
                  final nama = item.doctor.nama.toLowerCase();
                  final spesialis = item.doctor.spesialis.toLowerCase();
                  return nama.contains(_searchQuery) ||
                      spesialis.contains(_searchQuery);
                }).toList();

                if (filteredItems.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 42,
                            color: const Color(0xFF94A3B8).withValues(alpha: 0.7),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Dokter atau spesialis "$_searchQuery" tidak ditemukan.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.72,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    final doctor = item.doctor;
                    final bool isOnline = doctor.isShiftActiveToday;
                    final bool isBusy = doctor.isBusyInChat;
                    final bool isFav = _favoriteDoctorIds.contains(doctor.id);
                    final String shiftText = _formatShiftText(doctor);

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A)
                                .withValues(alpha: 0.06),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailDokterPage(
                                  doctor: doctor,
                                  namaUser: widget.namaUser,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            children: [
                              // AREA FOTO DOKTER (ATAS)
                              Expanded(
                                flex: 62,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      8, 8, 8, 0),
                                  child: Stack(
                                    children: [
                                      Positioned.fill(
                                        child: ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(16),
                                          child: _buildDoctorPhoto(item.fotoUrl),
                                        ),
                                      ),

                                      // BADGE STATUS ONLINE / OFFLINE (KIRI ATAS)
                                      Positioned(
                                        top: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 7,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.92),
                                            borderRadius:
                                            BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: 6,
                                                height: 6,
                                                decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: isOnline
                                                      ? (isBusy
                                                      ? const Color(
                                                      0xFFEA580C)
                                                      : const Color(
                                                      0xFF16A34A))
                                                      : const Color(0xFF94A3B8),
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                isOnline
                                                    ? (isBusy
                                                    ? 'Sesi'
                                                    : 'Online')
                                                    : 'Offline',
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w700,
                                                  color: isOnline
                                                      ? (isBusy
                                                      ? const Color(
                                                      0xFFC2410C)
                                                      : const Color(
                                                      0xFF15803D))
                                                      : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

                                      // TOMBOL HATI / FAVORIT (KANAN ATAS)
                                      Positioned(
                                        top: 8,
                                        right: 8,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              if (isFav) {
                                                _favoriteDoctorIds
                                                    .remove(doctor.id);
                                              } else {
                                                _favoriteDoctorIds
                                                    .add(doctor.id);
                                              }
                                            });
                                          },
                                          child: Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: Colors.white
                                                  .withValues(alpha: 0.92),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              isFav
                                                  ? Icons.favorite_rounded
                                                  : Icons.favorite_border_rounded,
                                              size: 16,
                                              color: isFav
                                                  ? const Color(0xFFEF4444)
                                                  : const Color(0xFF2563EB),
                                            ),
                                          ),
                                        ),
                                      ),

                                      // BADGE RATING (KIRI BAWAH FOTO)
                                      Positioned(
                                        bottom: 8,
                                        left: 8,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2.5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2563EB),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const Icon(
                                                Icons.star_rounded,
                                                size: 11,
                                                color: Colors.white,
                                              ),
                                              const SizedBox(width: 2),
                                              Text(
                                                _formatRating(doctor.rating),
                                                style: const TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // NAMA, SPESIALIS & JADWAL SHIFT (BAWAH)
                              Expanded(
                                flex: 38,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(
                                      10, 8, 10, 10),
                                  child: Column(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        doctor.nama,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              doctor.spesialis,
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w500,
                                                color: Color(0xFF475569),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          Icon(
                                            _spesialisIcon(doctor.spesialis),
                                            size: 13,
                                            color: const Color(0xFF2563EB),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        shiftText,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w600,
                                          color: isOnline
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
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
          ),
        ],
      ),
    );
  }
}

class _DoctorGridItem {
  final Doctor doctor;
  final String? fotoUrl;

  const _DoctorGridItem({
    required this.doctor,
    required this.fotoUrl,
  });
}

class LiquidHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.5, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.75, size.height - 60);
    var secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}