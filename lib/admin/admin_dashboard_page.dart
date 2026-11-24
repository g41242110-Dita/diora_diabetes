import 'package:flutter/material.dart';

import 'admin_beranda_page.dart';
import 'admin_pengguna_page.dart';
import 'admin_skrining_page.dart';
import 'admin_artikel_page.dart';
import 'admin_profil_page.dart';
import 'admin_curved_nav_bar.dart';
import 'admin_activity_notification_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    AdminActivityNotificationService.instance.startListening();
  }

  @override
  void dispose() {
    AdminActivityNotificationService.instance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AdminActivityNotificationService.instance.attachContext(context);

    final List<Widget> pages = [
      AdminBerandaPage(
        isActive: _selectedIndex == 0,
        onNavigateToPengguna: () => setState(() => _selectedIndex = 1),
        onNavigateToSkrining: () => setState(() => _selectedIndex = 2),
        onNavigateToArtikel: () => setState(() => _selectedIndex = 3),
      ),
      AdminPenggunaPage(
        onBack: () => setState(() => _selectedIndex = 0),
      ),
      AdminSkriningPage(
        onBack: () => setState(() => _selectedIndex = 0),
      ),
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