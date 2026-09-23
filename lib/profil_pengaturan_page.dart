import 'package:flutter/material.dart';
import 'profil_ubah_informasi_page.dart';
import 'profil_ganti_kata_sandi_page.dart';
import 'profil_notifikasi_page.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              // Judul Halaman
              const Text(
                'Pengaturan',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 24),

              // Group 1: Akun
              _buildGroupCard(
                headerIcon: Icons.person_outline,
                headerTitle: 'Akun',
                items: [
                  _SettingItem(
                    icon: Icons.person_outline,
                    title: 'Ubah Informasi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UbahInformasiPage(),
                        ),
                      );
                    },
                  ),
                  _SettingItem(
                    icon: Icons.lock_outline_rounded,
                    title: 'Ganti Kata Sandi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const GantiKataSandiPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Group 2: Notifikasi
              _buildGroupCard(
                headerIcon: Icons.notifications_none_rounded,
                headerTitle: 'Notifikasi',
                items: [
                  _SettingItem(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifikasi Aplikasi',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotifikasiAplikasiPage(),
                        ),
                      );
                    },
                  ),
                  _SettingItem(
                    icon: Icons.email_outlined,
                    title: 'Notifikasi Email',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NotifikasiEmailPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard({
    required IconData headerIcon,
    required String headerTitle,
    required List<_SettingItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Column(
        children: [
          // Header Group (Warna Biru Soft)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEBF2FE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  headerIcon,
                  size: 20,
                  color: Colors.black87,
                ),
                const SizedBox(width: 12),
                Text(
                  headerTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // List Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final item = items[index];
              return InkWell(
                onTap: item.onTap,
                borderRadius: index == items.length - 1
                    ? const BorderRadius.only(
                  bottomLeft: Radius.circular(11),
                  bottomRight: Radius.circular(11),
                )
                    : BorderRadius.zero,
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 20,
                        color: Colors.black87,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: Color(0xFF94A3B8),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  _SettingItem({
    required this.icon,
    required this.title,
    required this.onTap,
  });
}