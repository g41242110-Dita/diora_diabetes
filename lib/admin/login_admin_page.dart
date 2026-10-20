import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth_router.dart';
import 'admin_dashboard_page.dart';

class LoginAdminPage extends StatefulWidget {
  const LoginAdminPage({super.key});

  @override
  State<LoginAdminPage> createState() => _LoginAdminPageState();
}

class _LoginAdminPageState extends State<LoginAdminPage> {
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

  void _showLoginError(String message) {
    if (!mounted) return;

    setState(() {
      _showError = true;
      _errorMessage = message;
    });
  }

  Future<void> _handleLoginAdmin() async {
    if (_isLoading) return;

    final String email = _emailController.text.trim();
    final String password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showLoginError('Email dan kata sandi wajib diisi.');
      return;
    }

    setState(() {
      _isLoading = true;
      _showError = false;
      _errorMessage = '';
    });

    try {
      final UserCredential credential =
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User? user = credential.user;
      if (user == null) {
        await FirebaseAuth.instance.signOut();
        _showLoginError('Data akun tidak ditemukan.');
        return;
      }

      final data = await AuthRouter.ambilDataUser(user);

      if (data == null) {
        await FirebaseAuth.instance.signOut();
        _showLoginError(
          'Data akun tidak ditemukan di Firestore (koleksi users). '
              'Pastikan ID dokumen sama dengan UID atau field email sama.',
        );
        return;
      }

      final String role = AuthRouter.ambilRole(data);
      debugPrint('Login admin -> uid: ${user.uid}, role: $role');

      if (role != 'admin') {
        await FirebaseAuth.instance.signOut();
        _showLoginError(
          'Akun ini bukan akun Admin. Silakan gunakan akun admin yang benar.',
        );
        return;
      }

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const AdminDashboardPage()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'invalid-email':
          message = 'Format email tidak valid.';
          break;
        case 'user-not-found':
        case 'invalid-credential':
          message = 'Email atau kata sandi salah.';
          break;
        case 'wrong-password':
          message = 'Kata sandi salah.';
          break;
        case 'too-many-requests':
          message = 'Terlalu banyak percobaan. Coba lagi nanti.';
          break;
        case 'network-request-failed':
          message = 'Koneksi internet bermasalah.';
          break;
        default:
          message = e.message ?? 'Login gagal. Silakan coba lagi.';
      }
      _showLoginError(message);
    } catch (e) {
      debugPrint('Login admin error: $e');
      _showLoginError(
        'Gagal memeriksa akun. Periksa koneksi dan aturan akses Firestore.',
      );
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
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
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.grey,
          ),
          onPressed: _isLoading
              ? null
              : () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'LOG MASUK ADMIN',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              if (_showError) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFFCDD2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 24,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () {
                          setState(() => _showError = false);
                        },
                        icon: const Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              const Icon(
                Icons.admin_panel_settings_rounded,
                size: 90,
                color: Color(0xFF5B71F5),
              ),
              const SizedBox(height: 20),

              const Text(
                'Masuk Admin',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),

              const Text(
                'Log masuk ke akun Admin Diora',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                enabled: !_isLoading,
                decoration: InputDecoration(
                  labelText: 'Email Admin',
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFF5B71F5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                enabled: !_isLoading,
                onSubmitted: (_) => _handleLoginAdmin(),
                decoration: InputDecoration(
                  labelText: 'Kata Sandi',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: Colors.grey,
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.grey,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.black26),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(
                      color: Color(0xFF5B71F5),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleLoginAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B71F5),
                    disabledBackgroundColor:
                    const Color(0xFF5B71F5).withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'Log Masuk',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}