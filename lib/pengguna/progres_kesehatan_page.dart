import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'riwayat_mingguan_page.dart';

class ProgresKesehatanPage extends StatefulWidget {
  final String username;

  const ProgresKesehatanPage({
    super.key,
    required this.username, // Mewajibkan parameter username dikirim
  });

  @override
  State<ProgresKesehatanPage> createState() => _ProgresKesehatanPageState();
}

class _ProgresKesehatanPageState extends State<ProgresKesehatanPage> {
  bool _jalanKakiSelesai = false;
  bool _kurangiManisSelesai = false;
  bool _tidurCukupSelesai = false;
  bool _makanSayurSelesai = false;

  final List<String> _namaBulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final List<String> _namaHari = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
  ];

  @override
  void initState() {
    super.initState();
    _loadDataProgres();
  }

  // Jika username berubah saat runtime, muat ulang data milik akun baru
  @override
  void didUpdateWidget(covariant ProgresKesehatanPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username) {
      _loadDataProgres();
    }
  }

  // Key penyimpanan unik per akun
  String _getKey(String item) => '${widget.username}_$item';

  Future<void> _loadDataProgres() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jalanKakiSelesai = prefs.getBool(_getKey('jalan_kaki')) ?? false;
      _kurangiManisSelesai = prefs.getBool(_getKey('kurangi_manis')) ?? false;
      _tidurCukupSelesai = prefs.getBool(_getKey('tidur_cukup')) ?? false;
      _makanSayurSelesai = prefs.getBool(_getKey('makan_sayur')) ?? false;
    });
  }

  Future<void> _toggleStatus(String itemKey, bool currentValue) async {
    final prefs = await SharedPreferences.getInstance();
    bool newValue = !currentValue;
    await prefs.setBool(_getKey(itemKey), newValue);

    setState(() {
      if (itemKey == 'jalan_kaki') _jalanKakiSelesai = newValue;
      if (itemKey == 'kurangi_manis') _kurangiManisSelesai = newValue;
      if (itemKey == 'tidur_cukup') _tidurCukupSelesai = newValue;
      if (itemKey == 'makan_sayur') _makanSayurSelesai = newValue;
    });
  }

  int _hitungTotalTargetSelesai() {
    int total = 0;
    if (_jalanKakiSelesai) total++;
    if (_kurangiManisSelesai) total++;
    if (_tidurCukupSelesai) total++;
    if (_makanSayurSelesai) total++;
    return total;
  }

  String _getTanggalHariIni() {
    DateTime now = DateTime.now();
    String hari = _namaHari[now.weekday - 1];
    String tgl = now.day.toString().padLeft(2, '0');
    String bulan = _namaBulan[now.month - 1];

    return '$hari, $tgl $bulan';
  }

  void _navigateToRiwayatMingguan(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RiwayatMingguanPage(
          isCompletedToday: [
            _jalanKakiSelesai,
            _kurangiManisSelesai,
            _tidurCukupSelesai,
            _makanSayurSelesai,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalSelesai = _hitungTotalTargetSelesai();

    return Scaffold(
      backgroundColor: const Color(0xFFEBF3FF),
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Progres Kesehatan',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A72E8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalSelesai/4',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A72E8),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Target Selesai Hari Ini ${_getTanggalHariIni()}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4A72E8),
                ),
              ),
              const SizedBox(height: 20),

              _buildTargetCard(
                iconData: Icons.directions_walk,
                title: 'Jalan Kaki 30 Menit',
                countText: _jalanKakiSelesai ? '1/7 hari' : '0/7 hari',
                isDone: _jalanKakiSelesai,
                onTap: () => _toggleStatus('jalan_kaki', _jalanKakiSelesai),
              ),
              const SizedBox(height: 16),

              _buildTargetCard(
                iconData: Icons.no_drinks_outlined,
                title: 'Kurangi Minuman Manis',
                countText: _kurangiManisSelesai ? '1/7 hari' : '0/7 hari',
                isDone: _kurangiManisSelesai,
                onTap: () => _toggleStatus('kurangi_manis', _kurangiManisSelesai),
              ),
              const SizedBox(height: 16),

              _buildTargetCard(
                iconData: Icons.bedtime_outlined,
                title: 'Tidur Cukup 7 Jam',
                countText: _tidurCukupSelesai ? '1/7 hari' : '0/7 hari',
                isDone: _tidurCukupSelesai,
                onTap: () => _toggleStatus('tidur_cukup', _tidurCukupSelesai),
              ),
              const SizedBox(height: 16),

              _buildTargetCard(
                iconData: Icons.restaurant_outlined,
                title: 'Makan Sayur 3x Sehari',
                countText: _makanSayurSelesai ? '1/7 hari' : '0/7 hari',
                isDone: _makanSayurSelesai,
                onTap: () => _toggleStatus('makan_sayur', _makanSayurSelesai),
              ),
              const SizedBox(height: 20),

              InkWell(
                onTap: () => _navigateToRiwayatMingguan(context),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8ECEF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.calendar_month_outlined, size: 20, color: Colors.black87),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Riwayat Mingguan',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_right, color: Colors.black87),
                    ],
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

  Widget _buildTargetCard({
    required IconData iconData,
    required String title,
    required String countText,
    required bool isDone,
    required VoidCallback onTap,
  }) {
    int currentWeekday = DateTime.now().weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: const Color(0xFF6679F4), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              Text(countText, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDayItem('Senin', isDone: currentWeekday == DateTime.monday && isDone, isToday: currentWeekday == DateTime.monday),
              _buildDayItem('Selasa', isDone: currentWeekday == DateTime.tuesday && isDone, isToday: currentWeekday == DateTime.tuesday),
              _buildDayItem('Rabu', isDone: currentWeekday == DateTime.wednesday && isDone, isToday: currentWeekday == DateTime.wednesday),
              _buildDayItem('Kamis', isDone: currentWeekday == DateTime.thursday && isDone, isToday: currentWeekday == DateTime.thursday),
              _buildDayItem('Jumat', isDone: currentWeekday == DateTime.friday && isDone, isToday: currentWeekday == DateTime.friday),
              _buildDayItem('Sabtu', isDone: currentWeekday == DateTime.saturday && isDone, isToday: currentWeekday == DateTime.saturday),
              _buildDayItem('Minggu', isDone: currentWeekday == DateTime.sunday && isDone, isToday: currentWeekday == DateTime.sunday),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? const Color(0xFF72C175) : const Color(0xFF5D83EC),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                elevation: 0,
              ),
              onPressed: onTap,
              icon: Icon(isDone ? Icons.check : null, color: Colors.white, size: 18),
              label: Text(
                isDone ? 'Selesai hari ini' : 'Tandai Selesai Hari Ini',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItem(String day, {required bool isDone, bool isToday = false}) {
    return Column(
      children: [
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            color: isToday ? Colors.black : Colors.grey,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDone
                ? const Color(0xFF5D83EC)
                : (isToday ? Colors.transparent : Colors.grey.shade100),
            border: Border.all(
              color: isDone
                  ? const Color(0xFF5D83EC)
                  : (isToday ? const Color(0xFF5D83EC) : Colors.grey.shade300),
              width: 1.5,
            ),
          ),
          child: isDone ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
        ),
      ],
    );
  }
}