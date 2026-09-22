import 'package:flutter/material.dart';

class HasilSkriningPage extends StatefulWidget {
  final String nama;
  final String umur;
  final String jenisKelamin;
  final bool isPositif;
  final List<Map<String, String>> tableData;

  const HasilSkriningPage({
    super.key,
    this.nama = 'Aurelia Prisilla',
    this.umur = '22',
    this.jenisKelamin = 'Perempuan',
    this.isPositif = true,
    this.tableData = const [
      {'q': 'Apakah Anda sering merasa haus berlebihan?', 'a': 'Ya'},
      {'q': 'Apakah Anda sering buang air kecil di malam hari?', 'a': 'Ya'},
      {'q': 'Apakah ada riwayat diabetes di keluarga?', 'a': 'Tidak'},
    ],
  });

  @override
  State<HasilSkriningPage> createState() => _HasilSkriningPageState();
}

class _HasilSkriningPageState extends State<HasilSkriningPage> {
  void _navigateToProsesKirim() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProsesKirimEmailPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final String jamSkrining =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final String tanggalSkrining =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    final Color statusColor =
    widget.isPositif ? const Color(0xFFFFA8A8) : const Color(0xFFA8FFA8);
    final Color textColor =
    widget.isPositif ? Colors.red.shade900 : Colors.green.shade900;
    final String statusText = widget.isPositif ? 'Positif' : 'Negatif';
    final String ringkasanText = widget.isPositif
        ? 'Berdasarkan hasil skrining, Anda memiliki kemungkinan tinggi mengalami diabetes. Kami menyarankan untuk melakukan pemeriksaan lebih lanjut di fasilitas kesehatan.'
        : 'Berdasarkan hasil skrining, Anda memiliki kemungkinan rendah mengalami diabetes. Tetap jaga pola makan dan gaya hidup sehat.';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Text(
              'Hasil Skrining',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black87, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/logo.png',
                                height: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.favorite,
                                    color: Color(0xFF6679F4), size: 40),
                              ),
                              const SizedBox(width: 8),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Diora',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6679F4),
                                    ),
                                  ),
                                  Text(
                                    'Kenali Risiko, Jaga Masa Depanmu',
                                    style: TextStyle(
                                        fontSize: 8, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            height: 50,
                            width: 1,
                            color: Colors.grey.shade400,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hasil Skrining Diabetes',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text('Hasil : $statusText',
                                  style: const TextStyle(fontSize: 12)),
                              Text('Pukul Skrining : $jamSkrining',
                                  style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.black87, thickness: 1),
                      const SizedBox(height: 8),
                      const Center(
                        child: Text(
                          'Laporan Hasil Skrining Diabetes',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              title: 'Data Pengguna',
                              content: [
                                'Nama : ${widget.nama}',
                                'Usia : ${widget.umur} Tahun',
                                'Jenis Kelamin : ${widget.jenisKelamin}',
                                'Tanggal Skrining : $tanggalSkrining',
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              title: 'Ringkasan Hasil',
                              bodyText: ringkasanText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Hasil Skrining',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildQuestionsTable(widget.tableData),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Hasil Skrining : $statusText',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Rekomendasi',
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (widget.isPositif) ...const [
                        Text('• Cek kadar gula darah puasa',
                            style: TextStyle(fontSize: 11)),
                        Text('• Cek gula darah 2 jam setelah makan',
                            style: TextStyle(fontSize: 11)),
                        Text('• HbA1c (jika diperlukan)',
                            style: TextStyle(fontSize: 11)),
                        Text(
                            '• Konsultasi dengan dokter spesialis penyakit dalam / endokrin',
                            style: TextStyle(fontSize: 11)),
                      ] else ...const [
                        Text('• Pertahankan pola makan gizi seimbang',
                            style: TextStyle(fontSize: 11)),
                        Text('• Rutin melakukan aktivitas fisik/olahraga',
                            style: TextStyle(fontSize: 11)),
                        Text('• Melakukan tes gula darah secara berkala',
                            style: TextStyle(fontSize: 11)),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEEFE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF6679F4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.info,
                                  color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Penting',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Hasil skrining ini bukan pemeriksaan medis resmi. Untuk penegakan diagnosis yang akurat, harap berkonsultasi ke fasilitas kesehatan.',
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.black87),
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
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6679F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _navigateToProsesKirim,
                  child: const Text(
                    'Unduh Hasil Skrining',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    List<String>? content,
    String? bodyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          if (content != null)
            ...content.map(
                  (text) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(text,
                    style:
                    const TextStyle(fontSize: 9, color: Colors.black87)),
              ),
            ),
          if (bodyText != null)
            Text(
              bodyText,
              style: const TextStyle(
                  fontSize: 9.5, color: Colors.black87, height: 1.3),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionsTable(List<Map<String, String>> data) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(1),
          },
          border: TableBorder(
            horizontalInside:
            BorderSide(color: Colors.grey.shade300, width: 0.5),
            verticalInside: const BorderSide(color: Colors.black87, width: 1),
            top: const BorderSide(color: Colors.black87, width: 1),
            bottom: const BorderSide(color: Colors.black87, width: 1),
          ),
          children: [
            const TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Text(
                    'Pertanyaan',
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Text(
                    'Jawab',
                    textAlign: TextAlign.center,
                    style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            ...data.map(
                  (item) => TableRow(
                children: [
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    child: Text(
                      item['q'] ?? '',
                      style: const TextStyle(fontSize: 8.5),
                    ),
                  ),
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    child: Text(
                      item['a'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 8.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// HALAMAN PROSES & SUCCESS SEND EMAIL (SESUAI GAMBAR HASIL 3 & HASIL 4)
// -------------------------------------------------------------
class ProsesKirimEmailPage extends StatefulWidget {
  const ProsesKirimEmailPage({super.key});

  @override
  State<ProsesKirimEmailPage> createState() => _ProsesKirimEmailPageState();
}

class _ProsesKirimEmailPageState extends State<ProsesKirimEmailPage> {
  bool _isFinished = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _startSimulatedSending();
  }

  void _startSimulatedSending() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) setState(() => _progress = 0.5);
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _progress = 1.0);
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isFinished = true);
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: _isFinished ? _buildSuccessView() : _buildProgressView(),
        ),
      ),
    );
  }

  // Tampilan 1: Mengirim Email (HASIL 3)
  Widget _buildProgressView() {
    return Column(
      children: [
        const Spacer(flex: 2),

        // Ilustrasi Amplop Mengirim
        Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0FE),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.mark_email_read_outlined,
                  size: 90,
                  color: Color(0xFF4285F4),
                ),
                Positioned(
                  top: 35,
                  right: 35,
                  child: Transform.rotate(
                    angle: -0.2,
                    child: const Icon(
                      Icons.send_rounded,
                      size: 40,
                      color: Color(0xFF6679F4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),

        const Text(
          'Mengirim Email',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),

        const Text(
          'Mohon tunggu sebentar, kami sedang\nmengirimkan hasil skrining Anda ke\nemail yang telah terdaftar.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),

        const Spacer(flex: 3),

        // Progress Bar
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: 8,
            backgroundColor: const Color(0xFFE5E7EB),
            color: const Color(0xFF6679F4),
          ),
        ),
        const SizedBox(height: 8),

        Text(
          '${(_progress * 100).toInt()}%',
          style: const TextStyle(
            fontSize: 13,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  // Tampilan 2: Berhasil Dikirim! (HASIL 4)
  Widget _buildSuccessView() {
    return Column(
      children: [
        const Spacer(flex: 2),

        // Ilustrasi Amplop Berhasil / Check
        Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0FE),
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(
                  Icons.mark_email_unread_rounded,
                  size: 90,
                  color: Color(0xFF4285F4),
                ),
                Positioned(
                  bottom: 25,
                  right: 25,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      size: 44,
                      color: Color(0xFF22C55E),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 36),

        const Text(
          'Berhasil Dikirim!',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 12),

        const Text(
          'Hasil skrining Anda telah berhasil\ndikirak ke email Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),

        const Spacer(flex: 3),

        // Tombol Kembali Ke Beranda
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6679F4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
            child: const Text(
              'Kembali Ke Beranda',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}