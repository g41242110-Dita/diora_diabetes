import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'chat_konsultasi_page.dart';

class BookingDokterPage extends StatefulWidget {
  final Doctor doctor;
  final String namaUser;

  const BookingDokterPage({
    super.key,
    required this.doctor,
    required this.namaUser,
  });

  @override
  State<BookingDokterPage> createState() => _BookingDokterPageState();
}

class _BookingDokterPageState extends State<BookingDokterPage> {
  final int maxKuotaHarian = 20;
  int kuotaTerisi = 18; // Terisi 18, sisa 2 slot untuk uji coba

  String? selectedSlot;

  // LOGIKA SHIFT OTOMATIS BERDASARKAN NAMA DOKTER
  List<Map<String, dynamic>> _getSlotsForDoctor(String namaDokter) {
    // SHIFT 1: dr. Amanda Putri (07.00 - 15.00 | Istirahat 12.00 - 13.00)
    if (namaDokter.contains('Amanda')) {
      return [
        {'time': '07.00 - 07.20', 'isBooked': true, 'isOffline': false},
        {'time': '07.20 - 07.40', 'isBooked': true, 'isOffline': false},
        {'time': '07.40 - 08.00', 'isBooked': true, 'isOffline': false},
        {'time': '08.00 - 08.20', 'isBooked': true, 'isOffline': false},
        {'time': '08.20 - 08.40', 'isBooked': true, 'isOffline': false},
        {'time': '08.40 - 09.00', 'isBooked': true, 'isOffline': false},
        {'time': '09.00 - 09.20', 'isBooked': true, 'isOffline': false},
        {'time': '09.20 - 09.40', 'isBooked': true, 'isOffline': false},
        {'time': '09.40 - 10.00', 'isBooked': true, 'isOffline': false},
        {'time': '10.00 - 10.30', 'isBooked': true, 'isOffline': false},
        {'time': '10.30 - 11.00', 'isBooked': true, 'isOffline': false},
        {'time': '11.00 - 11.30', 'isBooked': true, 'isOffline': false},
        {'time': '11.30 - 12.00', 'isBooked': true, 'isOffline': false},
        // --- ISTIRAHAT SHIFT 1 (12.00 - 13.00) ---
        {'time': '12.00 - 13.00', 'isBooked': false, 'isOffline': true},
        {'time': '13.00 - 13.20', 'isBooked': false, 'isOffline': false}, // Kosong (Bisa dipilih)
        {'time': '13.20 - 13.40', 'isBooked': false, 'isOffline': false}, // Kosong (Bisa dipilih)
        {'time': '13.40 - 14.00', 'isBooked': true, 'isOffline': false},
        {'time': '14.00 - 14.30', 'isBooked': true, 'isOffline': false},
        {'time': '14.30 - 15.00', 'isBooked': true, 'isOffline': false},
      ];
    }
    // SHIFT 2: dr. Asila Salsavea Gunawan (15.00 - 23.00 | Istirahat 17.00 - 18.00)
    else if (namaDokter.contains('Asila')) {
      return [
        {'time': '15.00 - 15.20', 'isBooked': true, 'isOffline': false},
        {'time': '15.20 - 15.40', 'isBooked': true, 'isOffline': false},
        {'time': '15.40 - 16.00', 'isBooked': true, 'isOffline': false},
        {'time': '16.00 - 16.20', 'isBooked': true, 'isOffline': false},
        {'time': '16.20 - 16.40', 'isBooked': true, 'isOffline': false},
        {'time': '16.40 - 17.00', 'isBooked': true, 'isOffline': false},
        // --- ISTIRAHAT SHIFT 2 (17.00 - 18.00) ---
        {'time': '17.00 - 18.00', 'isBooked': false, 'isOffline': true},
        {'time': '18.00 - 18.20', 'isBooked': false, 'isOffline': false}, // Kosong (Bisa dipilih)
        {'time': '18.20 - 18.40', 'isBooked': false, 'isOffline': false}, // Kosong (Bisa dipilih)
        {'time': '18.40 - 19.00', 'isBooked': true, 'isOffline': false},
        {'time': '19.00 - 19.20', 'isBooked': true, 'isOffline': false},
        {'time': '19.20 - 19.40', 'isBooked': true, 'isOffline': false},
        {'time': '19.40 - 20.00', 'isBooked': true, 'isOffline': false},
        {'time': '20.00 - 20.30', 'isBooked': true, 'isOffline': false},
        {'time': '20.30 - 21.00', 'isBooked': true, 'isOffline': false},
        {'time': '21.00 - 21.30', 'isBooked': true, 'isOffline': false},
        {'time': '21.30 - 22.00', 'isBooked': true, 'isOffline': false},
        {'time': '22.00 - 22.30', 'isBooked': true, 'isOffline': false},
        {'time': '22.30 - 23.00', 'isBooked': true, 'isOffline': false},
      ];
    }
    // SHIFT 3: dr. Ryan Ramadhani (23.00 - 07.00 | Istirahat 03.00 - 04.00)
    else if (namaDokter.contains('Ryan')) {
      return [
        {'time': '23.00 - 23.30', 'isBooked': true, 'isOffline': false},
        {'time': '23.30 - 00.00', 'isBooked': true, 'isOffline': false},
        {'time': '00.00 - 00.30', 'isBooked': true, 'isOffline': false},
        {'time': '00.30 - 01.00', 'isBooked': true, 'isOffline': false},
        {'time': '01.00 - 01.30', 'isBooked': true, 'isOffline': false},
        {'time': '01.30 - 02.00', 'isBooked': true, 'isOffline': false},
        {'time': '02.00 - 02.30', 'isBooked': true, 'isOffline': false},
        {'time': '02.30 - 03.00', 'isBooked': true, 'isOffline': false},
        // --- ISTIRAHAT SHIFT 3 (03.00 - 04.00) ---
        {'time': '03.00 - 04.00', 'isBooked': false, 'isOffline': true},
        {'time': '04.00 - 04.30', 'isBooked': false, 'isOffline': false}, // Kosong (Bisa dipilih)
        {'time': '04.30 - 05.00', 'isBooked': false, 'isOffline': false}, // Kosong (Bisa dipilih)
        {'time': '05.00 - 05.20', 'isBooked': true, 'isOffline': false},
        {'time': '05.20 - 05.40', 'isBooked': true, 'isOffline': false},
        {'time': '05.40 - 06.00', 'isBooked': true, 'isOffline': false},
        {'time': '06.00 - 06.20', 'isBooked': true, 'isOffline': false},
        {'time': '06.20 - 06.40', 'isBooked': true, 'isOffline': false},
        {'time': '06.40 - 07.00', 'isBooked': true, 'isOffline': false},
      ];
    }
    // DEFAULT UNTUK DOKTER LAIN / OFFLINE
    else {
      return [
        {'time': 'Jadwal Tidak Tersedia', 'isBooked': false, 'isOffline': true},
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeSlots = _getSlotsForDoctor(widget.doctor.nama);
    int sisaKuota = maxKuotaHarian - kuotaTerisi;
    bool isKuotaPenuh = sisaKuota <= 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Booking Jadwal Dokter',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF6679F4), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Ringkas Dokter
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 26,
                      backgroundColor: Color(0xFFE2E7FF),
                      child: Icon(Icons.person, size: 32, color: Color(0xFF6679F4)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.doctor.nama,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.doctor.spesialis,
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Banner Status Kuota Pasien
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isKuotaPenuh ? const Color(0xFFFFEBF0) : const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isKuotaPenuh ? const Color(0xFFE53E3E) : const Color(0xFF2E7D32),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isKuotaPenuh ? Icons.error_outline : Icons.people_outline,
                      color: isKuotaPenuh ? const Color(0xFFE53E3E) : const Color(0xFF2E7D32),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kuota Pasien Hari Ini',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            isKuotaPenuh
                                ? 'Kuota Penuh ($kuotaTerisi/$maxKuotaHarian Pasien)'
                                : 'Terisi $kuotaTerisi dari $maxKuotaHarian pasien (Tersedia $sisaKuota slot waktu)',
                            style: TextStyle(
                              fontSize: 11,
                              color: isKuotaPenuh ? const Color(0xFFE53E3E) : const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'Pilih Sesi Jam Konsultasi (${widget.doctor.statusJam}):',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87),
              ),
              const SizedBox(height: 10),

              // Grid Slot Jam Konsultasi
              Expanded(
                child: GridView.builder(
                  itemCount: timeSlots.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.6,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (context, index) {
                    final slot = timeSlots[index];
                    final String timeText = slot['time'];
                    final bool isBooked = slot['isBooked'];
                    final bool isOffline = slot['isOffline'];
                    final bool isSelected = selectedSlot == timeText;

                    final bool canSelect = !isOffline && !isBooked && !isKuotaPenuh;

                    Color cardBgColor = Colors.white;
                    Color textColor = Colors.black87;
                    Color borderColor = Colors.grey.shade300;
                    String statusText = 'Tersedia';

                    if (isOffline) {
                      cardBgColor = Colors.orange.shade50;
                      borderColor = Colors.orange.shade300;
                      textColor = Colors.orange.shade900;
                      statusText = 'Jam Istirahat / Jeda';
                    } else if (isBooked) {
                      cardBgColor = Colors.grey.shade100;
                      borderColor = Colors.grey.shade300;
                      textColor = Colors.grey;
                      statusText = 'Sudah Dipesan';
                    } else if (isSelected) {
                      cardBgColor = const Color(0xFF6679F4);
                      borderColor = const Color(0xFF6679F4);
                      textColor = Colors.white;
                      statusText = 'Dipilih';
                    }

                    return InkWell(
                      borderRadius: BorderRadius.circular(10),
                      onTap: canSelect
                          ? () {
                        setState(() {
                          selectedSlot = timeText;
                        });
                      }
                          : null,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: cardBgColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              timeText,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontSize: 9,
                                color: isSelected ? Colors.white70 : textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Tombol Konfirmasi Booking
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedSlot != null ? const Color(0xFF6679F4) : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  onPressed: selectedSlot != null
                      ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Booking berhasil untuk jam $selectedSlot!'),
                        backgroundColor: Colors.green,
                      ),
                    );

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatKonsultasiPage(
                          doctor: widget.doctor,
                          namaUser: widget.namaUser,
                          jamBooking: selectedSlot,
                        ),
                      ),
                    );
                  }
                      : null,
                  child: const Text(
                    'Konfirmasi Booking & Masuk Chat',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}