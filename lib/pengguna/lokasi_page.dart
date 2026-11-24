import 'package:flutter/material.dart';
import 'daftar_klinik_page.dart';

class LokasiPage extends StatefulWidget {
  const LokasiPage({super.key});

  @override
  State<LokasiPage> createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  void _navigateToDaftarKlinik(bool isGranted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DaftarKlinikPage(
          isLocationGranted: isGranted,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FB),
      body: Stack(
        children: [
          // 1. LATAR BELAKANG HEADER MELENGKUNG
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 320,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFE4E9FF),
                    Color(0xFFEEF2FF),
                    Color(0xFFF8FAFC),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(42),
                  bottomRight: Radius.circular(42),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    left: -40,
                    child: Container(
                      width: 170,
                      height: 170,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF6679F4).withValues(alpha: 0.08),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    right: -30,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFEF4444).withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. KONTEN UTAMA HALAMAN PENUH
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tombol Kembali (AppBar Manual)
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E293B).withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF6679F4),
                            size: 20,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 36),

                  // Ilustrasi / Ikon Lokasi di Tengah Atas
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6679F4).withValues(alpha: 0.15),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.explore_rounded,
                        size: 46,
                        color: Color(0xFF6679F4),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Judul & Deskripsi (Mencakup Rumah Sakit, Puskesmas, dan Klinik)
                  const Text(
                    'Akses Lokasi Anda',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 13.5,
                          color: Color(0xFF475569),
                          height: 1.5,
                        ),
                        children: [
                          TextSpan(text: 'Izinkan '),
                          TextSpan(
                            text: 'Diora ',
                            style: TextStyle(
                              color: Color(0xFF6679F4),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: 'mengakses lokasi perangkat Anda untuk menemukan layanan Rumah Sakit, Puskesmas, dan Klinik terdekat dengan cepat.',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // KARTU TOMBOL IZIN LOKASI
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 26),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.06),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Tombol Aksi 1: Izinkan Saat Aplikasi Digunakan
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF6679F4), Color(0xFF5366E6)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF6679F4).withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () => _navigateToDaftarKlinik(true),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Izinkan Saat Aplikasi Digunakan',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Tombol Aksi 2: Izinkan Sekali Ini Saja
                        SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => _navigateToDaftarKlinik(true),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFF1E293B),
                              side: const BorderSide(
                                color: Color(0xFFCBD5E1),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                            ),
                            child: const Text(
                              'Izinkan Sekali Ini Saja',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Tombol Aksi 3: Jangan Izinkan -> Langsung kembali ke BerandaPage
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFFEF4444),
                            ),
                            child: const Text(
                              'Jangan Izinkan',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}