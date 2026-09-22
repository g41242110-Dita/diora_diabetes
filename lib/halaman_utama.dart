import 'package:flutter/material.dart';
import 'beranda_page.dart';
import 'profile_screen.dart';

class HalamanUtama extends StatefulWidget {
  final String namaUser;

  const HalamanUtama({super.key, this.namaUser = 'Pian'});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Daftar halaman sesuai urutan ikon di bawah
    final List<Widget> pages = [
      BerandaPage(
        namaUser: widget.namaUser,
      ),
      const Center(child: Text('Halaman Fitur 2')),
      const Center(child: Text('Halaman Fitur 3')),
      const Center(child: Text('Halaman Fitur 4')),
      ProfileScreen(namaUser: widget.namaUser), // Index 4: Profil
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Color(0xFF6679F4), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index; // Mengganti tampilan halaman secara langsung
            });
          },
          type: BottomNavigationBarType.fixed,
          selectedItemColor: const Color(0xFF6679F4),
          unselectedItemColor: Colors.blue.shade200,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.stars_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.help_outline), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.article_outlined), label: ''),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: ''),
          ],
        ),
      ),
    );
  }
}