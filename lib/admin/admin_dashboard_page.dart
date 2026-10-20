import 'package:flutter/material.dart';

import 'admin_beranda_page.dart';
import 'admin_logout.dart';
import 'admin_menu_pages.dart';
import 'admin_profil_page.dart';

/// Cangkang (shell) admin: satu Scaffold + satu navbar bawah.
/// Setiap tab hanya berisi konten (tanpa Scaffold sendiri).
class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _index = 0;

  static const List<String> _judul = [
    'Dashboard Admin Diora',
    'Data Pengguna',
    'Artikel',
    'Skrining',
    'Laporan Statistik',
    'Profil Admin',
  ];

  final List<Widget> _halaman = const [
    AdminBerandaPage(),
    AdminPenggunaPage(),
    AdminPlaceholderPage(
      icon: Icons.menu_book_rounded,
      nama: 'Artikel',
    ),
    AdminPlaceholderPage(
      icon: Icons.medical_services_rounded,
      nama: 'Skrining',
    ),
    AdminPlaceholderPage(
      icon: Icons.insert_chart_outlined_rounded,
      nama: 'Laporan Statistik',
    ),
    AdminProfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_index != 0) {
          setState(() => _index = 0); // back -> kembali ke Beranda
        } else {
          logoutAdmin(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          backgroundColor: const Color(0xFF5B71F5),
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          title: Text(
            _judul[_index],
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            if (_index != 5)
              IconButton(
                tooltip: 'Logout Admin',
                icon: const Icon(Icons.logout),
                onPressed: () => logoutAdmin(context),
              ),
          ],
        ),
        body: IndexedStack(index: _index, children: _halaman),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _index,
          onTap: (i) => setState(() => _index = i),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF5B71F5),
          unselectedItemColor: const Color(0xFF9AA5D8),
          selectedFontSize: 11,
          unselectedFontSize: 11,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home_rounded),
                label: 'Beranda'),
            BottomNavigationBarItem(
                icon: Icon(Icons.groups_outlined),
                activeIcon: Icon(Icons.groups_rounded),
                label: 'Pengguna'),
            BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_outlined),
                activeIcon: Icon(Icons.menu_book_rounded),
                label: 'Artikel'),
            BottomNavigationBarItem(
                icon: Icon(Icons.medical_services_outlined),
                activeIcon: Icon(Icons.medical_services_rounded),
                label: 'Skrining'),
            BottomNavigationBarItem(
                icon: Icon(Icons.insert_chart_outlined_rounded),
                activeIcon: Icon(Icons.insert_chart_rounded),
                label: 'Laporan'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profil'),
          ],
        ),
      ),
    );
  }
}