import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth_router.dart';

// Halaman utama dokter (BUKAN beranda pengguna / admin)
import 'dokter_beranda_page.dart';

class LoginDokterPage extends StatefulWidget {
  const LoginDokterPage({super.key});

  @override
  State<LoginDokterPage> createState() => _LoginDokterPageState();
}

class _LoginDokterPageState extends State<LoginDokterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _showError = false;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String _pesanError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet.';
      default:
        return e.message ?? 'Login gagal. Periksa email & password.';
    }
  }

  Future<void> _handleLoginDokter() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _showError = true;
        _errorMessage = 'Email dan Password tidak boleh kosong.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _showError = false;
    });

    try {
      // 1. Login ke Firebase Auth
      final UserCredential cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      final String uid = cred.user!.uid;

      // 2. Cek dokumen user di Firestore (role harus "dokter")
      final data = await AuthRouter.ambilDataUser(cred.user!);
      final role = data == null ? '' : AuthRouter.ambilRole(data);
      debugPrint('Login dokter -> uid: $uid, role: $role');

      if (role == 'dokter') {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DokterBerandaPage()),
              (route) => false,
        );
        return;
      }

      // Bukan dokter / dokumen tidak ada -> tampilkan diagnosa, lalu keluarkan
      final User userGagal = cred.user!;
      final String info = await AuthRouter.diagnosa(userGagal);
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      setState(() {
        _showError = true;
        _errorMessage = data == null
            ? 'Data dokter tidak ditemukan di Firestore.\n$info'
            : 'Akun ini bukan akun Dokter!\n$info';
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _showError = true;
        _errorMessage = _pesanError(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _showError = true;
        _errorMessage = 'Terjadi kesalahan sistem: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'LOGIN DOKTER',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 10),
              if (_showError) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFFCDD2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.cancel, color: Colors.red, size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _showError = false),
                        child: const Icon(Icons.close,
                            color: Colors.grey, size: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
              const Icon(
                Icons.medical_services_rounded,
                size: 90,
                color: Color(0xFF5B71F5),
              ),
              const SizedBox(height: 20),
              const Text(
                'Masuk Dokter',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Login ke akun Dokter Diora',
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email Dokter',
                  prefixIcon:
                  const Icon(Icons.email_outlined, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                onSubmitted: (_) => _isLoading ? null : _handleLoginDokter(),
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon:
                  const Icon(Icons.lock_outline, color: Colors.grey),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLoginDokter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B71F5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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