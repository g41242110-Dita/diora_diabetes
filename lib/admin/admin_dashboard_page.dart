import 'package:flutter/material.dart';

// Import seluruh halaman admin
import 'admin_beranda_page.dart';
import 'admin_pengguna_page.dart';
import 'admin_skrining_page.dart';
import 'admin_laporan_skrining_page.dart';
import 'admin_artikel_page.dart';
import 'admin_profil_page.dart';
import 'admin_curved_nav_bar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  // Daftar 6 halaman admin sesuai urutan di navbar
  final List<Widget> _pages = const [
    AdminBerandaPage(),            // Index 0: Beranda
    AdminPenggunaPage(),           // Index 1: Pengguna
    AdminSkriningPage(),           // Index 2: Skrining
    AdminLaporanSkriningPage(),    // Index 3: Laporan
    AdminArtikelPage(),            // Index 4: Artikel
    AdminProfilPage(),             // Index 5: Profil Admin
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: AdminCurvedNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}