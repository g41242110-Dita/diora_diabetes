import 'package:flutter/material.dart';
import 'beranda_page.dart';
import 'skrining_page.dart';
import 'konsultasi_page.dart';
import 'artikel_page.dart';
import 'profile_screen.dart';
import 'curved_nav_bar.dart';

class HalamanUtama extends StatefulWidget {
  final String namaUser;
  final int initialIndex;

  const HalamanUtama({
    super.key,
    this.namaUser = 'Pian',
    this.initialIndex = 0,
  });

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      BerandaPage(
        namaUser: widget.namaUser,
      ),
      SkriningPage(
        onBackToHome: () => _onItemTapped(0),
      ),
      KonsultasiPage(
        namaUser: widget.namaUser,
      ),
      const ArtikelPage(),
      ProfileScreen(
        namaUser: widget.namaUser,
        onBackToHome: () => _onItemTapped(0),
      ),
    ];

    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: pages[_selectedIndex],
        bottomNavigationBar: CurvedNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: _onItemTapped,
        ),
      ),
    );
  }
}