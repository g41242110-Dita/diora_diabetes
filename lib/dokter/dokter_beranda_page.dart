import 'package:flutter/material.dart';
import 'dokter_curved_nav_bar.dart';

class DokterBerandaPage extends StatefulWidget {
  const DokterBerandaPage({super.key});

  @override
  State<DokterBerandaPage> createState() => _DokterBerandaPageState();
}

class _DokterBerandaPageState extends State<DokterBerandaPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const _DokterDashboardContentView(),
      const Center(child: Text('Halaman Skrining Pasien')),
      const Center(child: Text('Halaman Konsultasi Chat')),
      const Center(child: Text('Halaman Lokasi Praktek')),
      const Center(child: Text('Halaman Profil Dokter')),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: DokterCurvedNavBar(
        selectedIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _DokterDashboardContentView extends StatelessWidget {
  const _DokterDashboardContentView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          // -----------------------------------------------------------------
          // 1. HEADER + BANNER DALAM 1 INTEGRATED CONTAINER (Presisi & Rapi)
          // -----------------------------------------------------------------
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 54.0,
              left: 20.0,
              right: 20.0,
              bottom: 20.0,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              children: [
                // Baris Info Profil Dokter & Notifikasi
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFFEEF2FF),
                        child: Icon(Icons.person, color: Color(0xFF4F46E5), size: 26),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Halo, dr. Amanda Putri, Sp.PD',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Dokter Spesialis Penyakit Dalam • Klinik Sentosa',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Color(0xFFE0E7FF),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Card Panel Kendali (Menjadi bagian langsung dari header)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Panel Kendali Dokter',
                              style: TextStyle(
                                color: Color(0xFF4F46E5),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'SIP : 446/SIP/2024',
                              style: TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Ada 4 pasien berisiko tinggi yang membutuhkan verifikasi skrining & anjuran lab hari ini.',
                        style: TextStyle(
                          color: Color(0xFF334155),
                          fontSize: 12,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // -----------------------------------------------------------------
          // 2. GRID KARTU STATISTIK DOKTER
          // -----------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.35,
              children: [
                _buildStatGridCard(
                  icon: Icons.chat_bubble_rounded,
                  accentColor: const Color(0xFF6366F1),
                  bgGradient: const [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
                  count: '3',
                  title: 'Antrean Konsul',
                  subtitle: '1 Pasien Baru',
                ),
                _buildStatGridCard(
                  icon: Icons.assignment_turned_in_rounded,
                  accentColor: const Color(0xFF8B5CF6),
                  bgGradient: const [Color(0xFFF3E8FF), Color(0xFFFAF5FF)],
                  count: '4',
                  title: 'Skrining Masuk',
                  subtitle: '2 Positif',
                ),
                _buildStatGridCard(
                  icon: Icons.groups_rounded,
                  accentColor: const Color(0xFF0EA5E9),
                  bgGradient: const [Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
                  count: '13',
                  title: 'Pasien Hari Ini',
                  subtitle: 'Klinik Sentosa',
                ),
                _buildStatGridCard(
                  icon: Icons.calendar_today_rounded,
                  accentColor: const Color(0xFFEC4899),
                  bgGradient: const [Color(0xFFFCE7F3), Color(0xFFFDF2F8)],
                  count: '08-14',
                  title: 'Jadwal Praktik',
                  subtitle: 'WIB',
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // -----------------------------------------------------------------
          // 3. ANTREAN KONSULTASI PASIEN
          // -----------------------------------------------------------------
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Antrean Konsultasi Pasien',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildConsultationItem(
            name: 'Aurelia Prislla',
            ageGender: '20 th • Perempuan',
            time: '09:17',
            status: 'Positif',
            message: 'Dok, saya ingin menanyakan hasil skrining',
          ),
          _buildConsultationItem(
            name: 'Budi Hartono',
            ageGender: '48 th • Laki-Laki',
            time: '08:17',
            status: 'Positif',
            message: 'Baik dok, besok pagi jam 8 saya akan datang ke klinik ...',
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildStatGridCard({
    required IconData icon,
    required Color accentColor,
    required List<Color> bgGradient,
    required String count,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              Text(
                count,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationItem({
    required String name,
    required String ageGender,
    required String time,
    required String status,
    required String message,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      ageGender,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  message,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFF4F46E5),
            size: 24,
          ),
        ],
      ),
    );
  }
}