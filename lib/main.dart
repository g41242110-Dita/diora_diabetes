import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth_router.dart';
import 'pengguna/firebase_options.dart';
import 'pengguna/onboarding_page.dart';

/// true  = setiap aplikasi dibuka SELALU harus login dulu
/// false = sesi login terakhir dipertahankan (langsung masuk sesuai role)
const bool wajibLoginSetiapBukaApp = false; // <-- Diubah jadi false!

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Buang sesi lama sebelum UI tampil, jika wajibLoginSetiapBukaApp bernilai true
  if (wajibLoginSetiapBukaApp) {
    await FirebaseAuth.instance.signOut();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HalamanUtama(),
    );
  }
}

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  bool _gagalMemeriksa = false;

  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndNavigate();
  }

  Future<void> _checkAuthenticationAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    // Jika wajibLoginSetiapBukaApp diaktifkan
    if (wajibLoginSetiapBukaApp && FirebaseAuth.instance.currentUser != null) {
      await FirebaseAuth.instance.signOut();
    }

    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _navigateTo(const OnboardingPage());
      return;
    }

    try {
      final halaman = await AuthRouter.halamanUntuk(user);
      if (!mounted) return;

      if (halaman == null) {
        await FirebaseAuth.instance.signOut();
        _navigateTo(const OnboardingPage());
        return;
      }

      _navigateTo(halaman);
    } catch (e) {
      debugPrint('Gagal memeriksa akun dari Firestore: $e');
      if (!mounted) return;
      setState(() => _gagalMemeriksa = true);
    }
  }

  void _navigateTo(Widget halaman) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => halaman),
    );
  }

  Future<bool> _showExitConfirmationDialog(BuildContext dialogContext) async {
    final result = await showDialog<bool>(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Keluar Aplikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi Diora?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5B71F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_gagalMemeriksa) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 64, color: Color(0xFF5B71F5)),
                const SizedBox(height: 16),
                const Text(
                  'Tidak dapat memeriksa akun.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Periksa koneksi internet dan akses Firestore.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _gagalMemeriksa = false);
                    _checkAuthenticationAndNavigate();
                  },
                  child: const Text('Coba Lagi'),
                ),
                TextButton(
                  onPressed: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!mounted) return;
                    _navigateTo(const OnboardingPage());
                  },
                  child: const Text('Kembali ke Login'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldExit = await _showExitConfirmationDialog(context);
        if (shouldExit) SystemNavigator.pop();
      },
      child: Scaffold(
        body: SizedBox.expand(
          child: Image.asset(
            'assets/HAL UTAMA.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF5B71F5),
                child: const Center(
                  child: Icon(Icons.medical_services_rounded,
                      size: 100, color: Colors.white),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}