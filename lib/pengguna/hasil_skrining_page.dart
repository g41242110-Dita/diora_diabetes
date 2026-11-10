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
    this.tableData = const [],
  });

  @override
  State<HasilSkriningPage> createState() => _HasilSkriningPageState();
}

class _HasilSkriningPageState extends State<HasilSkriningPage> {
  late List<Map<String, String>> _finalTableData;

  final List<String> _default14Pertanyaan = const [
    'Apakah Anda sering merasa haus berlebihan (Polidipsia)?',
    'Apakah Anda sering buang air kecil terutama di malam hari (Poliuria)?',
    'Apakah Anda sering merasa cepat lapar meski sudah makan (Polifagia)?',
    'Apakah Anda mengalami penurunan berat badan drastis tanpa alasan jelas?',
    'Apakah Anda sering merasa lelah, lemas, dan kurang berenergi?',
    'Apakah penglihatan Anda sering kabur atau berbayang?',
    'Apakah luka atau lecet pada tubuh Anda membutuhkan waktu sangat lama untuk sembuh?',
    'Apakah Anda sering mengalami kesemutan, mati rasa, atau nyeri pada tangan/kaki?',
    'Apakah Anda sering mengalami infeksi berulang (kulit, gusi, atau saluran kemih)?',
    'Apakah ada anggota keluarga kandung (orang tua/saudara) yang menderita diabetes?',
    'Apakah Anda memiliki riwayat tekanan darah tinggi (Hipertensi)?',
    'Apakah Anda jarang melakukan aktivitas fisik atau olahraga (gaya hidup sedenter)?',
    'Apakah usia Anda saat ini di atas 40 tahun?',
    'Apakah Anda pernah terdiagnosa kadar kolesterol tinggi atau obesitas?',
  ];

  @override
  void initState() {
    super.initState();
    _initTableData();
  }

  void _initTableData() {
    if (widget.tableData.isNotEmpty) {
      _finalTableData = widget.tableData
          .map((item) => {
        'q': ((item is Map ? item['q'] : null) ?? '').toString(),
        'a': ((item is Map ? item['a'] : null) ?? '').toString(),
      })
          .toList();
    } else {
      _finalTableData = List.generate(
        14,
            (index) => {
          'q': '${index + 1}. ${_default14Pertanyaan[index]}',
          'a': (index % 2 == 0 && widget.isPositif) ? 'Ya' : 'Tidak',
        },
      );
    }
  }

  // FUNGSI GENERATE PDF LAPORAN MEDIS
  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final DateTime now = DateTime.now();
    final String tanggal =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final String jam =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final String noRekamMedis = widget.docId.isNotEmpty
        ? widget.docId.toUpperCase()
        : 'SKR-${now.millisecondsSinceEpoch.toString().substring(5)}';

    final String statusStr = widget.isPositif
        ? 'RISIKO TINGGI (POSITIF)'
        : 'RISIKO RENDAH (NEGATIF)';

    final String ringkasanText = widget.isPositif
        ? 'Berdasarkan 14 indikator gejala skrining, Anda teridentifikasi memiliki potensi tinggi risiko diabetes. Disarankan segera berkonsultasi ke fasilitas kesehatan.'
        : 'Berdasarkan 14 indikator gejala skrining, Anda berada pada kategori risiko rendah diabetes. Tetap pertahankan pola hidup sehat.';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        build: (pw.Context context) {
          return [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'DIORA HEALTHCARE',
                      style: pw.TextStyle(
                        fontSize: 20,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex('#6679F4'),
                      ),
                    ),
                    pw.Text(
                      'Layanan Skrining Mandiri & Edukasi Diabetes Digital',
                      style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('No. Dokumen: $noRekamMedis',
                        style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Tanggal Cetak: $tanggal',
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                    pw.Text('Pukul: $jam WIB',
                        style: const pw.TextStyle(fontSize: 8.5, color: PdfColors.grey700)),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Divider(thickness: 1.5, color: PdfColor.fromHex('#6679F4')),
            pw.SizedBox(height: 10),
            pw.Center(
              child: pw.Text(
                'LAPORAN RESMI HASIL SKRINING RISIKO DIABETES',
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.black,
                ),
              ),
            ),
            pw.SizedBox(height: 14),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(6),
                      color: PdfColors.grey50,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('DATA PASIEN / PENGGUNA',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                        pw.SizedBox(height: 6),
                        pw.Text('Nama Lengkap : ${widget.nama}', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('Usia Pasien   : ${widget.umur} Tahun', style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('Jenis Kelamin : ${widget.jenisKelamin}', style: const pw.TextStyle(fontSize: 9)),
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
                      borderRadius: pw.BorderRadius.circular(6),
                      color: PdfColors.grey50,
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('RINGKASAN EVALUASI',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                        pw.SizedBox(height: 6),
                        pw.Text(ringkasanText, style: const pw.TextStyle(fontSize: 8.5, height: 1.3)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: pw.BoxDecoration(
                color: widget.isPositif ? PdfColor.fromHex('#FFEBEE') : PdfColor.fromHex('#E8F5E9'),
                border: pw.Border.all(
                  color: widget.isPositif ? PdfColors.red300 : PdfColors.green300,
                ),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Center(
                child: pw.Text(
                  'STATUS EVALUASI: $statusStr',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: widget.isPositif ? PdfColors.red900 : PdfColors.green900,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 14),
            pw.Text('Detail Jawaban 14 Indikator Skrining:',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10)),
            pw.SizedBox(height: 6),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
              columnWidths: const {
                0: pw.FlexColumnWidth(0.5),
                1: pw.FlexColumnWidth(3.8),
                2: pw.FlexColumnWidth(1.0),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey200),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('No', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Pertanyaan Skrining', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Jawaban', textAlign: pw.TextAlign.center, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    ),
                  ],
                ),
                ..._finalTableData.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  final String qText = (item['q'] ?? '').replaceAll(RegExp(r'^\d+\.\s*'), '');
                  final String ansText = item['a'] ?? '';

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('$idx', textAlign: pw.TextAlign.center, style: const pw.TextStyle(fontSize: 8.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(qText, style: const pw.TextStyle(fontSize: 8.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          ansText,
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                            fontSize: 8.5,
                            fontWeight: pw.FontWeight.bold,
                            color: (ansText == 'Ya' || ansText == 'Iya')
                                ? PdfColors.red700
                                : PdfColors.green700,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 14),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 3,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey50,
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Rekomendasi Medis:',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                        pw.SizedBox(height: 4),
                        if (widget.isPositif) ...[
                          pw.Text('• Lakukan pemeriksaan kadar gula darah puasa & 2 jam PP', style: const pw.TextStyle(fontSize: 8)),
                          pw.Text('• Konsultasikan tes HbA1c dengan dokter spesialis', style: const pw.TextStyle(fontSize: 8)),
                          pw.Text('• Kurangi konsumsi glukosa dan lakukan diet sehat teratur', style: const pw.TextStyle(fontSize: 8)),
                        ] else ...[
                          pw.Text('• Pertahankan pola makan gizi seimbang dan serat tinggi', style: const pw.TextStyle(fontSize: 8)),
                          pw.Text('• Rutin melakukan aktivitas fisik/olahraga minimal 30 menit/hari', style: const pw.TextStyle(fontSize: 8)),
                          pw.Text('• Lakukan pemeriksaan gula darah berkala 6 bulan sekali', style: const pw.TextStyle(fontSize: 8)),
                        ]
                      ],
                    ),
                  ),
                ),
                pw.SizedBox(width: 10),
                pw.Expanded(
                  flex: 2,
                  child: pw.Container(
                    padding: const pw.EdgeInsets.all(8),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey300),
                      borderRadius: pw.BorderRadius.circular(6),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text('Terverifikasi Sistem Digital', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700)),
                        pw.SizedBox(height: 16),
                        pw.Text('[ DIORA SYSTEM ]', style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, color: PdfColor.fromHex('#6679F4'))),
                        pw.SizedBox(height: 4),
                        pw.Text('Validasi Otomatis', style: const pw.TextStyle(fontSize: 7.5, color: PdfColors.grey600)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('#ECEEFE'),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Text(
                'Catatan Penting: Hasil skrining ini dibuat secara otomatis oleh sistem Diora sebagai langkah deteksi awal. Laporan ini bukan merupakan bukti diagnosis medis mutlak. Harap konsultasikan ke fasilitas medis profesional.',
                style: const pw.TextStyle(fontSize: 8, color: PdfColors.black),
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _kirimPdfLangsung() async {
    try {
      final Uint8List pdfBytes = await _generatePdf();
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: 'Laporan_Skrining_Diabetes_${widget.nama}.pdf',
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
    final String noDoc = widget.docId.isNotEmpty
        ? widget.docId.toUpperCase()
        : 'SKR-${now.millisecondsSinceEpoch.toString().substring(6)}';

    final Color statusColor =
    widget.isPositif ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
    final Color textColor =
    widget.isPositif ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final Color borderColor =
    widget.isPositif ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC);

    final String statusText = widget.isPositif
        ? 'RISIKO TINGGI (POSITIF)'
        : 'RISIKO RENDAH (NEGATIF)';

    final String ringkasanText = widget.isPositif
        ? 'Berdasarkan evaluasi 14 indikator medis, Anda memiliki potensi tinggi mengalami risiko diabetes. Disarankan segera berkonsultasi ke dokter.'
        : 'Berdasarkan evaluasi 14 indikator medis, Anda memiliki kemungkinan rendah mengalami diabetes. Tetap pertahankan pola hidup sehat.';

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0), // Latar studio agar efek dokumen kertas kontras
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        title: const Text(
          'Laporan Hasil Skrining',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF6679F4), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // KOP SURAT RESMI (KERTAS LAPORAN REAL)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.local_hospital_rounded,
                                    color: Color(0xFF6679F4), size: 28),
                              ),
                              const SizedBox(width: 10),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DIORA HEALTHCARE',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF6679F4),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  Text(
                                    'Layanan Skrining Diabetes Digital',
                                    style: TextStyle(
                                        fontSize: 9, color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'No: $noDoc',
                                style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B)),
                              ),
                              Text(
                                tanggalSkrining,
                                style: const TextStyle(
                                    fontSize: 9, color: Color(0xFF64748B)),
                              ),
                              Text(
                                '$jamSkrining WIB',
                                style: const TextStyle(
                                    fontSize: 9, color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // GARIS AKSEN GANDA KOP SURAT MEDIS
                      Column(
                        children: [
                          Container(height: 2, color: const Color(0xFF6679F4)),
                          const SizedBox(height: 2),
                          Container(height: 0.8, color: const Color(0xFF94A3B8)),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // JUDUL SURAT LAPORAN
                      const Center(
                        child: Text(
                          'LAPORAN RESMI HASIL SKRINING DIABETES',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // BLOK DATA PASIEN & RINGKASAN EVALUASI
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildRealReportCard(
                              title: 'DATA PASIEN',
                              lines: [
                                'Nama   : ${widget.nama}',
                                'Usia   : ${widget.umur} Tahun',
                                'Gender : ${widget.jenisKelamin}',
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildRealReportCard(
                              title: 'RINGKASAN EVALUASI',
                              bodyText: ringkasanText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // STEMPEL RISKO
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 14),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: borderColor, width: 1.2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              widget.isPositif
                                  ? Icons.warning_amber_rounded
                                  : Icons.verified_rounded,
                              color: textColor,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'STATUS EVALUASI: $statusText',
                                textAlign: TextAlign.center,
                                softWrap: true,
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  color: textColor,
                                  letterSpacing: 0.1,
                                  height: 1.25,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // TABEL 14 INDIKATOR
                      const Text(
                        'Detail Jawaban 14 Indikator Skrining:',
                        style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 8),
                      _buildRealTable(_finalTableData),
                      const SizedBox(height: 16),

                      // REKOMENDASI MEDIS & VERIFIKASI SISTEM
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rekomendasi Medis:',
                                    style: TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 4),
                                  if (widget.isPositif) ...const [
                                    Text('• Cek gula darah puasa & 2 jam PP',
                                        style: TextStyle(fontSize: 9.5, color: Color(0xFF334155))),
                                    Text('• Tes HbA1c dengan dokter spesialis',
                                        style: TextStyle(fontSize: 9.5, color: Color(0xFF334155))),
                                    Text('• Konsultasikan pola diet rendah gula',
                                        style: TextStyle(fontSize: 9.5, color: Color(0xFF334155))),
                                  ] else ...const [
                                    Text('• Pertahankan gizi seimbang & serat',
                                        style: TextStyle(fontSize: 9.5, color: Color(0xFF334155))),
                                    Text('• Olahraga teratur 30 menit/hari',
                                        style: TextStyle(fontSize: 9.5, color: Color(0xFF334155))),
                                    Text('• Tes gula darah rutin berkala',
                                        style: TextStyle(fontSize: 9.5, color: Color(0xFF334155))),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 2,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Terverifikasi Digital',
                                    style: TextStyle(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF64748B)),
                                  ),
                                  SizedBox(height: 12),
                                  Icon(Icons.verified_user_rounded,
                                      color: Color(0xFF6679F4), size: 22),
                                  SizedBox(height: 4),
                                  Text(
                                    '[ DIORA SYSTEM ]',
                                    style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF6679F4)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // FOOTER CATATAN HUKUM/MEDIS
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: const Text(
                          'Catatan: Laporan ini diterbitkan otomatis oleh sistem Diora sebagai langkah awal penilaian mandiri dan bukan pengganti rekam medis profesional.',
                          style: TextStyle(
                              fontSize: 8.5,
                              color: Color(0xFF3730A3),
                              height: 1.3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // BARIS TOMBOL AKSI
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6679F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _kirimPdfLangsung,
                  icon: const Icon(Icons.picture_as_pdf_rounded,
                      color: Colors.white, size: 18),
                  label: const Text(
                    'Cetak / Simpan Laporan PDF',
                    style: TextStyle(
                      fontSize: 13.5,
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

  Widget _buildRealReportCard({
    required String title,
    List<String>? lines,
    String? bodyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF334155)),
          ),
          const SizedBox(height: 6),
          if (lines != null)
            ...lines.map(
                  (line) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(line,
                    style: const TextStyle(
                        fontSize: 9.5, color: Color(0xFF0F172A))),
              ),
            ),
          if (bodyText != null)
            Text(
              bodyText,
              style: const TextStyle(
                  fontSize: 9, color: Color(0xFF334155), height: 1.3),
            ),
        ],
      ),
    );
  }

  Widget _buildRealTable(List<Map<String, String>> dataItems) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCBD5E1)),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(5),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(0.5),
            1: FlexColumnWidth(3.5),
            2: FlexColumnWidth(1.1),
          },
          border: const TableBorder(
            horizontalInside: BorderSide(
              color: Color(0xFFE2E8F0),
              width: 0.8,
            ),
            verticalInside: BorderSide(
              color: Color(0xFFE2E8F0),
              width: 0.8,
            ),
          ),
          children: [
            const TableRow(
              decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Text(
                    'No',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 9.5,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Text(
                    'Indikator Gejala',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 9.5,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: Text(
                    'Hasil',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 9.5,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ),
              ],
            ),
            ...dataItems.asMap().entries.map((entry) {
              final int index = entry.key + 1;
              final Map<String, String> item = entry.value;
              final String question = (item['q'] ?? '').replaceAll(
                RegExp(r'^\d+\.\s*'),
                '',
              );
              final String answer = item['a'] ?? '';
              final bool isYes = answer == 'Ya' || answer == 'Iya';

              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    child: Text(
                      '$index',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF334155),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 8,
                    ),
                    child: Text(
                      question,
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFF0F172A),
                        height: 1.25,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 4,
                    ),
                    child: Text(
                      answer,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: isYes
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF16A34A),
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
