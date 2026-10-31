import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

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
  // FUNGSI UNTUK GENERATE DOKUMEN PDF (SUDAH DISAMAKAN PERSIS)
  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final DateTime now = DateTime.now();
    final String tanggal =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final String jam =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final String statusStr = widget.isPositif
        ? 'Risiko Tinggi (Positif)'
        : 'Risiko Rendah (Negatif)';

    final String ringkasanText = widget.isPositif
        ? 'Berdasarkan hasil skrining, Anda memiliki kemungkinan tinggi mengalami diabetes. Kami menyarankan untuk melakukan pemeriksaan lebih lanjut di fasilitas kesehatan.'
        : 'Berdasarkan hasil skrining, Anda memiliki kemungkinan rendah mengalami diabetes. Tetap jaga pola makan dan gaya hidup sehat.';

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header Laporan
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Diora',
                        style: pw.TextStyle(
                          fontSize: 22,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColor.fromHex('#6679F4'),
                        ),
                      ),
                      pw.Text(
                        'Kenali Risiko, Jaga Masa Depanmu',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey700),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(tanggal,
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                      pw.Text(jam,
                          style: const pw.TextStyle(
                              fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                ],
              ),
              pw.Divider(thickness: 1, color: PdfColors.grey300),
              pw.SizedBox(height: 12),

              // Judul Laporan
              pw.Center(
                child: pw.Text(
                  'LAPORAN HASIL SKRINING DIABETES',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 16),

              // Data Pengguna & Ringkasan Hasil
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Data Pengguna',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 11)),
                          pw.SizedBox(height: 6),
                          pw.Text('Nama: ${widget.nama}',
                              style: const pw.TextStyle(fontSize: 9.5)),
                          pw.Text('Usia: ${widget.umur} Tahun',
                              style: const pw.TextStyle(fontSize: 9.5)),
                          pw.Text('Kelamin: ${widget.jenisKelamin}',
                              style: const pw.TextStyle(fontSize: 9.5)),
                        ],
                      ),
                    ),
                  ),
                  pw.SizedBox(width: 10),
                  pw.Expanded(
                    child: pw.Container(
                      padding: const pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(
                        border: pw.Border.all(color: PdfColors.grey300),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Ringkasan Hasil',
                              style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                  fontSize: 11)),
                          pw.SizedBox(height: 6),
                          pw.Text(ringkasanText,
                              style: const pw.TextStyle(fontSize: 9.5)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 14),

              // Status Hasil Card
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: widget.isPositif
                      ? PdfColor.fromHex('#FFEBEE')
                      : PdfColor.fromHex('#E8F5E9'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Center(
                  child: pw.Text(
                    'Status: $statusStr',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                      color: widget.isPositif
                          ? PdfColors.red800
                          : PdfColors.green800,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 16),

              // TABEL DETAIL JAWABAN SKRINING (SEKARANG DISAMAKAN)
              pw.Text('Detail Jawaban Skrining:',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.SizedBox(height: 6),

              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(4),
                  1: pw.FlexColumnWidth(1.2),
                },
                children: [
                  pw.TableRow(
                    decoration:
                    const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Pertanyaan',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(6),
                        child: pw.Text('Jawaban',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 10)),
                      ),
                    ],
                  ),
                  ...widget.tableData.map(
                        (item) => pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(item['q'] ?? '',
                              style: const pw.TextStyle(fontSize: 9.5)),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            item['a'] ?? '',
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              fontSize: 9.5,
                              fontWeight: pw.FontWeight.bold,
                              color: (item['a'] == 'Ya' || item['a'] == 'Iya')
                                  ? PdfColors.red700
                                  : PdfColors.green700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 16),

              // Rekomendasi Tindakan
              pw.Text('Rekomendasi Tindakan:',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 11)),
              pw.SizedBox(height: 6),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey50,
                  border: pw.Border.all(color: PdfColors.grey300),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: widget.isPositif
                      ? [
                    pw.Text(
                        '• Cek kadar gula darah puasa & 2 jam setelah makan',
                        style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(
                        '• Lakukan pemeriksaan HbA1c jika diperlukan',
                        style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(
                        '• Konsultasi dengan dokter spesialis penyakit dalam/endokrin',
                        style: const pw.TextStyle(fontSize: 9.5)),
                  ]
                      : [
                    pw.Text('• Pertahankan pola makan gizi seimbang',
                        style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text(
                        '• Rutin melakukan aktivitas fisik atau olahraga',
                        style: const pw.TextStyle(fontSize: 9.5)),
                    pw.Text('• Lakukan tes gula darah secara berkala',
                        style: const pw.TextStyle(fontSize: 9.5)),
                  ],
                ),
              ),
              pw.SizedBox(height: 16),

              // Catatan Penting
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#ECEEFE'),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  'Catatan Penting: Hasil skrining ini bukan diagnosis medis resmi. Harap berkonsultasi dengan tenaga medis profesional untuk penanganan akurat.',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // FUNGSI SHARE DOKUMEN PDF KE GMAIL / APPS LAIN
  Future<void> _kirimPdfLangsung() async {
    try {
      final Uint8List pdfBytes = await _generatePdf();

      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Laporan_Skrining_${widget.nama}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat PDF: $e')),
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

            // TOMBOL UNTUK GENERATE & SEND FILE PDF
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
                  onPressed: _kirimPdfLangsung,
                  child: const Text(
                    'Kirim Laporan PDF',
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