import 'package:flutter/material.dart';

/// Halaman Utama aplikasi DiOra yang diimplementasikan dengan tata letak
/// terstruktur menggunakan widget native untuk elemen interaktif sesuai desain Figma.
class HalamanUtama extends StatelessWidget {
  const HalamanUtama({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;

            return Stack(
              children: [
                // Komponen Dasar: Menggunakan asset gambar untuk mereproduksi visual
                // logo dan ilustrasi secara presisi sesuai proporsi Figma.
                Positioned.fill(
                  child: Image.asset(
                    'assets/HAL UTAMA.png',
                    fit: BoxFit.cover,
                  ),
                ),

                // Lapisan Komponen Native: Menyediakan teks interaktif dan terstruktur
                // yang menutupi teks statis pada screenshot dengan rapi.
                SizedBox.expand(
                  child: Column(
                    children: [
                      // Area atas untuk memberikan ruang bagi Logo DiOra dari gambar latar
                      SizedBox(height: screenHeight * 0.36),

                      // Kontainer Tagline: Menggunakan latar belakang putih untuk menutup
                      // teks statis di gambar dan menggantinya dengan widget Text native yang interaktif.
                      Container(
                        width: double.infinity,
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: const Text(
                          'Know Your Risk.\nCare For Your Health.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B66F5),
                            height: 1.3,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Teks Versi Native di bagian bawah halaman
                      const Padding(
                        padding: EdgeInsets.only(bottom: 20.0),
                        child: Text(
                          'VERSI 1.0',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF7A9AE0),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
