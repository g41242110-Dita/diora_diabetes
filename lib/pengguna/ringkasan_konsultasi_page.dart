import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'beranda_page.dart';
import 'rating_dialog.dart';

class RingkasanKonsultasiPage extends StatelessWidget {
  final Doctor doctor;
  final String namaUser;
  final String roomId;
  final String currentUserId;

  const RingkasanKonsultasiPage({
    super.key,
    required this.doctor,
    this.namaUser = 'Pengguna',
    this.roomId = '',
    this.currentUserId = '',
  });

  void _openRatingDialog(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RatingDialog(
        doctor: doctor,
        currentUserId: currentUserId,
        namaUser: namaUser,
      ),
    );

    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (context) => BerandaPage(
            namaUser: namaUser,
          ),
        ),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Hasil Skrining Terakhir',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Hasil Skrining',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF64748B))),
                            Text('Positif',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('Tanggal Skrining',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF64748B))),
                            Text('03 November 2026',
                                style: TextStyle(
                                    fontSize: 13, color: Color(0xFF94A3B8))),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Divider(),
                        ),
                        const Text(
                          'Kesimpulan Dokter',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Berdasarkan hasil skrining dan keluhan yang Anda sampaikan, disarankan untuk melanjutkan pemeriksaan laboratorium lebih lanjut (cek gula darah puasa, HbA1c) untuk memastikan kondisi Anda.',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF475569),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // TOMBOL KEMBALI KE BERANDA (AKAN MEMUNCULKAN RATING DIALOG SEBELUM KE BERANDA)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B71F3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => _openRatingDialog(context),
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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