import 'package:flutter/material.dart';

// Import file dari folder lib/admin/
import 'admin_beranda_page.dart';
import 'admin_curved_nav_bar.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const AdminBerandaPage(),                      // Index 0: Beranda
      const Center(child: Text('Halaman Pengguna')),    // Index 1: Pengguna
      const Center(child: Text('Halaman Skrining')),    // Index 2: Skrining
      const Center(child: Text('Halaman Laporan')),     // Index 3: Laporan
      const Center(child: Text('Halaman Artikel')),     // Index 4: Artikel
      const Center(child: Text('Halaman Profil')),      // Index 5: Profil
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),
      bottomNavigationBar: AdminCurvedNavBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}