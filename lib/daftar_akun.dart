import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'beranda_page.dart';
import 'login_page.dart';

class DaftarAkunPage extends StatefulWidget {
  const DaftarAkunPage({super.key});

  @override
  State<DaftarAkunPage> createState() => _DaftarAkunPageState();
}

class _DaftarAkunPageState extends State<DaftarAkunPage> {
  final namaController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final konfirmasiController = TextEditingController();
  final captchaController = TextEditingController();

  bool passwordVisible = false;
  bool konfirmasiVisible = false;
  bool isLoading = false;

  bool showErrorBanner = false;
  String errorMessage = 'Pastikan semua kolom telah diisi dengan benar.';

  bool namaError = false;
  bool emailError = false;
  bool passwordError = false;
  bool konfirmasiError = false;
  bool captchaError = false;

  String captcha = '';

  @override
  void initState() {
    super.initState();
    refreshCaptcha();
  }

  @override
  void dispose() {
    namaController.dispose();
    emailController.dispose();
    passwordController.dispose();
    konfirmasiController.dispose();
    captchaController.dispose();
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

  Future<void> daftar() async {
    setState(() {
      showErrorBanner = false;

      namaError = namaController.text.trim().isEmpty;
      emailError = emailController.text.trim().isEmpty;
      passwordError = passwordController.text.isEmpty;
      konfirmasiError = konfirmasiController.text.isEmpty;
      captchaError = captchaController.text.trim().isEmpty;
    });

    if (namaError ||
        emailError ||
        passwordError ||
        konfirmasiError ||
        captchaError) {
      setState(() {
        showErrorBanner = true;
        errorMessage = 'Pastikan semua kolom telah diisi dengan benar.';
      });
      return;
    }

    final nama = namaController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final konfirmasiPassword = konfirmasiController.text;
    final captchaInput = captchaController.text.trim().toUpperCase();

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

    if (password != konfirmasiPassword) {
      setState(() {
        showErrorBanner = true;
        passwordError = true;
        konfirmasiError = true;
        errorMessage = 'Konfirmasi password tidak sesuai.';
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
        'email': email,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BerandaPage(
            namaUser: nama,
          ),
        ),
      );
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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(24),
        borderSide: BorderSide(
          color: isError ? Colors.red : Colors.grey.shade400,
          width: 1.0,
        ),
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
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),

                  Center(
                    child: Image.asset(
                      'assets/logo.png',
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Daftar Akun',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Buat Akun Baru Untuk Mengakses Layanan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller: namaController,
                    enabled: !isLoading,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
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

                  const SizedBox(height: 12),

                  TextField(
                    controller: emailController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
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

                  const SizedBox(height: 12),

                  TextField(
                    controller: passwordController,
                    enabled: !isLoading,
                    obscureText: !passwordVisible,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    onChanged: (_) {
                      if (passwordError) {
                        setState(() => passwordError = false);
                      }
                    },
                    decoration: inputDecoration(
                      icon: Icons.lock_outline,
                      hint: 'Masukkan Password',
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

                  const SizedBox(height: 12),

                  TextField(
                    controller: konfirmasiController,
                    enabled: !isLoading,
                    obscureText: !konfirmasiVisible,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    onChanged: (_) {
                      if (konfirmasiError) {
                        setState(() => konfirmasiError = false);
                      }
                    },
                    decoration: inputDecoration(
                      icon: Icons.lock_outline,
                      hint: 'Konfirmasi Password',
                      isError: konfirmasiError,
                      suffixIcon: IconButton(
                        icon: Icon(
                          konfirmasiVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          size: 20,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            konfirmasiVisible = !konfirmasiVisible;
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

                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 45,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F3F5),
                            border: Border.all(
                              color: Colors.grey.shade400,
                            ),
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
                          border: Border.all(
                            color: Colors.grey.shade400,
                          ),
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.refresh,
                            size: 22,
                          ),
                          onPressed: isLoading ? null : refreshCaptcha,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: captchaController,
                    enabled: !isLoading,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    textCapitalization: TextCapitalization.characters,
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

                  const SizedBox(height: 24),

                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : daftar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6679F4),
                        foregroundColor: Colors.white,
                        elevation: 0,
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
                            'Daftar',
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

                  const SizedBox(height: 20),

                  const Divider(color: Color(0xFFE0E0E0), thickness: 1),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah Punya Akun? ',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginPage(),
                            ),
                          );
                        },
                        child: const Text(
                          'Masuk',
                          style: TextStyle(
                            fontSize: 13,
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

            if (showErrorBanner)
              Positioned(
                top: 10,
                left: 20,
                right: 20,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDE8E8),
                    border: Border.all(color: const Color(0xFFF87171)),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
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