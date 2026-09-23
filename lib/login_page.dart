import 'dart:math';
import 'package:flutter/material.dart';
import 'beranda_page.dart';
import 'daftar_akun.dart';
import 'forgot_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final captchaController = TextEditingController();

  bool passwordVisible = false;

  // Status Notifikasi & Error per Kolom
  bool showErrorBanner = false;
  String errorMessage = 'Pastikan semua kolom telah diisi dengan benar.';
  bool emailError = false;
  bool passwordError = false;
  bool captchaError = false;

  String captcha = '';

  @override
  void initState() {
    super.initState();
    refreshCaptcha(); // Bikin Captcha acak saat halaman pertama dibuka
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    captchaController.dispose();
    super.dispose();
  }

  // Fungsi acak Captcha dinamis
  void refreshCaptcha() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    Random random = Random();
    String newCaptcha = String.fromCharCodes(
      Iterable.generate(5, (_) => chars.codeUnitAt(random.nextInt(chars.length))),
    );

    setState(() {
      captcha = newCaptcha;
      captchaController.clear();
      captchaError = false;
    });
  }

  void login() {
    setState(() {
      // Cek field kosong
      emailError = emailController.text.trim().isEmpty;
      passwordError = passwordController.text.isEmpty;
      captchaError = captchaController.text.trim().isEmpty;
    });

    // 1. Validasi jika ada kolom kosong
    if (emailError || passwordError || captchaError) {
      setState(() {
        showErrorBanner = true;
        errorMessage = 'Pastikan semua kolom telah diisi dengan benar.';
      });
      return;
    }

    // 2. Validasi Captcha
    if (captchaController.text.trim().toUpperCase() != captcha) {
      setState(() {
        showErrorBanner = true;
        captchaError = true;
        errorMessage = 'Kode Captcha tidak sesuai.';
      });
      refreshCaptcha(); // Re-randomize captcha jika salah
      return;
    }

    // Jika Berhasil -> Tutup banner error & pindah ke Beranda
    setState(() {
      showErrorBanner = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BerandaPage(
          namaUser: emailController.text.split('@').first,
        ),
      ),
    );
  }

  InputDecoration inputDecoration({
    required IconData icon,
    String? hint,
    Widget? suffixIcon,
    bool isError = false,
  }) {
    return InputDecoration(
      prefixIcon: Icon(
        icon,
        size: 20,
        color: isError ? Colors.red : Colors.grey.shade600,
      ),
      suffixIcon: suffixIcon,
      hintText: hint,
      hintStyle: const TextStyle(
        fontSize: 13,
        color: Colors.grey,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(
          color: isError ? Colors.red : Colors.grey.shade400,
          width: isError ? 1.5 : 1.0,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(
          color: isError ? Colors.red : const Color(0xFF6679F4),
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // KONTEN UTAMA Halaman Login
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  // LOGO
                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // JUDUL & SUBJUDUL
                  const Text(
                    'Masuk',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Masuk Ke Akun Anda Untuk Melanjutkan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // EMAIL / USERNAME
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      if (emailError) setState(() => emailError = false);
                    },
                    decoration: inputDecoration(
                      icon: Icons.email_outlined,
                      hint: 'Masukkan Email Anda',
                      isError: emailError,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // PASSWORD
                  TextField(
                    controller: passwordController,
                    obscureText: !passwordVisible,
                    onChanged: (_) {
                      if (passwordError) setState(() => passwordError = false);
                    },
                    decoration: inputDecoration(
                      icon: Icons.lock_outline,
                      hint: 'Masukkan Kata Sandi',
                      isError: passwordError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            passwordVisible = !passwordVisible;
                          });
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const Text(
                    'Verifikasi Captcha',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // CAPTCHA DISPLAY & REFRESH
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            captcha,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 6,
                              fontStyle: FontStyle.italic,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 55,
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade400),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.refresh, size: 22),
                          onPressed: refreshCaptcha,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // INPUT CAPTCHA
                  TextField(
                    controller: captchaController,
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

                  const SizedBox(height: 24),

                  // BUTTON MASUK
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6679F4),
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
                            'Masuk',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 18),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // LUPA KATA SANDI
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
                      child: const Text(
                        'Lupa Kata Sandi?',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Divider(color: Color(0xFFE0E0E0), thickness: 1),

                  const SizedBox(height: 12),

                  // LINK KE DAFTAR AKUN
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Belum Punya Akun? ',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
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
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF558B82),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // BANNER POP-UP ERROR (MELAYANG DI ATAS KONTEN)
            if (showErrorBanner)
              Positioned(
                top: 10,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    border: Border.all(color: const Color(0xFFF87171)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05), // Menggunakan withValues
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gagal Melanjutkan!',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              errorMessage,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showErrorBanner = false;
                          });
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(bottom: 14),
                          child: Text(
                            'x',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}