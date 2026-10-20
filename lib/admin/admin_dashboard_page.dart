import 'package:flutter/material.dart';

// Import semua halaman admin
import 'admin_beranda_page.dart';
import 'admin_skrining_page.dart';         // Halaman Skrining
import 'admin_laporan_skrining_page.dart'; // Halaman Laporan
import 'admin_artikel_page.dart';          // Halaman Artikel
import 'admin_profil_page.dart';           // Halaman Profil
import 'admin_curved_nav_bar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  // Daftar 6 halaman admin (sesuai dengan urutan ikon di navbar)
  final List<Widget> _pages = const [
    AdminBerandaPage(),            // Index 0: Beranda
    Center(child: Text('Pengguna')), // Index 1: Pengguna
    AdminSkriningPage(),           // Index 2: Skrining
    AdminLaporanSkriningPage(),    // Index 3: Laporan
    AdminArtikelPage(),            // Index 4: ARTIKEL (Menggunakan AdminArtikelPage)
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