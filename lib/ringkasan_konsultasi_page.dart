import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'halaman_utama.dart';

class RingkasanKonsultasiPage extends StatelessWidget {
  final Doctor doctor;
  final String namaUser;

  const RingkasanKonsultasiPage({
    super.key,
    required this.doctor,
    this.namaUser = 'Pengguna',
  });

  String _getFormattedDate() {
    final now = DateTime.now();
    final List<String> months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    final day = now.day.toString().padLeft(2, '0');
    final month = months[now.month - 1];
    final year = now.year;
    return '$day $month $year';
  }

  @override
  Widget build(BuildContext context) {
    final currentDateStr = _getFormattedDate();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Ringkasan Konsultasi',
          style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hasil Skrining Terakhir',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Hasil Skrining', style: TextStyle(fontSize: 12, color: Colors.black87)),
                            Text('Positif', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tanggal Skrining', style: TextStyle(fontSize: 12, color: Colors.black87)),
                            Text(currentDateStr, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        const Divider(height: 32, thickness: 1),

                        const Text(
                          'Kesimpulan Dokter',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Berdasarkan hasil skrining dan keluhan yang Anda sampaikan, disarankan untuk melanjutkan pemeriksaan laboratorium lebih lanjut (cek gula darah puasa, HbA1c) untuk memastikan kondisi Anda.',
                          style: TextStyle(fontSize: 12, color: Colors.black87, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Tombol Kembali ke Beranda
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D83EC),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HalamanUtama(
                          namaUser: namaUser,
                          initialIndex: 0,
                        ),
                      ),
                          (route) => false,
                    );
                  },
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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