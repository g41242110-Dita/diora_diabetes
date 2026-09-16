import 'package:flutter/material.dart';
import 'beranda_page.dart';
import 'login_page.dart'; // 1. Tambahkan import ke Halaman Login

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

  // Status error per kolom
  bool showErrorBanner = false;
  String errorMessage = 'Pastikan semua kolom telah diisi dengan benar.';
  bool namaError = false;
  bool emailError = false;
  bool passwordError = false;
  bool konfirmasiError = false;
  bool captchaError = false;

  String captcha = '7KG2B';

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
    setState(() {
      captcha = '7KG2B';
      captchaController.clear();
      captchaError = false;
    });
  }

  // Fungsi pembantu untuk cek format Email
  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  void daftar() {
    setState(() {
      // Cek kolom kosong
      namaError = namaController.text.trim().isEmpty;
      emailError = emailController.text.trim().isEmpty;
      passwordError = passwordController.text.isEmpty;
      konfirmasiError = konfirmasiController.text.isEmpty;
      captchaError = captchaController.text.trim().isEmpty;
    });

    // 1. Cek jika ada kolom yang kosong
    if (namaError || emailError || passwordError || konfirmasiError || captchaError) {
      setState(() {
        showErrorBanner = true;
        errorMessage = 'Pastikan semua kolom telah diisi dengan benar.';
      });
      return;
    }

    // 2. Validasi Format Email
    if (!_isEmailValid(emailController.text.trim())) {
      setState(() {
        showErrorBanner = true;
        emailError = true;
        errorMessage = 'Format email tidak valid.';
      });
      return;
    }

    // 3. Validasi Panjang Minimal Password
    if (passwordController.text.length < 6) {
      setState(() {
        showErrorBanner = true;
        passwordError = true;
        errorMessage = 'Password minimal terdiri dari 6 karakter.';
      });
      return;
    }

    // 4. Cek jika password dan konfirmasi tidak sama
    if (passwordController.text != konfirmasiController.text) {
      setState(() {
        showErrorBanner = true;
        passwordError = true;
        konfirmasiError = true;
        errorMessage = 'Konfirmasi password tidak sesuai.';
      });
      return;
    }

    // 5. Cek Captcha
    if (captchaController.text.toUpperCase() != captcha) {
      setState(() {
        showErrorBanner = true;
        captchaError = true;
        errorMessage = 'Kode Captcha tidak sesuai.';
      });
      return;
    }

    // Berhasil -> Pindah ke BerandaPage
    setState(() {
      showErrorBanner = false;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => BerandaPage(
          namaUser: namaController.text.trim(),
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
            // CONTENT UTAMA
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

                  // NAMA LENGKAP
                  TextField(
                    controller: namaController,
                    onChanged: (_) {
                      if (namaError) setState(() => namaError = false);
                    },
                    decoration: inputDecoration(
                      icon: Icons.person_outline,
                      hint: 'Aurelia Prisilla',
                      isError: namaError,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // EMAIL
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (_) {
                      if (emailError) setState(() => emailError = false);
                    },
                    decoration: inputDecoration(
                      icon: Icons.email_outlined,
                      hint: 'Email',
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
                      hint: 'Password',
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

                  // KONFIRMASI PASSWORD
                  TextField(
                    controller: konfirmasiController,
                    obscureText: !konfirmasiVisible,
                    onChanged: (_) {
                      if (konfirmasiError) setState(() => konfirmasiError = false);
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
                      hint: '7KG2B',
                      isError: captchaError,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // BUTTON DAFTAR
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: daftar,
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

                  const SizedBox(height: 16),

                  const Divider(color: Color(0xFFE0E0E0), thickness: 1),

                  const SizedBox(height: 12),

                  // LINK KE MASUK (LOGIN)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Sudah Punya Akun? ',
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Pindah ke Halaman Login tanpa menumpuk Stack
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
                            color: Color(0xFF558B82), // Warna disesuaikan
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // BANNER POP-UP ERROR (OVERLAY MELAYANG)
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
                        color: Colors.black.withOpacity(0.05),
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