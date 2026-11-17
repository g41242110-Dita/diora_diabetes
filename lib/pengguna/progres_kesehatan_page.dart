import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'riwayat_mingguan_page.dart';

class ProgresKesehatanPage extends StatefulWidget {
  final String username;

  const ProgresKesehatanPage({
    super.key,
    required this.username,
  });

  @override
  State<ProgresKesehatanPage> createState() => _ProgresKesehatanPageState();
}

class _ProgresKesehatanPageState extends State<ProgresKesehatanPage> {
  bool _jalanKakiSelesai = false;
  bool _kurangiManisSelesai = false;
  bool _tidurCukupSelesai = false;
  bool _makanSayurSelesai = false;

  // Data catatan gula darah harian
  int? _gulaDarahHariIni;
  String _waktuCekGula = 'Puasa';

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

  @override
  void didUpdateWidget(covariant ProgresKesehatanPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.username != widget.username) {
      _loadDataProgres();
    }
  }

  String _getKey(String item) => '${widget.username}_$item';

  Future<void> _loadDataProgres() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _jalanKakiSelesai = prefs.getBool(_getKey('jalan_kaki')) ?? false;
      _kurangiManisSelesai = prefs.getBool(_getKey('kurangi_manis')) ?? false;
      _tidurCukupSelesai = prefs.getBool(_getKey('tidur_cukup')) ?? false;
      _makanSayurSelesai = prefs.getBool(_getKey('makan_sayur')) ?? false;

      final savedGula = prefs.getInt(_getKey('gula_darah'));
      _gulaDarahHariIni = (savedGula != null && savedGula > 0) ? savedGula : null;
      _waktuCekGula = prefs.getString(_getKey('waktu_cek_gula')) ?? 'Puasa';
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

  Future<void> _simpanGulaDarah(int nilai, String waktuCek) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_getKey('gula_darah'), nilai);
    await prefs.setString(_getKey('waktu_cek_gula'), waktuCek);
    setState(() {
      _gulaDarahHariIni = nilai;
      _waktuCekGula = waktuCek;
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

  String _getPesanMotivasi(int total) {
    if (total == 0) return 'Mulai 1 langkah sehat pertamamu hari ini!';
    if (total == 1) return 'Awal yang bagus! Teruskan kebiasaan baikmu.';
    if (total == 2) return 'Setengah jalan tercapai, tetap konsisten!';
    if (total == 3) return 'Tinggal 1 target lagi untuk hari yang sempurna!';
    return 'Luar biasa! Semua target sehat hari ini tercapai 🎉';
  }

  Map<String, dynamic> _getStatusGulaDarah(int nilai, String waktu) {
    if (waktu == 'Puasa') {
      if (nilai < 100) {
        return {'label': 'Normal', 'color': const Color(0xFF16A34A), 'bg': const Color(0xFFDCFCE7)};
      } else if (nilai <= 125) {
        return {'label': 'Prediabetes / Waspada', 'color': const Color(0xFFD97706), 'bg': const Color(0xFFFEF3C7)};
      } else {
        return {'label': 'Tinggi', 'color': const Color(0xFFDC2626), 'bg': const Color(0xFFFEE2E2)};
      }
    } else {
      // Sewaktu / 2 Jam Setelah Makan
      if (nilai < 140) {
        return {'label': 'Normal', 'color': const Color(0xFF16A34A), 'bg': const Color(0xFFDCFCE7)};
      } else if (nilai <= 199) {
        return {'label': 'Waspada', 'color': const Color(0xFFD97706), 'bg': const Color(0xFFFEF3C7)};
      } else {
        return {'label': 'Tinggi', 'color': const Color(0xFFDC2626), 'bg': const Color(0xFFFEE2E2)};
      }
    }
  }

  void _tampilkanDialogInputGulaDarah() {
    final TextEditingController gulaController = TextEditingController(
      text: _gulaDarahHariIni != null ? _gulaDarahHariIni.toString() : '',
    );
    String selectedWaktu = _waktuCekGula;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Catat Gula Darah',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Waktu Pengukuran:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Puasa', 'Sewaktu', '2 Jam PP'].map((waktu) {
                      final isSelected = selectedWaktu == waktu;
                      return ChoiceChip(
                        label: Text(
                          waktu,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF475569),
                          ),
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF6679F4),
                        backgroundColor: const Color(0xFFF1F5F9),
                        onSelected: (_) {
                          setDialogState(() => selectedWaktu = waktu);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: gulaController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Kadar Gula Darah (mg/dL)',
                      hintText: 'Contoh: 98',
                      suffixText: 'mg/dL',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Batal', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6679F4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    final parsed = int.tryParse(gulaController.text.trim());
                    if (parsed != null && parsed > 20 && parsed < 900) {
                      _simpanGulaDarah(parsed, selectedWaktu);
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Simpan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
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
    double progressValue = totalSelesai / 4.0;
    int persenSelesai = (progressValue * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Column(
        children: [
          // HEADER GRADIENT BIRU-UNGU SENADA DENGAN BERANDA
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Navigasi Atas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Text(
                      'Progres Kesehatan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Riwayat Mingguan',
                      icon: const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 24),
                      onPressed: () => _navigateToRiwayatMingguan(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Kartu Ringkasan Progres Harian + Circular Progress
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 64,
                        height: 64,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: progressValue,
                              strokeWidth: 7,
                              backgroundColor: Colors.white.withValues(alpha: 0.25),
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                            Center(
                              child: Text(
                                '$persenSelesai%',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$totalSelesai dari 4 Target Selesai',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _getTanggalHariIni(),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _getPesanMotivasi(totalSelesai),
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Colors.white,
                                height: 1.3,
                              ),
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

          // KONTEN SCROLLABLE
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // KARTU CATATAN GULA DARAH HARIAN
                  _buildGulaDarahCard(),
                  const SizedBox(height: 20),

                  const Text(
                    'Target Kebiasaan Sehat Harian',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildTargetCard(
                    iconData: Icons.directions_walk_rounded,
                    title: 'Jalan Kaki 30 Menit',
                    subtitle: 'Meningkatkan sensitivitas insulin & menstabilkan gula darah',
                    countText: _jalanKakiSelesai ? '1/7 hari' : '0/7 hari',
                    isDone: _jalanKakiSelesai,
                    onTap: () => _toggleStatus('jalan_kaki', _jalanKakiSelesai),
                  ),
                  const SizedBox(height: 14),

                  _buildTargetCard(
                    iconData: Icons.no_drinks_rounded,
                    title: 'Kurangi Minuman Manis',
                    subtitle: 'Mencegah lonjakan glukosa darah secara drastis',
                    countText: _kurangiManisSelesai ? '1/7 hari' : '0/7 hari',
                    isDone: _kurangiManisSelesai,
                    onTap: () => _toggleStatus('kurangi_manis', _kurangiManisSelesai),
                  ),
                  const SizedBox(height: 14),

                  _buildTargetCard(
                    iconData: Icons.bedtime_rounded,
                    title: 'Tidur Cukup 7 Jam',
                    subtitle: 'Menjaga keseimbangan hormon metabolisme tubuh',
                    countText: _tidurCukupSelesai ? '1/7 hari' : '0/7 hari',
                    isDone: _tidurCukupSelesai,
                    onTap: () => _toggleStatus('tidur_cukup', _tidurCukupSelesai),
                  ),
                  const SizedBox(height: 14),

                  _buildTargetCard(
                    iconData: Icons.restaurant_rounded,
                    title: 'Makan Sayur 3x Sehari',
                    subtitle: 'Serat memperlambat penyerapan gula ke dalam darah',
                    countText: _makanSayurSelesai ? '1/7 hari' : '0/7 hari',
                    isDone: _makanSayurSelesai,
                    onTap: () => _toggleStatus('makan_sayur', _makanSayurSelesai),
                  ),
                  const SizedBox(height: 18),

                  // KARTU TIPS EDUKASI SINGKAT
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF8E1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFFFECB3)),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.lightbulb_rounded, color: Color(0xFFF59E0B), size: 22),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tahukah Kamu?',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Berjalan kaki santai 10–15 menit setelah makan membantu otot menyerap glukosa lebih cepat.',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF78350F),
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // TOMBOL KE RIWAYAT MINGGUAN
                  InkWell(
                    onTap: () => _navigateToRiwayatMingguan(context),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.calendar_month_rounded, size: 20, color: Color(0xFF6679F4)),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Riwayat & Evaluasi Mingguan',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  'Lihat rekap pencapaian 7 hari terakhir',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Color(0xFF64748B)),
                        ],
                      ),
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

  Widget _buildGulaDarahCard() {
    final statusInfo = _gulaDarahHariIni != null
        ? _getStatusGulaDarah(_gulaDarahHariIni!, _waktuCekGula)
        : null;

    return Container(
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.water_drop_rounded, color: Color(0xFFEF4444), size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan Gula Darah',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                if (_gulaDarahHariIni == null)
                  const Text(
                    'Belum ada catatan kadar gula hari ini',
                    style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                  )
                else
                  Row(
                    children: [
                      Text(
                        '$_gulaDarahHariIni mg/dL',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '($_waktuCekGula)',
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusInfo!['bg'],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusInfo['label'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusInfo['color'],
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEEF2FF),
              foregroundColor: const Color(0xFF6679F4),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _tampilkanDialogInputGulaDarah,
            child: Text(
              _gulaDarahHariIni == null ? '+ Catat' : 'Ubah',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetCard({
    required IconData iconData,
    required String title,
    required String subtitle,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDone ? const Color(0xFFDCFCE7) : const Color(0xFFE2E7FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: isDone ? const Color(0xFF16A34A) : const Color(0xFF6679F4),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  countText,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF475569),
                  ),
                ),
              ),
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
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isDone ? const Color(0xFF22C55E) : const Color(0xFF6679F4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              onPressed: onTap,
              icon: Icon(isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded, color: Colors.white, size: 18),
              label: Text(
                isDone ? 'Selesai Hari Ini' : 'Tandai Selesai Hari Ini',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
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
            color: isToday ? const Color(0xFF0F172A) : Colors.grey,
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
                ? const Color(0xFF6679F4)
                : (isToday ? const Color(0xFFEEF2FF) : Colors.grey.shade100),
            border: Border.all(
              color: isDone
                  ? const Color(0xFF6679F4)
                  : (isToday ? const Color(0xFF6679F4) : Colors.grey.shade300),
              width: 1.5,
            ),
          ),
          child: isDone ? const Icon(Icons.check, color: Colors.white, size: 16) : null,
        ),
      ],
    );
  }
}