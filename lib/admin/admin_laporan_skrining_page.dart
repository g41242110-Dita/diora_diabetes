import 'package:flutter/material.dart';

class AdminLaporanSkriningPage extends StatefulWidget {
  const AdminLaporanSkriningPage({Key? key}) : super(key: key);

  @override
  State<AdminLaporanSkriningPage> createState() => _AdminLaporanSkriningPageState();
}

class _AdminLaporanSkriningPageState extends State<AdminLaporanSkriningPage> {
  String selectedMonth = 'Agustus';
  String selectedYear = '2026';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Laporan Skrining', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Filter Bulan & Tahun
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Bulan', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedMonth,
                          items: ['Agustus', 'September', 'Oktober'].map((month) {
                            return DropdownMenuItem(value: month, child: Text(month));
                          }).toList(),
                          onChanged: (val) => setState(() => selectedMonth = val!),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Tahun', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedYear,
                          items: ['2025', '2026'].map((year) {
                            return DropdownMenuItem(value: year, child: Text(year));
                          }).toList(),
                          onChanged: (val) => setState(() => selectedYear = val!),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card Total Skrining
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.groups, size: 40, color: Colors.blueAccent),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Skrining', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600)),
                        Text('968', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Row Negatif & Positif
            Row(
              children: [
                Expanded(
                  child: Card(
                    color: Colors.green.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Negatif', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                              Text('782', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Card(
                    color: Colors.red.shade50,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 30),
                          SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Positif', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                              Text('186', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Card Chart Trend Sederhana
            Expanded(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.show_chart, color: Colors.blueAccent),
                          SizedBox(width: 8),
                          Text('Trend Skrining Diabetes', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(8),
                          child: CustomPaint(
                            painter: TrendChartPainter(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Custom Painter Sederhana yang sudah diperbaiki
class TrendChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paintLine = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final paintFill = Paint()
      ..color = Colors.blueAccent.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.cubicTo(
      size.width * 0.25, size.height * 0.4,
      size.width * 0.5, size.height * 0.6,
      size.width * 0.75, size.height * 0.3,
    );
    path.lineTo(size.width, size.height * 0.1);

    final fillPath = Path.from(path)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(fillPath, paintFill);
    canvas.drawPath(path, paintLine);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}