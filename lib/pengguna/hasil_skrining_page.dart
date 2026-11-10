import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
    this.nama = '',
    this.umur = '',
    this.jenisKelamin = '',
    this.isPositif = true,
    this.tableData = const [],
  });

  @override
  State<HasilSkriningPage> createState() => _HasilSkriningPageState();
}

class _HasilSkriningPageState extends State<HasilSkriningPage> {
  late List<dynamic> _finalTableData;
  late String _nama;
  late String _umur;
  late String _jenisKelamin;
  late bool _isPositif;
  late String _docId;
  bool _isLoadingFirestore = false;

  @override
  void initState() {
    super.initState();
    _nama = widget.nama;
    _umur = widget.umur;
    _jenisKelamin = widget.jenisKelamin;
    _isPositif = widget.isPositif;
    _docId = widget.docId;
    _finalTableData = widget.tableData;

    // Jika dibuka dari menu Hasil Tes di Beranda (tanpa membawa data),
    // Ambil data tes terbaru secara otomatis dari Firebase Firestore
    if (_nama.isEmpty || _finalTableData.isEmpty) {
      _fetchLatestFromFirestore();
    }
  }

  Future<void> _fetchLatestFromFirestore() async {
    setState(() {
      _isLoadingFirestore = true;
    });

    try {
      if (_docId.isNotEmpty) {
        var docSnap = await FirebaseFirestore.instance
            .collection('screening_results')
            .doc(_docId)
            .get();
        if (docSnap.exists) {
          _populateDataFromDoc(docSnap.data() as Map<String, dynamic>);
          setState(() {
            _isLoadingFirestore = false;
          });
          return;
        }
      }

      // Ambil riwayat tes paling baru yang diisi pengguna
      var query = await FirebaseFirestore.instance
          .collection('screening_results')
          .orderBy('waktuSkrining', descending: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        var data = query.docs.first.data();
        _docId = query.docs.first.id;
        _populateDataFromDoc(data);
      }
    } catch (e) {
      debugPrint("Gagal load Firestore: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFirestore = false;
        });
      }
    }
  }

  void _populateDataFromDoc(Map<String, dynamic> data) {
    _nama = (data['nama'] ?? 'Pengguna').toString();
    _umur = (data['umur'] ?? '22').toString();
    _jenisKelamin = (data['jenisKelamin'] ?? 'Perempuan').toString();
    String hasilStr = (data['hasilPrediksi'] ?? '').toString();
    _isPositif = hasilStr == 'Positif Diabetes';

    _finalTableData = [
      {'q': 'Apakah Anda sering buang air kecil (BAK)?', 'a': data['seringBAK'] == true ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda sering merasa haus / dahaga?', 'a': data['seringHaus'] == true ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda sering merasa lemas atau mudah lelah?', 'a': data['seringLemas'] == true ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda mengalami rambut rontok?', 'a': data['rambutRontok'] == true ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda memiliki luka yang sulit sembuh?', 'a': data['lukaSulitSembuh'] == true ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda merasa mudah marah atau emosional?', 'a': data['mudahMarah'] == true ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda sering mengalami kaku otot?', 'a': data['kakuOtot'] == true ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda mengalami obesitas / kelebihan BB?', 'a': data['obesitas'] == true ? 'Ya' : 'Tidak'},
    ];
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final DateTime now = DateTime.now();
    final String tanggal =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    final String jam =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final String cleanId = _docId.length > 8
        ? _docId.substring(0, 8).toUpperCase()
        : _docId.toUpperCase();
    final String noRekamMedis = _docId.isNotEmpty
        ? cleanId
        : 'SKR-${now.millisecondsSinceEpoch.toString().substring(5)}';

    final String statusStr = _isPositif
        ? 'RISIKO TINGGI (POSITIF)'
        : 'RISIKO RENDAH (NEGATIF)';

    final String ringkasanText = _isPositif
        ? 'Berdasarkan evaluasi indikator medis, Anda teridentifikasi memiliki potensi tinggi risiko diabetes. Disarankan segera berkonsultasi ke fasilitas kesehatan.'
        : 'Berdasarkan evaluasi indikator medis, Anda berada pada kategori risiko rendah diabetes. Tetap pertahankan pola hidup sehat.';

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
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('No. Dokumen: $noRekamMedis',
                        style: pw.TextStyle(
                            fontSize: 9, fontWeight: pw.FontWeight.bold)),
                    pw.Text('Tanggal Cetak: $tanggal',
                        style: const pw.TextStyle(
                            fontSize: 8.5, color: PdfColors.grey700)),
                    pw.Text('Pukul: $jam WIB',
                        style: const pw.TextStyle(
                            fontSize: 8.5, color: PdfColors.grey700)),
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
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                        pw.SizedBox(height: 6),
                        pw.Text('Nama Lengkap : $_nama',
                            style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('Usia Pasien   : $_umur Tahun',
                            style: const pw.TextStyle(fontSize: 9)),
                        pw.Text('Jenis Kelamin : $_jenisKelamin',
                            style: const pw.TextStyle(fontSize: 9)),
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
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                        pw.SizedBox(height: 6),
                        pw.Text(ringkasanText,
                            style: const pw.TextStyle(
                                fontSize: 8.5, height: 1.3)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 12),
            pw.Container(
              width: double.infinity,
              padding:
              const pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: pw.BoxDecoration(
                color: _isPositif
                    ? PdfColor.fromHex('#FFEBEE')
                    : PdfColor.fromHex('#E8F5E9'),
                border: pw.Border.all(
                  color:
                  _isPositif ? PdfColors.red300 : PdfColors.green300,
                ),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Center(
                child: pw.Text(
                  'STATUS EVALUASI: $statusStr',
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 11,
                    color: _isPositif
                        ? PdfColors.red900
                        : PdfColors.green900,
                  ),
                ),
              ),
            ),
            pw.SizedBox(height: 14),
            pw.Text('Detail Jawaban Indikator Skrining:',
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold, fontSize: 10)),
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
                      child: pw.Text('No',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Pertanyaan Skrining',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text('Jawaban',
                          textAlign: pw.TextAlign.center,
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 9)),
                    ),
                  ],
                ),
                ..._finalTableData.asMap().entries.map((entry) {
                  final idx = entry.key + 1;
                  final item = entry.value;
                  final String qText = ((item is Map) ? (item['q'] ?? '') : '')
                      .toString()
                      .replaceAll(RegExp(r'^\d+\.\s*'), '');
                  final String ansText =
                  ((item is Map) ? (item['a'] ?? '') : '').toString();

                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text('$idx',
                            textAlign: pw.TextAlign.center,
                            style: const pw.TextStyle(fontSize: 8.5)),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(qText,
                            style: const pw.TextStyle(fontSize: 8.5)),
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
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 9.5)),
                        pw.SizedBox(height: 4),
                        if (_isPositif) ...[
                          pw.Text(
                              '• Lakukan pemeriksaan kadar gula darah puasa & 2 jam PP',
                              style: const pw.TextStyle(fontSize: 8)),
                          pw.Text(
                              '• Konsultasikan tes HbA1c dengan dokter spesialis',
                              style: const pw.TextStyle(fontSize: 8)),
                          pw.Text(
                              '• Kurangi konsumsi glukosa dan lakukan diet sehat teratur',
                              style: const pw.TextStyle(fontSize: 8)),
                        ] else ...[
                          pw.Text(
                              '• Pertahankan pola makan gizi seimbang dan serat tinggi',
                              style: const pw.TextStyle(fontSize: 8)),
                          pw.Text(
                              '• Rutin melakukan aktivitas fisik/olahraga minimal 30 menit/hari',
                              style: const pw.TextStyle(fontSize: 8)),
                          pw.Text(
                              '• Lakukan pemeriksaan gula darah berkala 6 bulan sekali',
                              style: const pw.TextStyle(fontSize: 8)),
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
                        pw.Text('Terverifikasi Digital',
                            style: const pw.TextStyle(
                                fontSize: 8, color: PdfColors.grey700)),
                        pw.SizedBox(height: 16),
                        pw.Text('[ DIORA SYSTEM ]',
                            style: pw.TextStyle(
                                fontSize: 9,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColor.fromHex('#6679F4'))),
                        pw.SizedBox(height: 4),
                        pw.Text('Validasi Otomatis',
                            style: const pw.TextStyle(
                                fontSize: 7.5, color: PdfColors.grey600)),
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
        filename: 'Laporan_Skrining_Diabetes_${_nama}.pdf',
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
    if (_isLoadingFirestore) {
      return Scaffold(
        backgroundColor: const Color(0xFFE2E8F0),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Laporan Hasil Skrining',
              style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0.5,
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF6679F4)),
        ),
      );
    }

    final DateTime now = DateTime.now();
    final String jamSkrining =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final String tanggalSkrining =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    final String displayDocId = _docId.length > 8
        ? _docId.substring(0, 8).toUpperCase()
        : _docId.toUpperCase();
    final String noDoc = _docId.isNotEmpty
        ? displayDocId
        : 'SKR-${now.millisecondsSinceEpoch.toString().substring(6)}';

    final Color statusColor =
    _isPositif ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
    final Color textColor =
    _isPositif ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final Color borderColor =
    _isPositif ? const Color(0xFFFCA5A5) : const Color(0xFF86EFAC);

    final String statusText = _isPositif
        ? 'RISIKO TINGGI (POSITIF)'
        : 'RISIKO RENDAH (NEGATIF)';

    final String ringkasanText = _isPositif
        ? 'Berdasarkan evaluasi indikator medis, Anda memiliki potensi tinggi mengalami risiko diabetes. Disarankan segera berkonsultasi ke dokter.'
        : 'Berdasarkan evaluasi indikator medis, Anda memiliki kemungkinan rendah mengalami diabetes. Tetap pertahankan pola hidup sehat.';

    return Scaffold(
      backgroundColor: const Color(0xFFE2E8F0),
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
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border:
                    Border.all(color: const Color(0xFFCBD5E1), width: 1),
                  ),
                  padding: const EdgeInsets.fromLTRB(14, 20, 14, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                    color: Color(0xFF6679F4), size: 24),
                              ),
                              const SizedBox(width: 8),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'DIORA HEALTHCARE',
                                    style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF6679F4),
                                      letterSpacing: 0.3,
                                    ),
                                  ),
                                  Text(
                                    'Layanan Skrining Digital',
                                    style: TextStyle(
                                        fontSize: 8.5,
                                        color: Color(0xFF64748B)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'No: $noDoc',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: const TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B)),
                                ),
                                Text(
                                  tanggalSkrining,
                                  style: const TextStyle(
                                      fontSize: 8.5, color: Color(0xFF64748B)),
                                ),
                                Text(
                                  '$jamSkrining WIB',
                                  style: const TextStyle(
                                      fontSize: 8.5, color: Color(0xFF64748B)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          Container(height: 2, color: const Color(0xFF6679F4)),
                          const SizedBox(height: 2),
                          Container(
                              height: 0.8, color: const Color(0xFF94A3B8)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Center(
                        child: Text(
                          'LAPORAN RESMI HASIL SKRINING DIABETES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildRealReportCard(
                              title: 'DATA PASIEN',
                              lines: [
                                'Nama   : $_nama',
                                'Usia   : $_umur Tahun',
                                'Gender : $_jenisKelamin',
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
                              _isPositif
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
                                  fontSize: 10.5,
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
                      const Text(
                        'Detail Jawaban Indikator Skrining:',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 8),
                      _buildRealTable(_finalTableData),
                      const SizedBox(height: 16),
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
                                border:
                                Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rekomendasi Medis:',
                                    style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF0F172A)),
                                  ),
                                  const SizedBox(height: 4),
                                  if (_isPositif) ...const [
                                    Text('• Cek gula darah puasa & 2 jam PP',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF334155))),
                                    Text('• Tes HbA1c dengan dokter spesialis',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF334155))),
                                    Text(
                                        '• Konsultasikan pola diet rendah gula',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF334155))),
                                  ] else ...const [
                                    Text('• Pertahankan gizi seimbang & serat',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF334155))),
                                    Text('• Olahraga teratur 30 menit/hari',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF334155))),
                                    Text('• Tes gula darah rutin berkala',
                                        style: TextStyle(
                                            fontSize: 9,
                                            color: Color(0xFF334155))),
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
                                border:
                                Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: const Column(
                                children: [
                                  Text(
                                    'Terverifikasi Digital',
                                    style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF64748B)),
                                  ),
                                  SizedBox(height: 12),
                                  Icon(Icons.verified_user_rounded,
                                      color: Color(0xFF6679F4), size: 20),
                                  SizedBox(height: 4),
                                  Text(
                                    '[ DIORA SYSTEM ]',
                                    style: TextStyle(
                                        fontSize: 7.5,
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
            Container(
              padding: const EdgeInsets.all(14),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6679F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _kirimPdfLangsung,
                  icon: const Icon(Icons.picture_as_pdf_rounded,
                      color: Colors.white, size: 20),
                  label: const Text(
                    'Cetak / Simpan Laporan PDF',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 6),
          if (lines != null)
            ...lines.map(
                  (line) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  line,
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
            ),
          if (bodyText != null)
            Text(
              bodyText,
              style: const TextStyle(
                fontSize: 8.5,
                color: Color(0xFF334155),
                height: 1.3,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRealTable(List<dynamic> data) {
    return Table(
      border: TableBorder.all(color: const Color(0xFFE2E8F0), width: 1),
      columnWidths: const {
        0: FlexColumnWidth(0.6),
        1: FlexColumnWidth(4.0),
        2: FlexColumnWidth(1.2),
      },
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF1F5F9)),
          children: [
            _buildTableCell('No', isHeader: true, align: TextAlign.center),
            _buildTableCell('Pertanyaan Skrining', isHeader: true),
            _buildTableCell('Jawaban', isHeader: true, align: TextAlign.center),
          ],
        ),
        ...data.asMap().entries.map((entry) {
          final idx = entry.key + 1;
          final item = entry.value;
          final String qText = ((item is Map) ? (item['q'] ?? '') : '')
              .toString()
              .replaceAll(RegExp(r'^\d+\.\s*'), '');
          final String ansText =
          ((item is Map) ? (item['a'] ?? '') : '').toString();
          final bool isYa = (ansText == 'Ya' || ansText == 'Iya');

          return TableRow(
            children: [
              _buildTableCell('$idx', align: TextAlign.center),
              _buildTableCell(qText),
              _buildTableCell(
                ansText,
                align: TextAlign.center,
                textColor:
                isYa ? const Color(0xFFDC2626) : const Color(0xFF16A34A),
                isBold: true,
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildTableCell(
      String text, {
        bool isHeader = false,
        TextAlign align = TextAlign.left,
        Color? textColor,
        bool isBold = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Text(
        text,
        textAlign: align,
        style: TextStyle(
          fontSize: isHeader ? 9 : 8.5,
          fontWeight: isHeader || isBold ? FontWeight.bold : FontWeight.normal,
          color: textColor ??
              (isHeader ? const Color(0xFF1E293B) : const Color(0xFF334155)),
        ),
      ),
    );
  }
}