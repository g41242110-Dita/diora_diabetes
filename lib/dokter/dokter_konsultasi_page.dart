import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'dokter_room_chat_page.dart';
import 'dokter_riwayat_konsultasi_page.dart';
import 'dokter_jadwal_praktik_page.dart';

typedef KonsulDocMap = Map<String, dynamic>;

class DokterKonsultasiPage extends StatefulWidget {
  final String doctorId;
  final VoidCallback? onBackToHome;

  const DokterKonsultasiPage({
    super.key,
    required this.doctorId,
    this.onBackToHome,
  });

  @override
  State<DokterKonsultasiPage> createState() => _DokterKonsultasiPageState();
}

class _DokterKonsultasiPageState extends State<DokterKonsultasiPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  DateTime _selectedDate = DateTime.now();
  String _filterStatus = 'Semua';

  String _namaHari(int weekday) {
    const hariMap = {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
      7: 'Minggu',
    };
    return hariMap[weekday] ?? 'Senin';
  }

  String _singkatanHari(int weekday) {
    const singkatMap = {
      1: 'Sen',
      2: 'Sel',
      3: 'Rab',
      4: 'Kam',
      5: 'Jum',
      6: 'Sab',
      7: 'Min',
    };
    return singkatMap[weekday] ?? 'Sen';
  }

  String _namaBulan(int month) {
    const bulanMap = {
      1: 'Jan',
      2: 'Feb',
      3: 'Mar',
      4: 'Apr',
      5: 'Mei',
      6: 'Jun',
      7: 'Jul',
      8: 'Agu',
      9: 'Sep',
      10: 'Okt',
      11: 'Nov',
      12: 'Des',
    };
    return bulanMap[month] ?? '';
  }

  String _formatDateIso(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatJam(int jam) {
    return '${jam.toString().padLeft(2, '0')}.00';
  }

  int _getBreakHour(int jamMulai) {
    if (jamMulai == 7) return 12;
    if (jamMulai == 15) return 18;
    if (jamMulai == 23) return 3;
    return (jamMulai + 4) % 24;
  }

  String _getBreakTimeRange(int jamMulai) {
    final int breakStart = _getBreakHour(jamMulai);
    final int breakEnd = (breakStart + 1) % 24;
    return '${_formatJam(breakStart)} - ${_formatJam(breakEnd)} WIB';
  }

  List<String> _generateShiftSlots(int jamMulai, int jamSelesai) {
    final List<String> slots = [];
    final int breakHour = _getBreakHour(jamMulai);

    int startMinutes = jamMulai * 60;
    int endMinutes = jamSelesai * 60;

    if (endMinutes <= startMinutes) {
      endMinutes += 24 * 60;
    }

    int current = startMinutes;
    while (current + 20 <= endMinutes) {
      final int next = current + 20;
      final int h1 = (current ~/ 60) % 24;

      if (h1 != breakHour) {
        final int m1 = current % 60;
        final int h2 = (next ~/ 60) % 24;
        final int m2 = next % 60;

        final String startStr =
            '${h1.toString().padLeft(2, '0')}.${m1.toString().padLeft(2, '0')}';
        final String endStr =
            '${h2.toString().padLeft(2, '0')}.${m2.toString().padLeft(2, '0')}';

        slots.add('$startStr - $endStr');
      }
      current = next;
    }

    return slots;
  }

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

  void _openAturJadwal() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DokterJadwalPraktikPage(
          doctorId: widget.doctorId,
        ),
      ),
    );
  }

  void _openChat(String namaPasien, String jamSlot, String tanggalIso) {
    final String cleanPasien = namaPasien.trim();
    final String cleanJam = jamSlot.replaceAll(' ', '');
    final String roomId =
        '${cleanPasien}_${widget.doctorId}_${tanggalIso}_$cleanJam';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DokterRoomChatPage(
          roomId: roomId,
          doctorId: widget.doctorId,
          namaPasien: cleanPasien,
          genderAge: 'Pasien Terdaftar',
          jamSesi: jamSlot,
          tanggalBooking: tanggalIso,
        ),
      ),
    );
  }

  Widget _buildDateSelectorStrip(KonsulDocMap jadwalShift) {
    final DateTime today = DateTime.now();

    return SizedBox(
      height: 78,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, index) {
          final DateTime date = today.add(Duration(days: index));
          final bool isSelected = date.year == _selectedDate.year &&
              date.month == _selectedDate.month &&
              date.day == _selectedDate.day;

          final String hariKey = _namaHari(date.weekday);
          final shiftDay = jadwalShift[hariKey] as KonsulDocMap?;
          final bool hasActiveShift =
              shiftDay != null && (shiftDay['isActive'] == true);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = date;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                  colors: [Color(0xFF4338CA), Color(0xFF6366F1)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected
                      ? Colors.transparent
                      : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isSelected
                        ? const Color(0xFF6366F1).withValues(alpha: 0.28)
                        : Colors.black.withValues(alpha: 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    index == 0 ? 'Hari Ini' : _singkatanHari(date.weekday),
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFFE0E7FF)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${date.day}',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasActiveShift
                          ? (isSelected
                          ? Colors.amberAccent
                          : const Color(0xFF10B981))
                          : Colors.transparent,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShiftSummaryCard({
    required String hariLabel,
    required String tanggalLengkap,
    required String namaShift,
    required int jamMulai,
    required int jamSelesai,
    required int totalSlot,
    required int totalBooked,
  }) {
    final int tersedia = (totalSlot - totalBooked).clamp(0, totalSlot);
    final double progress = totalSlot > 0 ? (totalBooked / totalSlot) : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.schedule_rounded,
                        color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$hariLabel, $tanggalLengkap',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFC7D2FE),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        namaShift,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 12),
                    SizedBox(width: 4),
                    Text(
                      'Aktif',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jam Operasional Shift',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFE0E7FF),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_formatJam(jamMulai)} - ${_formatJam(jamSelesai)} WIB',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildStatBox('Total Slot', '$totalSlot', Colors.white),
              const SizedBox(width: 8),
              _buildStatBox(
                  'Terbooked', '$totalBooked', const Color(0xFFFDE047)),
              const SizedBox(width: 8),
              _buildStatBox('Tersedia', '$tersedia', const Color(0xFF6EE7B7)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor:
              const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE0E7FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(int totalSemua, int totalBooked, int totalKosong) {
    final filters = [
      {'label': 'Semua', 'count': totalSemua},
      {'label': 'Terbooked', 'count': totalBooked},
      {'label': 'Tersedia', 'count': totalKosong},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: filters.map((item) {
          final String label = item['label'] as String;
          final int count = item['count'] as int;
          final bool isSelected = _filterStatus == label;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text('$label ($count)'),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  _filterStatus = label;
                });
              },
              selectedColor: const Color(0xFF4F46E5),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: isSelected
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBookedPatientCard(
      String jamSlot, KonsulDocMap pasienData, String tanggalIso) {
    final String namaPasien =
    (pasienData['user_id'] ?? pasienData['bookedByUserId'] ?? 'Pasien')
        .toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF6366F1).withValues(alpha: 0.4),
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person_rounded,
                color: Color(0xFF4F46E5), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$jamSlot WIB',
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  namaPasien,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                const Row(
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 13, color: Color(0xFF059669)),
                    SizedBox(width: 4),
                    Text(
                      'Terkonfirmasi Booking',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => _openChat(namaPasien, jamSlot, tanggalIso),
            icon: const Icon(Icons.chat_rounded, size: 15, color: Colors.white),
            label: const Text(
              'Chat',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableSlotTile(String jamSlot) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Tersedia',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            jamSlot,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Menunggu pasien',
            style: TextStyle(
              fontSize: 10,
              color: Color(0xFF94A3B8),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOffShiftEmptyState(String hariDipilih, bool adaTapiOff) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: adaTapiOff
                  ? Colors.orange.shade50
                  : const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(
              adaTapiOff
                  ? Icons.toggle_off_rounded
                  : Icons.event_available_rounded,
              size: 40,
              color: adaTapiOff
                  ? Colors.orange.shade700
                  : const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            adaTapiOff
                ? 'Shift Hari $hariDipilih Sedang Dinonaktifkan'
                : 'Tidak Ada Jadwal Shift pada Hari $hariDipilih',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            adaTapiOff
                ? 'Switch shift Anda untuk hari $hariDipilih sedang dalam posisi OFF sehingga pasien tidak dapat melakukan booking.'
                : 'Hari $hariDipilih merupakan jadwal libur rotasi Anda. Anda dapat mengambil shift pengganti dokter lain jika tersedia.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: _openAturJadwal,
            icon: const Icon(Icons.tune_rounded, size: 16, color: Colors.white),
            label: const Text(
              'Kelola Jadwal & Switch Shift',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String hariDipilih = _namaHari(_selectedDate.weekday);
    final String tanggalIso = _formatDateIso(_selectedDate);
    final String tanggalLengkap =
        '${_selectedDate.day} ${_namaBulan(_selectedDate.month)} ${_selectedDate.year}';

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed:
          widget.onBackToHome ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Jadwal & Antrean Konsultasi',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 16.5,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: _openRiwayat,
            icon: const Icon(Icons.history_rounded,
                color: Color(0xFF4F46E5), size: 18),
            label: const Text(
              'Riwayat',
              style: TextStyle(
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.w800,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('doctors').doc(widget.doctorId).snapshots(),
        builder: (context, doctorSnapshot) {
          if (doctorSnapshot.connectionState == ConnectionState.waiting &&
              !doctorSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }

          if (!doctorSnapshot.hasData || !doctorSnapshot.data!.exists) {
            return const Center(child: Text('Data dokter tidak ditemukan.'));
          }

          final doctorData =
              doctorSnapshot.data!.data() as KonsulDocMap? ?? {};
          final KonsulDocMap jadwalShift =
              (doctorData['jadwal_shift'] as KonsulDocMap?) ?? {};

          final shiftHariIni =
          jadwalShift[hariDipilih] as KonsulDocMap?;
          final bool adaJadwalHariIni = shiftHariIni != null;
          final bool isShiftAktif =
              adaJadwalHariIni && (shiftHariIni['isActive'] == true);

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 14, bottom: 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDateSelectorStrip(jadwalShift),
                const SizedBox(height: 16),
                if (!isShiftAktif)
                  _buildOffShiftEmptyState(hariDipilih, adaJadwalHariIni)
                else
                  StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('consultation_bookings')
                        .where('doctor_id', isEqualTo: widget.doctorId)
                        .where('booking_date', isEqualTo: tanggalIso)
                        .snapshots(),
                    builder: (context, bookingSnapshot) {
                      if (bookingSnapshot.connectionState ==
                          ConnectionState.waiting &&
                          !bookingSnapshot.hasData) {
                        return const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF4F46E5)),
                          ),
                        );
                      }

                      final String namaShift =
                          shiftHariIni['namaShift'] ?? 'Shift Praktik';
                      final int jamMulai =
                          (shiftHariIni['jamMulai'] as num?)?.toInt() ?? 7;
                      final int jamSelesai =
                          (shiftHariIni['jamSelesai'] as num?)?.toInt() ?? 15;

                      final bookingDocs = bookingSnapshot.data?.docs ?? [];
                      final Map<String, KonsulDocMap> bookedMap = {};

                      for (final doc in bookingDocs) {
                        final data = doc.data() as KonsulDocMap;
                        final String slotWaktu =
                            data['booking_time']?.toString() ?? '';
                        if (slotWaktu.isNotEmpty) {
                          bookedMap[slotWaktu] = data;
                        }
                      }

                      final List<String> allSlots =
                      _generateShiftSlots(jamMulai, jamSelesai);

                      for (final bookedSlot in bookedMap.keys) {
                        if (!allSlots.contains(bookedSlot)) {
                          allSlots.add(bookedSlot);
                        }
                      }

                      final List<String> bookedSlots = allSlots
                          .where((slot) => bookedMap.containsKey(slot))
                          .toList();
                      final List<String> availableSlots = allSlots
                          .where((slot) => !bookedMap.containsKey(slot))
                          .toList();

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildShiftSummaryCard(
                            hariLabel: hariDipilih,
                            tanggalLengkap: tanggalLengkap,
                            namaShift: namaShift,
                            jamMulai: jamMulai,
                            jamSelesai: jamSelesai,
                            totalSlot: allSlots.length,
                            totalBooked: bookedSlots.length,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFFBEB),
                              borderRadius: BorderRadius.circular(14),
                              border:
                              Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.coffee_rounded,
                                    color: Color(0xFFD97706), size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Jam Istirahat Shift: ${_getBreakTimeRange(jamMulai)} (otomatis dikecualikan dari slot booking)',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF92400E),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildFilterChips(
                            allSlots.length,
                            bookedSlots.length,
                            availableSlots.length,
                          ),
                          const SizedBox(height: 16),
                          if (_filterStatus != 'Tersedia' &&
                              bookedSlots.isNotEmpty) ...[
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'Antrean Pasien Terdaftar',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                children: bookedSlots
                                    .map((slot) => _buildBookedPatientCard(
                                    slot, bookedMap[slot]!, tanggalIso))
                                    .toList(),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                          if (_filterStatus != 'Terbooked') ...[
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Slot Sesi Tersedia (20 Menit)',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    '${availableSlots.length} slot',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (availableSlots.isEmpty)
                              Container(
                                margin:
                                const EdgeInsets.symmetric(horizontal: 16),
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Center(
                                  child: Text(
                                    'Semua slot pada shift ini sudah terisi penuh.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              )
                            else
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 16),
                                child: GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: availableSlots.length,
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 10,
                                    crossAxisSpacing: 10,
                                    childAspectRatio: 2.05,
                                  ),
                                  itemBuilder: (context, index) {
                                    return _buildAvailableSlotTile(
                                        availableSlots[index]);
                                  },
                                ),
                              ),
                          ],
                        ],
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