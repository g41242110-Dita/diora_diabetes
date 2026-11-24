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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatShiftText(Doctor doctor) {
    if (!doctor.isShiftActiveToday ||
        (doctor.jamMulai == 0 && doctor.jamSelesai == 0)) {
      return 'Libur / Jadwal Tutup Hari Ini';
    }

    final start = doctor.jamMulai.toString().padLeft(2, '0');
    final end = doctor.jamSelesai.toString().padLeft(2, '0');
    final suffix = doctor.isPenggantiHariIni &&
        doctor.menggantikanDokter.isNotEmpty
        ? ' • Pengganti ${doctor.menggantikanDokter}'
        : '';

    return '${doctor.namaShiftHariIni} ($start.00 - $end.00)$suffix';
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                    Color(0xFF388BFF)
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
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000000).withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: const Color(0xFF5B4AF4).withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.toLowerCase();
                        });
                      },
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontSize: 12.5),
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Cari Dokter atau Spesialis ...',
                        hintStyle:
                        TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 18,
                          color: Color(0xFF5B4AF4),
                        ),
                        prefixIconConstraints: BoxConstraints(
                          minWidth: 38,
                          minHeight: 40,
                        ),
                        border: InputBorder.none,
                        contentPadding:
                        EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // STREAM BUILDER DATA DOKTER REAL-TIME DARI FIREBASE
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
              FirebaseFirestore.instance.collection('doctors').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF6679F4)),
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

                final docs = snapshot.data!.docs;
                List<Doctor> doctorsList = docs.map((doc) {
                  return Doctor.fromFirestore(
                      doc.data() as Map<String, dynamic>, doc.id);
                }).toList();

                // Urutkan dokter yang aktif/online hari ini di bagian atas
                doctorsList.sort((a, b) {
                  if (a.isShiftActiveToday == b.isShiftActiveToday) {
                    return a.id.compareTo(b.id);
                  }
                  return a.isShiftActiveToday ? -1 : 1;
                });

                if (_searchQuery.isNotEmpty) {
                  doctorsList = doctorsList.where((doc) {
                    return doc.nama.toLowerCase().contains(_searchQuery) ||
                        doc.spesialis.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: doctorsList.length,
                    separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final doctor = doctorsList[index];

                      final bool isOnline = doctor.isShiftActiveToday;
                      final bool isBusy = doctor.isBusyInChat;
                      final String shiftText = _formatShiftText(doctor);

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF0F172A)
                                  .withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
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
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CircleAvatar(
                                    radius: 28,
                                    backgroundColor: Color(0xFFEEF2FF),
                                    child: Icon(Icons.person_rounded,
                                        size: 32, color: Color(0xFF4F46E5)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                doctor.nama,
                                                style: const TextStyle(
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0F172A),
                                                  height: 1.2,
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Container(
                                              padding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4),
                                              decoration: BoxDecoration(
                                                color: isOnline
                                                    ? (isBusy
                                                    ? const Color(
                                                    0xFFFFF7ED)
                                                    : const Color(
                                                    0xFFF0FDF4))
                                                    : const Color(0xFFF1F5F9),
                                                borderRadius:
                                                BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                isOnline
                                                    ? (isBusy
                                                    ? 'Dalam Sesi'
                                                    : 'Online')
                                                    : 'Offline',
                                                style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  color: isOnline
                                                      ? (isBusy
                                                      ? const Color(
                                                      0xFFC2410C)
                                                      : const Color(
                                                      0xFF15803D))
                                                      : const Color(0xFF64748B),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          doctor.spesialis,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF64748B)),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            const Icon(Icons.star_rounded,
                                                size: 15, color: Colors.amber),
                                            const SizedBox(width: 2),
                                            Text(
                                              doctor.rating,
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '(${doctor.ulasan} ulasan)',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF94A3B8)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          shiftText,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isOnline
                                                ? const Color(0xFF16A34A)
                                                : const Color(0xFF94A3B8),
                                          ),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
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