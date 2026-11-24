import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'dokter_jadwal_praktik_page.dart';

class DokterNotifikasiPage extends StatelessWidget {
  final String doctorId;
  final ValueChanged<int>? onNavigateToTab;

  const DokterNotifikasiPage({
    super.key,
    required this.doctorId,
    this.onNavigateToTab,
  });

  bool _isPesanPasienKeDokter(Map<String, dynamic> data, String roomId) {
    final String senderId =
    (data['senderId'] ?? data['sender_id'] ?? '').toString().trim();
    final String senderRole =
    (data['senderRole'] ?? data['role'] ?? '').toString().toLowerCase();

    if (senderRole == 'dokter' || senderRole == 'doctor') return false;
    if (senderId.isNotEmpty && senderId == doctorId) return false;

    if (roomId.isNotEmpty) {
      return roomId.contains('_${doctorId}_') ||
          roomId.endsWith('_$doctorId') ||
          roomId.startsWith('${doctorId}_');
    }

    return true;
  }

  String _formatWaktuSingkat(DateTime dt) {
    final String jam = dt.hour.toString().padLeft(2, '0');
    final String menit = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month} $jam:$menit';
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
          'Pemberitahuan Aktivitas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('messages')
            .snapshots(),
        builder: (context, msgSnapshot) {
          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('consultation_bookings')
                .where('doctor_id', isEqualTo: doctorId)
                .snapshots(),
            builder: (context, bookingSnapshot) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .snapshots(),
                builder: (context, doctorsSnapshot) {
                  if (msgSnapshot.connectionState == ConnectionState.waiting &&
                      !msgSnapshot.hasData &&
                      !bookingSnapshot.hasData) {
                    return const Center(
                      child:
                      CircularProgressIndicator(color: Color(0xFF6366F1)),
                    );
                  }

                  final List items = List.empty(growable: true);

                  // 1. Pemberitahuan Chat & Laporan Skrining PDF Pasien
                  if (msgSnapshot.hasData) {
                    for (final doc in msgSnapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String roomId =
                          doc.reference.parent.parent?.id ?? '';
                      if (!_isPesanPasienKeDokter(data, roomId)) continue;

                      final bool isSummary = data['isScreeningSummary'] == true;
                      final Timestamp? ts = data['timestamp'] as Timestamp?;
                      final DateTime sortTime = ts?.toDate() ??
                          DateTime.fromMillisecondsSinceEpoch(0);

                      items.add({
                        'title': isSummary
                            ? 'Laporan Skrining PDF Masuk'
                            : 'Pesan Konsultasi Pasien',
                        'subtitle': (data['text'] ?? '').toString(),
                        'timeLabel': ts != null
                            ? _formatWaktuSingkat(ts.toDate())
                            : 'Baru saja',
                        'sortTime': sortTime,
                        'icon': isSummary
                            ? Icons.picture_as_pdf_rounded
                            : Icons.chat_bubble_rounded,
                        'iconColor': isSummary
                            ? Colors.redAccent
                            : const Color(0xFF6366F1),
                        'bgIconColor': isSummary
                            ? Colors.red.shade50
                            : const Color(0xFFEEF2FF),
                        'targetIndex': isSummary ? 1 : 2,
                      });
                    }
                  }

                  // 2. Pemberitahuan Booking Konsultasi Pasien
                  if (bookingSnapshot.hasData) {
                    for (final doc in bookingSnapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      final String pasien = (data['user_id'] ??
                          data['bookedByUserId'] ??
                          'Pasien')
                          .toString();
                      final String tanggal =
                      (data['booking_date'] ?? '').toString();
                      final String jam =
                      (data['booking_time'] ?? '').toString();
                      final Timestamp? ts =
                      (data['created_at'] ?? data['timestamp'])
                      as Timestamp?;
                      final DateTime sortTime = ts?.toDate() ??
                          DateTime.tryParse(tanggal) ??
                          DateTime.fromMillisecondsSinceEpoch(0);

                      items.add({
                        'title': 'Booking Konsultasi Baru',
                        'subtitle':
                        '$pasien memesan sesi $jam WIB pada tanggal $tanggal.',
                        'timeLabel': ts != null
                            ? _formatWaktuSingkat(ts.toDate())
                            : tanggal,
                        'sortTime': sortTime,
                        'icon': Icons.event_available_rounded,
                        'iconColor': const Color(0xFF059669),
                        'bgIconColor': const Color(0xFFD1FAE5),
                        'targetIndex': 2,
                      });
                    }
                  }

                  // 3. Pemberitahuan Shift Kosong / Butuh Pengganti dari Dokter Lain
                  if (doctorsSnapshot.hasData) {
                    for (final doc in doctorsSnapshot.data!.docs) {
                      if (doc.id == doctorId) continue;
                      final otherData = doc.data() as Map<String, dynamic>;
                      final String namaDokterLain =
                      (otherData['nama'] ?? 'Dokter Lain').toString();
                      final Map<String, dynamic> schedule =
                          (otherData['jadwal_shift']
                          as Map<String, dynamic>?) ??
                              {};

                      schedule.forEach((hari, value) {
                        if (value is Map<String, dynamic>) {
                          final bool isActive = value['isActive'] ?? true;
                          final bool butuhPengganti =
                              value['butuhPengganti'] ?? (!isActive);
                          if (!isActive && butuhPengganti) {
                            final String namaShift =
                            (value['namaShift'] ?? 'Shift').toString();
                            items.add({
                              'title': 'Tawaran Gantikan Shift',
                              'subtitle':
                              'Jadwal $namaDokterLain di hari $hari ($namaShift) sedang OFF dan tersedia untuk digantikan.',
                              'timeLabel': hari,
                              'sortTime': DateTime.now()
                                  .subtract(const Duration(minutes: 1)),
                              'icon': Icons.swap_horiz_rounded,
                              'iconColor': const Color(0xFFD97706),
                              'bgIconColor': const Color(0xFFFEF3C7),
                              'openJadwal': true,
                            });
                          }
                        }
                      });
                    }
                  }

                  if (items.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.notifications_off_rounded,
                              size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 14),
                          const Text(
                            'Belum ada pemberitahuan aktivitas saat ini.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  items.sort((a, b) => (b['sortTime'] as DateTime)
                      .compareTo(a['sortTime'] as DateTime));

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index] as Map<String, dynamic>;
                      final IconData icon = item['icon'] as IconData;
                      final Color iconColor = item['iconColor'] as Color;
                      final Color bgIconColor = item['bgIconColor'] as Color;

                      return InkWell(
                        borderRadius: BorderRadius.circular(18),
                        onTap: () {
                          if (item['openJadwal'] == true) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DokterJadwalPraktikPage(
                                    doctorId: doctorId),
                              ),
                            );
                            return;
                          }

                          final int? targetIdx = item['targetIndex'] as int?;
                          if (targetIdx != null) {
                            onNavigateToTab?.call(targetIdx);
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: bgIconColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(icon, color: iconColor, size: 22),
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
                                        Expanded(
                                          child: Text(
                                            item['title'] as String,
                                            style: const TextStyle(
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w900,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          item['timeLabel'] as String,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF94A3B8),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      item['subtitle'] as String,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF475569),
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}