
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

  // Menyimpan slot yang sedang dibuka
  String? _expandedSlot;

  // Daftar slot konsultasi standar
  final List<String> _defaultSlots = [
    '09.40 - 10.00',
    '10.00 - 10.30',
    '10.30 - 11.00',
    '12.00 - 13.00',
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

  // Widget daftar pasien dalam slot
  Widget _buildPasienItem(
      Map<String, dynamic> pasien,
      String jamSlot,
      ) {
    final String namaPasien =
        pasien['user_id']?.toString() ?? 'Pasien';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color(0xFFC7D2FE),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
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
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
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
      ),
    );
  }

  // Widget slot konsultasi
  Widget _buildSlotItem(
      String jamSlot,
      List<Map<String, dynamic>> listPasien,
      ) {
    final bool isBreak = jamSlot == '12.00 - 13.00';
    final bool isBooked = listPasien.isNotEmpty;
    final bool isExpanded = _expandedSlot == jamSlot;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isBooked
            ? const Color(0xFFEEF2FF)
            : (isBreak
            ? const Color(0xFFFFFBEB)
            : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBooked
              ? const Color(0xFF6366F1)
              : (isBreak
              ? const Color(0xFFFDE68A)
              : const Color(0xFFE2E8F0)),
          width: isBooked ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bagian utama slot yang bisa diklik
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () {
              if (isBooked && !isBreak) {
                setState(() {
                  _expandedSlot =
                  isExpanded ? null : jamSlot;
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isBreak
                          ? 'Waktu istirahat dokter.'
                          : 'Slot ini belum dibooking pasien.',
                    ),
                  ),
                );
              }
            },
            child: Row(
              children: [
                Container(
                  width: 110,
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isBooked
                        ? const Color(0xFF4F46E5)
                        : (isBreak
                        ? const Color(0xFFFEF3C7)
                        : const Color(0xFFF1F5F9)),
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
                            : (isBreak
                            ? const Color(0xFF92400E)
                            : const Color(0xFF475569)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    isBooked
                        ? '${listPasien.length} Pasien Terdaftar'
                        : (isBreak
                        ? 'Jam Istirahat Dokter'
                        : 'Tersedia'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isBooked
                          ? const Color(0xFF0F172A)
                          : (isBreak
                          ? const Color(0xFF92400E)
                          : const Color(0xFF94A3B8)),
                    ),
                  ),
                ),
                if (isBooked)
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: const Color(0xFF4F46E5),
                  ),
              ],
            ),
          ),

          // Daftar pasien muncul saat slot dibuka
          if (isBooked && isExpanded) ...[
            const SizedBox(height: 12),
            const Divider(
              height: 1,
              color: Color(0xFFC7D2FE),
            ),
            const SizedBox(height: 10),

            ...listPasien.map(
                  (pasien) => _buildPasienItem(
                pasien,
                jamSlot,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Tanggal hari ini
    final String tanggalHariIni =
    DateTime.now().toString().split(' ')[0];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      // APP BAR
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

      // BODY
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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

          if (doctorSnapshot.hasError) {
            return const Center(
              child: Text('Gagal mengambil data dokter.'),
            );
          }

          if (!doctorSnapshot.hasData ||
              !doctorSnapshot.data!.exists) {
            return const Center(
              child: Text('Data dokter tidak ditemukan.'),
            );
          }

          final doctorData = doctorSnapshot.data!.data()!;

          final int jamMulai =
              (doctorData['jamMulai'] as num?)?.toInt() ?? 7;

          final int jamSelesai =
              (doctorData['jamSelesai'] as num?)?.toInt() ?? 23;

          // STREAM DATA BOOKING
          return StreamBuilder<
              QuerySnapshot<Map<String, dynamic>>>(
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

              if (bookingSnapshot.hasError) {
                return const Center(
                  child: Text('Gagal mengambil data booking.'),
                );
              }

              final bookingDocs =
                  bookingSnapshot.data?.docs ?? [];

              // Mengelompokkan booking berdasarkan jam
              final Map<
                  String,
                  List<Map<String, dynamic>>> groupedBookings = {};

              for (final doc in bookingDocs) {
                final data = doc.data();

                final String slotWaktu =
                    data['booking_time']?.toString() ?? '';

                if (slotWaktu.isNotEmpty) {
                  groupedBookings
                      .putIfAbsent(slotWaktu, () => [])
                      .add(data);
                }
              }

              // Menggabungkan slot standar dan slot aktif
              final Set<String> allActiveSlots = {
                ..._defaultSlots,
                ...groupedBookings.keys,
              };

              // Mengurutkan slot
              final List<String> sortedSlots =
              _sortSlots(allActiveSlots);

              // Total booking hari ini
              final int totalTerisi = bookingDocs.length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // BANNER KUOTA
                    _buildKuotaBanner(
                      totalTerisi,
                      jamMulai,
                      jamSelesai,
                    ),

                    const SizedBox(height: 20),

                    // JUDUL SESI
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

                    // DAFTAR SLOT KONSULTASI
                    ...sortedSlots.map((jamSlot) {
                      final List<Map<String, dynamic>>
                      listPasienDiSlot =
                          groupedBookings[jamSlot] ?? [];

                      return _buildSlotItem(
                        jamSlot,
                        listPasienDiSlot,
                      );
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
