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
            slotStartDateTime =
                DateTime(now.year, now.month, now.day + 1, hour, minute);
          } else {
            slotStartDateTime =
                DateTime(now.year, now.month, now.day, hour, minute);
          }
        } else {
          if (hour >= jamMulai) {
            slotStartDateTime =
                DateTime(now.year, now.month, now.day + 1, hour, minute);
          } else {
            slotStartDateTime =
                DateTime(now.year, now.month, now.day, hour, minute);
          }
        }
      } else {
        slotStartDateTime =
            DateTime(now.year, now.month, now.day, hour, minute);
      }

      return slotStartDateTime.isBefore(now);
    } catch (e) {
      return false;
    }
  }

  String _formatShiftRange() {
    final start = widget.doctor.jamMulai.toString().padLeft(2, '0');
    final end = widget.doctor.jamSelesai.toString().padLeft(2, '0');
    return '$start.00 - $end.00 WIB';
  }

  Future<void> _prosesBooking() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Pilih slot jam konsultasi terlebih dahulu!')),
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
      final result =
      await FirebaseFirestore.instance.runTransaction((transaction) async {
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
          await FirebaseFirestore.instance
              .collection('consultation_bookings')
              .add({
            'doctor_id': widget.doctor.id,
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
          final currentUserId =
              FirebaseAuth.instance.currentUser?.uid ?? widget.namaUser;
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
        SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.redAccent),
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
    final double topPadding = MediaQuery.of(context).padding.top + 12;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // HEADER LIQUID WAVE + JUDUL SIMETRIS DI TENGAH
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
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // INFORMASI DOKTER RINGKAS
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color:
                          const Color(0xFF5B4AF4).withValues(alpha: 0.06),
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
                              colors: [Color(0xFF6679F4), Color(0xFF8DA0FF)],
                            ),
                          ),
                          child: const CircleAvatar(
                            radius: 24,
                            backgroundColor: Color(0xFFEEF2FF),
                            child: Icon(
                              Icons.person_rounded,
                              size: 28,
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
                                widget.doctor.nama,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.5,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                widget.doctor.spesialis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

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
                              bookedSlotsWithUsers[slotName] =
                                  data['bookedByUserId'] ?? '';
                            }
                          }
                        }

                        // Hitung Kuota Sisa Terbuka Realtime
                        int activeAvailableSlots = 0;
                        for (var slot in widget.doctor.availableSlots) {
                          bool isBooked =
                          bookedSlotsWithUsers.containsKey(slot);
                          bool isExpired = _isSlotExpired(slot,
                              widget.doctor.jamMulai, widget.doctor.jamSelesai);
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: activeAvailableSlots > 0
                                    ? const Color(0xFFF0FDF4)
                                    : const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: activeAvailableSlots > 0
                                      ? const Color(0xFFBBF7D0)
                                      : const Color(0xFFFECACA),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: activeAvailableSlots > 0
                                          ? const Color(0xFFDCFCE7)
                                          : const Color(0xFFFEE2E2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.groups_rounded,
                                      size: 20,
                                      color: activeAvailableSlots > 0
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
                                          'Kuota Pasien',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.5,
                                            color: activeAvailableSlots > 0
                                                ? const Color(0xFF15803D)
                                                : const Color(0xFFB91C1C),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          activeAvailableSlots > 0
                                              ? 'Tersedia $activeAvailableSlots slot waktu konsultasi'
                                              : 'Semua slot waktu hari ini telah terisi / terlewat',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            color: activeAvailableSlots > 0
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
                            const SizedBox(height: 16),

                            // HEADER PILIH SESI + CHIP JAM SHIFT
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                      horizontal: 9, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _formatShiftRange(),
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
                                      final data =
                                      doc.data() as Map<String, dynamic>;
                                      if (data['isEnded'] == true) {
                                        endedRoomIds.add(doc.id);
                                      }
                                    }
                                  }

                                  return GridView.builder(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    physics: const BouncingScrollPhysics(),
                                    gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 1.75,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                    ),
                                    itemCount:
                                    widget.doctor.availableSlots.length,
                                    itemBuilder: (context, index) {
                                      final slot =
                                      widget.doctor.availableSlots[index];
                                      final bool isBooked = bookedSlotsWithUsers
                                          .containsKey(slot);
                                      final String bookedByUser =
                                          bookedSlotsWithUsers[slot] ?? '';
                                      final bool isDipesanOlehSaya = isBooked &&
                                          (bookedByUser == widget.namaUser);

                                      final String roomId =
                                          '${widget.namaUser}_${widget.doctor.id}_${slot.replaceAll(' ', '')}';
                                      final bool isChatEnded =
                                      endedRoomIds.contains(roomId);

                                      final bool isExpired = _isSlotExpired(
                                          slot,
                                          widget.doctor.jamMulai,
                                          widget.doctor.jamSelesai);

                                      final bool isBookedOrExpired =
                                          isBooked || isExpired;
                                      final bool isTersedia =
                                      !isBookedOrExpired;
                                      final bool isSelected =
                                          _selectedSlot == slot;

                                      return InkWell(
                                        borderRadius: BorderRadius.circular(14),
                                        onTap: () {
                                          if (isDipesanOlehSaya) {
                                            _bukaKembaliChat(slot);
                                          } else if (isTersedia) {
                                            setState(() {
                                              _selectedSlot = slot;
                                            });
                                          }
                                        },
                                        child: AnimatedContainer(
                                          duration:
                                          const Duration(milliseconds: 180),
                                          decoration: BoxDecoration(
                                            gradient: isSelected
                                                ? const LinearGradient(
                                              colors: [
                                                Color(0xFF5B4AF4),
                                                Color(0xFF4F46E5)
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                                : null,
                                            color: isSelected
                                                ? null
                                                : (isDipesanOlehSaya
                                                ? (isChatEnded
                                                ? const Color(
                                                0xFFF1F5F9)
                                                : const Color(
                                                0xFFEEF2FF))
                                                : (isBookedOrExpired
                                                ? const Color(
                                                0xFFF1F5F9)
                                                : Colors.white)),
                                            borderRadius:
                                            BorderRadius.circular(14),
                                            border: Border.all(
                                              color: isDipesanOlehSaya
                                                  ? (isChatEnded
                                                  ? const Color(0xFFCBD5E1)
                                                  : const Color(0xFF6366F1))
                                                  : (isSelected
                                                  ? const Color(0xFF5B4AF4)
                                                  : (isBookedOrExpired
                                                  ? const Color(
                                                  0xFFE2E8F0)
                                                  : const Color(
                                                  0xFFCBD5E1))),
                                              width: (isDipesanOlehSaya ||
                                                  isSelected)
                                                  ? 1.5
                                                  : 1.0,
                                            ),
                                            boxShadow: isSelected
                                                ? [
                                              BoxShadow(
                                                color: const Color(
                                                    0xFF5B4AF4)
                                                    .withValues(
                                                    alpha: 0.25),
                                                blurRadius: 8,
                                                offset:
                                                const Offset(0, 4),
                                              ),
                                            ]
                                                : [],
                                          ),
                                          alignment: Alignment.center,
                                          child: Column(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                slot,
                                                style: TextStyle(
                                                  fontSize: 11.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: isDipesanOlehSaya
                                                      ? (isChatEnded
                                                      ? const Color(
                                                      0xFF64748B)
                                                      : const Color(
                                                      0xFF4F46E5))
                                                      : (isSelected
                                                      ? Colors.white
                                                      : (isBookedOrExpired
                                                      ? const Color(
                                                      0xFF94A3B8)
                                                      : const Color(
                                                      0xFF0F172A))),
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                isDipesanOlehSaya
                                                    ? (isChatEnded
                                                    ? 'Sesi Berakhir'
                                                    : 'Buka Chat Saya')
                                                    : (isBookedOrExpired
                                                    ? 'Tidak Tersedia'
                                                    : (isSelected
                                                    ? 'Dipilih'
                                                    : 'Tersedia')),
                                                style: TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.w600,
                                                  color: isDipesanOlehSaya
                                                      ? (isChatEnded
                                                      ? const Color(
                                                      0xFF64748B)
                                                      : const Color(
                                                      0xFF4F46E5))
                                                      : (isSelected
                                                      ? Colors.white
                                                      .withValues(
                                                      alpha: 0.9)
                                                      : (isBookedOrExpired
                                                      ? const Color(
                                                      0xFF94A3B8)
                                                      : const Color(
                                                      0xFF16A34A))),
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
                ],
              ),
            ),
          ),
        ],
      ),

      // TOMBOL KONFIRMASI BOOKING ESTETIK DI BAGIAN BAWAH
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
            gradient: _selectedSlot != null
                ? const LinearGradient(
              colors: [Color(0xFF5B4AF4), Color(0xFF4F46E5)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
                : null,
            color: _selectedSlot != null ? null : const Color(0xFFE2E8F0),
            boxShadow: _selectedSlot != null
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
            onPressed:
            (_isLoading || _selectedSlot == null) ? null : _prosesBooking,
            icon: _isLoading
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: _selectedSlot != null
                  ? Colors.white
                  : const Color(0xFF94A3B8),
            ),
            label: Text(
              _selectedSlot != null
                  ? 'Konfirmasi Booking & Masuk Chat'
                  : 'Pilih Sesi Jam Terlebih Dahulu',
              style: TextStyle(
                color: _selectedSlot != null
                    ? Colors.white
                    : const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
                fontSize: 13.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BookingLiquidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 26);

    var firstControlPoint = Offset(size.width * 0.28, size.height);
    var firstEndPoint = Offset(size.width * 0.55, size.height - 20);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.8, size.height - 38);
    var secondEndPoint = Offset(size.width, size.height - 12);
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