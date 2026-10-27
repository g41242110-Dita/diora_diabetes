import 'package:flutter/material.dart';
import 'dokter_room_chat_page.dart';
import 'dokter_riwayat_konsultasi_page.dart';

class DokterKonsultasiPage extends StatefulWidget {
  const DokterKonsultasiPage({super.key});

  @override
  State<DokterKonsultasiPage> createState() => _DokterKonsultasiPageState();
}

class _DokterKonsultasiPageState extends State<DokterKonsultasiPage> {
  // Data slot booking: Hanya 1 pasien yang "Sedang Berlangsung"
  final List<Map<String, dynamic>> _slotKonsultasi = [
    {
      'jam': '09.40 - 10.00',
      'statusSlot': 'Selesai',
      'pasien': 'Aurelia Priscilla',
      'genderAge': '20 th • Perempuan',
      'keluhan': 'Dok, saya ingin menanyakan hasil skrining',
      'statusMedis': 'Positif',
    },
    {
      'jam': '10.00 - 10.30',
      'statusSlot': 'Selesai',
      'pasien': 'Budi Hartono',
      'genderAge': '48 th • Laki-Laki',
      'keluhan': 'Konsultasi hasil gula darah puasa',
      'statusMedis': 'Positif',
    },
    {
      'jam': '10.30 - 11.00',
      'statusSlot': 'Selesai',
      'pasien': 'Dewi Lestari',
      'genderAge': '30 th • Perempuan',
      'keluhan': 'Mual dan pusing sejak kemarin malam',
      'statusMedis': 'Negatif',
    },
    {
      'jam': '12.00 - 13.00',
      'statusSlot': 'Jam Istirahat',
      'pasien': null,
    },
    {
      'jam': '13.00 - 13.20',
      'statusSlot': 'Sedang Berlangsung', // HANYA INI YANG BISA DI-CHAT SEKARANG
      'pasien': 'Rian Hidayat',
      'genderAge': '42 th • Laki-Laki',
      'keluhan': 'Badan terasa lemas di siang hari',
      'statusMedis': 'Positif',
    },
    {
      'jam': '13.20 - 13.40',
      'statusSlot': 'Mendatang', // BELUM BISA DIKLIK (NUNGGU JAM SESI)
      'pasien': 'Maya Indah',
      'genderAge': '26 th • Perempuan',
      'keluhan': 'Konsultasi lanjutan gula darah',
      'statusMedis': 'Negatif',
    },
    {
      'jam': '13.40 - 14.00',
      'statusSlot': 'Tersedia',
      'pasien': null,
    },
    {
      'jam': '14.00 - 14.30',
      'statusSlot': 'Mendatang',
      'pasien': 'Hendra Wijaya',
      'genderAge': '51 th • Laki-Laki',
      'keluhan': 'Pemeriksaan rutin mingguan',
      'statusMedis': 'Positif',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Jadwal Booking Konsultasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DokterRiwayatKonsultasiPage(),
                ),
              );
            },
            icon: const Icon(Icons.history_rounded, color: Color(0xFF4F46E5), size: 18),
            label: const Text(
              'Riwayat',
              style: TextStyle(
                color: Color(0xFF4F46E5),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Kuota Pasien
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.people_alt_outlined, color: Color(0xFF166534), size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Kuota Pasien Hari Ini',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: Color(0xFF166534),
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Terisi 18 dari 20 pasien (Tersedia 2 slot waktu)',
                          style: TextStyle(fontSize: 11.5, color: Color(0xFF15803D)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'Sesi Jam Konsultasi Dokter (Shift 1 (07.00 - 15.00)):',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 12),

            // List Sesi Booking
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _slotKonsultasi.length,
              itemBuilder: (context, index) {
                final item = _slotKonsultasi[index];
                final String status = item['statusSlot'];

                final bool isAktif = status == 'Sedang Berlangsung';
                final bool isSelesai = status == 'Selesai';
                final bool isBreak = status == 'Jam Istirahat';
                final bool isTersedia = status == 'Tersedia';

                return InkWell(
                  onTap: () {
                    if (isSelesai) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sesi ini sudah lewat / selesai.'),
                          backgroundColor: Colors.grey,
                        ),
                      );
                    } else if (status == 'Mendatang') {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Sesi ${item['jam']} belum dimulai.'),
                          backgroundColor: Colors.orange,
                        ),
                      );
                    } else if (isAktif && item['pasien'] != null) {
                      // HANYA PASIEN SESI AKTIF YANG BISA DIBUKA CHATNYA
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DokterRoomChatPage(
                            namaPasien: item['pasien'],
                            genderAge: item['genderAge'] ?? 'Pasien',
                            jamSesi: item['jam'],
                          ),
                        ),
                      );
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isAktif
                          ? const Color(0xFFEEF2FF)
                          : (isSelesai
                          ? const Color(0xFFF8FAFC)
                          : (isBreak ? const Color(0xFFFFFBEB) : Colors.white)),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isAktif
                            ? const Color(0xFF6366F1)
                            : (isBreak ? const Color(0xFFFDE68A) : const Color(0xFFE2E8F0)),
                        width: isAktif ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Jam Slot
                        Container(
                          width: 95,
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
                          decoration: BoxDecoration(
                            color: isAktif
                                ? const Color(0xFF4F46E5)
                                : (isSelesai
                                ? const Color(0xFFE2E8F0)
                                : (isBreak ? const Color(0xFFFEF3C7) : const Color(0xFFF1F5F9))),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              item['jam'],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isAktif
                                    ? Colors.white
                                    : (isSelesai
                                    ? const Color(0xFF94A3B8)
                                    : (isBreak ? const Color(0xFF92400E) : const Color(0xFF475569))),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        // Detail Pasien
                        Expanded(
                          child: item['pasien'] != null
                              ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    item['pasien'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isSelesai
                                          ? const Color(0xFF94A3B8)
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  if (isAktif)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFDCFCE7),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: const Color(0xFF86EFAC)),
                                      ),
                                      child: const Text(
                                        'Mulai Chat',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF166534),
                                        ),
                                      ),
                                    )
                                  else if (!isSelesai)
                                    const Icon(
                                      Icons.chevron_right_rounded,
                                      color: Color(0xFF4F46E5),
                                      size: 20,
                                    ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: isSelesai
                                          ? Colors.grey
                                          : (item['statusMedis'] == 'Positif'
                                          ? Colors.redAccent
                                          : Colors.green),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    item['statusMedis'],
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSelesai
                                          ? const Color(0xFF94A3B8)
                                          : (item['statusMedis'] == 'Positif'
                                          ? Colors.redAccent
                                          : Colors.green),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '• ${item['genderAge']}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: isSelesai
                                          ? const Color(0xFFCBD5E1)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isSelesai ? 'Konsultasi telah selesai' : item['keluhan'],
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSelesai
                                      ? const Color(0xFFCBD5E1)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          )
                              : Text(
                            isTersedia ? 'Slot Masih Tersedia' : status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isBreak
                                  ? const Color(0xFFB45309)
                                  : const Color(0xFF94A3B8),
                            ),
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
    );
  }
}