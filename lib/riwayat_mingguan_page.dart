import 'package:flutter/material.dart';

class RiwayatMingguanPage extends StatefulWidget {
  final List<bool> isCompletedToday;

  const RiwayatMingguanPage({
    super.key,
    required this.isCompletedToday,
  });

  @override
  State<RiwayatMingguanPage> createState() => _RiwayatMingguanPageState();
}

class _RiwayatMingguanPageState extends State<RiwayatMingguanPage> {
  bool isExpanded = false;

  final List<String> _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  // Fungsi untuk otomatis menghitung tanggal Senin s/d Minggu minggu ini
  String _getRentangMingguIni() {
    DateTime now = DateTime.now();
    // Menghitung hari Senin di minggu ini
    DateTime senin = now.subtract(Duration(days: now.weekday - 1));
    // Menghitung hari Minggu di minggu ini
    DateTime minggu = senin.add(const Duration(days: 6));

    String tglAwal = senin.day.toString();
    String tglAkhir = minggu.day.toString();
    String bulan = _namaBulan[minggu.month - 1];

    return '$tglAwal-$tglAkhir $bulan';
  }

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
        title: const Text(
          'Riwayat Mingguan',
          style: TextStyle(
            color: Color(0xFF3B82F6),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Dropdown Ringkasan Mingguan
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        const Text(
                          'Minggu Ini',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _getRentangMingguIni(), // Tanggal otomatis dinamis
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                    trailing: Icon(
                      isExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: Colors.black,
                    ),
                    onTap: () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    },
                  ),

                  // Isi Ringkasan saat Dimekarkan
                  if (isExpanded) ...[
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildRingkasanItem(
                            icon: Icons.directions_walk,
                            title: 'Jalan Kaki 30 Menit',
                            count: widget.isCompletedToday[0] ? 1 : 0,
                          ),
                          const SizedBox(height: 12),
                          _buildRingkasanItem(
                            icon: Icons.block,
                            title: 'Kurangi Minuman Manis',
                            count: widget.isCompletedToday[1] ? 1 : 0,
                          ),
                          const SizedBox(height: 12),
                          _buildRingkasanItem(
                            icon: Icons.nightlight_round,
                            title: 'Tidur Cukup 7 Jam',
                            count: widget.isCompletedToday[2] ? 1 : 0,
                          ),
                          const SizedBox(height: 12),
                          _buildRingkasanItem(
                            icon: Icons.rice_bowl,
                            title: 'Makan Sayur 3x Sehari',
                            count: widget.isCompletedToday[3] ? 1 : 0,
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanItem({
    required IconData icon,
    required String title,
    required int count,
  }) {
    double progress = count / 7;

    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor:
              const AlwaysStoppedAnimation<Color>(Color(0xFF5D83EC)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$count/7',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}