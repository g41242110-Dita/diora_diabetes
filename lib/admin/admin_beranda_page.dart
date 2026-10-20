import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
    final snapshot =
    await FirebaseFirestore.instance.collection('users').get();

    return snapshot.docs.where((doc) {
      final data = doc.data();
      final role =
      (data['role'] ?? 'pengguna').toString().trim().toLowerCase();

      return role != 'admin';
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
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
        ],
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
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, Admin 👋',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Berikut ringkasan data pengguna dan aktivitas pada sistem Diora.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12),
          Icon(
            Icons.admin_panel_settings_rounded,
            size: 64,
            color: Color(0xFF5B71F5),
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
              child: FutureBuilder<int>(
                future: _totalPengguna,
                builder: (context, snapshot) {
                  final total = snapshot.data;
                  return _buildStatCard(
                    icon: Icons.group_rounded,
                    label: 'Total Pengguna',
                    value: snapshot.hasError
                        ? '-'
                        : total?.toString() ?? '...',
                    iconBgColor: const Color(0xFFE2E8FF),
                    iconColor: const Color(0xFF4C63E6),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.auto_awesome_rounded,
                label: 'Total Skrining',
                value: '968',
                iconBgColor: const Color(0xFFE2E8FF),
                iconColor: const Color(0xFF4C63E6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.error_rounded,
                label: 'Skrining Positif',
                value: '186',
                iconBgColor: const Color(0xFFFFE5E5),
                iconColor: Colors.redAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.article_rounded,
                label: 'Total Artikel',
                value: '58',
                iconBgColor: const Color(0xFFE2E8FF),
                iconColor: const Color(0xFF4C63E6),
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
    required Color iconBgColor,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 23),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
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
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.show_chart_rounded,
                color: Color(0xFF4C63E6),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Trend Skrining Diabetes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
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
              color: const Color(0xFFF3F5FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomPaint(
              painter: _SimpleChartPainter(),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ilustrasi tren — belum menggunakan data skrining sebenarnya.',
            style: TextStyle(fontSize: 11, color: Colors.black54),
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
        border: Border.all(color: Colors.black12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.access_time_rounded,
                color: Color(0xFF4C63E6),
              ),
              SizedBox(width: 8),
              Text(
                'Aktivitas Terbaru',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          _ActivityItem(
            name: 'Siti Aisyah',
            action: 'Melakukan skrining diet',
            time: 'Contoh aktivitas',
            female: true,
          ),
          Divider(height: 24),
          _ActivityItem(
            name: 'Rina Marlina',
            action: 'Membaca artikel',
            time: 'Contoh aktivitas',
            female: true,
          ),
          Divider(height: 24),
          _ActivityItem(
            name: 'Bimo Setiawan',
            action: 'Konsultasi',
            time: 'Contoh aktivitas',
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
        CircleAvatar(
          backgroundColor: const Color(0xFFDCE4FF),
          child: Icon(
            female ? Icons.face_3_rounded : Icons.face_rounded,
            color: const Color(0xFF4C63E6),
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
                ),
              ),
              const SizedBox(height: 3),
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
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            time,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 10,
              color: Colors.black45,
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
      ..color = Colors.black12
      ..strokeWidth = 0.7;

    final linePaint = Paint()
      ..color = const Color(0xFF4C63E6)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = const Color(0xFF4C63E6).withValues(alpha: 0.10)
      ..style = PaintingStyle.fill;

    for (int i = 1; i <= 3; i++) {
      final y = size.height * i / 4;
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

    final dotPaint = Paint()..color = const Color(0xFF4C63E6);

    for (final point in points) {
      canvas.drawCircle(point, 3.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SimpleChartPainter oldDelegate) => false;
}