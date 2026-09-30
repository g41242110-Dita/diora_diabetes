import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'pengguna/firebase_options.dart';
import 'pengguna/onboarding_page.dart';
import 'pengguna/beranda_page.dart';
import 'admin/admin_dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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
  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndNavigate();
  }

  Future<void> _checkAuthenticationAndNavigate() async {
    // Tampilkan Splash Screen selama 2 detik
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String namaUser = user.email?.split('@').first ?? 'Pengguna';
      String roleUser = 'pengguna'; // Role default jika tidak ditemukan

      try {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;

          if (data.containsKey('nama') && data['nama'] != null) {
            namaUser = data['nama'].toString();
          }

          if (data.containsKey('role') && data['role'] != null) {
            roleUser = data['role'].toString().trim().toLowerCase();
          }
        } else {
          debugPrint('⚠️ Dokumen pengguna tidak ditemukan di Firestore untuk UID: ${user.uid}');
        }
      } catch (e) {
        debugPrint('❌ Gagal mengambil data Firestore: $e');
      }

      // CEK DEBUGGING DI TERMINAL/CONSOLE
      debugPrint('----------------------------------------------------');
      debugPrint('👤 LOGGED IN UID : ${user.uid}');
      debugPrint('📧 EMAIL         : ${user.email}');
      debugPrint('🏷️ ROLE DETEKSI  : "$roleUser"');
      debugPrint('----------------------------------------------------');

      if (!mounted) return;

      // NAVIGASI BERDASARKAN ROLE
      if (roleUser == 'admin') {
        debugPrint('➡️ Navigasi ke AdminDashboardPage');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboardPage(),
          ),
        );
      } else {
        debugPrint('➡️ Navigasi ke BerandaPage (Pengguna)');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BerandaPage(namaUser: namaUser),
          ),
        );
      }
    } else {
      debugPrint('🔒 Belum ada sesi login -> Ke OnboardingPage');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingPage(),
        ),
      );
    }
  }

  Future<bool> _showExitConfirmationDialog(BuildContext dialogContext) async {
    final result = await showDialog<bool>(
      context: dialogContext,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Keluar Aplikasi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari aplikasi Diora?',
        ),
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _showExitConfirmationDialog(context);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: SizedBox.expand(
          child: Image.asset(
            'assets/HAL UTAMA.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF5B71F5),
              child: const Center(
                child: Icon(
                  Icons.medical_services_rounded,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}