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

  /// Cek apakah shift dokter sedang aktif jam sekarang
  bool _isShiftAktif(int jamMulai, int jamSelesai) {
    if (jamMulai == 0 && jamSelesai == 0) return false;

    final currentHour = DateTime.now().hour;

    // Shift Malam Lintas Hari (23.00 - 07.00)
    if (jamMulai > jamSelesai) {
      return (currentHour >= jamMulai || currentHour < jamSelesai);
    }
    // Shift Normal Hari yang Sama (07.00 - 15.00 atau 15.00 - 23.00)
    return (currentHour >= jamMulai && currentHour < jamSelesai);
  }

  /// Cek apakah dokter bertugas dan bisa dibooking
  bool _canBeBooked(int jamMulai, int jamSelesai) {
    if (jamMulai == 0 && jamSelesai == 0) return false;

    final currentHour = DateTime.now().hour;

    // Shift Aktif
    if (_isShiftAktif(jamMulai, jamSelesai)) return true;

    // Shift Malam (23 - 07) -> Bisa dibooking dari jam 15.00 sore
    if (jamMulai == 23 && jamSelesai == 7) {
      return (currentHour >= 15 || currentHour < 7);
    }

    // Shift Pagi (07 - 15) -> Bisa dibooking untuk besok pagi
    if (jamMulai == 7 && jamSelesai == 15) {
      return true;
    }

    return true;
  }

  /// Memproses rotasi 7 dokter per hari (Rolling Shift)
  List<Doctor> _process7DoctorRotations(List<Doctor> allDoctors) {
    if (allDoctors.isEmpty) return [];

    final now = DateTime.now();
    final currentHour = now.hour;

    // Shift aktif sekarang: 0 = Pagi (07-15), 1 = Siang (15-23), 2 = Malam (23-07)
    int activeShiftNow;
    if (currentHour >= 7 && currentHour < 15) {
      activeShiftNow = 0;
    } else if (currentHour >= 15 && currentHour < 23) {
      activeShiftNow = 1;
    } else {
      activeShiftNow = 2;
    }

    // Hitung offset rotasi harian
    final referenceDate = DateTime(2026, 1, 1);
    final dayOffset = now.difference(referenceDate).inDays;
    int totalDocs = allDoctors.length;

    List<Doctor> processedDoctors = [];

    for (int i = 0; i < totalDocs; i++) {
      Doctor doc = allDoctors[i];

      // Tentukan giliran shift dokter (0 = Pagi, 1 = Siang, 2 = Malam, >=3 = Libur)
      int shiftIndexHariIni = (i + dayOffset) % totalDocs;

      int jamMulai = 0;
      int jamSelesai = 0;

      if (shiftIndexHariIni == 0) {
        jamMulai = 7;
        jamSelesai = 15;
      } else if (shiftIndexHariIni == 1) {
        jamMulai = 15;
        jamSelesai = 23;
      } else if (shiftIndexHariIni == 2) {
        jamMulai = 23;
        jamSelesai = 7;
      } else {
        // Dokter ke-4 sampai ke-7 Libur
        jamMulai = 0;
        jamSelesai = 0;
      }

      bool isOnlineNow = (shiftIndexHariIni == activeShiftNow);

      processedDoctors.add(
        Doctor(
          id: doc.id,
          nama: doc.nama,
          spesialis: doc.spesialis,
          jamMulai: jamMulai,
          jamSelesai: jamSelesai,
          isOnline: isOnlineNow,
          isBusyInChat: doc.isBusyInChat,
          rating: doc.rating,
          ulasan: doc.ulasan,
          deskripsi: doc.deskripsi,
        ),
      );
    }

    // SORTING KRONOLOGIS URUTAN JAM:
    // 1. Shift Aktif saat ini (misal 15-23)
    // 2. Shift Malam Nanti (23-07)
    // 3. Shift Besok Pagi (07-15)
    // 4. Dokter Libur / Offline
    processedDoctors.sort((a, b) {
      int getPriority(Doctor doc) {
        if (_isShiftAktif(doc.jamMulai, doc.jamSelesai)) return 1; // Paling Atas
        if (doc.jamMulai == 23) return 2; // Shift Malam Nanti
        if (doc.jamMulai == 7) return 3;  // Shift Besok Pagi
        return 4;                         // Offline / Libur
      }

      return getPriority(a).compareTo(getPriority(b));
    });

    return processedDoctors;
  }

  String _formatShiftText(int jamMulai, int jamSelesai) {
    if (jamMulai == 0 && jamSelesai == 0) {
      return 'Libur Hari Ini';
    }

    final start = jamMulai.toString().padLeft(2, '0');
    final end = jamSelesai.toString().padLeft(2, '0');

    if (_isShiftAktif(jamMulai, jamSelesai)) {
      return 'Shift Aktif ($start.00 - $end.00)';
    } else if (jamMulai == 23) {
      return 'Shift Malam Nanti ($start.00 - $end.00)';
    } else if (jamMulai == 7) {
      return 'Shift Besok Pagi ($start.00 - $end.00)';
    } else {
      return 'Shift Hari Ini ($start.00 - $end.00)';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // HEADER BIRU GRADIENT DENGAN SEARCH BAR
          Container(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 12, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6679F4), Color(0xFF8B5CF6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.maybePop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Konsultasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
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
                    style: const TextStyle(fontSize: 13.5),
                    decoration: const InputDecoration(
                      hintText: 'Cari Dokter atau Spesialis ...',
                      hintStyle:
                      TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                      prefixIcon: Icon(Icons.search_rounded,
                          size: 20, color: Color(0xFF6679F4)),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // STREAM BUILDER DATA DOKTER REAL-TIME
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctors')
                  .snapshots(),
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

                // TERAPKAN ROTASI 7 DOKTER HARIAN & SORTING KRONOLOGIS
                doctorsList = _process7DoctorRotations(doctorsList);

                if (_searchQuery.isNotEmpty) {
                  doctorsList = doctorsList.where((doc) {
                    return doc.nama.toLowerCase().contains(_searchQuery) ||
                        doc.spesialis.toLowerCase().contains(_searchQuery);
                  }).toList();
                }

                return SingleChildScrollView(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Pilih dokter yang sesuai dengan kebutuhanmu.',
                        style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(height: 12),
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: doctorsList.length,
                        separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final doctor = doctorsList[index];
                          final bool isAktif = _isShiftAktif(
                              doctor.jamMulai, doctor.jamSelesai);
                          final bool canBook = _canBeBooked(
                              doctor.jamMulai, doctor.jamSelesai);
                          final String shiftText = _formatShiftText(
                              doctor.jamMulai, doctor.jamSelesai);

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.04),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(16),
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
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      const CircleAvatar(
                                        radius: 28,
                                        backgroundColor: Color(0xFFEEF2FF),
                                        child: Icon(Icons.person_rounded,
                                            size: 32,
                                            color: Color(0xFF4F46E5)),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                              MainAxisAlignment
                                                  .spaceBetween,
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    doctor.nama,
                                                    style: const TextStyle(
                                                      fontSize: 13.5,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: Color(0xFF0F172A),
                                                      height: 1.2,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                    TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                const SizedBox(width: 8),

                                                // BADGE STATUS DOKTER
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: isAktif
                                                        ? (doctor.isBusyInChat
                                                        ? const Color(0xFFFFF7ED)
                                                        : const Color(0xFFF0FDF4))
                                                        : (canBook
                                                        ? const Color(0xFFEFF6FF)
                                                        : const Color(0xFFF1F5F9)),
                                                    borderRadius:
                                                    BorderRadius.circular(6),
                                                  ),
                                                  child: Text(
                                                    isAktif
                                                        ? (doctor.isBusyInChat
                                                        ? 'Dalam Sesi'
                                                        : 'Praktek')
                                                        : (canBook
                                                        ? 'Bisa Dibooking'
                                                        : 'Offline'),
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: isAktif
                                                          ? (doctor.isBusyInChat
                                                          ? const Color(0xFFC2410C)
                                                          : const Color(0xFF15803D))
                                                          : (canBook
                                                          ? const Color(0xFF2563EB)
                                                          : const Color(0xFF64748B)),
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
                                                const Icon(
                                                    Icons.star_rounded,
                                                    size: 15,
                                                    color: Colors.amber),
                                                const SizedBox(width: 2),
                                                Text(
                                                  doctor.rating,
                                                  style: const TextStyle(
                                                      fontSize: 11,
                                                      fontWeight:
                                                      FontWeight.bold),
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
                                                color: isAktif
                                                    ? const Color(0xFF16A34A)
                                                    : (canBook
                                                    ? const Color(0xFF2563EB)
                                                    : const Color(0xFF94A3B8)),
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
                    ],
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