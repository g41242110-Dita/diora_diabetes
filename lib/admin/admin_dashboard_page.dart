import 'package:flutter/material.dart';

// Import halaman admin kamu
import 'admin_beranda_page.dart';
import 'admin_skrining_page.dart';        // Halaman Skrining hasil buatanmu
import 'admin_laporan_skrining_page.dart';// Halaman Laporan hasil buatanmu
import 'admin_profil_page.dart';
import 'admin_curved_nav_bar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  // Urutan 6 Halaman Admin presisi dengan 6 ikon di navbar bawah
  final List<Widget> _pages = [
    const AdminBerandaPage(),            // Index 0: Beranda
    const Center(child: Text('Pengguna')), // Index 1: Pengguna
    const AdminSkriningPage(),           // Index 2: SKRINING (Nampilin kodingan skrining kamu!)
    const AdminLaporanSkriningPage(),    // Index 3: Laporan
    const Center(child: Text('Artikel')),  // Index 4: Artikel
    const AdminProfilPage(),             // Index 5: Profil
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