import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dokter_room_chat_page.dart';
import 'dokter_riwayat_konsultasi_page.dart';

class DokterKonsultasiPage extends StatefulWidget {
  final String doctorId;

  const DokterKonsultasiPage({
    super.key,
    required this.doctorId,
  });

  @override
  State<DokterKonsultasiPage> createState() =>
      _DokterKonsultasiPageState();
}

class _DokterKonsultasiPageState extends State<DokterKonsultasiPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Daftar slot konsultasi standar (durasi per slot 20 menit / 30 menit)
  final List<String> _defaultSlots = [
    '07.00 - 07.20',
    '07.20 - 07.40',
    '07.40 - 08.00',
    '09.40 - 10.00',
    '10.00 - 10.30',
    '10.30 - 11.00',
    '12.00 - 13.00', // Istirahat
    '13.00 - 13.20',
    '13.20 - 13.40',
    '13.40 - 14.00',
    '14.00 - 14.30',
  ];

  // Mengubah jam menjadi menit untuk pengurutan
  int _getMinutes(String slot) {
    final waktu = slot.split(' - ').first;
    final bagian = waktu.split('.');

    if (bagian.length != 2) return 0;

    final jam = int.tryParse(bagian[0]) ?? 0;
    final menit = int.tryParse(bagian[1]) ?? 0;

    return (jam * 60) + menit;
  }

  // Mengurutkan slot berdasarkan jam
  List<String> _sortSlots(Set<String> slots) {
    final result = slots.toList();
    result.sort(
          (a, b) => _getMinutes(a).compareTo(_getMinutes(b)),
    );
    return result;
  }

  // Membuka halaman riwayat konsultasi
  void _openRiwayat() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DokterRiwayatKonsultasiPage(
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  // Membuka ruang chat pasien
  void _openChat(String namaPasien, String jamSlot) {
    final String roomId =
        '${namaPasien}_${widget.doctorId}_${jamSlot.replaceAll(' ', '')}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DokterRoomChatPage(
          roomId: roomId,
          doctorId: widget.doctorId,
          namaPasien: namaPasien,
          genderAge: 'Pasien Terdaftar',
          jamSesi: jamSlot,
        ),
      ),
    );
  }

  // Banner kuota pasien
  Widget _buildKuotaBanner(
      int totalTerisi,
      int jamMulai,
      int jamSelesai,
      ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFDCFCE7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF86EFAC),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.people_alt_outlined,
            color: Color(0xFF166534),
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kuota Pasien Hari Ini',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF166534),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total $totalTerisi pasien terdaftar '
                      'dari shift ($jamMulai.00 - $jamSelesai.00 WIB)',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF15803D),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Tampilan Slot Standar (Jam di Kiri, Nama/Status di Kanan)
  Widget _buildSlotItem(
      String jamSlot,
      Map<String, dynamic>? pasienData,
      ) {
    final bool isBreak = jamSlot == '12.00 - 13.00';
    final bool isBooked = pasienData != null;
    final String namaPasien = pasienData?['user_id']?.toString() ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isBooked
            ? const Color(0xFFEEF2FF)
            : (isBreak ? const Color(0xFFFFFBEB) : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBooked
              ? const Color(0xFF6366F1)
              : (isBreak ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
          width: isBooked ? 1.5 : 1.0,
        ),
      ),
      child: Row(
        children: [
          // Kotak Jam di Kiri
          Container(
            width: 110,
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 6,
            ),
            decoration: BoxDecoration(
              color: isBooked
                  ? const Color(0xFF4F46E5)
                  : (isBreak ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                jamSlot,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isBooked
                      ? Colors.white
                      : (isBreak ? const Color(0xFF92400E) : const Color(0xFF475569)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Informasi Pasien atau Status Slot di Kanan
          Expanded(
            child: isBooked
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      namaPasien,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Terkonfirmasi Booking',
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    _openChat(namaPasien, jamSlot);
                  },
                  child: const Text(
                    'Mulai Chat',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            )
                : Text(
              isBreak ? 'Jam Istirahat Dokter' : 'Tersedia',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isBreak
                    ? const Color(0xFF92400E)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String tanggalHariIni =
    DateTime.now().toString().split(' ')[0];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Jadwal Booking Konsultasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: _openRiwayat,
            icon: const Icon(
              Icons.history_rounded,
              color: Color(0xFF4F46E5),
              size: 18,
            ),
            label: const Text(
              'Riwayat',
              style: TextStyle(
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore
            .collection('doctors')
            .doc(widget.doctorId)
            .snapshots(),
        builder: (context, doctorSnapshot) {
          if (doctorSnapshot.connectionState ==
              ConnectionState.waiting &&
              !doctorSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF4F46E5),
              ),
            );
          }

          if (!doctorSnapshot.hasData ||
              !doctorSnapshot.data!.exists) {
            return const Center(
              child: Text('Data dokter tidak ditemukan.'),
            );
          }

          final doctorData = doctorSnapshot.data!.data() as Map<String, dynamic>? ?? {};
          final int jamMulai =
              (doctorData['jamMulai'] as num?)?.toInt() ?? 7;
          final int jamSelesai =
              (doctorData['jamSelesai'] as num?)?.toInt() ?? 23;

          return StreamBuilder<QuerySnapshot>(
            stream: _firestore
                .collection('consultation_bookings')
                .where(
              'doctor_id',
              isEqualTo: widget.doctorId,
            )
                .where(
              'booking_date',
              isEqualTo: tanggalHariIni,
            )
                .snapshots(),
            builder: (context, bookingSnapshot) {
              if (bookingSnapshot.connectionState ==
                  ConnectionState.waiting &&
                  !bookingSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF4F46E5),
                  ),
                );
              }

              final bookingDocs =
                  bookingSnapshot.data?.docs ?? [];

              // Memetakan booking berdasarkan jam slot
              final Map<String, Map<String, dynamic>> bookedMap = {};

              for (final doc in bookingDocs) {
                final data = doc.data() as Map<String, dynamic>;
                final String slotWaktu =
                    data['booking_time']?.toString() ?? '';

                if (slotWaktu.isNotEmpty) {
                  bookedMap[slotWaktu] = data;
                }
              }

              // Menggabungkan slot standar dan slot booking aktif
              final Set<String> allActiveSlots = {
                ..._defaultSlots,
                ...bookedMap.keys,
              };

              final List<String> sortedSlots =
              _sortSlots(allActiveSlots);
              final int totalTerisi = bookingDocs.length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildKuotaBanner(
                      totalTerisi,
                      jamMulai,
                      jamSelesai,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Sesi Jam Konsultasi Dokter '
                          '($jamMulai.00 - $jamSelesai.00 WIB):',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Render Daftar Slot Waktu Biasa
                    ...sortedSlots.map((jamSlot) {
                      final pasienData = bookedMap[jamSlot];
                      return _buildSlotItem(jamSlot, pasienData);
                    }),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}