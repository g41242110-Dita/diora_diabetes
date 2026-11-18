import 'package:flutter/material.dart';

import 'admin_beranda_page.dart';
import 'admin_pengguna_page.dart';
import 'admin_skrining_page.dart';
import 'admin_laporan_skrining_page.dart';
import 'admin_profil_page.dart';
import 'admin_artikel_page.dart';
import 'admin_curved_nav_bar.dart';

class AdminMenuPages extends StatefulWidget {
  const AdminMenuPages({super.key});

  @override
  State<AdminMenuPages> createState() => _AdminMenuPagesState();
}

class _AdminMenuPagesState extends State<AdminMenuPages> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      AdminBerandaPage(
        isActive: _selectedIndex == 0,
        onNavigateToPengguna: () {
          setState(() {
            _selectedIndex = 1;
          });
        },
        onNavigateToSkrining: () {
          setState(() {
            _selectedIndex = 2;
          });
        },
        onNavigateToArtikel: () {
          setState(() {
            _selectedIndex = 4;
          });
        },
      ),                                // Index 0: Beranda
      AdminPenggunaPage(
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),                                // Index 1: Pengguna (Aktif & Real-time)
      AdminSkriningPage(
        onBack: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),                                // Index 2: Skrining
      const AdminLaporanSkriningPage(), // Index 3: Laporan
      AdminArtikelPage(
        onBackToBeranda: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),                                // Index 4: Artikel
      AdminProfilPage(
        onBackToHome: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),                                // Index 5: Profil
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