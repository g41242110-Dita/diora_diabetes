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
  bool isExpanded = true; // Default terbuka agar langsung terlihat jelas
  int? _expandedPastWeekIndex;

  final List<String> _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  // Menghitung rentang tanggal Senin s/d Minggu untuk minggu ke-N (0 = minggu ini, 1 = minggu lalu, dst.)
  String _getRentangMinggu(int weeksAgo) {
    DateTime now = DateTime.now().subtract(Duration(days: weeksAgo * 7));
    DateTime senin = now.subtract(Duration(days: now.weekday - 1));
    DateTime minggu = senin.add(const Duration(days: 6));

    String tglAwal = senin.day.toString();
    String tglAkhir = minggu.day.toString();
    String bulanAkhir = _namaBulan[minggu.month - 1];

    if (senin.month != minggu.month) {
      String bulanAwal = _namaBulan[senin.month - 1];
      return '$tglAwal $bulanAwal - $tglAkhir $bulanAkhir';
    }
    return '$tglAwal-$tglAkhir $bulanAkhir';
  }

  int _hitungTotalMingguIni() {
    int total = 0;
    for (bool done in widget.isCompletedToday) {
      if (done) total++;
    }
    return total;
  }

  String _getEvaluasiMingguan(int totalSelesai) {
    if (totalSelesai == 0) {
      return 'Belum ada target yang ditandai minggu ini. Cobalah selesaikan minimal 2 kebiasaan sehat hari ini untuk menjaga kestabilan gula darah.';
    } else if (totalSelesai <= 2) {
      return 'Langkah awal yang baik! Pertahankan rutinitas harianmu dan tingkatkan konsistensi hingga minimal 5 hari dalam seminggu.';
    } else {
      return 'Performa mingguanmu sangat baik! Kebiasaan sehat seperti jalan kaki dan membatasi gula membantu menjaga sensitivitas insulin.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalSelesai = _hitungTotalMingguIni();
    final int persentaseMingguan = ((totalSelesai / 28) * 100).round();
    final int todayWeekday = DateTime.now().weekday; // 1 = Senin .. 7 = Minggu

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Column(
        children: [
          // HEADER GRADIENT BIRU-UNGU
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50, left: 16, right: 20, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6679F4), Color(0xFF8DA0FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Riwayat Mingguan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 12),

                // KARTU RINGKASAN SKOR KONSISTENSI
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderStat(
                        label: 'Target Tercapai',
                        value: '$totalSelesai / 28',
                        icon: Icons.check_circle_outline_rounded,
                      ),
                      Container(
                        height: 36,
                        width: 1,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                      _buildHeaderStat(
                        label: 'Konsistensi',
                        value: '$persentaseMingguan%',
                        icon: Icons.trending_up_rounded,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // KONTEN SCROLLABLE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // GRAFIK BATANG AKTIVITAS 7 HARI (SENIN - MINGGU)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
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
                            const Text(
                              'Grafik Pencapaian Harian',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Maks. 4/hari',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6679F4),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBarItem('Sen', 1, todayWeekday == 1 ? totalSelesai : 0, todayWeekday == 1),
                            _buildBarItem('Sel', 2, todayWeekday == 2 ? totalSelesai : 0, todayWeekday == 2),
                            _buildBarItem('Rab', 3, todayWeekday == 3 ? totalSelesai : 0, todayWeekday == 3),
                            _buildBarItem('Kam', 4, todayWeekday == 4 ? totalSelesai : 0, todayWeekday == 4),
                            _buildBarItem('Jum', 5, todayWeekday == 5 ? totalSelesai : 0, todayWeekday == 5),
                            _buildBarItem('Sab', 6, todayWeekday == 6 ? totalSelesai : 0, todayWeekday == 6),
                            _buildBarItem('Min', 7, todayWeekday == 7 ? totalSelesai : 0, todayWeekday == 7),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Detail Rincian Mingguan',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // DROPDOWN RINGKASAN MINGGU INI
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFF6679F4).withValues(alpha: 0.35)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.calendar_today_rounded, size: 18, color: Color(0xFF6679F4)),
                          ),
                          title: Row(
                            children: [
                              const Text(
                                'Minggu Ini',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _getRentangMinggu(0),
                                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          trailing: Icon(
                            isExpanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: const Color(0xFF6679F4),
                          ),
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded;
                            });
                          },
                        ),

                        if (isExpanded) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                _buildRingkasanItem(
                                  icon: Icons.directions_walk_rounded,
                                  title: 'Jalan Kaki 30 Menit',
                                  count: widget.isCompletedToday[0] ? 1 : 0,
                                ),
                                const SizedBox(height: 14),
                                _buildRingkasanItem(
                                  icon: Icons.no_drinks_rounded,
                                  title: 'Kurangi Minuman Manis',
                                  count: widget.isCompletedToday[1] ? 1 : 0,
                                ),
                                const SizedBox(height: 14),
                                _buildRingkasanItem(
                                  icon: Icons.bedtime_rounded,
                                  title: 'Tidur Cukup 7 Jam',
                                  count: widget.isCompletedToday[2] ? 1 : 0,
                                ),
                                const SizedBox(height: 14),
                                _buildRingkasanItem(
                                  icon: Icons.restaurant_rounded,
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
                  const SizedBox(height: 12),

                  // KARTU RIWAYAT MINGGU SEBELUMNYA (AGAR TIDAK KOSONG)
                  _buildPastWeekCard(
                    index: 1,
                    label: 'Minggu Lalu',
                    dateRange: _getRentangMinggu(1),
                  ),
                  const SizedBox(height: 12),
                  _buildPastWeekCard(
                    index: 2,
                    label: '2 Minggu Lalu',
                    dateRange: _getRentangMinggu(2),
                  ),
                  const SizedBox(height: 18),

                  // KARTU EVALUASI & SARAN MEDIS MINGGUAN
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.health_and_safety_rounded, color: Color(0xFF4F46E5), size: 24),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Evaluasi Pola Hidup Minggu Ini',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Color(0xFF1E1B4B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getEvaluasiMingguan(totalSelesai),
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF3730A3),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBarItem(String dayLabel, int dayNum, int count, bool isToday) {
    const double maxBarHeight = 76.0;
    final double barHeight = count == 0 ? 10.0 : (count / 4.0) * maxBarHeight;

    return Column(
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.bold,
            color: isToday ? const Color(0xFF6679F4) : const Color(0xFF94A3B8),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 22,
          height: barHeight,
          decoration: BoxDecoration(
            color: count > 0
                ? const Color(0xFF6679F4)
                : (isToday ? const Color(0xFFDbe4FF) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(8),
            border: isToday && count == 0
                ? Border.all(color: const Color(0xFF6679F4), width: 1.2)
                : null,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          dayLabel,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            color: isToday ? const Color(0xFF0F172A) : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildPastWeekCard({
    required int index,
    required String label,
    required String dateRange,
  }) {
    final bool opened = _expandedPastWeekIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.history_rounded, size: 18, color: Color(0xFF64748B)),
            ),
            title: Row(
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: Color(0xFF334155),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    dateRange,
                    style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: Icon(
              opened ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: const Color(0xFF64748B),
            ),
            onTap: () {
              setState(() {
                _expandedPastWeekIndex = opened ? null : index;
              });
            },
          ),
          if (opened) ...[
            const Divider(height: 1),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 18, color: Color(0xFF94A3B8)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Tidak ada catatan aktivitas yang tersimpan pada periode minggu ini.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
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
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFEEF2FF),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF6679F4)),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6679F4)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '$count/7',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}