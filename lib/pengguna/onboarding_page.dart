import 'package:flutter/material.dart';
import 'daftar_akun.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Gambar Ilustrasi
              Center(
                child: Image.asset(
                  'assets/onboarding1.png',
                  height: 240,
                  fit: BoxFit.contain,
                ),
              ),

              const Spacer(flex: 2),

              // Judul Utama
              const Text(
                'Kenali Risiko\nDiabetes Sejak Dini',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.25,
                ),
              ),

              const SizedBox(height: 12),

              // Deskripsi
              const Text(
                'Lakukan skrining, dapatkan rekomendasi, dan jaga kesehatan bersama Diora.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF555555),
                  height: 1.4,
                ),
              ),

              const Spacer(flex: 3),

              // Tombol Mulai
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    // Diubah dari Navigator.push menjadi Navigator.pushReplacement
                    // agar halaman Onboarding tertutup dan tidak bisa di-back ke sini
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DaftarAkunPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6675F5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Mulai',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 18),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Teks Versi
              const Center(
                child: Text(
                  'VERSI 1.0',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFFBDBDBD),
                    letterSpacing: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}