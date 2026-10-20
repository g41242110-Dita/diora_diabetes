import 'package:flutter/material.dart';

import 'admin_beranda_page.dart';
import 'admin_skrining_page.dart';
import 'admin_laporan_skrining_page.dart';
import 'admin_profil_page.dart';
import 'admin_curved_nav_bar.dart';

class AdminMenuPages extends StatefulWidget {
  const AdminMenuPages({super.key});

  @override
  State<AdminMenuPages> createState() => _AdminMenuPagesState();
}

class _AdminMenuPagesState extends State<AdminMenuPages> {
  int _selectedIndex = 0;

  // Tepat 6 Halaman Sesuai Urutan 6 Menu di AdminCurvedNavBar
  final List<Widget> _pages = [
    const AdminBerandaPage(),         // Index 0: Beranda
    const _DummyPage(title: 'Pengguna'), // Index 1: Pengguna
    const AdminSkriningPage(),        // Index 2: Skrining (Tampilan Skrining Kamu)
    const AdminLaporanSkriningPage(), // Index 3: Laporan
    const _DummyPage(title: 'Artikel'),  // Index 4: Artikel
    const AdminProfilPage(),          // Index 5: Profil
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

class _DummyPage extends StatelessWidget {
  final String title;
  const _DummyPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Halaman $title',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }
}