import 'package:flutter/material.dart';

// Import seluruh halaman admin
import 'admin_beranda_page.dart';
import 'admin_pengguna_page.dart';
import 'admin_skrining_page.dart';
import 'admin_laporan_skrining_page.dart';
import 'admin_profil_page.dart';
import 'admin_curved_nav_bar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Presisi 6 halaman sesuai urutan 6 ikon di AdminCurvedNavBar
    final List<Widget> pages = [
      const AdminBerandaPage(),            // Index 0: Beranda
      const AdminPenggunaPage(),           // Index 1: Pengguna
      const AdminSkriningPage(),           // Index 2: Skrining
      const AdminLaporanSkriningPage(),    // Index 3: Laporan
      const Center(child: Text('Artikel')),  // Index 4: Artikel
      const AdminProfilPage(),             // Index 5: Profil
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
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