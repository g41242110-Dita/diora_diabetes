import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// SESUAIKAN PATH INI DENGAN FOLDER LOGIN_PAGE KAMU
import '../pengguna/login_page.dart';

class DokterProfilPage extends StatefulWidget {
  const DokterProfilPage({super.key});

  @override
  State<DokterProfilPage> createState() => _DokterProfilPageState();
}

class _DokterProfilPageState extends State<DokterProfilPage> {
  // ---------------------------------------------------------------------------
  // DIALOG KONFIRMASI LOGOUT
  // ---------------------------------------------------------------------------
  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF0F0), Color(0xFFFFDADA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF83B3B).withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFE53935),
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Sesi Akan Berakhir',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Apakah Anda yakin ingin keluar?\nAnda perlu masuk kembali untuk mengakses akun Diora.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            shadowColor: const Color(0xFFE53935).withValues(alpha: 0.3),
                          ),
                          onPressed: () async {
                            Navigator.pop(dialogContext); // Tutup Dialog

                            // 1. Sign out Firebase
                            await FirebaseAuth.instance.signOut();

                            if (!context.mounted) return;

                            // 2. Navigasi Langsung ke LoginPage & Hapus Navigation Stack
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                                  (route) => false,
                            );
                          },
                          child: const Text(
                            'Keluar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------------------------------------------------------------
              // 1. HEADER JUDUL HALAMAN
              // -------------------------------------------------------------
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Profil Dokter',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E2761),
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Kredensial medis resmi dan informasi profil',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // -------------------------------------------------------------
              // 2. KARTU UTAMA PROFIL DOKTER
              // -------------------------------------------------------------
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      height: 70,
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(0, -38),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(3),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const CircleAvatar(
                                  radius: 36,
                                  backgroundColor: Color(0xFFEEF2FF),
                                  child: Icon(Icons.person, color: Color(0xFF4F46E5), size: 42),
                                ),
                              ),
                              Positioned(
                                right: 3,
                                bottom: 3,
                                child: Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.white, width: 2.5),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'dr. Amanda Putri, Sp.PD',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Dokter Spesialis Penyakit Dalam',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'FK UI • Pengalaman 5 Tahun',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.verified, color: Color(0xFF4F46E5), size: 15),
                                SizedBox(width: 6),
                                Text(
                                  'Terverifikasi Resmi IDI & KKI',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn('★ 4.8', '324 Ulasan', const Color(0xFFF59E0B)),
                              Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                              _buildStatColumn('5 Thn', 'Pengalaman', const Color(0xFF4F46E5)),
                              Container(width: 1, height: 28, color: const Color(0xFFE2E8F0)),
                              _buildStatColumn('186+', 'Skrining', const Color(0xFF10B981)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // -------------------------------------------------------------
              // 3. SEKSI LEGALITAS DAN KREDENSIAL DOKTER
              // -------------------------------------------------------------
              const Text(
                'Legalitas dan Kredensial Dokter',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF0F7FF), Color(0xFFF8FAFC)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF3B82F6).withValues(alpha: 0.15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildCredentialRow(
                      icon: Icons.assignment_ind_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      label: 'Nomor Surat Izin Praktik (SIP)',
                      value: '446/SIP/2024',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                    ),
                    _buildCredentialRow(
                      icon: Icons.verified_user_rounded,
                      iconColor: const Color(0xFF8B5CF6),
                      label: 'Nomor Registrasi Dokter (STR)',
                      value: '33.1.1.100.2.21.09876',
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 10),
                      child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                    ),
                    _buildCredentialRow(
                      icon: Icons.local_hospital_rounded,
                      iconColor: const Color(0xFFEC4899),
                      label: 'Klinik Dinas Utama',
                      value: 'Klinik Sehat Sentosa',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // -------------------------------------------------------------
              // 4. TOMBOL KELUAR PORTAL DOKTER
              // -------------------------------------------------------------
              Center(
                child: SizedBox(
                  width: 220,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () => _showLogoutConfirmationDialog(context),
                    icon: const Icon(Icons.logout_rounded, color: Colors.white, size: 18),
                    label: const Text(
                      'Keluar Portal Dokter',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE53935),
                      elevation: 2,
                      shadowColor: const Color(0xFFE53935).withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}