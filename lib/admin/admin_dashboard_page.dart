import 'package:flutter/material.dart';

// Import halaman admin
import 'admin_beranda_page.dart';
import 'admin_pengguna_page.dart';
import 'admin_skrining_page.dart';
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

  // Daftar 5 halaman admin sesuai urutan di navbar
  final List<Widget> _pages = const [
    AdminBerandaPage(),   // Index 0: Beranda
    AdminPenggunaPage(),  // Index 1: Pengguna
    AdminSkriningPage(),  // Index 2: Skrining
    AdminArtikelPage(),   // Index 3: Artikel
    AdminProfilPage(),    // Index 4: Profil Admin
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