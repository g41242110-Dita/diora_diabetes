import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'dokter_curved_nav_bar.dart';
import 'dokter_skrining_page.dart';
import 'dokter_konsultasi_page.dart';
import 'dokter_lokasi_page.dart';
import 'dokter_profil_page.dart';
import 'dokter_room_chat_page.dart';
import 'dokter_jadwal_praktik_page.dart';
import 'dokter_notifikasi_page.dart';

class DokterBerandaPage extends StatefulWidget {
  final String? doctorId;

  const DokterBerandaPage({super.key, this.doctorId});

  @override
  State<DokterBerandaPage> createState() => DokterBerandaPageState();
}

class DokterBerandaPageState extends State<DokterBerandaPage> {
  int currentIndex = 0;
  bool hasUnreadNotif = false;
  bool _isInitialBookingLoad = true;
  bool _isInitialChatLoad = true;

  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel _dioraAlertChannel =
  AndroidNotificationChannel(
    'diora_dokter_alerts_v1',
    'Notifikasi Pasien & Chat Dokter',
    description: 'Pemberitahuan booking konsultasi dan pesan pasien baru',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  String get _activeDoctorId =>
      (widget.doctorId != null && widget.doctorId!.trim().isNotEmpty)
          ? widget.doctorId!.trim()
          : '1';

  @override
  void initState() {
    super.initState();
    _initLocalNotification();
    _dengarkanBookingMasuk();
    _dengarkanPesanChatMasuk();
  }

  Future<void> _initLocalNotification() async {
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {}

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _localNotificationsPlugin.initialize(initializationSettings);

    final androidImplementation =
    _localNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(_dioraAlertChannel);
      await androidImplementation.requestNotificationsPermission();
    }
  }

  Future<void> _showHeadsUpNotification({
    required String judul,
    required String pesan,
  }) async {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _dioraAlertChannel.id,
      _dioraAlertChannel.name,
      channelDescription: _dioraAlertChannel.description,
      importance: Importance.max,
      priority: Priority.high,
      ticker: judul,
      playSound: true,
      enableVibration: true,
      visibility: NotificationVisibility.public,
    );

    final NotificationDetails notificationDetails =
    NotificationDetails(android: androidDetails);

    await _localNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      judul,
      pesan,
      notificationDetails,
    );
  }

  void _dengarkanBookingMasuk() {
    FirebaseFirestore.instance
        .collection('consultation_bookings')
        .where('doctor_id', isEqualTo: _activeDoctorId)
        .snapshots()
        .listen((snapshot) {
      if (_isInitialBookingLoad) {
        _isInitialBookingLoad = false;
        return;
      }

      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>? ?? {};
          final namaPasien = (data['user_id'] ??
              data['bookedByUserId'] ??
              data['patient_name'] ??
              'Pasien')
              .toString();
          final jamSesi =
          (data['booking_time'] ?? data['jam_sesi'] ?? '').toString();
          final tanggal =
          (data['booking_date'] ?? data['tanggal'] ?? '').toString();

          if (!mounted) return;
          setState(() => hasUnreadNotif = true);

          final detailWaktu = [
            if (tanggal.isNotEmpty) tanggal,
            if (jamSesi.isNotEmpty) '$jamSesi WIB',
          ].join(' • ');

          _showHeadsUpNotification(
            judul: 'Booking Konsultasi Baru',
            pesan: detailWaktu.isNotEmpty
                ? '$namaPasien menjadwalkan konsultasi ($detailWaktu).'
                : '$namaPasien menjadwalkan konsultasi baru.',
          );
        }
      }
    });
  }

  void _dengarkanPesanChatMasuk() {
    FirebaseFirestore.instance
        .collectionGroup('messages')
        .where('senderId', isNotEqualTo: _activeDoctorId)
        .snapshots()
        .listen((snapshot) {
      if (_isInitialChatLoad) {
        _isInitialChatLoad = false;
        return;
      }

      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final String roomPath = change.doc.reference.parent.parent?.id ?? '';
          final bool isRoomMilikDokter = roomPath.isEmpty ||
              !roomPath.contains('_') ||
              roomPath.contains('_${_activeDoctorId}_') ||
              roomPath.endsWith('_$_activeDoctorId');
          if (!isRoomMilikDokter) continue;

          final data = change.doc.data() as Map<String, dynamic>? ?? {};
          final String pesanTeks =
          (data['text'] ?? 'Mengirim pesan baru...').toString();
          final bool isSummary = data['isScreeningSummary'] == true;

          if (!mounted) return;
          setState(() => hasUnreadNotif = true);

          _showHeadsUpNotification(
            judul: isSummary
                ? 'Laporan Skrining PDF dari Pasien'
                : 'Pesan Baru dari Pasien',
            pesan: pesanTeks,
          );
        }
      }
    });
  }

  void _bukaHalamanNotifikasi(BuildContext context) {
    if (hasUnreadNotif) {
      setState(() => hasUnreadNotif = false);
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DokterNotifikasiPage(
          doctorId: _activeDoctorId,
          onNavigateToTab: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _DokterDashboardContentView(
        doctorId: _activeDoctorId,
        hasUnreadNotif: hasUnreadNotif,
        onNotificationTap: () => _bukaHalamanNotifikasi(context),
      ),
      DokterSkriningPage(
        doctorId: _activeDoctorId,
        onBackToHome: () => setState(() => currentIndex = 0),
      ),
      DokterKonsultasiPage(
        doctorId: _activeDoctorId,
        onBackToHome: () => setState(() => currentIndex = 0),
      ),
      DokterLokasiPage(
        doctorId: _activeDoctorId,
        onBackToHome: () => setState(() => currentIndex = 0),
      ),
      DokterProfilPage(doctorId: _activeDoctorId),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        if (didPop) return;

        final bool? keluar = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Text(
              'Keluar Aplikasi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            content: const Text(
              'Apakah Anda yakin ingin keluar dari aplikasi Diora?',
              style: TextStyle(fontSize: 13, color: Color(0xFF475569)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text(
                  'Tidak',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Text(
                  'Ya, Keluar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );

        if (keluar == true && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: IndexedStack(
          index: currentIndex,
          children: pages,
        ),
        bottomNavigationBar: DokterCurvedNavBar(
          selectedIndex: currentIndex,
          onItemTapped: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}

class _DokterDashboardContentView extends StatelessWidget {
  final String doctorId;
  final bool hasUnreadNotif;
  final VoidCallback onNotificationTap;

  const _DokterDashboardContentView({
    required this.doctorId,
    required this.hasUnreadNotif,
    required this.onNotificationTap,
  });

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

  bool _isDokumenPdfSkriningData(Map<String, dynamic> msgData) {
    final bool isSummary = msgData['isScreeningSummary'] == true;
    final String messageType =
    (msgData['message_type'] ?? '').toString().toLowerCase();
    final String type = (msgData['type'] ?? '').toString().toLowerCase();
    final String fileType =
    (msgData['fileType'] ?? '').toString().toLowerCase();
    final String text =
    (msgData['text'] ?? msgData['message'] ?? '').toString().toLowerCase();
    final String fileName =
    (msgData['fileName'] ?? '').toString().toLowerCase();
    final String fileUrl = (msgData['fileUrl'] ??
        msgData['pdfUrl'] ??
        msgData['attachmentUrl'] ??
        '')
        .toString()
        .toLowerCase();

    return isSummary ||
        messageType == 'screening_attachment' ||
        messageType == 'pdf' ||
        type == 'pdf' ||
        fileType == 'pdf' ||
        fileName.endsWith('.pdf') ||
        fileUrl.endsWith('.pdf') ||
        text.contains('.pdf') ||
        text.contains('hasil skrining') ||
        text.contains('screening');
  }

  bool _isPesanMilikDokter(DocumentSnapshot doc) {
    final String docId = doctorId.trim();
    if (docId.isEmpty) return true;

    final data = doc.data() as Map<String, dynamic>? ?? {};
    final String fieldDoctorId =
    (data['doctor_id'] ?? data['doctorId'] ?? '').toString().trim();
    if (fieldDoctorId.isNotEmpty) {
      return fieldDoctorId == docId;
    }

    final String roomPath = doc.reference.parent.parent?.id ?? '';
    if (roomPath.isEmpty || !roomPath.contains('_')) return true;
    return roomPath.contains('_${docId}_') || roomPath.endsWith('_$docId');
  }

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

  String _formatDateIso(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  String _formatTanggalIndonesia(DateTime date) {
    const bulanList = [
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
    return '${_namaHari(date.weekday)}, ${date.day} ${bulanList[date.month]} ${date.year}';
  }

  bool _cekSedangPraktik(Map<String, dynamic> jadwalShift) {
    final now = DateTime.now();
    final int jamSekarang = now.hour;

    final String hariIni = _namaHari(now.weekday);
    final shiftHariIni = jadwalShift[hariIni] as Map<String, dynamic>?;
    if (shiftHariIni != null && (shiftHariIni['isActive'] == true)) {
      final int mulai = (shiftHariIni['jamMulai'] ?? 7) as int;
      final int selesai = (shiftHariIni['jamSelesai'] ?? 15) as int;
      if (mulai < selesai) {
        if (jamSekarang >= mulai && jamSekarang < selesai) return true;
      } else {
        if (jamSekarang >= mulai || jamSekarang < selesai) return true;
      }
    }

    if (jamSekarang < 7) {
      final kemarin = now.subtract(const Duration(days: 1));
      final String hariKemarin = _namaHari(kemarin.weekday);
      final shiftKemarin = jadwalShift[hariKemarin] as Map<String, dynamic>?;
      if (shiftKemarin != null && (shiftKemarin['isActive'] == true)) {
        final int mulai = (shiftKemarin['jamMulai'] ?? 0) as int;
        final int selesai = (shiftKemarin['jamSelesai'] ?? 0) as int;
        if (mulai > selesai && jamSekarang < selesai) return true;
      }
    }

    return false;
  }

  String _getKodeJamShiftHariIni(Map<String, dynamic> jadwalShift) {
    final now = DateTime.now();
    final String hariIni = _namaHari(now.weekday);
    final shiftHariIni = jadwalShift[hariIni] as Map<String, dynamic>?;

    if (shiftHariIni != null && (shiftHariIni['isActive'] == true)) {
      final int mulai = (shiftHariIni['jamMulai'] ?? 7) as int;
      final int selesai = (shiftHariIni['jamSelesai'] ?? 15) as int;
      return '${mulai.toString().padLeft(2, '0')}-${selesai.toString().padLeft(2, '0')}';
    }
    return 'OFF';
  }

  String _getSubtitelShiftHariIni(Map<String, dynamic> jadwalShift) {
    final now = DateTime.now();
    final String hariIni = _namaHari(now.weekday);
    final shiftHariIni = jadwalShift[hariIni] as Map<String, dynamic>?;

    if (shiftHariIni != null && (shiftHariIni['isActive'] == true)) {
      return '${shiftHariIni['namaShift'] ?? 'Shift Aktif'} • WIB';
    }
    return 'Hari Ini Tidak Praktik';
  }

  @override
  Widget build(BuildContext context) {
    final DateTime sekarang = DateTime.now();
    final String tanggalHariIniIso = _formatDateIso(sekarang);
    final String tanggalLengkap = _formatTanggalIndonesia(sekarang);

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('doctors')
          .doc(doctorId)
          .snapshots(),
      builder: (context, doctorSnapshot) {
        String namaDokter = 'dr. Spesialis';
        String spesialisasi = 'Dokter Spesialis Penyakit Dalam';
        bool sedangPraktik = false;
        Map<String, dynamic> jadwalShift = {};
        Uint8List? photoBytes;
        String? photoUrl;

        if (doctorSnapshot.hasData && doctorSnapshot.data!.exists) {
          final docData = doctorSnapshot.data!.data() as Map<String, dynamic>;
          namaDokter = docData['nama'] ?? namaDokter;
          spesialisasi = docData['spesialis'] ?? spesialisasi;
          jadwalShift =
              (docData['jadwal_shift'] as Map<String, dynamic>?) ?? {};
          sedangPraktik = _cekSedangPraktik(jadwalShift);
          photoBytes = _decodePhotoBytes(docData['photoBase64']);
          if (docData['photoUrl'] != null &&
              docData['photoUrl'].toString().trim().isNotEmpty) {
            photoUrl = docData['photoUrl'].toString().trim();
          }
        }

        ImageProvider? avatarProvider;
        if (photoBytes != null) {
          avatarProvider = MemoryImage(photoBytes);
        } else if (photoUrl != null) {
          avatarProvider = NetworkImage(photoUrl);
        }

        final String kodeJamShift = _getKodeJamShiftHariIni(jadwalShift);
        final String subtitelShift = _getSubtitelShiftHariIni(jadwalShift);

        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('consultation_bookings')
              .where('doctor_id', isEqualTo: doctorId)
              .where('booking_date', isEqualTo: tanggalHariIniIso)
              .snapshots(),
          builder: (context, bookingSnapshot) {
            final bookingDocs = bookingSnapshot.data?.docs ?? [];
            final int totalKonsulHariIni = bookingDocs.length;

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collectionGroup('messages')
                  .snapshots(),
              builder: (context, messageSnapshot) {
                int totalPdfSkrining = 0;

                if (messageSnapshot.hasData) {
                  for (final doc in messageSnapshot.data!.docs) {
                    if (!_isPesanMilikDokter(doc)) continue;
                    final msgData = doc.data() as Map<String, dynamic>;
                    if (_isDokumenPdfSkriningData(msgData)) {
                      totalPdfSkrining++;
                    }
                  }
                }

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                            top: 50.0, left: 20.0, right: 20.0, bottom: 32.0),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Color(0xFF4338CA),
                              Color(0xFF6366F1),
                              Color(0xFF818CF8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(32),
                            bottomRight: Radius.circular(32),
                          ),
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
                                      padding: const EdgeInsets.all(2),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.1),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 22,
                                        backgroundColor: const Color(0xFFEEF2FF),
                                        backgroundImage: avatarProvider,
                                        child: avatarProvider == null
                                            ? const Icon(Icons.person_rounded,
                                            color: Color(0xFF6366F1),
                                            size: 26)
                                            : null,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Selamat Datang,',
                                          style: TextStyle(
                                            color: Color(0xFFE0E7FF),
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        SizedBox(
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.55,
                                          child: Text(
                                            namaDokter,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: 0.2,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: IconButton(
                                        onPressed: onNotificationTap,
                                        constraints: const BoxConstraints(),
                                        padding: const EdgeInsets.all(8),
                                        icon: const Icon(
                                          Icons.notifications_active_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    if (hasUnreadNotif)
                                      Positioned(
                                        top: 5,
                                        right: 5,
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEF4444),
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 1.5,
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color:
                                      Colors.white.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.verified_rounded,
                                            color: Colors.amberAccent,
                                            size: 13),
                                        const SizedBox(width: 5),
                                        Flexible(
                                          child: Text(
                                            spesialisasi,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: sedangPraktik
                                        ? const Color(0xFF059669)
                                        : const Color(0xFF475569),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        sedangPraktik
                                            ? Icons.access_time_rounded
                                            : Icons.bedtime_rounded,
                                        color: Colors.white,
                                        size: 12,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        sedangPraktik
                                            ? 'Siap Praktik'
                                            : 'Di Luar Jam Shift',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1)
                                      .withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Icon(Icons.event_note_rounded,
                                    color: Color(0xFF818CF8), size: 26),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          'Ringkasan Praktik',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white
                                                .withValues(alpha: 0.12),
                                            borderRadius:
                                            BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            tanggalLengkap,
                                            style: const TextStyle(
                                              color: Color(0xFFC7D2FE),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      totalKonsulHariIni > 0
                                          ? 'Terdapat $totalKonsulHariIni jadwal konsultasi pasien hari ini dan $totalPdfSkrining laporan PDF masuk.'
                                          : 'Belum ada jadwal pasien masuk hari ini. Total $totalPdfSkrining laporan PDF skrining tersimpan.',
                                      style: const TextStyle(
                                        color: Color(0xFF94A3B8),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Menu Utama & Layanan',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1.32,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final berandaState =
                                    context.findAncestorStateOfType<
                                        DokterBerandaPageState>();
                                    if (berandaState != null) {
                                      berandaState.setState(() {
                                        berandaState.currentIndex = 2;
                                      });
                                    }
                                  },
                                  child: _buildMetricCard(
                                    icon: Icons.chat_bubble_rounded,
                                    primaryColor: const Color(0xFF6366F1),
                                    bgCardColor: const Color(0xFFEEF2FF),
                                    metricValue: '$totalKonsulHariIni',
                                    title: 'Konsultasi Aktif',
                                    subtitle: totalKonsulHariIni > 0
                                        ? '$totalKonsulHariIni Pasien Hari Ini'
                                        : 'Belum Ada Antrean',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final berandaState =
                                    context.findAncestorStateOfType<
                                        DokterBerandaPageState>();
                                    if (berandaState != null) {
                                      berandaState.setState(() {
                                        berandaState.currentIndex = 1;
                                      });
                                    }
                                  },
                                  child: _buildMetricCard(
                                    icon: Icons.picture_as_pdf_rounded,
                                    primaryColor: const Color(0xFF8B5CF6),
                                    bgCardColor: const Color(0xFFF3E8FF),
                                    metricValue: '$totalPdfSkrining',
                                    title: 'Verifikasi Medis',
                                    subtitle: totalPdfSkrining > 0
                                        ? '$totalPdfSkrining PDF Skrining'
                                        : 'Belum Ada PDF',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    final berandaState =
                                    context.findAncestorStateOfType<
                                        DokterBerandaPageState>();
                                    if (berandaState != null) {
                                      berandaState.setState(() {
                                        berandaState.currentIndex = 3;
                                      });
                                    }
                                  },
                                  child: _buildMetricCard(
                                    icon: Icons.local_hospital_rounded,
                                    primaryColor: const Color(0xFF0EA5E9),
                                    bgCardColor: const Color(0xFFE0F2FE),
                                    metricValue: '3',
                                    title: 'Fasyankes',
                                    subtitle: '3 Fasyankes Mitra',
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            DokterJadwalPraktikPage(
                                                doctorId: doctorId),
                                      ),
                                    );
                                  },
                                  child: _buildMetricCard(
                                    icon: Icons.calendar_month_rounded,
                                    primaryColor: const Color(0xFFEC4899),
                                    bgCardColor: const Color(0xFFFCE7F3),
                                    metricValue: kodeJamShift,
                                    title: 'Jadwal Praktik',
                                    subtitle: subtitelShift,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Antrean Pasien (${sekarang.day}/${sekarang.month}/${sekarang.year})',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const Text(
                              'Live Cloud',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (bookingDocs.isEmpty)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(22),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.event_busy_rounded,
                                  size: 36, color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              const Text(
                                'Belum ada pasien yang booking konsultasi hari ini.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: bookingDocs.length,
                          itemBuilder: (context, index) {
                            final data = bookingDocs[index].data()
                            as Map<String, dynamic>;
                            final namaPasien = (data['user_id'] ??
                                data['bookedByUserId'] ??
                                'Pasien')
                                .toString();
                            final jamSesi =
                            (data['booking_time'] ?? '07.00 - 07.20')
                                .toString();
                            final tanggal =
                            (data['booking_date'] ?? tanggalHariIniIso)
                                .toString();

                            return InkWell(
                              onTap: () {
                                final String roomId =
                                    '${namaPasien}_${doctorId}_${jamSesi.replaceAll(' ', '')}';
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => DokterRoomChatPage(
                                      roomId: roomId,
                                      doctorId: doctorId,
                                      namaPasien: namaPasien,
                                      genderAge: 'Pasien Terdaftar',
                                      jamSesi: jamSesi,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 5),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      Colors.black.withValues(alpha: 0.03),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(
                                      color: const Color(0xFFF1F5F9)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEEF2FF),
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      child: const Icon(Icons.person_rounded,
                                          color: Color(0xFF6366F1), size: 24),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  namaPasien,
                                                  maxLines: 1,
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 13.5,
                                                    fontWeight: FontWeight.w900,
                                                    color: Color(0xFF0F172A),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Container(
                                                padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 3),
                                                decoration: BoxDecoration(
                                                  color:
                                                  const Color(0xFFEEF2FF),
                                                  borderRadius:
                                                  BorderRadius.circular(8),
                                                ),
                                                child: Text(
                                                  jamSesi,
                                                  style: const TextStyle(
                                                    fontSize: 10.5,
                                                    color: Color(0xFF6366F1),
                                                    fontWeight: FontWeight.w900,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Container(
                                                width: 7,
                                                height: 7,
                                                decoration: const BoxDecoration(
                                                  color: Colors.green,
                                                  shape: BoxShape.circle,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              const Text(
                                                'Terkonfirmasi',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.green,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                '• $tanggal',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: Color(0xFF94A3B8),
                                      size: 14,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildMetricCard({
    required IconData icon,
    required Color primaryColor,
    required Color bgCardColor,
    required String metricValue,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgCardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: primaryColor, size: 20),
              ),
              Text(
                metricValue,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}