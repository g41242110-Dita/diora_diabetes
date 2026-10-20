import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../auth_router.dart';
import '../pengguna/onboarding_page.dart';

/// Ambil data dokter yang sedang login (lewat AuthRouter, supaya konsisten
/// dengan penentuan role di halaman login).
Future<Map<String, dynamic>?> ambilDataDokter() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return null;
  return AuthRouter.ambilDataUser(user);
}

/// Dialog konfirmasi + logout. Dipakai di beranda & profil dokter.
Future<void> logoutDokter(BuildContext context) async {
  final bool? konfirmasi = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Konfirmasi Logout',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text('Apakah Anda yakin ingin keluar dari akun Dokter?'),
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
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingPage()),
          (route) => false,
    );
  }
}

/// Isi tab Profil dokter (tanpa Scaffold, ditempel di DokterBerandaPage).
class DokterProfilPage extends StatelessWidget {
  const DokterProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: FutureBuilder<Map<String, dynamic>?>(
          future: ambilDataDokter(),
          builder: (context, snapshot) {
            final data = snapshot.data;
            final nama = (data?['nama'] ?? 'Dokter Diora').toString();
            final spesialis =
            (data?['spesialisasi'] ?? 'Dokter Umum').toString();
            final email = FirebaseAuth.instance.currentUser?.email ?? '-';

            return Column(
              children: [
                const SizedBox(height: 10),
                const Row(
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
                const SizedBox(height: 24),
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFDCE4FF),
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.medical_services_rounded,
                    size: 56,
                    color: Color(0xFF5B71F5),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  spesialis,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: const TextStyle(fontSize: 12, color: Colors.black45),
                ),
                const SizedBox(height: 32),
                _menuItem(
                  icon: Icons.person_outline_rounded,
                  title: 'Informasi Pribadi',
                  subtitle: 'Lihat detail akun Anda',
                  onTap: () {},
                ),
                const SizedBox(height: 14),
                _menuItem(
                  icon: Icons.lock_outline_rounded,
                  title: 'Ubah Password',
                  subtitle: 'Ganti password akun',
                  onTap: () {},
                ),
                const SizedBox(height: 14),
                _menuItem(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifikasi',
                  subtitle: 'Pilih jenis notifikasi yang ingin Anda terima',
                  onTap: () {},
                ),
                const SizedBox(height: 14),
                _menuItem(
                  icon: Icons.logout_rounded,
                  title: 'Keluar',
                  isLogout: true,
                  onTap: () => logoutDokter(context),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _menuItem({
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