import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth_router.dart';
import 'daftar_akun.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with TickerProviderStateMixin {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final captchaController = TextEditingController();

  bool passwordVisible = false;
  bool isLoading = false;

  bool showErrorBanner = false;
  String errorMessage = 'Pastikan semua kolom telah diisi dengan benar.';
  bool emailError = false;
  bool passwordError = false;
  bool captchaError = false;

  String captcha = '';
  int captchaSeed = 0;

  // Controller Animasi Masuk Halaman
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Controller Animasi Denyut Halus Khusus Ikon Tetesan Darah
  late AnimationController _bloodPulseController;
  late Animation<double> _bloodPulseAnimation;

  @override
  void initState() {
    super.initState();
    refreshCaptcha();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _animController.forward();

    // Denyut lembut khusus ikon tetesan darah
    _bloodPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _bloodPulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _bloodPulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    _animController.dispose();
    _bloodPulseController.dispose();
    super.dispose();
  }

  void refreshCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    Random random = Random();
    String newCaptcha = String.fromCharCodes(
      Iterable.generate(5, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );

    setState(() {
      captcha = newCaptcha;
      captchaSeed = random.nextInt(100000);
      captchaController.clear();
      captchaError = false;
    });
  }

  Future<void> login() async {
    setState(() {
      showErrorBanner = false;
      emailError = emailController.text.trim().isEmpty;
      passwordError = passwordController.text.isEmpty;
      captchaError = captchaController.text.trim().isEmpty;
    });

    if (emailError || passwordError || captchaError) {
      setState(() {
        showErrorBanner = true;
        errorMessage = 'Pastikan semua kolom telah diisi dengan benar.';
      });
      return;
    }

    if (captchaController.text.trim().toUpperCase() != captcha) {
      setState(() {
        showErrorBanner = true;
        captchaError = true;
        errorMessage = 'Kode Captcha tidak sesuai.';
      });
      refreshCaptcha();
      return;
    }

    setState(() {
      isLoading = true;
      showErrorBanner = false;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final User? user = userCredential.user;

      if (user == null) {
        throw Exception('User tidak ditemukan.');
      }

      if (!mounted) return;

      final bool berhasil = await AuthRouter.arahkan(context, user);

      if (!mounted) return;

      if (!berhasil) {
        setState(() {
          isLoading = false;
          showErrorBanner = true;
          errorMessage =
          'Data akun tidak ditemukan atau role tidak dikenal. Hubungi admin.';
        });
        refreshCaptcha();
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'Email belum terdaftar.';
          break;
        case 'wrong-password':
        case 'invalid-credential':
          message = 'Email atau Kata Sandi yang Anda masukkan salah.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        case 'user-disabled':
          message = 'Akun ini telah dinonaktifkan.';
          break;
        case 'network-request-failed':
          message = 'Tidak ada koneksi internet.';
          break;
        default:
          message = 'Gagal masuk: ${e.message ?? e.code}';
      }

      setState(() {
        isLoading = false;
        showErrorBanner = true;
        emailError = true;
        passwordError = true;
        errorMessage = message;
      });
      refreshCaptcha();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        showErrorBanner = true;
        errorMessage = 'Terjadi kesalahan: $e';
      });
      refreshCaptcha();
    }
  }

  InputDecoration inputDecoration({
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
    bool isError = false,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: isError ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
      prefixIcon: Icon(
        icon,
        size: 20,
        color: isError ? const Color(0xFFEF4444) : const Color(0xFF6679F4),
      ),
      suffixIcon: suffixIcon,
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade400,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: isError ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: isError ? const Color(0xFFEF4444) : const Color(0xFFE2E8F0),
          width: 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(
          color: isError ? const Color(0xFFEF4444) : const Color(0xFF6679F4),
          width: 1.5,
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
            height: 310,
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

          // 2. KONTEN UTAMA
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 2),

                      // AREA HEADER: LOGO & TETESAN DARAH
                      SizedBox(
                        height: 145,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 14),
                              child: SizedBox(
                                height: 138,
                                child: Image.asset(
                                  'assets/logo.png',
                                  fit: BoxFit.contain,
                                  filterQuality: FilterQuality.high,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 6,
                              right: 12,
                              child: ScaleTransition(
                                scale: _bloodPulseAnimation,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFFEF4444).withValues(alpha: 0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.water_drop_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 2),

                      // JUDUL "Masuk" & SUBJUDUL
                      const Text(
                        'Masuk',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Masuk ke akun Diora Anda untuk melanjutkan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                        ),
                      ),

                      const SizedBox(height: 22),

                      // 3. FLOATING FORM CARD
                      Container(
                        padding: const EdgeInsets.all(22),
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
                            // Input Email
                            TextField(
                              controller: emailController,
                              enabled: !isLoading,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                              onChanged: (_) {
                                if (emailError) setState(() => emailError = false);
                              },
                              decoration: inputDecoration(
                                icon: Icons.email_outlined,
                                hint: 'Masukkan Email Anda',
                                isError: emailError,
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Input Password
                            TextField(
                              controller: passwordController,
                              enabled: !isLoading,
                              obscureText: !passwordVisible,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                              ),
                              onChanged: (_) {
                                if (passwordError) setState(() => passwordError = false);
                              },
                              decoration: inputDecoration(
                                icon: Icons.lock_outline_rounded,
                                hint: 'Masukkan Kata Sandi',
                                isError: passwordError,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    passwordVisible
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                    color: Colors.grey.shade500,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      passwordVisible = !passwordVisible;
                                    });
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 18),

                            // Label Captcha
                            const Text(
                              'Verifikasi Captcha',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                            ),

                            const SizedBox(height: 8),

                            // Baris Kotak Captcha & Refresh
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(
                                        color: const Color(0xFFCBD5E1),
                                        width: 1.2,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(17),
                                      child: CustomPaint(
                                        painter: DistortedCaptchaPainter(
                                          code: captcha,
                                          seed: captchaSeed,
                                        ),
                                        child: const SizedBox.expand(),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 54,
                                  height: 54,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(
                                      color: const Color(0xFF6679F4).withValues(alpha: 0.2),
                                    ),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.refresh_rounded,
                                      size: 22,
                                      color: Color(0xFF6679F4),
                                    ),
                                    onPressed: isLoading ? null : refreshCaptcha,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 12),

                            // Input Kode Captcha
                            TextField(
                              controller: captchaController,
                              enabled: !isLoading,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                              ),
                              textCapitalization: TextCapitalization.characters,
                              onChanged: (_) {
                                if (captchaError) setState(() => captchaError = false);
                              },
                              decoration: inputDecoration(
                                icon: Icons.shield_outlined,
                                hint: 'Masukkan Kode Captcha',
                                isError: captchaError,
                              ),
                            ),

                            const SizedBox(height: 22),

                            // TOMBOL MASUK
                            Container(
                              height: 52,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(24),
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF6679F4), Color(0xFF5366E6)],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6679F4).withValues(alpha: 0.32),
                                    blurRadius: 14,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: isLoading ? null : login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: isLoading
                                    ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                    : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Masuk',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      size: 18,
                                      color: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            // Lupa Kata Sandi
                            Center(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const ForgotPasswordPage(),
                                    ),
                                  );
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                  child: Text(
                                    'Lupa Kata Sandi?',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF6679F4),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 22),

                      // Bagian Bawah: Belum Punya Akun? Daftar
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Belum Punya Akun? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DaftarAkunPage(),
                                ),
                              );
                            },
                            child: const Text(
                              'Daftar',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6679F4),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 4. BANNER ERROR MERAH PENUH (Gaya Baru ala Daftar Akun)
          if (showErrorBanner)
            Positioned(
              top: 10,
              left: 20,
              right: 20,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 300),
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, -20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.priority_high_rounded,
                          color: Color(0xFFEF4444),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          errorMessage,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showErrorBanner = false;
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// PAINTER KHUSUS CAPTCHA DENGAN BINTIK NOISE, GARIS GELOMBANG & HURUF WARNA-WARNI
class DistortedCaptchaPainter extends CustomPainter {
  final String code;
  final int seed;

  DistortedCaptchaPainter({required this.code, required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(seed);

    // 1. Background putih bersih
    final bgPaint = Paint()..color = Colors.white;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 2. Bintik-bintik noise halus warna-warni di seluruh latar belakang
    final noiseColors = [
      Colors.red.withValues(alpha: 0.25),
      Colors.blue.withValues(alpha: 0.25),
      Colors.green.withValues(alpha: 0.25),
      Colors.orange.withValues(alpha: 0.25),
      Colors.purple.withValues(alpha: 0.25),
      Colors.teal.withValues(alpha: 0.25),
    ];

    final dotPaint = Paint()..strokeWidth = 1.4;
    for (int i = 0; i < 420; i++) {
      dotPaint.color = noiseColors[random.nextInt(noiseColors.length)];
      final dx = random.nextDouble() * size.width;
      final dy = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(dx, dy), 0.9, dotPaint);
    }

    // 3. Karakter Captcha warna-warni dengan rotasi & posisi naik-turun
    final charColors = [
      const Color(0xFFB45309), // Cokelat oranye
      const Color(0xFF0891B2), // Biru cyan
      const Color(0xFF15803D), // Hijau tua
      const Color(0xFF9CA309), // Hijau zaitun / kuning tua
      const Color(0xFF4F46E5), // Indigo
      const Color(0xFFBE123C), // Merah marun
    ];

    final charCount = code.length;
    final stepX = (size.width - 32) / charCount;

    for (int i = 0; i < charCount; i++) {
      final char = code[i];
      final color = charColors[random.nextInt(charColors.length)];

      TextPainter textPainter = TextPainter(
        text: TextSpan(
          text: char,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      canvas.save();
      double x = 16 + (i * stepX) + random.nextDouble() * 4;
      double y = (size.height - textPainter.height) / 2 + (random.nextDouble() * 10 - 5);

      canvas.translate(x, y);
      double angle = (random.nextDouble() - 0.5) * 0.5; // Rotasi acak (-0.25 sampai 0.25 radian)
      canvas.rotate(angle);

      textPainter.paint(canvas, Offset.zero);
      canvas.restore();
    }

    // 4. Garis gelombang pengganggu (noise lines) di atas teks
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int l = 0; l < 3; l++) {
      linePaint.color = noiseColors[random.nextInt(noiseColors.length)];
      Path path = Path();
      double startY = random.nextDouble() * size.height;
      path.moveTo(0, startY);

      for (double x = 0; x < size.width; x += 20) {
        double y = startY + sin(x * 0.05 + l) * 8 + (random.nextDouble() * 6 - 3);
        path.lineTo(x, y);
      }
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}