import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'profil_informasi_pribadi_page.dart';
import 'profil_artikel_tersimpan_page.dart';
import 'profil_pengaturan_page.dart';
import 'profil_bantuan_dukungan_page.dart';
import 'profil_keluar_page.dart';

class ProfileScreen extends StatefulWidget {
  final String namaUser;
  final VoidCallback? onBackToHome;

  const ProfileScreen({
    super.key,
    this.namaUser = 'Pengguna',
    this.onBackToHome,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _namaDisplay = '';
  String _emailDisplay = '';
  String? _base64Image;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _emailDisplay = user.email ?? '';
      _namaDisplay = widget.namaUser != 'Pengguna' && widget.namaUser.isNotEmpty
          ? widget.namaUser
          : (_emailDisplay.split('@').first);

      try {
        final DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data() as Map<String, dynamic>;
          if (data.containsKey('nama') && data['nama'].toString().isNotEmpty) {
            _namaDisplay = data['nama'];
          }
          if (data.containsKey('photoBase64') && data['photoBase64'] != null) {
            _base64Image = data['photoBase64'];
          }
        }
      } catch (e) {
        debugPrint("Error memuat data profil: $e");
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    List<String> names = name.trim().split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return names[0][0].toUpperCase();
  }

  void _handleBackAction() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else if (widget.onBackToHome != null) {
      widget.onBackToHome!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackAction();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Header & Kartu Mengambang
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          _buildTopGradientHeader(),
                          Positioned(
                            top: 85,
                            left: 20,
                            right: 20,
                            child: _buildFloatingCard(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 155),
                      // Menu Navigasi
                      _buildMenuList(),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // 1. Header Gradien Atas
  Widget _buildTopGradientHeader() {
    return Container(
      width: double.infinity,
      height: 180,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF4F46E5), Color(0xFF4338CA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: _handleBackAction,
            borderRadius: BorderRadius.circular(50),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.arrow_back, color: Colors.white, size: 22),
            ),
          ),
          const SizedBox(width: 8),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'Profil Saya',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 2. Kartu Profil Mengambang (Nama & Email yang diperjelas warnanya)
  Widget _buildFloatingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildAvatar(size: 84),
          const SizedBox(height: 12),
          Text(
            'Halo, $_namaDisplay 👋',
            style: const TextStyle(
              color: Color(0xFF0F172A), // Hitam arang pekat (Slate 900)
              fontSize: 18,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            _emailDisplay,
            style: const TextStyle(
              color: Color(0xFF334155), // Abu-abu gelap tegas (Slate 700)
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // 3. Avatar Foto / Inisial
  Widget _buildAvatar({double size = 88}) {
    if (_base64Image != null && _base64Image!.isNotEmpty) {
      try {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEEF2FF), width: 4),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withOpacity(0.15),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.memory(
              base64Decode(_base64Image!),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => _buildInitialsAvatar(size),
            ),
          ),
        );
      } catch (_) {}
    }

    return _buildInitialsAvatar(size);
  }

  Widget _buildInitialsAvatar(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getInitials(_namaDisplay),
          style: TextStyle(
            fontSize: size * 0.36,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4F46E5),
          ),
        ),
      ),
    );
  }

  // 4. Daftar Menu Pilihan
  Widget _buildMenuList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline_rounded,
            iconColor: const Color(0xFF4F46E5),
            bgColor: const Color(0xFFEEF2FF),
            title: 'Informasi Pribadi',
            subtitle: 'Ubah data diri & akun',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const InformasiPribadiPage()),
              ).then((_) => _fetchUserData());
            },
          ),
          _buildMenuItem(
            icon: Icons.bookmark_border_rounded,
            iconColor: const Color(0xFF10B981),
            bgColor: const Color(0xFFECFDF5),
            title: 'Artikel Tersimpan',
            subtitle: 'Daftar bacaan favorit Anda',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ArtikelTersimpanPage()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            iconColor: const Color(0xFFF59E0B),
            bgColor: const Color(0xFFFEF3C7),
            title: 'Pengaturan',
            subtitle: 'Preferensi aplikasi & keamanan',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PengaturanPage()),
              );
            },
          ),
          _buildMenuItem(
            icon: Icons.help_outline_rounded,
            iconColor: const Color(0xFF8B5CF6),
            bgColor: const Color(0xFFF3E8FF),
            title: 'Bantuan & Dukungan',
            subtitle: 'Pusat bantuan & FAQ',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BantuanDukunganPage()),
              );
            },
          ),
          const SizedBox(height: 6),
          _buildMenuItem(
            icon: Icons.logout_rounded,
            iconColor: const Color(0xFFEF4444),
            bgColor: const Color(0xFFFEE2E2),
            title: 'Keluar',
            subtitle: 'Keluar dari akun Anda',
            isLogout: true,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const KeluarPage()),
              );
            },
          ),
        ],
      ),
    );
  }

  // 5. Item Menu Individual
  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, size: 22, color: iconColor),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isLogout ? const Color(0xFFEF4444) : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: isLogout ? const Color(0xFFEF4444) : const Color(0xFFCBD5E1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}