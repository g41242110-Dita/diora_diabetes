import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'booking_dokter_page.dart';

class DetailDokterPage extends StatefulWidget {
  final Doctor doctor;
  final String namaUser;

  const DetailDokterPage({
    super.key,
    required this.doctor,
    this.namaUser = 'Pengguna',
  });

  @override
  State<DetailDokterPage> createState() => _DetailDokterPageState();
}

class _DetailDokterPageState extends State<DetailDokterPage> {
  Uint8List? _decodePhotoBytes(dynamic rawBase64) {
    if (rawBase64 == null) return null;
    final str = rawBase64.toString().trim();
    if (str.isEmpty) return null;
    try {
      final cleaned = str.contains(',') ? str.split(',').last : str;
      return base64Decode(cleaned);
    } catch (_) {
      return null;
    }
  }

  /// Cek apakah shift dokter sedang aktif jam sekarang
  bool _isShiftAktif(Doctor doc) {
    if (doc.jamMulai == 0 && doc.jamSelesai == 0) return false;

    final currentHour = DateTime.now().hour;

    // Shift Malam Lintas Hari (23.00 - 07.00)
    if (doc.jamMulai > doc.jamSelesai) {
      return (currentHour >= doc.jamMulai || currentHour < doc.jamSelesai);
    }
    // Shift Normal Hari yang Sama (07.00 - 15.00 atau 15.00 - 23.00)
    return (currentHour >= doc.jamMulai && currentHour < doc.jamSelesai);
  }

  /// Cek apakah dokter bertugas dan bisa dibooking
  bool _canDoctorBeBooked(Doctor doc) {
    if (doc.jamMulai == 0 && doc.jamSelesai == 0) return false;

    final currentHour = DateTime.now().hour;

    if (_isShiftAktif(doc)) return true;

    if (doc.jamMulai == 23 && doc.jamSelesai == 7) {
      return (currentHour >= 15 || currentHour < 7);
    }

    if (doc.jamMulai == 7 && doc.jamSelesai == 15) {
      return true;
    }

    return true;
  }

  String _getShiftLabelText(Doctor doc) {
    if (doc.jamMulai == 0 && doc.jamSelesai == 0) {
      return 'Dokter Sedang Libur Hari Ini';
    }

    final String startStr = doc.jamMulai.toString().padLeft(2, '0');
    final String endStr = doc.jamSelesai.toString().padLeft(2, '0');

    if (_isShiftAktif(doc)) {
      return 'Shift Aktif ($startStr.00 - $endStr.00 WIB)';
    } else if (doc.jamMulai == 23) {
      return 'Shift Malam Nanti ($startStr.00 - $endStr.00 WIB)';
    } else if (doc.jamMulai == 7) {
      return 'Shift Besok Pagi ($startStr.00 - $endStr.00 WIB)';
    } else {
      return 'Shift Hari Ini ($startStr.00 - $endStr.00 WIB)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final baseDoctor = widget.doctor;
    final double topPadding = MediaQuery.of(context).padding.top + 12;

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctors')
          .doc(baseDoctor.id)
          .snapshots(),
      builder: (context, snapshot) {
        final Map<String, dynamic> liveData =
        (snapshot.hasData && snapshot.data!.exists)
            ? (snapshot.data!.data() as Map<String, dynamic>? ?? {})
            : <String, dynamic>{};

        final String nama =
        (liveData['nama'] ?? baseDoctor.nama).toString().trim();
        final String spesialis =
        (liveData['spesialis'] ?? baseDoctor.spesialis).toString().trim();
        final String rating =
        (liveData['rating'] ?? baseDoctor.rating).toString().trim();
        final String ulasan =
        (liveData['ulasan'] ?? baseDoctor.ulasan).toString().trim();
        final String deskripsiText = (liveData['deskripsi'] ??
            liveData['tentangDokter'] ??
            baseDoctor.deskripsi ??
            '')
            .toString()
            .trim();
        final String almamater =
        (liveData['almamater'] ?? liveData['pendidikan'] ?? '')
            .toString()
            .trim();
        final String pengalaman =
        (liveData['pengalaman'] ?? liveData['pengalamanTahun'] ?? '')
            .toString()
            .trim();
        final String klinikUtama =
        (liveData['klinikUtama'] ?? '').toString().trim();
        final String sip = (liveData['sip'] ?? '').toString().trim();
        final String str = (liveData['str'] ?? '').toString().trim();
        final bool isOnline = liveData['isOnline'] is bool
            ? liveData['isOnline'] as bool
            : baseDoctor.isOnline;

        final Uint8List? photoBytes = _decodePhotoBytes(liveData['photoBase64']);
        final String? photoUrl =
        (liveData['photoUrl'] != null && liveData['photoUrl'].toString().trim().isNotEmpty)
            ? liveData['photoUrl'].toString().trim()
            : null;

        final Doctor effectiveDoctor = Doctor(
          id: baseDoctor.id,
          nama: nama.isNotEmpty ? nama : baseDoctor.nama,
          spesialis: spesialis.isNotEmpty ? spesialis : baseDoctor.spesialis,
          jamMulai: baseDoctor.jamMulai,
          jamSelesai: baseDoctor.jamSelesai,
          isOnline: isOnline,
          isBusyInChat: baseDoctor.isBusyInChat,
          rating: rating.isNotEmpty ? rating : baseDoctor.rating,
          ulasan: ulasan.isNotEmpty ? ulasan : baseDoctor.ulasan,
          deskripsi: deskripsiText,
        );

        final bool isAktif = _isShiftAktif(effectiveDoctor);
        final bool canBook = _canDoctorBeBooked(effectiveDoctor);
        final String shiftText = _getShiftLabelText(effectiveDoctor);

        ImageProvider? avatarProvider;
        if (photoBytes != null) {
          avatarProvider = MemoryImage(photoBytes);
        } else if (photoUrl != null) {
          avatarProvider = NetworkImage(photoUrl);
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // STACK HEADER LIQUID + FLOATING CARD PROFIL DOKTER
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // BACKGROUND LIQUID WAVE
                    ClipPath(
                      clipper: _DetailLiquidClipper(),
                      child: Container(
                        height: topPadding + 130,
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(16, topPadding, 16, 0),
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
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: SizedBox(
                            height: 40,
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
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                                const Text(
                                  'Detail Dokter',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // FLOATING PROFILE CARD
                    Padding(
                      padding:
                      EdgeInsets.fromLTRB(16, topPadding + 52, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5B4AF4)
                                  .withValues(alpha: 0.07),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(2.5),
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          colors: [
                                            Color(0xFF6679F4),
                                            Color(0xFF8DA0FF)
                                          ],
                                        ),
                                      ),
                                      child: CircleAvatar(
                                        radius: 26,
                                        backgroundColor: const Color(0xFFEEF2FF),
                                        backgroundImage: avatarProvider,
                                        child: avatarProvider == null
                                            ? const Icon(
                                          Icons.person_rounded,
                                          size: 30,
                                          color: Color(0xFF4F46E5),
                                        )
                                            : null,
                                      ),
                                    ),
                                    Positioned(
                                      right: 1,
                                      bottom: 1,
                                      child: Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          color: effectiveDoctor.isOnline
                                              ? const Color(0xFF22C55E)
                                              : const Color(0xFF94A3B8),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        effectiveDoctor.nama,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14.5,
                                          color: Color(0xFF0F172A),
                                          height: 1.25,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        effectiveDoctor.spesialis,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 7),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 7, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFFBEB),
                                              borderRadius:
                                              BorderRadius.circular(6),
                                              border: Border.all(
                                                  color:
                                                  const Color(0xFFFEF3C7)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.star_rounded,
                                                    size: 13,
                                                    color: Colors.amber),
                                                const SizedBox(width: 3),
                                                Text(
                                                  effectiveDoctor.rating,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFB45309),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '(${effectiveDoctor.ulasan} ulasan)',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Color(0xFF94A3B8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMiniStat(
                                  icon: Icons.timer_outlined,
                                  label: '20 Menit / Sesi',
                                ),
                                Container(
                                  width: 1,
                                  height: 18,
                                  color: const Color(0xFFE2E8F0),
                                ),
                                _buildMiniStat(
                                  icon: Icons.chat_outlined,
                                  label: 'Chat Online',
                                ),
                                Container(
                                  width: 1,
                                  height: 18,
                                  color: const Color(0xFFE2E8F0),
                                ),
                                _buildMiniStat(
                                  icon: Icons.verified_user_outlined,
                                  label: 'Terverifikasi',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // KARTU JADWAL SHIFT DOKTER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(
                                Icons.access_time_filled_rounded,
                                size: 16,
                                color: Color(0xFF5B4AF4),
                              ),
                            ),
                            const SizedBox(width: 9),
                            const Text(
                              'Jadwal Shift Dokter',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: isAktif
                                ? const Color(0xFFF0FDF4)
                                : (canBook
                                ? const Color(0xFFEFF6FF)
                                : const Color(0xFFFEF2F2)),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isAktif
                                  ? const Color(0xFFBBF7D0)
                                  : (canBook
                                  ? const Color(0xFFBFDBFE)
                                  : const Color(0xFFFECACA)),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isAktif
                                    ? Icons.check_circle_rounded
                                    : (canBook
                                    ? Icons.event_available_rounded
                                    : Icons.cancel_rounded),
                                size: 15,
                                color: isAktif
                                    ? const Color(0xFF16A34A)
                                    : (canBook
                                    ? const Color(0xFF2563EB)
                                    : const Color(0xFFB91C1C)),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  shiftText,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: isAktif
                                        ? const Color(0xFF15803D)
                                        : (canBook
                                        ? const Color(0xFF1D4ED8)
                                        : const Color(0xFFB91C1C)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // KARTU TENTANG DOKTER & INFORMASI PROFIL
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(
                                Icons.medical_information_rounded,
                                size: 16,
                                color: Color(0xFF5B4AF4),
                              ),
                            ),
                            const SizedBox(width: 9),
                            const Text(
                              'Tentang Dokter',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          deskripsiText.isNotEmpty
                              ? deskripsiText
                              : 'Spesialis berpengalaman dalam penanganan dan edukasi pasien diabetes secara menyeluruh.',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                        if (almamater.isNotEmpty ||
                            pengalaman.isNotEmpty ||
                            klinikUtama.isNotEmpty ||
                            sip.isNotEmpty ||
                            str.isNotEmpty) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFF1F5F9)),
                          const SizedBox(height: 10),
                          if (almamater.isNotEmpty)
                            _buildDetailMetaRow(
                                'Almamater', almamater),
                          if (pengalaman.isNotEmpty)
                            _buildDetailMetaRow(
                                'Pengalaman', '$pengalaman Tahun'),
                          if (klinikUtama.isNotEmpty)
                            _buildDetailMetaRow(
                                'Fasyankes Utama', klinikUtama),
                          if (sip.isNotEmpty)
                            _buildDetailMetaRow('No. SIP', sip),
                          if (str.isNotEmpty)
                            _buildDetailMetaRow('No. STR', str),
                        ],
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // KARTU ALUR KONSULTASI
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(7),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: const Icon(
                                Icons.info_outline_rounded,
                                size: 16,
                                color: Color(0xFF5B4AF4),
                              ),
                            ),
                            const SizedBox(width: 9),
                            const Text(
                              'Alur Konsultasi',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildStepItem(
                          step: '1',
                          text:
                          'Pilih jam konsultasi yang tersedia sesuai jadwal dokter.',
                        ),
                        const SizedBox(height: 8),
                        _buildStepItem(
                          step: '2',
                          text:
                          'Lampirkan hasil skrining mandiri Anda di ruang chat.',
                        ),
                        const SizedBox(height: 8),
                        _buildStepItem(
                          step: '3',
                          text:
                          'Dapatkan saran medis & ringkasan hasil setelah sesi selesai.',
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),

          // TOMBOL AKSI KONSULTASI DI BAGIAN BAWAH
          bottomNavigationBar: Container(
            padding: EdgeInsets.fromLTRB(
                16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: canBook
                    ? const LinearGradient(
                  colors: [Color(0xFF5B4AF4), Color(0xFF4F46E5)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
                    : null,
                color: canBook ? null : const Color(0xFFE2E8F0),
                boxShadow: canBook
                    ? [
                  BoxShadow(
                    color: const Color(0xFF5B4AF4).withValues(alpha: 0.28),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
                    : [],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: canBook
                    ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingDokterPage(
                        doctor: effectiveDoctor,
                        namaUser: widget.namaUser,
                      ),
                    ),
                  );
                }
                    : null,
                icon: Icon(
                  canBook
                      ? (isAktif
                      ? Icons.chat_bubble_rounded
                      : Icons.calendar_month_rounded)
                      : Icons.block_rounded,
                  size: 17,
                  color: canBook ? Colors.white : const Color(0xFF64748B),
                ),
                label: Text(
                  canBook
                      ? (isAktif
                      ? 'Konsultasi Sekarang'
                      : 'Pilih Jadwal Konsultasi')
                      : 'Dokter Sedang Offline / Libur',
                  style: TextStyle(
                    color: canBook ? Colors.white : const Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({required IconData icon, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF5B4AF4)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildStepItem({required String step, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color(0xFFEEF2FF),
            shape: BoxShape.circle,
          ),
          child: Text(
            step,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Color(0xFF5B4AF4),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailLiquidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 28);

    var firstControlPoint = Offset(size.width * 0.28, size.height);
    var firstEndPoint = Offset(size.width * 0.55, size.height - 22);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.8, size.height - 42);
    var secondEndPoint = Offset(size.width, size.height - 14);
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