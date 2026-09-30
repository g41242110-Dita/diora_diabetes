import 'package:flutter/material.dart';
import 'beranda_page.dart';

class HasilSkriningPage extends StatefulWidget {
  final String nama;
  final String umur;
  final String jenisKelamin;
  final bool isPositif;
  final List<Map<String, String>> tableData;

  const HasilSkriningPage({
    super.key,
    this.nama = 'Kenny',
    this.umur = '21',
    this.jenisKelamin = 'Perempuan',
    this.isPositif = true,
    this.tableData = const [
      {'q': 'Apakah kamu sering buang air kecil (BAK)?', 'a': 'Iya'},
      {'q': 'Apakah kamu sering merasa haus?', 'a': 'Iya'},
      {'q': 'Apakah berat badan kamu turun secara drastis tanpa sebab yang jelas?', 'a': 'Iya'},
      {'q': 'Apakah kamu sering merasa lemas atau mudah lelah?', 'a': 'Tidak'},
      {'q': 'Apakah kamu sering merasa lapar meskipun sudah makan?', 'a': 'Iya'},
      {'q': 'Apakah kamu sering mengalami infeksi jamur, terutama di area genital?', 'a': 'Tidak'},
      {'q': 'Apakah penglihatan kamu sering terasa kabur?', 'a': 'Iya'},
      {'q': 'Apakah kamu sering mengalami gatal-gatal pada kulit?', 'a': 'Iya'},
      {'q': 'Apakah kamu mudah merasa marah atau mengalami perubahan suasana hati?', 'a': 'Iya'},
      {'q': 'Apakah luka pada tubuh kamu sulit sembuh?', 'a': 'Iya'},
      {'q': 'Apakah kamu pernah mengalami kelemahan pada sebagian tubuh?', 'a': 'Iya'},
      {'q': 'Apakah kamu sering mengalami kaku atau tegang pada otot?', 'a': 'Iya'},
      {'q': 'Apakah kamu mengalami kerontokan rambut yang tidak biasa?', 'a': 'Iya'},
      {'q': 'Apakah berat badan kamu termasuk berlebih/obesitas?', 'a': 'Tidak'},
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
    widget.isPositif ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9);
    final Color textColor =
    widget.isPositif ? Colors.red.shade800 : Colors.green.shade800;
    final String statusText = widget.isPositif
        ? 'Status: Risiko Tinggi (Positif)'
        : 'Status: Risiko Rendah (Negatif)';
    final String ringkasanText = widget.isPositif
        ? 'Berdasarkan hasil skrining, Anda memiliki kemungkinan tinggi mengalami diabetes. Kami menyarankan untuk melakukan pemeriksaan lebih lanjut di fasilitas kesehatan.'
        : 'Berdasarkan hasil skrining, Anda memiliki kemungkinan rendah mengalami diabetes. Tetap jaga pola makan dan gaya hidup sehat.';

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Hasil Skrining',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFF6679F4), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. HEADER BRAND & TANGGAL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Image.asset(
                                  'assets/logo.png',
                                  height: 36,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.favorite,
                                      color: Color(0xFF6679F4), size: 32),
                                ),
                                const SizedBox(width: 8),
                                const Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Diora',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF6679F4),
                                        ),
                                      ),
                                      Text(
                                        'Kenali Risiko, Jaga Masa Depanmu',
                                        style: TextStyle(
                                            fontSize: 9.5, color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                tanggalSkrining,
                                style: const TextStyle(
                                    fontSize: 10.5, color: Colors.grey),
                              ),
                              Text(
                                jamSkrining,
                                style: const TextStyle(
                                    fontSize: 10.5, color: Colors.grey),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(color: Colors.grey, thickness: 0.5),
                      const SizedBox(height: 12),

                      const Center(
                        child: Text(
                          'Laporan Hasil Skrining Diabetes',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 2. DATA PENGGUNA (FULL WIDTH ATAS)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data Pengguna',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 8),
                            Text('Nama : ${widget.nama}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text('Usia : ${widget.umur} Tahun',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black87)),
                            const SizedBox(height: 4),
                            Text('Jenis Kelamin : ${widget.jenisKelamin}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black87)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. STATUS BADGE
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: textColor.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isPositif
                                  ? Icons.warning_rounded
                                  : Icons.check_circle_rounded,
                              color: textColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              statusText,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 4. DETAIL JAWABAN SKRINING (TABEL)
                      const Text(
                        'Detail Jawaban Skrining',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      _buildQuestionsTable(widget.tableData),
                      const SizedBox(height: 20),

                      // 5. RINGKASAN HASIL
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ringkasan Hasil',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              ringkasanText,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.black87,
                                  height: 1.4),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 6. REKOMENDASI TINDAKAN
                      const Text(
                        'Rekomendasi Tindakan',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: widget.isPositif
                              ? const [
                            Text(
                                '• Cek kadar gula darah puasa & 2 jam setelah makan',
                                style: TextStyle(
                                    fontSize: 11, height: 1.4)),
                            Text(
                                '• Lakukan pemeriksaan HbA1c jika diperlukan',
                                style: TextStyle(
                                    fontSize: 11, height: 1.4)),
                            Text(
                                '• Konsultasi dengan dokter spesialis penyakit dalam/endokrin',
                                style: TextStyle(
                                    fontSize: 11, height: 1.4)),
                          ]
                              : const [
                            Text('• Pertahankan pola makan gizi seimbang',
                                style: TextStyle(
                                    fontSize: 11, height: 1.4)),
                            Text(
                                '• Rutin melakukan aktivitas fisik atau olahraga',
                                style: TextStyle(
                                    fontSize: 11, height: 1.4)),
                            Text(
                                '• Lakukan tes gula darah secara berkala',
                                style: TextStyle(
                                    fontSize: 11, height: 1.4)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 7. CATATAN PENTING
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEEFE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.info_outline,
                                color: Color(0xFF6679F4), size: 18),
                            SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Catatan Penting',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF4A5BD0)),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Hasil skrining ini bukan diagnosis medis resmi. Harap berkonsultasi dengan tenaga medis profesional untuk penanganan akurat.',
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.black87,
                                        height: 1.3),
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

            // TOMBOL KIRIM EMAIL
            Padding(
              padding: const EdgeInsets.all(16.0),
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
                    'Kirim Hasil ke Email',
                    style: TextStyle(
                      fontSize: 15,
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

  Widget _buildQuestionsTable(List<Map<String, String>> data) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(1.2),
          },
          border: TableBorder(
            horizontalInside:
            BorderSide(color: Colors.grey.shade200, width: 0.5),
          ),
          children: [
            TableRow(
              decoration: BoxDecoration(color: Colors.grey.shade100),
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Text(
                    'Pertanyaan',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                  child: Text(
                    'Jawaban',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: Colors.black87),
                  ),
                ),
              ],
            ),
            ...data.asMap().entries.map((entry) {
              int index = entry.key + 1;
              var item = entry.value;
              String questionText = item['q'] ?? '';

              // Format otomatis penomoran jika belum ada nomornya
              if (!questionText.startsWith(RegExp(r'\d+\.'))) {
                questionText = '$index. $questionText';
              }

              bool isYa = item['a'] == 'Ya' || item['a'] == 'Iya';

              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 10),
                    child: Text(
                      questionText,
                      style: const TextStyle(
                          fontSize: 10.5, color: Colors.black87),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 10),
                    child: Text(
                      item['a'] ?? '',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isYa ? Colors.red.shade700 : Colors.green.shade700,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// HALAMAN PROSES & SUCCESS SEND EMAIL
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

  Widget _buildProgressView() {
    return Column(
      children: [
        const Spacer(flex: 2),
        Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0FE),
              shape: BoxShape.circle,
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.mark_email_read_outlined,
                  size: 90,
                  color: Color(0xFF4285F4),
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
          'Mohon tunggu sebentar, kami sedang\nmengirimkan hasil skrining Anda ke email.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        const Spacer(flex: 3),
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

  Widget _buildSuccessView() {
    return Column(
      children: [
        const Spacer(flex: 2),
        Center(
          child: Container(
            width: 180,
            height: 180,
            decoration: const BoxDecoration(
              color: Color(0xFFE8F0FE),
              shape: BoxShape.circle,
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(
                  Icons.mark_email_unread_rounded,
                  size: 90,
                  color: Color(0xFF4285F4),
                ),
                Positioned(
                  bottom: 25,
                  right: 25,
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 44,
                    color: Color(0xFF22C55E),
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
          'Hasil skrining Anda telah berhasil\ndikirimkan ke email Anda.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
        const Spacer(flex: 3),
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
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const BerandaPage(),
                ),
                    (route) => false,
              );
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