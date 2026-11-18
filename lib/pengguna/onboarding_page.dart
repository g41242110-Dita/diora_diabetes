import 'dart:math';
import 'package:flutter/material.dart';
import 'daftar_akun.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatingController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _floatingAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatingAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            // --- GELEMBUNG LATAR BELAKANG UTAMA ---
            Positioned(
              top: -50,
              right: -40,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF4F46E5).withValues(alpha: 0.22),
                        const Color(0xFF3B82F6).withValues(alpha: 0.05),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 190,
              left: -70,
              child: ScaleTransition(
                scale: _pulseAnimation,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFFEF4444).withValues(alpha: 0.16),
                        const Color(0xFFF59E0B).withValues(alpha: 0.04),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              bottom: 100,
              right: -30,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF6366F1).withValues(alpha: 0.08),
                ),
              ),
            ),

            // --- IKON KESEHATAN DI KANAN ATAS ---
            Positioned(
              top: 95,
              right: 45,
              child: AnimatedBuilder(
                animation: _floatingAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _floatingAnimation.value),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.health_and_safety,
                        size: 26,
                        color: Color(0xFF4F46E5),
                      ),
                    ),
                  );
                },
              ),
            ),

            // --- KONTEN UTAMA (1 HALAMAN) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  const Spacer(flex: 1),

                  // FOTO / ILUSTRASI DENGAN CAHAYA PEMANCAR (GLOW)
                  Center(
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(38),
                            border: Border.all(
                              color: Colors.white,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF4F46E5).withValues(
                                  alpha: 0.4 * _pulseAnimation.value,
                                ),
                                blurRadius: 50,
                                spreadRadius: 4,
                                offset: const Offset(0, 14),
                              ),
                              BoxShadow(
                                color: const Color(0xFFEF4444).withValues(
                                  alpha: 0.25,
                                ),
                                blurRadius: 25,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            'assets/onboarding1.png',
                            height: 230,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ),

                  const Spacer(flex: 1),

                  // --- JUDUL DENGAN GAYA TULISAN ELEGAN / ARTISTIK (SEMICLASSIC) ---
                  RichText(
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                        letterSpacing: -0.5,
                      ),
                      children: [
                        TextSpan(text: 'Kenali '),
                        TextSpan(
                          text: 'Risiko\n',
                          style: TextStyle(
                            color: Color(0xFF4F46E5),
                            fontStyle: FontStyle.italic, // Memberikan sentuhan artistik/semi-serif
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        TextSpan(text: 'Diabetes Sejak Dini'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // DESKRIPSI DENGAN GAYA ELEGAN
                  const Text(
                    'Lakukan skrining mandiri secara akurat, dapatkan rekomendasi terbaik, dan jaga kesehatan masa depan bersama Diora.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const Spacer(flex: 2),

                  // --- TOMBOL MULAI (SUDAH DIKECILKAN) ---
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF6679F4)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const DaftarAkunPage(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Mulai',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // TEKS VERSI
                  const Center(
                    child: Text(
                      'VERSI 1.0',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF94A3B8),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),

            // --- IKON TETESAN DARAH DI DEPAN (DI POJOK KANAN ATAS FOTO) ---
            Positioned(
              top: 85,
              right: 22,
              child: AnimatedBuilder(
                animation: _floatingAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -_floatingAnimation.value),
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        size: 32,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}