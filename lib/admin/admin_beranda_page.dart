import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_pengguna_page.dart';
import 'admin_skrining_page.dart';
import 'admin_artikel_page.dart';

class AdminBerandaPage extends StatefulWidget {
  const AdminBerandaPage({super.key});

  @override
  State<AdminBerandaPage> createState() => _AdminBerandaPageState();
}

class _AdminBerandaPageState extends State<AdminBerandaPage> {
  late final Future<int> _totalPengguna;

  @override
  void initState() {
    super.initState();
    _totalPengguna = _ambilTotalPengguna();
  }

  Future<int> _ambilTotalPengguna() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection('users').get();

      return snapshot.docs.where((doc) {
        final data = doc.data();
        final role =
        (data['role'] ?? 'pengguna').toString().trim().toLowerCase();

        return role != 'admin';
      }).length;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Latar belakang abu-abu terang modern
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // --- KARTU HEADER EKSKLUSIF (TAMPILAN BEDA SENDIRI) ---
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF1E3A8A), Color(0xFF2563EB), Color(0xFF3B82F6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Dashboard Admin',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFFBFDBFE),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Halo, Admin 👋',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sistem pemantauan kesehatan & edukasi diabetes aktif berjalan.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFFE2E8F0),
                                height: 1.3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 14),
                      // GAMBAR ADMIN YANG RAPI TANPA TERPOTONG
                      Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage('assets/admin_avatar.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // --- KARTU STATISTIK GRID ---
                _buildStatGrid(),
                const SizedBox(height: 24),

                // --- GRAFIK TREN ---
                _buildTrendChartCard(),
                const SizedBox(height: 24),

                // --- AKTIVITAS TERBARU ---
                _buildAktivitasTerbaruCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminPenggunaPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(22),
                child: FutureBuilder<int>(
                  future: _totalPengguna,
                  builder: (context, snapshot) {
                    final total = snapshot.data;
                    return _buildStatCard(
                      icon: Icons.group_rounded,
                      label: 'Total Pengguna',
                      value: snapshot.hasError ? '-' : total?.toString() ?? '...',
                      cardColor: Colors.white,
                      iconBgColor: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminSkriningPage(
                        initialFilter: 'Semua',
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(22),
                child: _buildStatCard(
                  icon: Icons.auto_awesome_rounded,
                  label: 'Total Skrining',
                  value: '968',
                  cardColor: Colors.white,
                  iconBgColor: const Color(0xFFF0FDFA),
                  iconColor: const Color(0xFF0D9488),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminSkriningPage(
                        initialFilter: 'Positif',
                      ),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(22),
                child: _buildStatCard(
                  icon: Icons.warning_amber_rounded,
                  label: 'Skrining Positif',
                  value: '186',
                  cardColor: Colors.white,
                  iconBgColor: const Color(0xFFFEF2F2),
                  iconColor: const Color(0xFFDC2626),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminArtikelPage(),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(22),
                child: _buildStatCard(
                  icon: Icons.article_rounded,
                  label: 'Total Artikel',
                  value: '58',
                  cardColor: Colors.white,
                  iconBgColor: const Color(0xFFF5F3FF),
                  iconColor: const Color(0xFF7C3AED),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color cardColor,
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendChartCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.show_chart_rounded,
                    color: Color(0xFF2563EB),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Trend Skrining Diabetes',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Bulanan',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 170,
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: CustomPaint(
              painter: _SimpleChartPainter(),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Ilustrasi tren — belum menggunakan data skrining sebenarnya.',
            style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildAktivitasTerbaruCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: Color(0xFF2563EB),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _ActivityItem(
            name: 'Siti Aisyah',
            action: 'Melakukan skrining diet',
            time: 'Baru saja',
            female: true,
          ),
          Divider(height: 24, color: Color(0xFFF1F5F9)),
          _ActivityItem(
            name: 'Rina Marlina',
            action: 'Membaca artikel',
            time: '10 menit lalu',
            female: true,
          ),
          Divider(height: 24, color: Color(0xFFF1F5F9)),
          _ActivityItem(
            name: 'Bimo Setiawan',
            action: 'Konsultasi',
            time: '1 jam lalu',
            female: false,
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String name;
  final String action;
  final String time;
  final bool female;

  const _ActivityItem({
    required this.name,
    required this.action,
    required this.time,
    required this.female,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Icon(
            female ? Icons.face_3_rounded : Icons.face_rounded,
            color: const Color(0xFF2563EB),
            size: 20,
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
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                action,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            time,
            style: const TextStyle(
              fontSize: 10,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _SimpleChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.7;

    final linePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF2563EB).withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = <Offset>[
      Offset(size.width * 0.03, size.height * 0.75),
      Offset(size.width * 0.18, size.height * 0.60),
      Offset(size.width * 0.34, size.height * 0.68),
      Offset(size.width * 0.50, size.height * 0.38),
      Offset(size.width * 0.66, size.height * 0.52),
      Offset(size.width * 0.82, size.height * 0.28),
      Offset(size.width * 0.97, size.height * 0.16),
    ];

    final path = Path()..moveTo(points.first.dx, points.first.dy);

    for (int i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height)
      ..lineTo(points.first.dx, size.height)
      ..close();

    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(path, linePaint);

    final dotPaint = Paint()..color = const Color(0xFF2563EB);

    for (final point in points) {
      canvas.drawCircle(point, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleChartPainter oldDelegate) => false;
}