import 'package:flutter/material.dart';

class ProfilPage extends StatefulWidget {
  final String nama;
  final String email;

  const ProfilPage({
    super.key,
    this.nama = 'Aurelia Prisilla',
    this.email = 'Aurelia.Prisilla@gmail.com',
  });

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int _currentIndex = 4; // Aktif di menu Profil

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAF2FF),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Column(
                  children: [
                    // KARTU PROFIL UTAMA
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFB0C4DE),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Stack(
                            children: [
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: const Color(0xFFFFE0B2),
                                child: Icon(
                                  Icons.person,
                                  size: 50,
                                  color: Colors.orange.shade700,
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.grey.shade400,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt_outlined,
                                    size: 14,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Menampilkan Nama Dinamis
                                Text(
                                  widget.nama,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                // Menampilkan Email Dinamis
                                Text(
                                  widget.email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // LIST MENU PENGATURAN
                    _buildMenuItem(
                      icon: Icons.person_outline,
                      title: 'Informasi Pribadi',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.bookmark_border,
                      title: 'Artikel Tersimpan',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Pengaturan',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.help_outline,
                      title: 'Bantuan & Dukungan',
                      onTap: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Keluar',
                      isLogout: true,
                      onTap: () {
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM NAVIGATION BAR
            Container(
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFFE8EEFF), width: 1.5),
                ),
              ),
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.white,
                elevation: 0,
                selectedItemColor: const Color(0xFF6679F4),
                unselectedItemColor: const Color(0xFF8E99AF),
                showSelectedLabels: false,
                showUnselectedLabels: false,
                onTap: (index) {
                  if (index == 0) {
                    Navigator.pop(context);
                  } else {
                    setState(() {
                      _currentIndex = index;
                    });
                  }
                },
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined, size: 26),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.auto_awesome, size: 26),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.chat_bubble_outline, size: 24),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.article_outlined, size: 26),
                    label: '',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline, size: 26),
                    label: '',
                  ),
                ],
              ),
            ),
          ],
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
    final backgroundColor =
        isLogout ? const Color(0xFFFFD6D6) : Colors.white;
    final textColor = isLogout ? Colors.redAccent : Colors.black87;
    final iconColor = isLogout ? Colors.redAccent : const Color(0xFF6679F4);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLogout
                ? const Color(0xFFFFB3B3)
                : const Color(0xFFD9E2EC),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: textColor.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}