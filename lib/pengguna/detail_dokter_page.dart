import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'chat_konsultasi_page.dart';

class DetailDokterPage extends StatefulWidget {
  final Doctor doctor;
  final String namaUser;

  const DetailDokterPage({super.key, required this.doctor, this.namaUser = 'Pengguna'});

  @override
  State<DetailDokterPage> createState() => _DetailDokterPageState();
}

class _DetailDokterPageState extends State<DetailDokterPage> {
  TimeSlot? _selectedSlot;

  void _prosesBooking() {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih slot konsultasi yang masih tersedia.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final DateTime sessionTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedSlot!.startHour,
      _selectedSlot!.startMinute,
    );

    final DateTime notificationTime = sessionTime.subtract(const Duration(minutes: 5));
    final String timeReminderStr =
        '${notificationTime.hour.toString().padLeft(2, '0')}:${notificationTime.minute.toString().padLeft(2, '0')}';

    final bool isSessionNow = now.isAfter(sessionTime) &&
        now.isBefore(sessionTime.add(const Duration(minutes: 30)));

    if (widget.doctor.isOnline && isSessionNow && !widget.doctor.isBusyInChat) {
      final String roomId = '${widget.namaUser}_${widget.doctor.nama}';
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatKonsultasiPage(
            roomId: roomId,
            currentUserId: widget.namaUser,
            dokterNama: widget.doctor.nama,
          ),
        ),
      );
    } else {
      // Menampilkan Modal Popup Aesthetic (Foto 3)
      _showBookingSuccessDialog(timeReminderStr);
    }
  }

  void _showBookingSuccessDialog(String timeReminderStr) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFEEF2FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF4F46E5), size: 40),
              ),
              const SizedBox(height: 14),
              const Text(
                'Booking Berhasil!',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 8),
              Text(
                'Slot ${_selectedSlot!.timeText} berhasil dipesan.\n\nNotifikasi pengingat akan dikirim pukul $timeReminderStr WIB (5 menit sebelum sesi).',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 42,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: const Text('Mengerti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Detail & Booking Dokter', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF4F46E5), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Dokter
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFFEEF2FF),
                            child: Icon(Icons.person_rounded, size: 32, color: Color(0xFF4F46E5)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.doctor.nama,
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.doctor.spesialis,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Pilih Slot Jam
                    const Text('Pilih Slot Jam Konsultasi (30 Menit)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('*Slot otomatis "Sold" jika sudah dibooking atau dokter sedang dalam sesi chat.', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                    const SizedBox(height: 12),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.8,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: widget.doctor.slots.length,
                      itemBuilder: (context, index) {
                        final slot = widget.doctor.slots[index];

                        // Logika Otomatis Slot Sold jika dokter sedang chat di jam tersebut
                        final isCurrentActiveSlot = now.hour == slot.startHour && (now.minute >= slot.startMinute && now.minute < slot.startMinute + 30);
                        final bool isSold = slot.isBooked || (widget.doctor.isBusyInChat && isCurrentActiveSlot);

                        final bool isSelected = _selectedSlot == slot;

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: isSold
                              ? null
                              : () {
                            setState(() {
                              _selectedSlot = slot;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSold
                                  ? const Color(0xFFF1F5F9)
                                  : (isSelected ? const Color(0xFF4F46E5) : Colors.white),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSold
                                    ? const Color(0xFFE2E8F0)
                                    : (isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1)),
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  slot.timeText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isSold
                                        ? const Color(0xFF94A3B8)
                                        : (isSelected ? Colors.white : const Color(0xFF1E293B)),
                                  ),
                                ),
                                if (isSold) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE2E8F0),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('Sold', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    const Text('Tentang Dokter', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(
                      widget.doctor.tentangDokter,
                      style: const TextStyle(fontSize: 12, color: Color(0xFF475569), height: 1.4),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol Konfirmasi
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  onPressed: _prosesBooking,
                  child: const Text('Konfirmasi Booking', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}