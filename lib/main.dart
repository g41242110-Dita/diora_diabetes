import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'onboarding_page.dart';
import 'beranda_page.dart';
// Menggunakan package path resmi agar kelas AdminDashboardPage terdeteksi
import 'package:diora_diabetes/admin/admin_dashboard_page.dart';

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
    // Tampilkan Splash Screen selama 3 detik
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Cek status sesi pengguna dari Firebase Auth
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String namaUser = user.email?.split('@').first ?? 'Pengguna';
      String roleUser = 'user'; // Default role jika tidak ditemukan

      try {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;

          if (data.containsKey('nama')) {
            namaUser = data['nama'];
          }

          // Ambil role dari Firestore
          if (data.containsKey('role')) {
            roleUser = data['role'];
          }
        }
      } catch (_) {
        // Jika gagal ambil Firestore, tetap gunakan default
      }

      if (!mounted) return;

      // NAVIGASI BERDASARKAN ROLE
      if (roleUser.toLowerCase() == 'admin') {
        // Jika Admin -> Masuk ke Dashboard Admin
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboardPage(),
          ),
        );
      } else {
        // Jika Pengguna Biasa -> Masuk ke Beranda
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BerandaPage(namaUser: namaUser),
          ),
        );
      }
    } else {
      // Belum Login -> Ke Onboarding Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const OnboardingPage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox.expand(
        child: Image.asset(
          'assets/HAL UTAMA.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}