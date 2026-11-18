import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      AdminBerandaPage(
        isActive: _selectedIndex == 0,
        onNavigateToPengguna: () => setState(() => _selectedIndex = 1),
        onNavigateToSkrining: () => setState(() => _selectedIndex = 2),
        onNavigateToArtikel: () => setState(() => _selectedIndex = 3),
      ),
      const AdminPenggunaPage(),
      const AdminSkriningPage(),
      AdminArtikelPage(
        onBackToBeranda: () => setState(() => _selectedIndex = 0),
      ),
      AdminProfilPage(
        onBackToHome: () => setState(() => _selectedIndex = 0),
      ),
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