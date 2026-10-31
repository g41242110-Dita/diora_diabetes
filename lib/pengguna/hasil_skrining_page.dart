import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class HasilSkriningPage extends StatefulWidget {
  final String docId;
  final String nama;
  final String umur;
  final String jenisKelamin;
  final bool isPositif;
  final List<dynamic> tableData;

  const HasilSkriningPage({
    super.key,
    this.docId = '',
    this.nama = 'Pengguna',
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
  // FUNGSI LANGSUNG KIRIM EMAIL VIA URL_LAUNCHER
  Future<void> _kirimEmailLangsung() async {
    final String emailUser = FirebaseAuth.instance.currentUser?.email ?? '';
    final String statusStr =
    widget.isPositif ? 'Risiko Tinggi (Positif)' : 'Risiko Rendah (Negatif)';

    final String isiPesan = '''
Halo ${widget.nama},

Berikut adalah Laporan Hasil Skrining Diabetes dari Aplikasi Diora:

--------------------------------------------------
DATA PENGGUNA:
- Nama: ${widget.nama}
- Usia: ${widget.umur} Tahun
- Jenis Kelamin: ${widget.jenisKelamin}

HASIL SKRINING:
- Status: $statusStr

REKOMENDASI:
${widget.isPositif ? '• Cek kadar gula darah puasa & 2 jam setelah makan\n• Lakukan pemeriksaan HbA1c jika diperlukan\n• Konsultasi dengan dokter spesialis penyakit dalam' : '• Pertahankan pola makan gizi seimbang\n• Rutin melakukan aktivitas fisik/olahraga\n• Lakukan tes gula darah secara berkala'}
--------------------------------------------------

*Catatan: Hasil skrining ini bukan diagnosis medis resmi. Harap berkonsultasi dengan tenaga medis profesional.

Salam sehat,
Tim Diora
''';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: emailUser,
      queryParameters: {
        'subject': 'Laporan Hasil Skrining Diabetes - Diora',
        'body': isiPesan,
      },
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        await launchUrl(emailUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuka aplikasi email: $e')),
        );
      }
    }
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
        ? 'Risiko Tinggi (Positif)'
        : 'Risiko Rendah (Negatif)';
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
                padding: const EdgeInsets.all(20),
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

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              title: 'Data Pengguna',
                              content: [
                                'Nama: ${widget.nama}',
                                'Usia: ${widget.umur} Tahun',
                                'Kelamin: ${widget.jenisKelamin}',
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
                      const SizedBox(height: 20),

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
                              'Status: $statusText',
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

                      const Text(
                        'Rekomendasi Tindakan',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                      const SizedBox(height: 8),
                      Container(
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
                            Text(
                                '• Pertahankan pola makan gizi seimbang',
                                style: TextStyle(
                                    fontSize: 11, height: 1.4)),
                            Text(
                                '• Rutin melakukan aktivitas fisik atau olahraga',
                                style: TextStyle(
                                    fontSize: 11, height: 1.4)),
                            Text('• Lakukan tes gula darah secara berkala',
                                style: TextStyle(
                                    fontSize: 11, height: 1.4)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

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
                  onPressed: _kirimEmailLangsung,
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

  Widget _buildInfoCard({
    required String title,
    List<String>? content,
    String? bodyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          if (content != null)
            ...content.map(
                  (text) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(text,
                    style: const TextStyle(
                        fontSize: 10.5, color: Colors.black87)),
              ),
            ),
          if (bodyText != null)
            Text(
              bodyText,
              style: const TextStyle(
                  fontSize: 10.5, color: Colors.black87, height: 1.3),
            ),
        ],
      ),
    );
  }

  Widget _buildQuestionsTable(List<dynamic> dataItems) {
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
            ...dataItems.map(
                  (item) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8, horizontal: 10),
                    child: Text(
                      item['q'] ?? '',
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
                        color: item['a'] == 'Ya' || item['a'] == 'Iya'
                            ? Colors.red.shade700
                            : Colors.green.shade700,
                      ),
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