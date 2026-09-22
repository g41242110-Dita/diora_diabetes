import 'package:flutter/material.dart';
import 'profil_informasi_pribadi_page.dart';
import 'profil_artikel_tersimpan_page.dart';

class ProfileScreen extends StatefulWidget {
  final String namaUser;
  final String emailUser;

  const ProfileScreen({
    super.key,
    this.namaUser = 'Aurelia Prisilla',
    this.emailUser = 'Aurelia.Prisilla@gmail.com',
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _currentIndex = 4; // Aktif di menu Profile

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3EFFC),
              Color(0xFFF7FAFC),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Card Profil Pengguna
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Avatar + Icon Kamera Badge
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 34,
                                  backgroundColor: const Color(0xFFFCE3CE),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/avatar.png',
                                      width: 68,
                                      height: 68,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.person, size: 45, color: Color(0xFF8D6E63)),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 0,
                                  bottom: 0,
                                  child: Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.black87, width: 1),
                                    ),
                                    child: const Icon(
                                      Icons.add_a_photo_outlined,
                                      size: 11,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 14),
                            // Nama dan Email
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.namaUser,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.emailUser,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // List Menu Berbentuk Kapsul
                      _buildMenuItem(
                        icon: Icons.person_outline,
                        title: 'Informasi Pribadi',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InformasiPribadiPage(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.bookmark_border_rounded,
                        title: 'Artikel Tersimpan',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ArtikelTersimpanPage(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.settings_outlined,
                        title: 'Pengaturan',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Bantuan & Dukungan',
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.logout_rounded,
                        title: 'Keluar',
                        isLogout: true,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),

              // Bottom Navigation Bar
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: BottomNavigationBar(
                  currentIndex: _currentIndex,
                  onTap: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor: const Color(0xFF6679F4),
                  unselectedItemColor: const Color(0xFF94A3B8),
                  showSelectedLabels: false,
                  showUnselectedLabels: false,
                  elevation: 0,
                  items: const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home_outlined, size: 26),
                      activeIcon: Icon(Icons.home, size: 26),
                      label: 'Beranda',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.auto_awesome_outlined, size: 24),
                      activeIcon: Icon(Icons.auto_awesome, size: 24),
                      label: 'Fitur',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.chat_bubble_outline_rounded, size: 24),
                      activeIcon: Icon(Icons.chat_bubble_rounded, size: 24),
                      label: 'Bantuan',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.article_outlined, size: 24),
                      activeIcon: Icon(Icons.article, size: 24),
                      label: 'Artikel',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person_outline, size: 26),
                      activeIcon: Icon(Icons.person, size: 26),
                      label: 'Profil',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    final Color bgColor = isLogout ? const Color(0xFFFDE8E8) : Colors.white;
    final Color borderColor = isLogout ? const Color(0xFFF87171) : const Color(0xFFCBD5E1);
    final Color contentColor = isLogout ? const Color(0xFFEF4444) : const Color(0xFF1E293B);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: contentColor,
                  size: 22,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: contentColor,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isLogout ? const Color(0xFFEF4444) : Colors.black87,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}