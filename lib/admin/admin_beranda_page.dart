import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pengguna/onboarding_page.dart';

class AdminBerandaPage extends StatefulWidget {
  const AdminBerandaPage({super.key});

  @override
  State<AdminBerandaPage> createState() => _AdminBerandaPageState();
}

class _AdminBerandaPageState extends State<AdminBerandaPage> {
  int _currentBottomIndex = 2;

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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _logoutAdmin();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderBanner(),
                const SizedBox(height: 20),
                _buildStatGrid(),
                const SizedBox(height: 20),
                _buildTrendChartCard(),
                const SizedBox(height: 20),
                _buildAktivitasTerbaruCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFDCE4FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Hallo, Admin ',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Image.network(
                      'https://cdn-icons-png.flaticon.com/512/10813/10813372.png',
                      height: 22,
                      errorBuilder: (ctx, err, stack) =>
                      const Text('👋', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Berikut ringkasan data pengguna dan aktifitas pada sistem Diora.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Image.network(
            'https://cdn-icons-png.flaticon.com/512/3774/3774299.png',
            height: 80,
            errorBuilder: (ctx, err, stack) =>
            const Icon(Icons.medical_information, size: 60, color: Color(0xFF5B71F5)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.group_rounded,
                iconBgColor: const Color(0xFFE2E8FF),
                iconColor: const Color(0xFF4C63E6),
                label: 'Total Pengguna',
                value: '1.248',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                icon: Icons.auto_awesome_rounded,
                iconBgColor: const Color(0xFFE2E8FF),
                iconColor: const Color(0xFF4C63E6),
                label: 'Total Skrining',
                value: '968',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.error_rounded,
                iconBgColor: const Color(0xFFFFE5E5),
                iconColor: const Color(0xFFFF5252),
                label: 'Skrining Positif',
                value: '186',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildStatCard(
                icon: Icons.article_rounded,
                iconBgColor: const Color(0xFFE2E8FF),
                iconColor: const Color(0xFF4C63E6),
                label: 'Total Artikel',
                value: '58',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.show_chart_rounded,
                  color: Color(0xFF4C63E6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Trend Skrining Diabetes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF4C63E6).withValues(alpha: 0.05),
                  const Color(0xFF4C63E6).withValues(alpha: 0.2),
                ],
              ),
            ),
            child: Stack(
              children: [
                const Positioned(
                  left: 8,
                  top: 10,
                  child: Text('200', style: TextStyle(fontSize: 9, color: Colors.grey)),
                ),
                const Positioned(
                  left: 8,
                  top: 45,
                  child: Text('150', style: TextStyle(fontSize: 9, color: Colors.grey)),
                ),
                const Positioned(
                  left: 8,
                  top: 80,
                  child: Text('100', style: TextStyle(fontSize: 9, color: Colors.grey)),
                ),
                const Positioned(
                  left: 12,
                  bottom: 25,
                  child: Text('0', style: TextStyle(fontSize: 9, color: Colors.grey)),
                ),
                Center(
                  child: CustomPaint(
                    size: const Size(double.infinity, 80),
                    painter: _SimpleChartPainter(),
                  ),
                ),
                const Positioned(
                  bottom: 8,
                  left: 30,
                  right: 10,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('24 Apr', style: TextStyle(fontSize: 9, color: Color(0xFF4C63E6))),
                      Text('25 Apr', style: TextStyle(fontSize: 9, color: Color(0xFF4C63E6))),
                      Text('26 Apr', style: TextStyle(fontSize: 9, color: Color(0xFF4C63E6))),
                      Text('27 Apr', style: TextStyle(fontSize: 9, color: Color(0xFF4C63E6))),
                      Text('28 Apr', style: TextStyle(fontSize: 9, color: Color(0xFF4C63E6))),
                      Text('29 Apr', style: TextStyle(fontSize: 9, color: Color(0xFF4C63E6))),
                      Text('30 Apr', style: TextStyle(fontSize: 9, color: Color(0xFF4C63E6))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAktivitasTerbaruCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.access_time_filled_rounded,
                  color: Color(0xFF4C63E6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            name: 'Siti Aisyah',
            action: 'Melakukan skrining diet',
            dateTime: '30 Agustus 2026\n14.32 WIB',
            avatarBgColor: const Color(0xFFDCE4FF),
            genderIsFemale: true,
          ),
          const Divider(height: 20, thickness: 0.5),
          _buildActivityItem(
            name: 'Rina Marlina',
            action: 'Membaca artikel',
            dateTime: '30 Agustus 2026\n10.56 WIB',
            avatarBgColor: const Color(0xFFDCE4FF),
            genderIsFemale: true,
          ),
          const Divider(height: 20, thickness: 0.5),
          _buildActivityItem(
            name: 'Bimo Setiawan',
            action: 'Konsultasi',
            dateTime: '30 Agustus 2026\n08.13 WIB',
            avatarBgColor: const Color(0xFFDCE4FF),
            genderIsFemale: false,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required String name,
    required String action,
    required String dateTime,
    required Color avatarBgColor,
    required bool genderIsFemale,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: avatarBgColor,
          child: Icon(
            genderIsFemale ? Icons.face_3_rounded : Icons.face_rounded,
            color: const Color(0xFF4C63E6),
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                action,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
        Text(
          dateTime,
          textAlign: TextAlign.end,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black45,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.black12, width: 0.8)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(icon: Icons.groups_outlined, index: 0),
          _buildNavItem(icon: Icons.menu_book_rounded, index: 1),
          _buildNavItem(icon: Icons.medical_services_rounded, index: 2, isMain: true),
          _buildNavItem(icon: Icons.insert_chart_outlined_rounded, index: 3),
          _buildNavItem(icon: Icons.person_outline_rounded, index: 4),
        ],
      ),
    );
  }

  Widget _buildNavItem({required IconData icon, required int index, bool isMain = false}) {
    final bool isSelected = _currentBottomIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentBottomIndex = index;
        });
        if (index == 4) {
          _logoutAdmin();
        }
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: isMain
            ? BoxDecoration(
          color: const Color(0xFF5B71F5),
          borderRadius: BorderRadius.circular(12),
        )
            : null,
        child: Icon(
          icon,
          size: 28,
          color: isMain
              ? Colors.white
              : (isSelected ? const Color(0xFF5B71F5) : const Color(0xFF5B71F5).withValues(alpha: 0.7)),
        ),
      ),
    );
  }
}

class _SimpleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF4C63E6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = const Color(0xFF4C63E6)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.75);
    path.cubicTo(
      size.width * 0.2,
      size.height * 0.3,
      size.width * 0.4,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.6,
    );
    path.cubicTo(
      size.width * 0.7,
      size.height * 0.8,
      size.width * 0.85,
      size.height * 0.3,
      size.width,
      size.height * 0.1,
    );

    canvas.drawPath(path, paint);

    canvas.drawCircle(Offset(0, size.height * 0.75), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.28, size.height * 0.48), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.45, size.height * 0.52), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.65), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.5), 3, dotPaint);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.38), 3, dotPaint);
    canvas.drawCircle(Offset(size.width, size.height * 0.1), 3, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}