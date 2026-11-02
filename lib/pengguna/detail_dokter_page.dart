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

  // Menghasilkan List Item yang berisi Slot Konsultasi & Slot Istirahat
  List _generateSlotsAndBreak() {
    final List itemList = [];
    int currentMinutes = widget.doctor.jamMulai * 60;

    for (int i = 0; i < 20; i++) {
      // Sisipkan 1 Jam Istirahat di Tengah Shift (setelah pasien ke-10)
      if (i == 10) {
        int breakStart = currentMinutes;
        int breakEnd = currentMinutes + 60;

        int bsh = (breakStart ~/ 60) % 24;
        int bsm = breakStart % 60;
        int beh = (breakEnd ~/ 60) % 24;
        int bem = breakEnd % 60;

        String breakTimeText =
            '${bsh.toString().padLeft(2, '0')}.${bsm.toString().padLeft(2, '0')} - ${beh.toString().padLeft(2, '0')}.${bem.toString().padLeft(2, '0')}';

        itemList.add({
          'isBreak': true,
          'timeText': breakTimeText,
        });

        currentMinutes += 60; // Waktu istirahat 1 jam
      }

      int startMins = currentMinutes;
      int endMins = currentMinutes + 20;

      int sh = (startMins ~/ 60) % 24;
      int sm = startMins % 60;
      int eh = (endMins ~/ 60) % 24;
      int em = endMins % 60;

      String timeText =
          '${sh.toString().padLeft(2, '0')}.${sm.toString().padLeft(2, '0')} - ${eh.toString().padLeft(2, '0')}.${em.toString().padLeft(2, '0')}';

      itemList.add({
        'isBreak': false,
        'slot': TimeSlot(
          id: 's_$i',
          timeText: timeText,
          startHour: sh,
          startMinute: sm,
          isBooked: false, // Semua slot terbuka untuk uji coba
        ),
      });

      currentMinutes += 20;
    }

    return itemList;
  }

  void _prosesBooking() {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih slot konsultasi terlebih dahulu.'),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    final String roomId = '${widget.namaUser}_${widget.doctor.nama}';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatKonsultasiPage(
          roomId: roomId,
          currentUserId: widget.namaUser,
          dokterNama: widget.doctor.nama,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allItems = _generateSlotsAndBreak();
    final totalSlotsCount = allItems.where((item) => item['isBreak'] == false).length;

    final startShift = widget.doctor.jamMulai.toString().padLeft(2, '0');
    final endShift = widget.doctor.jamSelesai.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Booking Jadwal Dokter', style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold)),
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
                    // KARTU PROFIL DOKTER
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
                    const SizedBox(height: 14),

                    // TENTANG DOKTER
                    if (widget.doctor.tentangDokter.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFF1F5F9)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tentang Dokter', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                            const SizedBox(height: 6),
                            Text(
                              widget.doctor.tentangDokter,
                              style: const TextStyle(fontSize: 11.5, color: Color(0xFF475569), height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // KOTAK KUOTA PASIEN
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBBF7D0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.group_rounded, color: Color(0xFF16A34A), size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Kuota Pasien Hari Ini',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    color: Color(0xFF14532D),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Tersedia $totalSlotsCount slot waktu (Siap Diuji Coba)',
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF166534)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // JUDUL SHIFT JAM KONSULTASI
                    Text(
                      'Pilih Sesi Jam Konsultasi (Shift ($startShift.00 - $endShift.00)):',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    ),
                    const SizedBox(height: 12),

                    // GRID SLOT KONSULTASI & ISTIRAHAT
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.3,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: allItems.length,
                      itemBuilder: (context, index) {
                        final item = allItems[index];

                        if (item['isBreak'] == true) {
                          return Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFFFEDD5)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  item['timeText'],
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFFC2410C),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                const Text(
                                  'Istirahat Dokter',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFFEA580C),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        final TimeSlot slot = item['slot'];
                        final bool isSelected = _selectedSlot?.id == slot.id;

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() {
                              _selectedSlot = slot;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFCBD5E1),
                                width: isSelected ? 1.8 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  slot.timeText,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? const Color(0xFF4338CA) : const Color(0xFF334155),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isSelected ? 'Dipilih' : 'Tersedia',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFF16A34A),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // TOMBOL KONFIRMASI BOOKING
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
                  child: const Text('Konfirmasi Booking & Masuk Chat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}