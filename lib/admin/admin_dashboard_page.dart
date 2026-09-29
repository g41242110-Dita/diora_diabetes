import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 2; // Default aktif di Tab Dashboard (tengah)

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Apakah Anda yakin ingin keluar dari akun Admin?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(context);
              await FirebaseAuth.instance.signOut();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BANNER HEADER WELCOME ADMIN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E2FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFB4C8FF), width: 1),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Text(
                                'Hallo, Admin ',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              Text('👋', style: TextStyle(fontSize: 18)),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Berikut ringkasan data pengguna dan aktifitas pada sistem Diora.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black87,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        'assets/dokter_illustration.png',
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person, size: 60, color: Color(0xFF6679F4)),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. GRID 4 KARTU STATISTIK (2x2)
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.people_alt_rounded,
                      iconBgColor: const Color(0xFFDDE6FF),
                      iconColor: Colors.black,
                      title: 'Total Pengguna',
                      count: '1.248',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.auto_awesome_rounded,
                      iconBgColor: const Color(0xFFE2E0FF),
                      iconColor: Colors.black,
                      title: 'Total Skrining',
                      count: '968',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.warning_rounded,
                      iconBgColor: const Color(0xFFFFD6D6),
                      iconColor: Colors.redAccent,
                      title: 'Skrining Positif',
                      count: '186',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.article_rounded,
                      iconBgColor: const Color(0xFFDCE2FF),
                      iconColor: Colors.black,
                      title: 'Total Artikel',
                      count: '58',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 3. KARTU GRAFIK TREND SKRINING (Custom Painter)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.show_chart_rounded,
                            color: Color(0xFF4F46E5),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Trend Skrining Diabetes',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 130,
                      width: double.infinity,
                      child: Row(
                        children: [
                          // Sumbu Y
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('200', style: TextStyle(fontSize: 8, color: Colors.grey)),
                              Text('150', style: TextStyle(fontSize: 8, color: Colors.grey)),
                              Text('100', style: TextStyle(fontSize: 8, color: Colors.grey)),
                              Text('50', style: TextStyle(fontSize: 8, color: Colors.grey)),
                              Text('0', style: TextStyle(fontSize: 8, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(width: 8),
                          // Area Grafik + Sumbu X
                          Expanded(
                            child: Column(
                              children: [
                                Expanded(
                                  child: CustomPaint(
                                    size: Size.infinite,
                                    painter: LineChartPainter(),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: const [
                                    Text('24 Apr', style: TextStyle(fontSize: 8, color: Color(0xFF475569))),
                                    Text('25 Apr', style: TextStyle(fontSize: 8, color: Color(0xFF475569))),
                                    Text('26 Apr', style: TextStyle(fontSize: 8, color: Color(0xFF475569))),
                                    Text('27 Apr', style: TextStyle(fontSize: 8, color: Color(0xFF475569))),
                                    Text('28 Apr', style: TextStyle(fontSize: 8, color: Color(0xFF475569))),
                                    Text('29 Apr', style: TextStyle(fontSize: 8, color: Color(0xFF475569))),
                                    Text('30 Apr', style: TextStyle(fontSize: 8, color: Color(0xFF475569))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 4. KARTU AKTIVITAS TERBARU
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.black, width: 1.2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE0E7FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.access_time_rounded,
                            color: Color(0xFF4F46E5),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Aktivitas Terbaru',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildActivityItem(
                      name: 'Siti Aisyah',
                      action: 'Melakukan skrining diet',
                      time: '30 Agustus 2026\n14.32 WIB',
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildActivityItem(
                      name: 'Rina Marlina',
                      action: 'Membaca artikel',
                      time: '30 Agustus 2026\n10.56 WIB',
                    ),
                    const Divider(height: 20, color: Color(0xFFF1F5F9)),
                    _buildActivityItem(
                      name: 'Bimo Setiawan',
                      action: 'Konsultasi',
                      time: '30 Agustus 2026\n08.13 WIB',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // 5. BOTTOM NAVIGATION BAR
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            if (index == 4) {
              _logout();
            } else {
              setState(() {
                _selectedIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF5568FE),
          unselectedItemColor: const Color(0xFF64748B),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.people_outline_rounded, size: 28),
              activeIcon: Icon(Icons.people_rounded, size: 28),
              label: 'Pengguna',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined, size: 26),
              activeIcon: Icon(Icons.menu_book_rounded, size: 26),
              label: 'Artikel',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined, size: 28),
              activeIcon: Icon(Icons.analytics_rounded, size: 28),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.insert_drive_file_outlined, size: 26),
              activeIcon: Icon(Icons.insert_drive_file_rounded, size: 26),
              label: 'Laporan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded, size: 28),
              activeIcon: Icon(Icons.person_rounded, size: 28),
              label: 'Profil / Logout',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String count,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.black, width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  count,
                  style: const TextStyle(
                    fontSize: 18,
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

  Widget _buildActivityItem({
    required String name,
    required String action,
    required String time,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFDDE6FF),
          child: Text(
            name[0],
            style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6679F4)),
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
                  color: Colors.black,
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
          time,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.black45,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

// Painter Khusus Line Chart Halus Murni Flutter
class LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(0, size.height * 0.75),
      Offset(size.width * 0.16, size.height * 0.52),
      Offset(size.width * 0.33, size.height * 0.45),
      Offset(size.width * 0.50, size.height * 0.60),
      Offset(size.width * 0.66, size.height * 0.48),
      Offset(size.width * 0.83, size.height * 0.42),
      Offset(size.width, size.height * 0.25),
    ];

    final path = Path();
    path.moveTo(points[0].dx, points[0].dy);

    for (int i = 0; i < points.length - 1; i++) {
      final xAvg = (points[i].dx + points[i + 1].dx) / 2;
      final yAvg = (points[i].dy + points[i + 1].dy) / 2;
      path.quadraticBezierTo(points[i].dx, points[i].dy, xAvg, yAvg);
    }
    path.lineTo(points.last.dx, points.last.dy);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF3B82F6).withValues(alpha: 0.3),
          const Color(0xFF3B82F6).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, fillPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = const Color(0xFF3B82F6);
    final dotBorderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (var point in points) {
      canvas.drawCircle(point, 3.5, dotPaint);
      canvas.drawCircle(point, 3.5, dotBorderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}