import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../pengguna/onboarding_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  int _currentBottomIndex = 5; // Tab aktif pada Profil (Icon paling kanan)

  Future<void> _logoutAdmin() async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Konfirmasi Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
            (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const SizedBox(height: 10),

              // 1. LOGO DIORA
              Center(
                child: Image.network(
                  'https://cdn-icons-png.flaticon.com/512/869/869636.png', // Ganti dengan Image.asset('assets/logo_diora.png') jika ada
                  height: 60,
                  errorBuilder: (ctx, err, stack) => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.bloodtype_rounded, color: Color(0xFF5B71F5), size: 36),
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

              // 2. FOTO PROFIL DENGAN BADGE KAMERA
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
                        'https://img.freepik.com/free-vector/user-blue-gradient-concept-illustration_114360-12467.jpg', // URL Ilustrasi Karakter Wanitanya
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
                        // Fitur ubah foto profil
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.black26, width: 1),
                        ),
                        child: const Icon(
                          Icons.add_a_photo_outlined,
                          size: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 3. NAMA DAN ROLE
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
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 32),

              // 4. DAFTAR MENU
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

              // MENU KELUAR (LOGOUT)
              _buildMenuItem(
                icon: Icons.logout_rounded,
                title: 'Keluar',
                subtitle: null,
                isLogout: true,
                onTap: _logoutAdmin,
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      // 5. BOTTOM NAVIGATION BAR (6 MENU / SESUAI GAMBAR)
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  // WIDGET ITEM MENU LIST
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
          color: isLogout ? Colors.redAccent.withValues(alpha: 0.3) : Colors.black26,
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
            ? Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
          ),
        )
            : null,
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 18,
          color: isLogout ? Colors.redAccent : Colors.black87,
        ),
      ),
    );
  }

  // WIDGET BOTTOM NAVIGATION BAR SAMA SEPERTI GAMBAR
  Widget _buildBottomNavigationBar() {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFF8CA0FF), width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.home_outlined, index: 0),
          _buildNavItem(icon: Icons.groups_outlined, index: 1),
          _buildNavItem(icon: Icons.menu_book_rounded, index: 2),
          _buildNavItem(icon: Icons.medical_services_rounded, index: 3),
          _buildNavItem(icon: Icons.insert_chart_outlined_rounded, index: 4),
          _buildNavItem(icon: Icons.person_outline_rounded, index: 5),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index}) {
    final bool isSelected = _currentBottomIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentBottomIndex = index;
        });
      },
      child: Icon(
        icon,
        size: 28,
        color: isSelected
            ? const Color(0xFF5B71F5)
            : const Color(0xFF5B71F5).withValues(alpha: 0.7),
      ),
    );
  }
}