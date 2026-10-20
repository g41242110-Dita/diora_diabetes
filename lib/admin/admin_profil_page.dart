import 'package:flutter/material.dart';

import 'admin_logout.dart';

/// Konten tab Profil (tanpa Scaffold & navbar; keduanya ada di dashboard).
class AdminProfilPage extends StatelessWidget {
  const AdminProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // Logo
          Center(
            child: Image.network(
              'https://cdn-icons-png.flaticon.com/512/869/869636.png',
              height: 60,
              errorBuilder: (ctx, err, stack) => const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bloodtype_rounded,
                      color: Color(0xFF5B71F5), size: 36),
                  SizedBox(width: 8),
                  Text(
                    'Diora',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5B71F5),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Foto profil
          Stack(
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    'https://img.freepik.com/free-vector/user-blue-gradient-concept-illustration_114360-12467.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => const Icon(
                      Icons.account_circle,
                      size: 100,
                      color: Color(0xFF5B71F5),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    // TODO: fitur ubah foto profil
                  },
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.black26, width: 1),
                    ),
                    child: const Icon(Icons.add_a_photo_outlined,
                        size: 16, color: Colors.black87),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            'Admin Diora',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Mustika Cahya',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),

          const SizedBox(height: 32),

          _buildMenuItem(
            icon: Icons.person_outline_rounded,
            title: 'Informasi Pribadi',
            subtitle: 'Lihat detail Akun Anda',
            onTap: () {},
          ),
          const SizedBox(height: 14),
          _buildMenuItem(
            icon: Icons.bookmark_border_rounded,
            title: 'Ubah Password',
            subtitle: 'Ganti password akun',
            onTap: () {},
          ),
          const SizedBox(height: 14),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: 'Notifikasi',
            subtitle: 'pilih jenis notifikasi yang ingin anda terima',
            onTap: () {},
          ),
          const SizedBox(height: 14),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            title: 'Keluar',
            isLogout: true,
            onTap: () => logoutAdmin(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isLogout ? const Color(0xFFFFD1D1) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isLogout
              ? Colors.redAccent.withValues(alpha: 0.3)
              : Colors.black26,
          width: 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        onTap: onTap,
        leading: Icon(
          icon,
          color: isLogout ? Colors.redAccent : const Color(0xFF4C63E6),
          size: 26,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isLogout ? Colors.redAccent : Colors.black87,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.black54))
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: isLogout ? Colors.redAccent : Colors.black87,
        ),
      ),
    );
  }
}