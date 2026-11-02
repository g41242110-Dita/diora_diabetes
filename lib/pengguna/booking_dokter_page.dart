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

  Future<void> _prosesBooking() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih slot jam konsultasi terlebih dahulu!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final String tanggalHariIni = DateTime.now().toString().split(' ')[0];
    final DocumentReference slotRef = FirebaseFirestore.instance
        .collection('doctors')
        .doc(widget.doctor.id)
        .collection('booking_slots')
        .doc('${tanggalHariIni}_${_selectedSlot!}');

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
          'tanggal': tanggalHariIni,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return true;
      });

      // Pengecekan Guard Context Pertama setelah transaksi async
      if (!mounted) return;

      if (result) {
        final jamMulaiStr = _selectedSlot!.split(' - ')[0].replaceAll('.', ':');
        final jamSelesaiStr = _selectedSlot!.split(' - ')[1].replaceAll('.', ':');

        final now = DateTime.now();
        final waktuMulaiSesi = DateTime(
          now.year,
          now.month,
          now.day,
          int.parse(jamMulaiStr.split(':')[0]),
          int.parse(jamMulaiStr.split(':')[1]),
        );

        // 1. Jalankan notifikasi lokal (alarm HP)
        await NotificationService().scheduleReminder(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          dokterNama: widget.doctor.nama,
          waktuMulaiSesi: waktuMulaiSesi,
        );

        // 2. Simpan ke database Firestore (koleksi notifications agar muncul di ikon lonceng)
        try {
          final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? widget.namaUser;
          await FirebaseFirestore.instance.collection('notifications').add({
            'user_id': currentUserId,
            'title': 'Jadwal Konsultasi Dikonfirmasi',
            'body': 'Konsultasi Anda dengan ${widget.doctor.nama} pada pukul $_selectedSlot telah berhasil dijadwalkan.',
            'type': 'booking',
            'is_read': false,
            'created_at': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          debugPrint('Gagal menyimpan notifikasi ke database: $e');
        }

        // Pengecekan Guard Context Kedua setelah panggilan async
        if (!mounted) return;

        final String roomId = '${widget.namaUser}_${widget.doctor.id}_${_selectedSlot!.replaceAll(' ', '')}';
        final int jamMulai = int.parse(jamMulaiStr.split(':')[0]);
        final int jamSelesai = int.parse(jamSelesaiStr.split(':')[0]);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ChatKonsultasiPage(
              roomId: roomId,
              currentUserId: widget.namaUser,
              dokterNama: widget.doctor.nama,
              jamMulai: jamMulai,
              jamSelesai: jamSelesai,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Slot waktu ini baru saja dibooking oleh orang lain. Silakan pilih slot lain.'),
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

  @override
  Widget build(BuildContext context) {
    final String tanggalHariIni = DateTime.now().toString().split(' ')[0];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Pilih Slot Konsultasi'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.doctor.nama,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(widget.doctor.spesialis, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Text(
              'Slot Jam Tersedia (30 Menit / Sesi):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .doc(widget.doctor.id)
                    .collection('booking_slots')
                    .where('tanggal', isEqualTo: tanggalHariIni)
                    .snapshots(),
                builder: (context, snapshot) {
                  List<String> bookedSlots = [];

                  if (snapshot.hasData) {
                    for (var doc in snapshot.data!.docs) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['isBooked'] == true) {
                        bookedSlots.add(doc.id.split('_').last);
                      }
                    }
                  }

                  return GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.8,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: widget.doctor.availableSlots.length,
                    itemBuilder: (context, index) {
                      final slot = widget.doctor.availableSlots[index];
                      final bool isBooked = bookedSlots.contains(slot);
                      final bool isSelected = _selectedSlot == slot;

                      return InkWell(
                        onTap: isBooked
                            ? null
                            : () {
                          setState(() {
                            _selectedSlot = slot;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isBooked
                                ? Colors.grey.shade300
                                : (isSelected ? const Color(0xFF6679F4) : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isBooked
                                  ? Colors.grey.shade400
                                  : (isSelected ? const Color(0xFF6679F4) : Colors.grey.shade300),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isBooked ? '$slot (Penuh)' : slot,
                            style: TextStyle(
                              color: isBooked
                                  ? Colors.grey.shade600
                                  : (isSelected ? Colors.white : Colors.black87),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6679F4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                ),
                onPressed: _isLoading ? null : _prosesBooking,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                  'Konfirmasi Booking',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}