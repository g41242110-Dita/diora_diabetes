import 'package:flutter/material.dart';
// Import semua halaman pendukung
import 'profil_informasi_pribadi_page.dart';
import 'profil_artikel_tersimpan_page.dart';
import 'profil_pengaturan_page.dart';
import 'profil_bantuan_dukungan_page.dart';
import 'profil_keluar_page.dart';

class ProfileScreen extends StatelessWidget {
  final String namaUser;

  const ProfileScreen({
    super.key,
    this.namaUser = 'Aurelia Prisilla', // Default value jika parameter kosong
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Header Judul
              const Text(
                'Profil',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // Avatar & Info Pengguna
              CircleAvatar(
                radius: 40,
                backgroundColor: const Color(0xFFBAC8FF),
                child: Text(
                  _getInitials(namaUser),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                namaUser,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Aurelia.Prisilla@gmail.com',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                ),
              ),
              const SizedBox(height: 32),

              // List Menu Profil
              _buildMenuItem(
                context: context,
                icon: Icons.person_outline_rounded,
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
                context: context,
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
                context: context,
                icon: Icons.settings_outlined,
                title: 'Pengaturan',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PengaturanPage(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.help_outline_rounded,
                title: 'Bantuan & Dukungan',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BantuanDukunganPage(),
                    ),
                  );
                },
              ),
              _buildMenuItem(
                context: context,
                icon: Icons.logout_rounded,
                title: 'Keluar',
                isLogout: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KeluarPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Helper untuk mengambil inisial dari nama
  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'AP';
    List<String> names = name.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isLogout ? const Color(0xFFF83B3B) : Colors.black87,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isLogout ? const Color(0xFFF83B3B) : Colors.black87,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isLogout ? const Color(0xFFF83B3B) : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}