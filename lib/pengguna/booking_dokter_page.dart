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

  /// Memeriksa apakah slot waktu sudah lewat dari jam HP saat ini
  bool _isSlotExpired(String slotRange, int jamMulai, int jamSelesai) {
    final now = DateTime.now();

    try {
      List<String> slotParts = slotRange.split('-');
      if (slotParts.isEmpty) return false;

      String startTimeStr = slotParts[0].trim().replaceAll(':', '.');
      List<String> parts = startTimeStr.split('.');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);

      DateTime slotStartDateTime;

      if (jamMulai > jamSelesai) {
        if (now.hour >= jamMulai) {
          if (hour < jamMulai) {
            slotStartDateTime = DateTime(now.year, now.month, now.day + 1, hour, minute);
          } else {
            slotStartDateTime = DateTime(now.year, now.month, now.day, hour, minute);
          }
        } else {
          if (hour >= jamMulai) {
            slotStartDateTime = DateTime(now.year, now.month, now.day + 1, hour, minute);
          } else {
            slotStartDateTime = DateTime(now.year, now.month, now.day, hour, minute);
          }
        }
      } else {
        slotStartDateTime = DateTime(now.year, now.month, now.day, hour, minute);
      }

      return slotStartDateTime.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  Future<void> _prosesBooking() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih slot jam konsultasi terlebih dahulu!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final DateTime now = DateTime.now();
    final String tanggalStr = now.toString().split(' ')[0];
    final DocumentReference slotRef = FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctor.id)
        .collection('booking_slots')
        .doc('${tanggalStr}_${_selectedSlot!}');

    try {
      final result = await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(slotRef);

        if (snapshot.exists) {
          final data = snapshot.data() as Map<String, dynamic>;
          if (data['isBooked'] == true) {
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
        // --- CATAT KE KOLEKSI GLOBAL CONSULTATION_BOOKINGS UNTUK RIWAYAT & DASHBOARD DOKTER ---
        try {
          await FirebaseFirestore.instance.collection('consultation_bookings').add({
            'doctor_id': widget.doctor.id, // Menggunakan ID asli dokter (misal: '1')
            'user_id': widget.namaUser,
            'booking_date': tanggalStr, // Tanggal otomatis hari ini
            'booking_time': _selectedSlot,
            'status': 'confirmed',
            'screening_result_id': 'ID_SCREENING_HASIL',
            'created_at': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          debugPrint('Gagal mencatat ke consultation_bookings: $e');
        }

        List<String> slotParts = _selectedSlot!.split('-');
        String jamMulaiStr = slotParts[0].trim().replaceAll('.', ':');
        String jamSelesaiStr = slotParts.length > 1
            ? slotParts[1].trim().replaceAll('.', ':')
            : jamMulaiStr;

        List<String> startParts = jamMulaiStr.split(':');
        int jamMulai = int.parse(startParts[0]);
        int menitMulai = startParts.length > 1 ? int.parse(startParts[1]) : 0;

        List<String> endParts = jamSelesaiStr.split(':');
        int jamSelesai = int.parse(endParts[0]);

        final waktuMulaiSesi = DateTime(
          now.year,
          now.month,
          now.day,
          jamMulai,
          menitMulai,
        );

        try {
          await NotificationService().scheduleReminder(
            id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
            dokterNama: widget.doctor.nama,
            waktuMulaiSesi: waktuMulaiSesi,
          );
        } catch (e) {
          debugPrint('NotificationService belum siap: $e');
        }

        try {
          final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? widget.namaUser;
          await FirebaseFirestore.instance.collection('notifications').add({
            'user_id': currentUserId,
            'title': 'Jadwal Konsultasi Dikonfirmasi',
            'body':
            'Konsultasi Anda dengan ${widget.doctor.nama} pada pukul $_selectedSlot telah berhasil dijadwalkan.',
            'type': 'booking',
            'is_read': false,
            'created_at': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          debugPrint('Gagal menyimpan notifikasi ke database: $e');
        }

        if (!mounted) return;

        final String roomId =
            '${widget.namaUser}_${widget.doctor.id}_${_selectedSlot!.replaceAll(' ', '')}';

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatKonsultasiPage(
              roomId: roomId,
              currentUserId: widget.namaUser,
              dokterNama: widget.doctor.nama,
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
                'Slot waktu ini baru saja dibooking oleh orang lain. Silakan pilih slot lain.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e'), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Fungsi khusus untuk membuka kembali room chat yang sudah pernah dipesan pengguna
  void _bukaKembaliChat(String slotWaktu) {
    List<String> slotParts = slotWaktu.split('-');
    String jamMulaiStr = slotParts[0].trim().replaceAll('.', ':');
    String jamSelesaiStr = slotParts.length > 1
        ? slotParts[1].trim().replaceAll('.', ':')
        : jamMulaiStr;

    int jamMulai = int.parse(jamMulaiStr.split(':')[0]);
    int jamSelesai = int.parse(jamSelesaiStr.split(':')[0]);

    final String roomId =
        '${widget.namaUser}_${widget.doctor.id}_${slotWaktu.replaceAll(' ', '')}';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatKonsultasiPage(
          roomId: roomId,
          currentUserId: widget.namaUser,
          dokterNama: widget.doctor.nama,
          jamMulai: jamMulai,
          jamSelesai: jamSelesai,
          slotWaktu: slotWaktu,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String tanggalHariIni = DateTime.now().toString().split(' ')[0];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Booking Jadwal Dokter',
          style: TextStyle(
              color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // INFORMASI DOKTER
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
                    radius: 26,
                    backgroundColor: Color(0xFFEEF2FF),
                    child: Icon(Icons.person_rounded,
                        size: 30, color: Color(0xFF4F46E5)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctor.nama,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.doctor.spesialis,
                          style: const TextStyle(
                              fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // STREAM BUILDER SLOT REAL-TIME HARI INI
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .doc(widget.doctor.id)
                    .collection('booking_slots')
                    .where('tanggal', isEqualTo: tanggalHariIni)
                    .snapshots(),
                builder: (context, snapshot) {
                  Map<String, String> bookedSlotsWithUsers = {};

                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['isBooked'] == true) {
                        final slotName = doc.id.split('_').last;
                        bookedSlotsWithUsers[slotName] = data['bookedByUserId'] ?? '';
                      }
                    }
                  }

                  // Hitung Kuota Sisa Terbuka Realtime
                  int activeAvailableSlots = 0;
                  for (var slot in widget.doctor.availableSlots) {
                    bool isBooked = bookedSlotsWithUsers.containsKey(slot);
                    bool isExpired = _isSlotExpired(
                        slot, widget.doctor.jamMulai, widget.doctor.jamSelesai);
                    if (!isBooked && !isExpired) {
                      activeAvailableSlots++;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // BANNER KUOTA DINAMIS
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFDCFCE7)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.group_rounded,
                                color: Color(0xFF16A34A), size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Kuota Pasien',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xFF15803D),
                                    ),
                                  ),
                                  Text(
                                    'Tersedia $activeAvailableSlots slot waktu',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text(
                        'Pilih Sesi Jam Konsultasi (Shift (${widget.doctor.jamMulai.toString().padLeft(2, '0')}.00 - ${widget.doctor.jamSelesai.toString().padLeft(2, '0')}.00)):',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(height: 10),

                      // STREAM BUILDER DAFTAR CHATS UNTUK CEK STATUS CHAT SUDAH DIAKHIRI / BELUM
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('chats')
                              .snapshots(),
                          builder: (context, chatSnapshot) {
                            Set<String> endedRoomIds = {};
                            if (chatSnapshot.hasData) {
                              for (var doc in chatSnapshot.data!.docs) {
                                final data = doc.data() as Map<String, dynamic>;
                                if (data['isEnded'] == true) {
                                  endedRoomIds.add(doc.id);
                                }
                              }
                            }

                            return GridView.builder(
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 2.5,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                              itemCount: widget.doctor.availableSlots.length,
                              itemBuilder: (context, index) {
                                final slot = widget.doctor.availableSlots[index];
                                final bool isBooked = bookedSlotsWithUsers.containsKey(slot);
                                final String bookedByUser = bookedSlotsWithUsers[slot] ?? '';
                                final bool isDipesanOlehSaya = isBooked && (bookedByUser == widget.namaUser);

                                final String roomId =
                                    '${widget.namaUser}_${widget.doctor.id}_${slot.replaceAll(' ', '')}';
                                final bool isChatEnded = endedRoomIds.contains(roomId);

                                final bool isExpired = _isSlotExpired(
                                    slot,
                                    widget.doctor.jamMulai,
                                    widget.doctor.jamSelesai);

                                final bool isBookedOrExpired = isBooked || isExpired;
                                final bool isTersedia = !isBookedOrExpired;
                                final bool isSelected = _selectedSlot == slot;

                                return InkWell(
                                  onTap: () {
                                    if (isDipesanOlehSaya) {
                                      _bukaKembaliChat(slot);
                                    } else if (isTersedia) {
                                      setState(() {
                                        _selectedSlot = slot;
                                      });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isDipesanOlehSaya
                                          ? (isChatEnded
                                          ? const Color(0xFFF1F5F9)
                                          : const Color(0xFFEEF2FF))
                                          : (isSelected
                                          ? const Color(0xFF4F46E5)
                                          : (isBookedOrExpired
                                          ? const Color(0xFFF1F5F9)
                                          : Colors.white)),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: isDipesanOlehSaya
                                            ? (isChatEnded
                                            ? const Color(0xFFCBD5E1)
                                            : const Color(0xFF6366F1))
                                            : (isSelected
                                            ? const Color(0xFF4F46E5)
                                            : (isBookedOrExpired
                                            ? const Color(0xFFE2E8F0)
                                            : const Color(0xFFCBD5E1))),
                                        width: (isDipesanOlehSaya || isSelected) ? 1.5 : 1.0,
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          slot,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isDipesanOlehSaya
                                                ? (isChatEnded
                                                ? const Color(0xFF64748B)
                                                : const Color(0xFF4F46E5))
                                                : (isSelected
                                                ? Colors.white
                                                : (isBookedOrExpired
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF0F172A))),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          isDipesanOlehSaya
                                              ? (isChatEnded ? 'Sesi Berakhir' : 'Buka Chat Saya')
                                              : (isBookedOrExpired
                                              ? 'Tidak Tersedia'
                                              : 'Tersedia'),
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: isDipesanOlehSaya
                                                ? (isChatEnded
                                                ? const Color(0xFF64748B)
                                                : const Color(0xFF4F46E5))
                                                : (isSelected
                                                ? Colors.white.withValues(alpha: 0.9)
                                                : (isBookedOrExpired
                                                ? const Color(0xFF94A3B8)
                                                : const Color(0xFF16A34A))),
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
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // TOMBOL KONFIRMASI BOOKING
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed:
                (_isLoading || _selectedSlot == null) ? null : _prosesBooking,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Konfirmasi Booking & Masuk Chat',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}