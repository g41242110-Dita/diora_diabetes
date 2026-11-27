import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../auth_router.dart';
import 'login_page.dart';

class DaftarAkunPage extends StatefulWidget {
  const DaftarAkunPage({super.key});

  @override
  State<DaftarAkunPage> createState() => _DaftarAkunPageState();
}

class _DaftarAkunPageState extends State<DaftarAkunPage>
    with TickerProviderStateMixin {
  final namaController = TextEditingController();
  final nikController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final captchaController = TextEditingController();

  bool passwordVisible = false;
  bool isLoading = false;

  bool showErrorBanner = false;
  String errorMessage = 'Pastikan semua kolom telah diisi dengan benar.';

  bool namaError = false;
  bool nikError = false;
  bool emailError = false;
  bool passwordError = false;
  bool captchaError = false;

  String captcha = '';
  int captchaSeed = 0;

  late AnimationController _animController;
  late AnimationController _bloodPulseController;

  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
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
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _bloodPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _bloodPulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _bloodPulseController, curve: Curves.easeInOut),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    namaController.dispose();
    nikController.dispose();
    emailController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    _animController.dispose();
    _bloodPulseController.dispose();
    super.dispose();
  }

  void refreshCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = Random();
    final newCaptcha = String.fromCharCodes(
      Iterable.generate(
        5,
            (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );

    setState(() {
      captcha = newCaptcha;
      captchaSeed = random.nextInt(100000);
      captchaController.clear();
      captchaError = false;
    });
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isNikValid(String nik) {
    return RegExp(r'^\d{16}$').hasMatch(nik);
  }

  Future<void> daftar() async {
    setState(() {
      showErrorBanner = false;
      namaError = namaController.text.trim().isEmpty;
      nikError = nikController.text.trim().isEmpty;
      emailError = emailController.text.trim().isEmpty;
      passwordError = passwordController.text.isEmpty;
      captchaError = captchaController.text.trim().isEmpty;
    });

    if (namaError ||
        nikError ||
        emailError ||
        passwordError ||
        captchaError) {
      setState(() {
        showErrorBanner = true;
        errorMessage = 'Pastikan semua kolom telah diisi dengan benar.';
      });
      return;
    }

    final nama = namaController.text.trim();
    final nik = nikController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final captchaInput = captchaController.text.trim().toUpperCase();

    if (!_isNikValid(nik)) {
      setState(() {
        showErrorBanner = true;
        nikError = true;
        errorMessage = 'NIK harus terdiri dari 16 digit angka.';
      });
      return;
    }

    if (!_isEmailValid(email)) {
      setState(() {
        showErrorBanner = true;
        emailError = true;
        errorMessage = 'Format email tidak valid.';
      });
      return;
    }

    if (password.length < 6) {
      setState(() {
        showErrorBanner = true;
        passwordError = true;
        errorMessage = 'Password minimal terdiri dari 6 karakter.';
      });
      return;
    }

    if (captchaInput != captcha) {
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
      final UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = userCredential.user;
      if (user == null) {
        throw Exception('User Firebase tidak ditemukan.');
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nama': nama,
        'nik': nik,
        'email': email,
        'uid': user.uid,
        'role': 'pengguna',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      final bool berhasil = await AuthRouter.arahkan(context, user);

      if (!mounted) return;

      if (!berhasil) {
        setState(() {
          isLoading = false;
          showErrorBanner = true;
          errorMessage = 'Akun dibuat, tetapi data akun tidak ditemukan.';
        });
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'Email tersebut sudah terdaftar.';
          break;
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        case 'weak-password':
          message = 'Password terlalu lemah.';
          break;
        case 'operation-not-allowed':
          message = 'Login Email/Password belum diaktifkan di Firebase.';
          break;
        case 'network-request-failed':
          message = 'Tidak ada koneksi internet.';
          break;
        default:
          message = 'Gagal membuat akun: ${e.message ?? e.code}';
      }

      setState(() {
        isLoading = false;
        showErrorBanner = true;
        errorMessage = message;
      });
      refreshCaptcha();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        showErrorBanner = true;
        errorMessage =
        'Gagal menyimpan data ke Firebase: ${e.message ?? e.code}';
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
      isDense: true,
      filled: true,
      fillColor: isError ? const Color(0xFFFEF2F2) : const Color(0xFFF8FAFC),
      prefixIcon: Icon(
        icon,
        size: 19,
        color: isError ? const Color(0xFFEF4444) : const Color(0xFF6679F4),
      ),
      suffixIcon: suffixIcon,
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 12.5,
        color: Colors.grey.shade400,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 11,
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
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
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
          SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
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
                                        color: const Color(0xFFEF4444)
                                            .withValues(alpha: 0.2),
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
                      const Text(
                        'Daftar Akun',
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
                        'Buat akun Diora baru untuk mengakses layanan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E293B)
                                    .withValues(alpha: 0.06),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextField(
                                controller: namaController,
                                enabled: !isLoading,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF1E293B),
                                ),
                                onChanged: (_) {
                                  if (namaError) {
                                    setState(() => namaError = false);
                                  }
                                },
                                decoration: inputDecoration(
                                  icon: Icons.person_outline,
                                  hint: 'Masukkan Nama Lengkap',
                                  isError: namaError,
                                ),
                              ),
                              TextField(
                                controller: nikController,
                                enabled: !isLoading,
                                keyboardType: TextInputType.number,
                                maxLength: 16,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF1E293B),
                                ),
                                onChanged: (_) {
                                  if (nikError) {
                                    setState(() => nikError = false);
                                  }
                                },
                                decoration: inputDecoration(
                                  icon: Icons.badge_outlined,
                                  hint: 'Masukkan NIK (16 Digit)',
                                  isError: nikError,
                                ).copyWith(counterText: ''),
                              ),
                              TextField(
                                controller: emailController,
                                enabled: !isLoading,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF1E293B),
                                ),
                                onChanged: (_) {
                                  if (emailError) {
                                    setState(() => emailError = false);
                                  }
                                },
                                decoration: inputDecoration(
                                  icon: Icons.email_outlined,
                                  hint: 'Masukkan Email Anda',
                                  isError: emailError,
                                ),
                              ),
                              TextField(
                                controller: passwordController,
                                enabled: !isLoading,
                                obscureText: !passwordVisible,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: Color(0xFF1E293B),
                                ),
                                onChanged: (_) {
                                  if (passwordError) {
                                    setState(() => passwordError = false);
                                  }
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
                                      size: 18,
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
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Text(
                                    'Verifikasi Captcha',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                            BorderRadius.circular(18),
                                            border: Border.all(
                                              color: const Color(0xFFCBD5E1),
                                              width: 1.2,
                                            ),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                            BorderRadius.circular(17),
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
                                      SizedBox(
                                        width: 50,
                                        height: 50,
                                        child: ElevatedButton(
                                          onPressed:
                                          isLoading ? null : refreshCaptcha,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                            const Color(0xFFEEF2FF),
                                            foregroundColor:
                                            const Color(0xFF6679F4),
                                            elevation: 0,
                                            padding: EdgeInsets.zero,
                                            shape: const StadiumBorder(),
                                          ),
                                          child: const Icon(
                                            Icons.refresh_rounded,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextField(
                                    controller: captchaController,
                                    enabled: !isLoading,
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      color: Color(0xFF1E293B),
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1.2,
                                    ),
                                    textCapitalization:
                                    TextCapitalization.characters,
                                    onChanged: (_) {
                                      if (captchaError) {
                                        setState(() => captchaError = false);
                                      }
                                    },
                                    decoration: inputDecoration(
                                      icon: Icons.shield_outlined,
                                      hint: 'Masukkan Kode Captcha',
                                      isError: captchaError,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF6679F4),
                                      Color(0xFF5366E6),
                                    ],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6679F4)
                                          .withValues(alpha: 0.32),
                                      blurRadius: 14,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: isLoading ? null : daftar,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: const StadiumBorder(),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2.4,
                                    ),
                                  )
                                      : const Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Daftar',
                                        style: TextStyle(
                                          fontSize: 14.5,
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Sudah Punya Akun? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF475569),
                            ),
                          ),
                          TextButton(
                            onPressed: isLoading
                                ? null
                                : () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const LoginPage(),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: const StadiumBorder(),
                            ),
                            child: const Text(
                              'Masuk',
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6679F4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
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
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          setState(() {
                            showErrorBanner = false;
                          });
                        },
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 18,
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
