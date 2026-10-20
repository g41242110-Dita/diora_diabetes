import 'package:flutter/material.dart';

import 'admin_beranda_page.dart';
import 'admin_skrining_page.dart';
import 'admin_laporan_skrining_page.dart';
import 'admin_profil_page.dart';
import 'admin_artikel_page.dart'; // Import halaman artikel
import 'admin_curved_nav_bar.dart';

class AdminMenuPages extends StatefulWidget {
  const AdminMenuPages({super.key});

  @override
  State<AdminMenuPages> createState() => _AdminMenuPagesState();
}

class _AdminMenuPagesState extends State<AdminMenuPages> {
  int _selectedIndex = 0;

  // 6 Halaman Admin Terhubung dengan Lengkap
  late final List<Widget> _pages = [
    const AdminBerandaPage(),            // Index 0: Beranda
    const _DummyPage(title: 'Pengguna'), // Index 1: Pengguna
    const AdminSkriningPage(),           // Index 2: Skrining
    const AdminLaporanSkriningPage(),    // Index 3: Laporan
    const AdminArtikelPage(),            // Index 4: Artikel (Sudah terhubung ke UI asli)
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