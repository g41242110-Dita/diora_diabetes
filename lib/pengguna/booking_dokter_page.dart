import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'notification_service.dart';
import 'chat_konsultasi_page.dart';

class BookingDokterPage extends StatefulWidget {
  final Doctor doctor;
  final String namaUser;

  const BookingDokterPage({
    super.key,
    required this.doctor,
    this.namaUser = 'Pengguna',
  });

  @override
  State<BookingDokterPage> createState() => _BookingDokterPageState();
}

class _BookingDokterPageState extends State<BookingDokterPage> {
  String? _selectedSlot;
  bool _isLoading = false;

  int _weekOffset = 0;
  late DateTime _selectedDate;

  static const List<String> _hariPendek = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> _hariLengkap = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _bulanPendek = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  DateTime _startOfWeek(DateTime referenceDate) {
    final normalized =
    DateTime(referenceDate.year, referenceDate.month, referenceDate.day);
    return normalized.subtract(Duration(days: normalized.weekday - 1));
  }

  List<DateTime> _getWeekDays(int weekOffset) {
    final baseMonday = _startOfWeek(DateTime.now()).add(
      Duration(days: weekOffset * 7),
    );
    return List.generate(
      7,
          (index) => DateTime(
        baseMonday.year,
        baseMonday.month,
        baseMonday.day + index,
      ),
    );
  }

  String _formatDateKey(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatTanggalIndonesia(DateTime date) {
    final hari = _hariLengkap[date.weekday - 1];
    final bulan = _bulanPendek[date.month - 1];
    return '$hari, ${date.day} $bulan ${date.year}';
  }

  String _formatRentangMinggu(List<DateTime> weekDays) {
    final first = weekDays.first;
    final last = weekDays.last;
    final bulanAwal = _bulanPendek[first.month - 1];
    final bulanAkhir = _bulanPendek[last.month - 1];

    if (first.year == last.year) {
      if (first.month == last.month) {
        return '${first.day} - ${last.day} $bulanAkhir ${last.year}';
      }
      return '${first.day} $bulanAwal - ${last.day} $bulanAkhir ${last.year}';
    }
    return '${first.day} $bulanAwal ${first.year} - ${last.day} $bulanAkhir ${last.year}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isPastDay(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    return target.isBefore(today);
  }

  String _formatJamMenit(int hour, int minute) {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    return '$h.$m';
  }

  Map<String, dynamic>? _getDayScheduleMap(
      DocumentSnapshot? doctorDoc,
      DateTime date,
      ) {
    if (doctorDoc == null || !doctorDoc.exists) return null;
    final rawData = doctorDoc.data() as Map<String, dynamic>?;
    if (rawData == null) return null;

    final weekly = rawData['weeklySchedule'];
    if (weekly is Map<String, dynamic>) {
      final entry = weekly[date.weekday.toString()];
      if (entry is Map<String, dynamic>) {
        return entry;
      }
    }
    return null;
  }

  bool _isShiftActiveOnDate(
      DocumentSnapshot? doctorDoc,
      Doctor liveDoctor,
      DateTime date,
      ) {
    final daySchedule = _getDayScheduleMap(doctorDoc, date);
    if (daySchedule != null) {
      return (daySchedule['isActive'] as bool?) ?? false;
    }
    return liveDoctor.isShiftActiveToday;
  }

  String _namaShiftOnDate(
      DocumentSnapshot? doctorDoc,
      Doctor liveDoctor,
      DateTime date,
      ) {
    final daySchedule = _getDayScheduleMap(doctorDoc, date);
    if (daySchedule != null) {
      final nama = (daySchedule['namaShift'] ?? '').toString().trim();
      if (nama.isNotEmpty) return nama;
    }
    if (liveDoctor.namaShiftHariIni.trim().isNotEmpty) {
      return liveDoctor.namaShiftHariIni.trim();
    }
    return 'Jadwal Praktik';
  }

  int _jamMulaiOnDate(
      DocumentSnapshot? doctorDoc,
      Doctor liveDoctor,
      DateTime date,
      ) {
    final daySchedule = _getDayScheduleMap(doctorDoc, date);
    if (daySchedule != null) {
      return (daySchedule['jamMulai'] as num?)?.toInt() ?? 0;
    }
    return liveDoctor.jamMulai;
  }

  int _jamSelesaiOnDate(
      DocumentSnapshot? doctorDoc,
      Doctor liveDoctor,
      DateTime date,
      ) {
    final daySchedule = _getDayScheduleMap(doctorDoc, date);
    if (daySchedule != null) {
      return (daySchedule['jamSelesai'] as num?)?.toInt() ?? 0;
    }
    return liveDoctor.jamSelesai;
  }

  String _breakTimeOnDate(
      DocumentSnapshot? doctorDoc,
      Doctor liveDoctor,
      DateTime date,
      ) {
    final daySchedule = _getDayScheduleMap(doctorDoc, date);
    if (daySchedule != null) {
      final bStart = (daySchedule['breakStart'] as num?)?.toInt();
      final bEnd = (daySchedule['breakEnd'] as num?)?.toInt();
      if (bStart != null && bEnd != null && bStart >= 0 && bEnd >= 0) {
        return '${bStart.toString().padLeft(2, '0')}.00 - ${bEnd.toString().padLeft(2, '0')}.00 WIB';
      }
      return 'Tidak ada';
    }
    try {
      return liveDoctor.breakTimeRange;
    } catch (_) {
      return '18.00 - 19.00 WIB';
    }
  }

  List<String> _slotsOnDate(
      DocumentSnapshot? doctorDoc,
      Doctor liveDoctor,
      DateTime date, {
        int intervalMinutes = 20,
      }) {
    if (!_isShiftActiveOnDate(doctorDoc, liveDoctor, date)) return [];

    final int startHour = _jamMulaiOnDate(doctorDoc, liveDoctor, date);
    int endHour = _jamSelesaiOnDate(doctorDoc, liveDoctor, date);
    if (startHour == endHour) return [];

    if (endHour < startHour) {
      endHour += 24;
    }

    final daySchedule = _getDayScheduleMap(doctorDoc, date);
    final int? bStartHour = (daySchedule?['breakStart'] as num?)?.toInt();
    final int? bEndHour = (daySchedule?['breakEnd'] as num?)?.toInt();

    final bool hasCustomBreak =
        bStartHour != null && bEndHour != null && bStartHour >= 0 && bEndHour >= 0;
    final int breakStartMin = hasCustomBreak ? bStartHour * 60 : 18 * 60;
    final int breakEndMin = hasCustomBreak ? bEndHour * 60 : 19 * 60;
    final bool checkBreak =
    daySchedule != null ? hasCustomBreak : true;

    final int startTotalMin = startHour * 60;
    final int endTotalMin = endHour * 60;

    final List<String> slots = [];
    int currentMin = startTotalMin;

    while (currentMin + intervalMinutes <= endTotalMin) {
      final int nextMin = currentMin + intervalMinutes;
      final bool overlapsBreak = checkBreak &&
          (currentMin < breakEndMin) &&
          (nextMin > breakStartMin);

      if (!overlapsBreak) {
        final int sHour = (currentMin ~/ 60) % 24;
        final int sMin = currentMin % 60;
        final int eHour = (nextMin ~/ 60) % 24;
        final int eMin = nextMin % 60;

        slots.add(
          '${_formatJamMenit(sHour, sMin)} - ${_formatJamMenit(eHour, eMin)}',
        );
      }

      currentMin = nextMin;
    }

    return slots;
  }

  bool _isSlotExpiredForDate(
      String slotRange,
      DateTime targetDate,
      int jamMulai,
      int jamSelesai,
      ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected =
    DateTime(targetDate.year, targetDate.month, targetDate.day);

    if (selected.isBefore(today)) return true;
    if (selected.isAfter(today)) return false;

    try {
      final slotParts = slotRange.split('-');
      if (slotParts.isEmpty) return false;

      final startTimeStr = slotParts[0].trim().replaceAll(':', '.');
      final parts = startTimeStr.split('.');
      final int hour = int.parse(parts[0]);
      final int minute = parts.length > 1 ? int.parse(parts[1]) : 0;

      DateTime slotStartDateTime;
      if (jamMulai > jamSelesai) {
        if (now.hour >= jamMulai && hour < jamMulai) {
          slotStartDateTime =
              DateTime(now.year, now.month, now.day + 1, hour, minute);
        } else {
          slotStartDateTime =
              DateTime(now.year, now.month, now.day, hour, minute);
        }
      } else {
        slotStartDateTime =
            DateTime(now.year, now.month, now.day, hour, minute);
      }

      return slotStartDateTime.isBefore(now);
    } catch (_) {
      return false;
    }
  }

  String _formatShiftRange(
      DocumentSnapshot? doctorDoc,
      Doctor liveDoctor,
      DateTime date,
      ) {
    final isActive = _isShiftActiveOnDate(doctorDoc, liveDoctor, date);
    final startHour = _jamMulaiOnDate(doctorDoc, liveDoctor, date);
    final endHour = _jamSelesaiOnDate(doctorDoc, liveDoctor, date);

    if (!isActive || (startHour == 0 && endHour == 0)) {
      return 'Jadwal Tutup / Libur';
    }
    final start = startHour.toString().padLeft(2, '0');
    final end = endHour.toString().padLeft(2, '0');
    return '$start.00 - $end.00 WIB';
  }

  DateTime _buildSessionStartDateTime(DateTime date, String slotRange) {
    final slotParts = slotRange.split('-');
    final jamMulaiStr = slotParts[0].trim().replaceAll('.', ':');
    final startParts = jamMulaiStr.split(':');
    final int jamMulai = int.parse(startParts[0]);
    final int menitMulai = startParts.length > 1 ? int.parse(startParts[1]) : 0;

    return DateTime(
      date.year,
      date.month,
      date.day,
      jamMulai,
      menitMulai,
    );
  }

  Future<void> _prosesBooking(
      DocumentSnapshot? doctorDoc,
      Doctor liveDoctor,
      ) async {
    final isActive = _isShiftActiveOnDate(doctorDoc, liveDoctor, _selectedDate);
    if (!isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Maaf, jadwal shift dokter pada tanggal ini sedang dinonaktifkan.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih slot jam konsultasi terlebih dahulu!'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String tanggalStr = _formatDateKey(_selectedDate);
    final DocumentReference slotRef = FirebaseFirestore.instance
        .collection('doctors')
        .doc(liveDoctor.id)
        .collection('booking_slots')
        .doc('${tanggalStr}_${_selectedSlot!}');

    try {
      final result =
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(slotRef);

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>?;
          if (data?['isBooked'] == true) {
            return false;
          }
        }

        transaction.set(slotRef, {
          'slotWaktu': _selectedSlot,
          'isBooked': true,
          'bookedByUserId': widget.namaUser,
          'tanggal': tanggalStr,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return true;
      });

      if (!mounted) return;

      if (result) {
        try {
          await FirebaseFirestore.instance
              .collection('consultation_bookings')
              .add({
            'doctor_id': liveDoctor.id,
            'user_id': widget.namaUser,
            'booking_date': tanggalStr,
            'booking_time': _selectedSlot,
            'status': 'confirmed',
            'screening_result_id': 'ID_SCREENING_HASIL',
            'created_at': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          debugPrint('Gagal mencatat ke consultation_bookings: $e');
        }

        final slotParts = _selectedSlot!.split('-');
        final jamMulaiStr = slotParts[0].trim().replaceAll('.', ':');
        final jamSelesaiStr = slotParts.length > 1
            ? slotParts[1].trim().replaceAll('.', ':')
            : jamMulaiStr;

        final int jamMulai = int.parse(jamMulaiStr.split(':')[0]);
        final int jamSelesai = int.parse(jamSelesaiStr.split(':')[0]);

        final waktuMulaiSesi =
        _buildSessionStartDateTime(_selectedDate, _selectedSlot!);

        try {
          await NotificationService().scheduleReminder(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            dokterNama: liveDoctor.nama,
            waktuMulaiSesi: waktuMulaiSesi,
          );
        } catch (e) {
          debugPrint('NotificationService belum siap: $e');
        }

        try {
          final currentUserId =
              FirebaseAuth.instance.currentUser?.uid ?? widget.namaUser;
          await FirebaseFirestore.instance.collection('notifications').add({
            'user_id': currentUserId,
            'title': 'Jadwal Konsultasi Dikonfirmasi',
            'body':
            'Konsultasi Anda dengan ${liveDoctor.nama} pada ${_formatTanggalIndonesia(_selectedDate)} pukul $_selectedSlot telah berhasil dijadwalkan.',
            'type': 'booking',
            'is_read': false,
            'created_at': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          debugPrint('Gagal menyimpan notifikasi ke database: $e');
        }

        if (!mounted) return;

        final String roomId =
            '${widget.namaUser}_${liveDoctor.id}_${tanggalStr}_${_selectedSlot!.replaceAll(' ', '')}';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatKonsultasiPage(
              roomId: roomId,
              currentUserId: widget.namaUser,
              dokterNama: liveDoctor.nama,
              jamMulai: jamMulai,
              jamSelesai: jamSelesai,
              slotWaktu: _selectedSlot!,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Slot waktu ini baru saja dibooking oleh orang lain. Silakan pilih slot lain.',
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _bukaKembaliChat(Doctor liveDoctor, String slotWaktu) {
    final slotParts = slotWaktu.split('-');
    final jamMulaiStr = slotParts[0].trim().replaceAll('.', ':');
    final jamSelesaiStr = slotParts.length > 1
        ? slotParts[1].trim().replaceAll('.', ':')
        : jamMulaiStr;

    final int jamMulai = int.parse(jamMulaiStr.split(':')[0]);
    final int jamSelesai = int.parse(jamSelesaiStr.split(':')[0]);
    final String tanggalStr = _formatDateKey(_selectedDate);

    final String roomId =
        '${widget.namaUser}_${liveDoctor.id}_${tanggalStr}_${slotWaktu.replaceAll(' ', '')}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatKonsultasiPage(
          roomId: roomId,
          currentUserId: widget.namaUser,
          dokterNama: liveDoctor.nama,
          jamMulai: jamMulai,
          jamSelesai: jamSelesai,
          slotWaktu: slotWaktu,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String tanggalDipilihStr = _formatDateKey(_selectedDate);
    final double topPadding = MediaQuery.of(context).padding.top + 12;
    final List<DateTime> weekDays = _getWeekDays(_weekOffset);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctor.id)
          .snapshots(),
      builder: (context, doctorDocSnap) {
        final DocumentSnapshot? docSnap =
        (doctorDocSnap.hasData && doctorDocSnap.data!.exists)
            ? doctorDocSnap.data
            : null;

        final Doctor liveDoctor = docSnap != null
            ? Doctor.fromFirestore(
          docSnap.data() as Map<String, dynamic>,
          docSnap.id,
        )
            : widget.doctor;

        final bool isShiftActive =
        _isShiftActiveOnDate(docSnap, liveDoctor, _selectedDate);
        final String namaShift =
        _namaShiftOnDate(docSnap, liveDoctor, _selectedDate);
        final int jamMulaiShift =
        _jamMulaiOnDate(docSnap, liveDoctor, _selectedDate);
        final int jamSelesaiShift =
        _jamSelesaiOnDate(docSnap, liveDoctor, _selectedDate);
        final String breakRange =
        _breakTimeOnDate(docSnap, liveDoctor, _selectedDate);
        final List<String> daftarSlot =
        _slotsOnDate(docSnap, liveDoctor, _selectedDate);

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          body: Column(
            children: [
              // HEADER LIQUID WAVE
              ClipPath(
                clipper: _BookingLiquidClipper(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(16, topPadding, 16, 42),
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
                  child: SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 0,
                          top: 0,
                          bottom: 0,
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
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 36),
                            child: Text(
                              'Booking Jadwal Dokter',
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // KONTEN UTAMA
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // INFORMASI DOKTER RINGKAS
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF5B4AF4)
                                  .withValues(alpha: 0.06),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF6679F4),
                                    Color(0xFF8DA0FF),
                                  ],
                                ),
                              ),
                              child: const CircleAvatar(
                                radius: 22,
                                backgroundColor: Color(0xFFEEF2FF),
                                child: Icon(
                                  Icons.person_rounded,
                                  size: 26,
                                  color: Color(0xFF4F46E5),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    liveDoctor.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14.5,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    liveDoctor.spesialis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                  if (liveDoctor.isPenggantiHariIni &&
                                      liveDoctor
                                          .menggantikanDokter.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 7,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade50,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.amber.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        'Menggantikan ${liveDoctor.menggantikanDokter}',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // PEMILIH TANGGAL MINGGUAN (1 MINGGU 1 MINGGU)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 30,
                                        minHeight: 30,
                                      ),
                                      onPressed: _weekOffset > 0
                                          ? () {
                                        setState(() {
                                          _weekOffset--;
                                          _selectedSlot = null;
                                          final newDays =
                                          _getWeekDays(_weekOffset);
                                          _selectedDate =
                                          _isPastDay(newDays.first)
                                              ? DateTime.now()
                                              : newDays.first;
                                        });
                                      }
                                          : null,
                                      icon: Icon(
                                        Icons.chevron_left_rounded,
                                        color: _weekOffset > 0
                                            ? const Color(0xFF4F46E5)
                                            : const Color(0xFFCBD5E1),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _formatRentangMinggu(weekDays),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12.5,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    IconButton(
                                      visualDensity: VisualDensity.compact,
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 30,
                                        minHeight: 30,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _weekOffset++;
                                          _selectedSlot = null;
                                          final newDays =
                                          _getWeekDays(_weekOffset);
                                          _selectedDate = newDays.first;
                                        });
                                      },
                                      icon: const Icon(
                                        Icons.chevron_right_rounded,
                                        color: Color(0xFF4F46E5),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _weekOffset == 0
                                        ? 'Minggu Ini'
                                        : 'Minggu +$_weekOffset',
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4F46E5),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: weekDays.map((day) {
                                final bool isSelected =
                                _isSameDay(day, _selectedDate);
                                final bool isPast = _isPastDay(day);
                                final String labelHari =
                                _hariPendek[day.weekday - 1];

                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(12),
                                      onTap: isPast
                                          ? null
                                          : () {
                                        setState(() {
                                          _selectedDate = DateTime(
                                            day.year,
                                            day.month,
                                            day.day,
                                          );
                                          _selectedSlot = null;
                                        });
                                      },
                                      child: AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 160),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 8),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? const Color(0xFF4F46E5)
                                              : isPast
                                              ? const Color(0xFFF8FAFC)
                                              : const Color(0xFFF1F5F9),
                                          borderRadius:
                                          BorderRadius.circular(12),
                                          border: Border.all(
                                            color: isSelected
                                                ? const Color(0xFF4F46E5)
                                                : Colors.transparent,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              labelHari,
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? Colors.white70
                                                    : isPast
                                                    ? const Color(
                                                    0xFFCBD5E1)
                                                    : const Color(
                                                    0xFF64748B),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${day.day}',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected
                                                    ? Colors.white
                                                    : isPast
                                                    ? const Color(
                                                    0xFFCBD5E1)
                                                    : const Color(
                                                    0xFF0F172A),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatTanggalIndonesia(_selectedDate),
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // STREAM BUILDER SLOT REAL-TIME UNTUK TANGGAL TERPILIH
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('consultation_bookings')
                              .where('doctor_id', isEqualTo: liveDoctor.id)
                              .where(
                            'booking_date',
                            isEqualTo: tanggalDipilihStr,
                          )
                              .snapshots(),
                          builder: (context, snapshot) {
                            final Map<String, String> bookedSlotsWithUsers = {};

                            if (snapshot.hasData) {
                              for (var doc in snapshot.data!.docs) {
                                final data =
                                doc.data() as Map<String, dynamic>;
                                final slotName =
                                (data['booking_time'] ?? '').toString();
                                if (slotName.isNotEmpty) {
                                  bookedSlotsWithUsers[slotName] =
                                      (data['user_id'] ?? '').toString();
                                }
                              }
                            }

                            int activeAvailableSlots = 0;
                            for (var slot in daftarSlot) {
                              final bool isBooked =
                              bookedSlotsWithUsers.containsKey(slot);
                              final bool isExpired = _isSlotExpiredForDate(
                                slot,
                                _selectedDate,
                                jamMulaiShift,
                                jamSelesaiShift,
                              );
                              if (!isBooked && !isExpired) {
                                activeAvailableSlots++;
                              }
                            }

                            final String? selectedBookedBy = _selectedSlot != null
                                ? bookedSlotsWithUsers[_selectedSlot]
                                : null;
                            final bool isSelectedBookedByMe =
                                _selectedSlot != null &&
                                    selectedBookedBy == widget.namaUser;

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // BANNER SHIFT & KUOTA DINAMIS
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 11,
                                  ),
                                  decoration: BoxDecoration(
                                    color: activeAvailableSlots > 0 &&
                                        isShiftActive
                                        ? const Color(0xFFF0FDF4)
                                        : const Color(0xFFFEF2F2),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: activeAvailableSlots > 0 &&
                                          isShiftActive
                                          ? const Color(0xFFBBF7D0)
                                          : const Color(0xFFFECACA),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: activeAvailableSlots > 0 &&
                                              isShiftActive
                                              ? const Color(0xFFDCFCE7)
                                              : const Color(0xFFFEE2E2),
                                          borderRadius:
                                          BorderRadius.circular(10),
                                        ),
                                        child: Icon(
                                          Icons.schedule_rounded,
                                          size: 20,
                                          color: activeAvailableSlots > 0 &&
                                              isShiftActive
                                              ? const Color(0xFF16A34A)
                                              : const Color(0xFFDC2626),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              !isShiftActive
                                                  ? 'Jadwal Dokter Tidak Aktif'
                                                  : 'Kuota Pasien ($namaShift)',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12.5,
                                                color: activeAvailableSlots > 0 &&
                                                    isShiftActive
                                                    ? const Color(0xFF15803D)
                                                    : const Color(0xFFB91C1C),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              !isShiftActive
                                                  ? 'Dokter tidak membuka praktik pada tanggal yang dipilih.'
                                                  : (activeAvailableSlots > 0
                                                  ? 'Tersedia $activeAvailableSlots slot waktu (Istirahat: $breakRange)'
                                                  : 'Semua slot waktu pada tanggal ini telah terisi / terlewat'),
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: activeAvailableSlots > 0 &&
                                                    isShiftActive
                                                    ? const Color(0xFF166534)
                                                    : const Color(0xFF991B1B),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 14),

                                // HEADER PILIH SESI + CHIP JAM SHIFT
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Pilih Sesi Konsultasi',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        _formatShiftRange(
                                            docSnap, liveDoctor, _selectedDate),
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF5B4AF4),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // GRID SLOT KONSULTASI
                                Expanded(
                                  child: daftarSlot.isEmpty
                                      ? Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(18),
                                        border: Border.all(
                                          color: const Color(0xFFE2E8F0),
                                        ),
                                      ),
                                      child: const Text(
                                        'Tidak ada slot konsultasi tersedia untuk jadwal dokter pada tanggal ini.',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          color: Color(0xFF64748B),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                      : StreamBuilder<QuerySnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('chats')
                                        .snapshots(),
                                    builder: (context, chatSnapshot) {
                                      final Set<String> endedRoomIds = {};
                                      if (chatSnapshot.hasData) {
                                        for (var doc
                                        in chatSnapshot.data!.docs) {
                                          final data = doc.data()
                                          as Map<String, dynamic>;
                                          if (data['isEnded'] == true) {
                                            endedRoomIds.add(doc.id);
                                          }
                                        }
                                      }

                                      return GridView.builder(
                                        padding: const EdgeInsets.only(
                                            bottom: 12),
                                        physics:
                                        const BouncingScrollPhysics(),
                                        gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 1.65,
                                          crossAxisSpacing: 10,
                                          mainAxisSpacing: 10,
                                        ),
                                        itemCount: daftarSlot.length,
                                        itemBuilder: (context, index) {
                                          final slot = daftarSlot[index];
                                          final bool isBooked =
                                          bookedSlotsWithUsers
                                              .containsKey(slot);
                                          final String bookedByUser =
                                              bookedSlotsWithUsers[slot] ??
                                                  '';
                                          final bool isDipesanOlehSaya =
                                              isBooked &&
                                                  (bookedByUser ==
                                                      widget.namaUser);

                                          final String roomId =
                                              '${widget.namaUser}_${liveDoctor.id}_${tanggalDipilihStr}_${slot.replaceAll(' ', '')}';
                                          final bool isChatEnded =
                                          endedRoomIds.contains(roomId);

                                          final bool isExpired =
                                          _isSlotExpiredForDate(
                                            slot,
                                            _selectedDate,
                                            jamMulaiShift,
                                            jamSelesaiShift,
                                          );

                                          final bool isTersedia =
                                              !isBooked && !isExpired;
                                          final bool isSelected =
                                              _selectedSlot == slot;

                                          String statusLabel = 'Tersedia';
                                          Color statusColor =
                                          const Color(0xFF16A34A);
                                          Color textColor =
                                          const Color(0xFF0F172A);
                                          Color bgColor = Colors.white;
                                          Color borderColor =
                                          const Color(0xFFE2E8F0);

                                          if (isSelected) {
                                            textColor = Colors.white;
                                            statusColor = Colors.white70;
                                            borderColor =
                                            const Color(0xFF4F46E5);
                                          } else if (isDipesanOlehSaya) {
                                            bgColor =
                                            const Color(0xFFEEF2FF);
                                            borderColor =
                                            const Color(0xFFC7D2FE);
                                            statusColor =
                                            const Color(0xFF4F46E5);
                                            statusLabel = isChatEnded
                                                ? 'Selesai'
                                                : 'Jadwal Saya';
                                          } else if (isBooked) {
                                            bgColor =
                                            const Color(0xFFF8FAFC);
                                            textColor =
                                            const Color(0xFF94A3B8);
                                            statusColor =
                                            const Color(0xFF94A3B8);
                                            statusLabel = 'Terisi';
                                          } else if (isExpired) {
                                            bgColor =
                                            const Color(0xFFF8FAFC);
                                            textColor =
                                            const Color(0xFF94A3B8);
                                            statusColor =
                                            const Color(0xFF94A3B8);
                                            statusLabel = 'Terlewat';
                                          }

                                          return InkWell(
                                            borderRadius:
                                            BorderRadius.circular(14),
                                            onTap: () {
                                              if (isDipesanOlehSaya) {
                                                _bukaKembaliChat(
                                                    liveDoctor, slot);
                                              } else if (isTersedia) {
                                                setState(() {
                                                  _selectedSlot = slot;
                                                });
                                              }
                                            },
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 180),
                                              padding:
                                              const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 6,
                                              ),
                                              decoration: BoxDecoration(
                                                gradient: isSelected
                                                    ? const LinearGradient(
                                                  colors: [
                                                    Color(0xFF5B4AF4),
                                                    Color(0xFF4F46E5),
                                                  ],
                                                  begin: Alignment
                                                      .topLeft,
                                                  end: Alignment
                                                      .bottomRight,
                                                )
                                                    : null,
                                                color: isSelected
                                                    ? null
                                                    : bgColor,
                                                borderRadius:
                                                BorderRadius.circular(
                                                    14),
                                                border: Border.all(
                                                  color: borderColor,
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                children: [
                                                  Text(
                                                    slot,
                                                    textAlign:
                                                    TextAlign.center,
                                                    maxLines: 1,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 11.5,
                                                      fontWeight:
                                                      FontWeight.bold,
                                                      color: textColor,
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                      height: 3),
                                                  Text(
                                                    statusLabel,
                                                    maxLines: 1,
                                                    overflow: TextOverflow
                                                        .ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                      FontWeight.w600,
                                                      color: statusColor,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // TOMBOL KONFIRMASI BOOKING / BUKA CHAT
                                SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: ElevatedButton(
                                    onPressed: _isLoading || !isShiftActive
                                        ? null
                                        : (isSelectedBookedByMe &&
                                        _selectedSlot != null)
                                        ? () => _bukaKembaliChat(
                                        liveDoctor, _selectedSlot!)
                                        : (_selectedSlot != null
                                        ? () => _prosesBooking(
                                        docSnap, liveDoctor)
                                        : null),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      disabledBackgroundColor:
                                      const Color(0xFFE2E8F0),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                        : Text(
                                      !isShiftActive
                                          ? 'Jadwal Tidak Aktif'
                                          : _selectedSlot == null
                                          ? 'Pilih Sesi Jam Terlebih Dahulu'
                                          : isSelectedBookedByMe
                                          ? 'Buka Ruang Konsultasi ($_selectedSlot)'
                                          : 'Konfirmasi Booking ($_selectedSlot)',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BookingLiquidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 24);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height,
      size.width * 0.5,
      size.height - 14,
    );
    path.quadraticBezierTo(
      size.width * 0.78,
      size.height - 32,
      size.width,
      size.height - 10,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}