// ignore_for_file: type_annotate_public_apis, spell_check_on_only_sample_attachments

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

import 'admin_logout_profil.dart';
import 'admin_informasi_pribadi_page.dart';
import 'admin_ubah_password_admin_page.dart';
import 'admin_notifikasi_page.dart';

class AdminProfilPage extends StatefulWidget {
  final String namaUser;
  final VoidCallback? onBackToHome;

  const AdminProfilPage({
    super.key,
    this.namaUser = 'Admin',
    this.onBackToHome,
  });

  @override
  State<AdminProfilPage> createState() => _AdminProfilPageState();
}

class _AdminProfilPageState extends State<AdminProfilPage> {
  String _namaDisplay = 'Admin Diora';
  String _emailDisplay = '';
  String? _base64Image;
  bool _isLoading = true;
  bool _isUploadingPhoto = false;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _emailDisplay = user.email ?? '';
      _namaDisplay = widget.namaUser != 'Admin' && widget.namaUser.isNotEmpty
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
          _base64Image = data['photoBase64'];
        }
      } catch (e) {
        debugPrint("Error memuat data profil admin: $e");
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndSaveImage(ImageSource source) async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      setState(() {
        _isUploadingPhoto = true;
      });

      final File file = File(pickedFile.path);
      final List<int> imageBytes = await file.readAsBytes();
      final String encoded = base64Encode(imageBytes);

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoBase64': encoded,
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _base64Image = encoded;
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil admin berhasil diperbarui!'),
            backgroundColor: Color(0xFF0D9488),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error mengganti foto profil admin: $e");
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal memperbarui foto profil.'),
            backgroundColor: Color(0xFFE11D48),
          ),
        );
      }
    }
  }

  Future<void> _hapusFotoProfil() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isUploadingPhoto = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'photoBase64': null,
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _base64Image = null;
          _isUploadingPhoto = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto profil berhasil dihapus.'),
            backgroundColor: Color(0xFF475569),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingPhoto = false;
        });
      }
    }
  }

  void _showPhotoPickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  title: const Text(
                    'Pilih dari Galeri',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndSaveImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  title: const Text(
                    'Ambil Foto Kamera',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14.5,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickAndSaveImage(ImageSource.camera);
                  },
                ),
                if (_base64Image != null && _base64Image!.isNotEmpty)
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                    title: const Text(
                      'Hapus Foto Profil',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _hapusFotoProfil();
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'A';
    final List<String> names = name.trim().split(' ');
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
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBackAction();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F6FC),
        body: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
        )
            : Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                _buildLiquidHeader(context),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    statusBarHeight + 70,
                    20,
                    0,
                  ),
                  child: _buildFloatingCard(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 82),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 4,
                          height: 15,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4F46E5),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const Text(
                          'Pengaturan Akun',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildMenuItem(
                        icon: Icons.person_outline_rounded,
                        iconColor: const Color(0xFF4F46E5),
                        bgColor: const Color(0xFFEEF2FF),
                        title: 'Informasi Pribadi',
                        subtitle: 'Lihat & perbarui detail akun Anda',
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const AdminInformasiPribadiPage(),
                            ),
                          );
                          _fetchUserData();
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildMenuItem(
                        icon: Icons.lock_outline_rounded,
                        iconColor: const Color(0xFF0D9488),
                        bgColor: const Color(0xFFCCFBF1),
                        title: 'Ubah Password',
                        subtitle: 'Ganti kata sandi keamanan akun',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const UbahPasswordAdminPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildMenuItem(
                        icon: Icons.notifications_none_rounded,
                        iconColor: const Color(0xFFD97706),
                        bgColor: const Color(0xFFFEF3C7),
                        title: 'Notifikasi',
                        subtitle: 'Atur pemberitahuan aplikasi admin',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                              const NotifikasiAplikasiAdminPage(),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: _buildMenuItem(
                        icon: Icons.logout_rounded,
                        iconColor: const Color(0xFFE11D48),
                        bgColor: const Color(0xFFFFE4E6),
                        title: 'Keluar',
                        subtitle: 'Keluar dari akun administrator',
                        isLogout: true,
                        onTap: () {
                          logoutAdmin(context);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiquidHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Stack(
      children: [
        ClipPath(
          clipper: _ProfilLiquidHeaderClipper(offsetY: 10),
          child: Container(
            width: double.infinity,
            height: topPadding + 154,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4F46E5).withValues(alpha: 0.22),
                  const Color(0xFF38BDF8).withValues(alpha: 0.22),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        ClipPath(
          clipper: _ProfilLiquidHeaderClipper(offsetY: 0),
          child: Container(
            width: double.infinity,
            height: topPadding + 144,
            padding: EdgeInsets.fromLTRB(16, topPadding + 4, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4338CA),
                  Color(0xFF4F46E5),
                  Color(0xFF3B82F6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 36),
                        child: Text(
                          'Profil Admin',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'Kembali ke Beranda',
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          onPressed: _handleBackAction,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildInteractiveAvatar(size: 64),
          const SizedBox(height: 9),
          Text(
            'Halo, $_namaDisplay 👋',
            style: const TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2.5),
          Text(
            _emailDisplay,
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified_user_rounded,
                  size: 14,
                  color: Color(0xFF4F46E5),
                ),
                SizedBox(width: 5),
                Text(
                  'Administrator',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInteractiveAvatar({double size = 64}) {
    return GestureDetector(
      onTap: _isUploadingPhoto ? null : _showPhotoPickerModal,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildAvatar(size: size),
          if (_isUploadingPhoto)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black.withValues(alpha: 0.45),
              ),
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            ),
          Positioned(
            right: -2,
            bottom: -2,
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF4F46E5).withValues(alpha: 0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar({double size = 64}) {
    if (_base64Image != null && _base64Image!.isNotEmpty) {
      try {
        final cleanBase64 = _base64Image!.contains(',')
            ? _base64Image!.split(',').last
            : _base64Image!;
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEEF2FF), width: 3.5),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.memory(
              base64Decode(cleanBase64),
              width: size,
              height: size,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (context, error, stackTrace) =>
                  _buildInitialsAvatar(size),
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
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getInitials(_namaDisplay),
          style: TextStyle(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF4F46E5),
          ),
        ),
      ),
    );
  }

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
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLogout ? const Color(0xFFFFCDD2) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(icon, size: 23, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isLogout
                              ? const Color(0xFFE11D48)
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      if (subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2.5),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 21,
                  color: isLogout
                      ? const Color(0xFFE11D48)
                      : const Color(0xFF94A3B8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfilLiquidHeaderClipper extends CustomClipper<Path> {
  final double offsetY;

  _ProfilLiquidHeaderClipper({this.offsetY = 0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final h = size.height - offsetY;

    path.lineTo(0, h - 22);

    path.quadraticBezierTo(
      size.width * 0.25,
      h + 6,
      size.width * 0.52,
      h - 14,
    );

    path.quadraticBezierTo(
      size.width * 0.80,
      h - 32,
      size.width,
      h - 10,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _ProfilLiquidHeaderClipper oldClipper) {
    return oldClipper.offsetY != offsetY;
  }
}