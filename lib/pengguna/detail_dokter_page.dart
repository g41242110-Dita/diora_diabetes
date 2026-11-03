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

  /// Cek apakah dokter bertugas dan bisa dibooking (Aktif, Shift Malam Nanti, atau Besok Pagi)
  bool _canDoctorBeBooked(Doctor doc) {
    if (doc.jamMulai == 0 && doc.jamSelesai == 0) return false;

    final currentHour = DateTime.now().hour;

    // Shift Aktif
    if (_isShiftAktif(doc)) return true;

    // Shift Malam (23.00 - 07.00) -> Bisa dibooking dari jam 15.00 sore
    if (doc.jamMulai == 23 && doc.jamSelesai == 7) {
      return (currentHour >= 15 || currentHour < 7);
    }

    // Shift Pagi (07.00 - 15.00) -> Bisa dibooking untuk jadwal besok pagi
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
    final doctor = widget.doctor;

    final bool isAktif = _isShiftAktif(doctor);
    final bool canBook = _canDoctorBeBooked(doctor);
    final String shiftText = _getShiftLabelText(doctor);
    final String deskripsiText = doctor.deskripsi ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Detail Dokter',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // PROFIL DOKTER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFFEEF2FF),
                    child: Icon(Icons.person_rounded,
                        size: 40, color: Color(0xFF4F46E5)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor.nama,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor.spesialis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              doctor.rating,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${doctor.ulasan} ulasan)',
                              style: const TextStyle(
                                fontSize: 12,
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
            ),
            const SizedBox(height: 16),

            // INFO SHIFT DOKTER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Jadwal Shift Dokter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    shiftText,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isAktif
                          ? const Color(0xFF16A34A)
                          : (canBook
                          ? const Color(0xFF2563EB)
                          : const Color(0xFFB91C1C)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // TENTANG DOKTER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF1F5F9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tentang Dokter',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deskripsiText.isNotEmpty
                        ? deskripsiText
                        : 'Berfokus pada perawatan pasien diabetes.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                canBook ? const Color(0xFF4F46E5) : Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              onPressed: canBook
                  ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingDokterPage(
                      doctor: doctor,
                      namaUser: widget.namaUser,
                    ),
                  ),
                );
              }
                  : null,
              child: Text(
                canBook
                    ? (isAktif
                    ? 'Konsultasi Sekarang / Booking Jam'
                    : 'Pilih Jadwal Konsultasi')
                    : 'Dokter Sedang Offline / Libur',
                style: TextStyle(
                  color: canBook ? Colors.white : Colors.grey[700],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}