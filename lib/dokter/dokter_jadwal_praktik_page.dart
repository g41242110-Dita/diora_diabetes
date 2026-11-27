import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

typedef ShiftMap = Map<String, dynamic>;

class DokterJadwalPraktikPage extends StatefulWidget {
  final String doctorId;

  const DokterJadwalPraktikPage({super.key, required this.doctorId});

  @override
  State<DokterJadwalPraktikPage> createState() =>
      _DokterJadwalPraktikPageState();
}

class _DokterJadwalPraktikPageState extends State<DokterJadwalPraktikPage> {
  final List<String> _urutanHari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  final Map<String, int> _weekdayMap = {
    'Senin': 1,
    'Selasa': 2,
    'Rabu': 3,
    'Kamis': 4,
    'Jumat': 5,
    'Sabtu': 6,
    'Minggu': 7,
  };

  final List<String> _namaBulan = [
    '',
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

  String _formatJam(int jam) {
    return '${jam.toString().padLeft(2, '0')}.00';
  }

  DateTime _getTanggalTerdekat(String namaHari) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final int targetWeekday = _weekdayMap[namaHari] ?? today.weekday;
    int selisihHari = targetWeekday - today.weekday;
    if (selisihHari < 0) {
      selisihHari += 7;
    }
    return today.add(Duration(days: selisihHari));
  }

  String _formatDateIso(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatLabelTanggal(DateTime targetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final diff = targetDate.difference(today).inDays;

    final String tglStr = '${targetDate.day}${_namaBulan[targetDate.month]}';
    if (diff == 0) return '$tglStr • Hari Ini';
    if (diff == 1) return '$tglStr • Besok';
    return '$tglStr • Minggu Depan';
  }

  Future<int> _hitungPasienBookedPadaTanggal(String tanggalIso) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('consultation_bookings')
        .where('doctor_id', isEqualTo: widget.doctorId)
        .where('booking_date', isEqualTo: tanggalIso)
        .get();

    return snapshot.docs.length;
  }

  Future<void> _handleToggleShift({
    required String hari,
    required String tanggalIso,
    required String labelTanggal,
    required bool newValue,
    required ShiftMap shiftData,
  }) async {
    final bool isPengganti = shiftData['isPengganti'] == true;
    final String dokterAsalId =
    (shiftData['dokterAsalId'] ?? '').toString().trim();
    final String menggantikanDokter =
    (shiftData['menggantikanDokter'] ?? '').toString().trim();

    // Jika dokter pengganti mematikan shift penggantinya, kembalikan status shift ke dokter asal
    if (isPengganti && !newValue) {
      final bool? batalGanti = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          title: const Text(
            'Batalkan Penggantian Shift?',
            style: TextStyle(
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          content: Text(
            'Shift hari $hari ($labelTanggal) yang menggantikan $menggantikanDokter akan dilepas dan dibuka kembali untuk dokter lain. Lanjutkan?',
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF475569),
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text(
                'Batal',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Ya, Lepas Shift',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );

      if (batalGanti != true) return;

      final batch = FirebaseFirestore.instance.batch();
      final doctorsRef = FirebaseFirestore.instance.collection('doctors');

      batch.update(doctorsRef.doc(widget.doctorId), {
        'jadwal_shift.$hari': FieldValue.delete(),
      });

      if (dokterAsalId.isNotEmpty) {
        batch.update(doctorsRef.doc(dokterAsalId), {
          'jadwal_shift.$hari.butuhPengganti': true,
          'jadwal_shift.$hari.digantikanOleh': FieldValue.delete(),
          'jadwal_shift.$hari.digantikanOlehId': FieldValue.delete(),
        });
      }

      await batch.commit();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Shift pengganti hari $hari ($labelTanggal) dilepas & dibuka kembali.'),
            backgroundColor: const Color(0xFF475569),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    // Cegah mengaktifkan ulang jika shift sudah diambil dokter pengganti
    final String digantikanOleh =
    (shiftData['digantikanOleh'] ?? '').toString().trim();
    if (newValue && digantikanOleh.isNotEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Jadwal tidak dapat diaktifkan karena sudah digantikan oleh $digantikanOleh.'),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    if (!newValue) {
      final int jumlahPasien = await _hitungPasienBookedPadaTanggal(tanggalIso);

      if (jumlahPasien > 0 && mounted) {
        final bool? lanjutTutup = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 26),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Peringatan Antrean Pasien',
                    style: TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              'Pada hari $hari ($labelTanggal) terdapat $jumlahPasien pasien yang sudah booking konsultasi.\n\nJika shift dimatikan, slot baru akan ditutup dan jadwal dibuka agar bisa digantikan dokter lain. Tetap nonaktifkan?',
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF475569),
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text(
                  'Batal',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Ya, Nonaktifkan',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );

        if (lanjutTutup != true) return;
      }
    }

    await FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctorId)
        .update({
      'jadwal_shift.$hari.isActive': newValue,
      'jadwal_shift.$hari.butuhPengganti': !newValue,
      if (newValue) 'jadwal_shift.$hari.digantikanOleh': FieldValue.delete(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newValue
                ? 'Shift hari $hari ($labelTanggal) diaktifkan.'
                : 'Shift hari $hari ($labelTanggal) dinonaktifkan & dibuka untuk dokter pengganti.',
          ),
          backgroundColor:
          newValue ? const Color(0xFF059669) : const Color(0xFF475569),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _ambilShiftPengganti({
    required String dokterAsalId,
    required String namaDokterAsal,
    required String namaDokterPengganti,
    required String hari,
    required String labelTanggal,
    required ShiftMap shiftData,
  }) async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Gantikan Shift Dokter',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Anda akan menggantikan jadwal $namaDokterAsal pada hari $hari ($labelTanggal) • ${shiftData['namaShift']} (${_formatJam(shiftData['jamMulai'])} - ${_formatJam(shiftData['jamSelesai'])} WIB).\n\nLanjutkan mengambil shift ini?',
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF475569),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Ya, Gantikan',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (konfirmasi != true) return;

    final batch = FirebaseFirestore.instance.batch();
    final doctorsRef = FirebaseFirestore.instance.collection('doctors');
    final notifRef =
    FirebaseFirestore.instance.collection('notifications').doc();

    final String jamStr =
        '${_formatJam(shiftData['jamMulai'])} - ${_formatJam(shiftData['jamSelesai'])} WIB';
    final String namaShift =
    (shiftData['namaShift'] ?? 'Shift Praktik').toString();

    batch.update(doctorsRef.doc(widget.doctorId), {
      'jadwal_shift.$hari': {
        'namaShift': namaShift,
        'jamMulai': shiftData['jamMulai'],
        'jamSelesai': shiftData['jamSelesai'],
        'isActive': true,
        'isPengganti': true,
        'menggantikanDokter': namaDokterAsal,
        'dokterAsalId': dokterAsalId,
      },
    });

    batch.update(doctorsRef.doc(dokterAsalId), {
      'jadwal_shift.$hari.butuhPengganti': false,
      'jadwal_shift.$hari.digantikanOleh': namaDokterPengganti,
      'jadwal_shift.$hari.digantikanOlehId': widget.doctorId,
    });

    batch.set(notifRef, {
      'recipient_id': dokterAsalId,
      'doctor_id': dokterAsalId,
      'sender_id': widget.doctorId,
      'sender_name': namaDokterPengganti,
      'type': 'shift_replacement',
      'title': 'Shift Digantikan Dokter Lain',
      'message':
      '$namaDokterPengganti telah mengambil alih jadwal $hari ($labelTanggal) • $namaShift ($jamStr).',
      'hari': hari,
      'label_tanggal': labelTanggal,
      'is_read': false,
      'created_at': FieldValue.serverTimestamp(),
    });

    await batch.commit();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Berhasil menggantikan shift $namaDokterAsal pada hari $hari ($labelTanggal).'),
          backgroundColor: const Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Jadwal Praktik & Shift',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('doctors').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Data dokter tidak ditemukan.'));
          }

          DocumentSnapshot? myDoc;
          final List<ShiftMap> shiftButuhPengganti = [];

          for (var doc in snapshot.data!.docs) {
            if (doc.id == widget.doctorId) {
              myDoc = doc;
            }
          }

          if (myDoc == null || !myDoc.exists) {
            return const Center(child: Text('Akun dokter tidak ditemukan.'));
          }

          final myData = myDoc.data() as ShiftMap;
          final String namaSaya =
          (myData['nama'] ?? 'Dokter Pengganti').toString();
          final ShiftMap myJadwalShift =
              (myData['jadwal_shift'] as ShiftMap?) ?? {};

          for (var doc in snapshot.data!.docs) {
            if (doc.id == widget.doctorId) continue;
            final otherData = doc.data() as ShiftMap;
            final String namaDokterLain = otherData['nama'] ?? 'Dokter Lain';
            final ShiftMap otherSchedule =
                (otherData['jadwal_shift'] as ShiftMap?) ?? {};

            otherSchedule.forEach((hari, value) {
              if (value is ShiftMap) {
                final bool isActive = value['isActive'] ?? true;
                final bool butuhPengganti =
                    value['butuhPengganti'] ?? (!isActive);
                if (!isActive &&
                    butuhPengganti &&
                    !myJadwalShift.containsKey(hari)) {
                  shiftButuhPengganti.add({
                    'dokterAsalId': doc.id,
                    'namaDokterAsal': namaDokterLain,
                    'hari': hari,
                    'shiftData': value,
                  });
                }
              }
            });
          }

          final List<String> hariAktifDokter = _urutanHari
              .where((hari) => myJadwalShift.containsKey(hari))
              .toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        color: Color(0xFF6366F1), size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Jadwal berlaku mingguan. Geser switch ke OFF jika Anda berhalangan; shift akan dibuka agar bisa digantikan dokter lain.',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF3730A3),
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 10),
                child: Text(
                  'Jadwal Shift Rutin Anda',
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
              if (hariAktifDokter.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Text(
                    'Belum ada jadwal shift yang diatur untuk akun ini.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                )
              else
                ...hariAktifDokter.map((hari) {
                  final shiftData = myJadwalShift[hari] as ShiftMap;
                  final String namaShift =
                      shiftData['namaShift'] ?? 'Shift Praktik';
                  final int jamMulai = (shiftData['jamMulai'] ?? 7) as int;
                  final int jamSelesai = (shiftData['jamSelesai'] ?? 15) as int;
                  final bool isActive = shiftData['isActive'] ?? false;
                  final bool isPengganti = shiftData['isPengganti'] == true;
                  final String menggantikan =
                  (shiftData['menggantikanDokter'] ?? '').toString().trim();
                  final String digantikanOleh =
                  (shiftData['digantikanOleh'] ?? '').toString().trim();

                  // Kunci tombol switch jika jadwal sudah diambil dokter pengganti
                  final bool terkunciDigantikan =
                      !isActive && digantikanOleh.isNotEmpty;

                  final DateTime targetDate = _getTanggalTerdekat(hari);
                  final String tanggalIso = _formatDateIso(targetDate);
                  final String labelTanggal = _formatLabelTanggal(targetDate);

                  String statusText;
                  Color statusColor;
                  if (isPengganti && menggantikan.isNotEmpty) {
                    statusText = 'Menggantikan $menggantikan';
                    statusColor = const Color(0xFF059669);
                  } else if (isActive) {
                    statusText = 'Slot terbuka untuk booking pasien';
                    statusColor = const Color(0xFF059669);
                  } else if (digantikanOleh.isNotEmpty) {
                    statusText = 'Digantikan oleh $digantikanOleh (Terkunci)';
                    statusColor = const Color(0xFF4338CA);
                  } else {
                    statusText = 'Jadwal ditutup (Menunggu pengganti / izin)';
                    statusColor = const Color(0xFF94A3B8);
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isActive
                            ? const Color(0xFF6366F1).withValues(alpha: 0.35)
                            : const Color(0xFFE2E8F0),
                        width: 1.3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                spacing: 6,
                                runSpacing: 4,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 9, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFFEEF2FF)
                                          : const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '$hari ($labelTanggal)',
                                      style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w900,
                                        color: isActive
                                            ? const Color(0xFF4338CA)
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                  if (isPengganti)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.amber.shade100,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        'Pengganti',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.amber.shade900,
                                        ),
                                      ),
                                    ),
                                  if (terkunciDigantikan)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 7, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.lock_rounded,
                                              size: 10,
                                              color: Color(0xFF4338CA)),
                                          SizedBox(width: 3),
                                          Text(
                                            'Sudah Digantikan',
                                            style: TextStyle(
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w800,
                                              color: Color(0xFF4338CA),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                namaShift,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? const Color(0xFF475569)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatJam(jamMulai)} - ${_formatJam(jamSelesai)} WIB',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.3,
                                  color: isActive
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: statusColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isActive,
                          activeThumbColor: Colors.white,
                          activeTrackColor: const Color(0xFF059669),
                          onChanged: terkunciDigantikan
                              ? null
                              : (val) => _handleToggleShift(
                            hari: hari,
                            tanggalIso: tanggalIso,
                            labelTanggal: labelTanggal,
                            newValue: val,
                            shiftData: shiftData,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              if (shiftButuhPengganti.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz_rounded,
                          color: Color(0xFF6366F1), size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Shift Tersedia untuk Digantikan',
                        style: TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
                ...shiftButuhPengganti.map((item) {
                  final String hari = item['hari'];
                  final String namaDokterAsal = item['namaDokterAsal'];
                  final String dokterAsalId = item['dokterAsalId'];
                  final ShiftMap shiftData = item['shiftData'];
                  final int jamMulai = (shiftData['jamMulai'] ?? 7) as int;
                  final int jamSelesai = (shiftData['jamSelesai'] ?? 15) as int;
                  final String labelTanggal =
                  _formatLabelTanggal(_getTanggalTerdekat(hari));

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$hari ($labelTanggal) • ${shiftData['namaShift']}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF4338CA),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatJam(jamMulai)} - ${_formatJam(jamSelesai)} WIB',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                'Jadwal milik $namaDokterAsal sedang kosong',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _ambilShiftPengganti(
                            dokterAsalId: dokterAsalId,
                            namaDokterAsal: namaDokterAsal,
                            namaDokterPengganti: namaSaya,
                            hari: hari,
                            labelTanggal: labelTanggal,
                            shiftData: shiftData,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6366F1),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Gantikan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          );
        },
      ),
    );
  }
}