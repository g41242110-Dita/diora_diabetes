// ignore_for_file: spelling

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef SkriningDetailMap = Map<String, dynamic>;

class AdminDetailSkriningPage extends StatelessWidget {
  final String docId;
  final String nama;
  final String email;
  final bool isPositif;
  final String waktu;
  final SkriningDetailMap rawData;

  const AdminDetailSkriningPage({
    super.key,
    required this.docId,
    required this.nama,
    required this.email,
    required this.isPositif,
    required this.waktu,
    required this.rawData,
  });

  String _formatFieldLabel(String key) {
    const customLabels = {
      'luka_sulit_sembuh': 'Luka Sulit Sembuh',
      'lukasulitsembuh': 'Luka Sulit Sembuh',
      'obesitas': 'Obesitas',
      'gatal_gatal': 'Gatal - Gatal',
      'infeksi_jamur': 'Infeksi Jamur',
      'infeksiberulang': 'Infeksi Berulang',
      'bb_turun_drastis': 'Berat Badan Turun Drastis',
      'penurunanberatbadan': 'Penurunan Berat Badan',
      'rambut_rontok': 'Rambut Rontok',
      'kelemahan': 'Kelemahan Tubuh',
      'kelemahan_sebagian_tubuh': 'Kelemahan Sebagian Tubuh',
      'sering_haus': 'Sering Haus',
      'seringhausberlebihan': 'Sering Haus Berlebihan',
      'sering_lapar': 'Sering Lapar',
      'cepatlapar': 'Cepat Lapar',
      'mudah_marah': 'Mudah Marah',
      'sering_lemas': 'Sering Lemas',
      'lemaskurangberenergi': 'Lemas Kurang Berenergi',
      'penglihatan_kabur': 'Penglihatan Kabur',
      'penglihatankabur': 'Penglihatan Kabur',
      'sering_bak': 'Sering Buang Air Kecil (BAK)',
      'seringbakmalamhari': 'Sering BAK Malam Hari',
      'kaku_otot': 'Kaku Otot',
      'kolesteroltinggiobesitas': 'Kolesterol Tinggi / Obesitas',
      'jarangaktivitasfisik': 'Jarang Aktivitas Fisik',
      'riwayathipertensi': 'Riwayat Hipertensi',
      'riwayatkeluarga': 'Riwayat Keluarga Diabetes',
      'kesemutannyeri': 'Kesemutan / Nyeri',
      'usiadiatas40': 'Usia Diatas 40 Tahun',
    };

    final lowerKey = key.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (customLabels.containsKey(lowerKey)) {
      return customLabels[lowerKey]!;
    }

    final separated = key.replaceAllMapped(
      RegExp(r'(?=[A-Z])|[_\s-]'),
          (match) => ' ',
    ).trim();

    if (separated.isEmpty) return key;
    return separated[0].toUpperCase() + separated.substring(1);
  }

  String _extractUsia() {
    for (final entry in rawData.entries) {
      final k = entry.key.toLowerCase().trim();
      if (k == 'usia' || k == 'umur' || k == 'age') {
        final val = (entry.value ?? '').toString().trim();
        if (val.isNotEmpty && val != 'null' && val != '-') {
          final isNumeric = double.tryParse(val) != null;
          return isNumeric ? '$val Thn' : val;
        }
      }
    }
    return '';
  }

  String _extractJenisKelamin() {
    for (final entry in rawData.entries) {
      final k = entry.key.toLowerCase().trim();
      if (k.contains('gender') || k.contains('kelamin')) {
        final raw = entry.value;
        if (raw == null) continue;
        final lowerVal = raw.toString().trim().toLowerCase();
        if (lowerVal.isEmpty || lowerVal == 'null' || lowerVal == '-') continue;

        if (lowerVal == '1' ||
            lowerVal.startsWith('l') ||
            lowerVal == 'pria' ||
            lowerVal == 'male') {
          return 'Laki-laki';
        }
        if (lowerVal == '0' ||
            lowerVal.startsWith('p') ||
            lowerVal == 'wanita' ||
            lowerVal == 'female') {
          return 'Perempuan';
        }
        return raw.toString().trim();
      }
    }
    return '';
  }

  String _formatAnswerValue(dynamic value) {
    final strVal = value.toString().trim();
    final lowerVal = strVal.toLowerCase();

    if (value == 1 ||
        value == true ||
        lowerVal == '1' ||
        lowerVal == 'true' ||
        lowerVal == 'yes' ||
        lowerVal == 'ya') {
      return 'Ya';
    }
    return 'Tidak';
  }

  static bool evaluateIsPositive(Map<String, dynamic> data) {
    final hasilPrediksi = (data['hasilPrediksi'] ?? '').toString().toLowerCase();
    if (hasilPrediksi.contains('positif') ||
        hasilPrediksi.contains('positive') ||
        hasilPrediksi.contains('diabetes')) {
      return true;
    }
    if (hasilPrediksi.contains('negatif') ||
        hasilPrediksi.contains('negative')) {
      return false;
    }

    final rawStatus = (data['status'] ??
        data['hasil'] ??
        data['result'] ??
        data['prediction'] ??
        data['risk_level'] ??
        '')
        .toString()
        .toLowerCase();

    if (rawStatus.contains('tidak terindikasi') ||
        rawStatus.contains('risiko rendah') ||
        rawStatus.contains('negatif') ||
        rawStatus.contains('negative') ||
        rawStatus == '0' ||
        rawStatus == 'false') {
      return false;
    }

    if (rawStatus.contains('positif') ||
        rawStatus.contains('positive') ||
        rawStatus.contains('tinggi') ||
        rawStatus.contains('high') ||
        rawStatus.contains('diabetes') ||
        rawStatus == '1' ||
        rawStatus == 'true') {
      return true;
    }

    final summary = (data['summary'] ??
        data['ringkasan'] ??
        data['keterangan'] ??
        '')
        .toString()
        .toLowerCase();

    if (summary.contains('tidak terindikasi') ||
        summary.contains('risiko rendah')) {
      return false;
    }

    return summary.contains('terindikasi memiliki risiko') ||
        summary.contains('risiko tinggi') ||
        summary.contains('positif');
  }

  @override
  Widget build(BuildContext context) {
    final bool realIsPositif = evaluateIsPositive(rawData);

    final Color accentColor =
    realIsPositif ? const Color(0xFFE11D48) : const Color(0xFF0D9488);
    final Color softBg =
    realIsPositif ? const Color(0xFFFFE4E6) : const Color(0xFFCCFBF1);
    final String hasilLabel = realIsPositif ? 'Positif' : 'Negatif';

    final String usiaText = _extractUsia();
    final String jkText = _extractJenisKelamin();

    final String summaryText = (rawData['summary'] ??
        rawData['ringkasan'] ??
        rawData['keterangan'] ??
        '')
        .toString()
        .trim();

    const ignoredKeysLower = {
      'id',
      'docid',
      'uid',
      'userid',
      'user_id',
      'nama',
      'username',
      'patientname',
      'name',
      'email',
      'useremail',
      'usia',
      'umur',
      'age',
      'gender',
      'jeniskelamin',
      'jenis_kelamin',
      'status',
      'hasil',
      'result',
      'prediction',
      'risk_level',
      'risklevel',
      'ispositive',
      'is_positive',
      'score',
      'skor',
      'probability',
      'probabilitas',
      'created_at',
      'createdat',
      'updated_at',
      'updatedat',
      'tanggal',
      'timestamp',
      'date',
      'waktu',
      'waktuskrining',
      'photobase64',
      'summary',
      'ringkasan',
      'keterangan',
      'rekomendasi',
      'recommendation',
      'kategori',
      'category',
      'jenis_tes',
      'hasilprediksi',
    };

    final List<MapEntry<String, String>> questionEntries = [];
    rawData.forEach((key, value) {
      if (value == null) return;
      if (value is Timestamp || value is DateTime || value is Map || value is List) {
        return;
      }

      final lowerKey = key.toLowerCase().trim().replaceAll(RegExp(r'[^a-z0-9]'), '');
      if (ignoredKeysLower.contains(lowerKey)) return;

      final rawStr = value.toString().trim();
      if (rawStr.isEmpty ||
          rawStr == 'null' ||
          rawStr.startsWith('Timestamp(')) {
        return;
      }

      questionEntries.add(
        MapEntry(
          _formatFieldLabel(key),
          _formatAnswerValue(value),
        ),
      );
    });

    final String shortId = docId.length > 8
        ? docId.substring(0, 8).toUpperCase()
        : docId.toUpperCase();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildLiquidHeader(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 36),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // KARTU UTAMA RINGKAS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  email.isNotEmpty && email != '-' ? email : 'ID: #$shortId',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: softBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              hasilLabel,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: accentColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (usiaText.isNotEmpty || jkText.isNotEmpty || waktu.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            if (usiaText.isNotEmpty || jkText.isNotEmpty)
                              Text(
                                [usiaText, jkText].where((e) => e.isNotEmpty).join(' • '),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            const Spacer(),
                            Text(
                              waktu,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (summaryText.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ringkasan Analisis AI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          summaryText,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF334155),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // LIST PERTANYAAN SKRINING (MURNI GEJALA YA / TIDAK)
                if (questionEntries.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'Jawaban Pertanyaan Skrining',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        ...List.generate(questionEntries.length, (index) {
                          final entry = questionEntries[index];
                          final bool isYes = entry.value == 'Ya';

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 9),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isYes
                                        ? const Color(0xFFFEF3C7)
                                        : const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    entry.value,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                      color: isYes
                                          ? const Color(0xFFB45309)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Stack(
      children: [
        ClipPath(
          clipper: _DetailSkriningHeaderClipper(offsetY: 10),
          child: Container(
            width: double.infinity,
            height: topPadding + 88,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4F46E5).withValues(alpha: 0.22),
                  const Color(0xFF38BDF8).withValues(alpha: 0.22),
                ],
              ),
            ),
          ),
        ),
        ClipPath(
          clipper: _DetailSkriningHeaderClipper(offsetY: 0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, topPadding, 16, 36),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4338CA),
                  Color(0xFF4F46E5),
                  Color(0xFF3B82F6),
                ],
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 36,
              child: Stack(
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 36),
                      child: Text(
                        'Detail Hasil Skrining',
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      tooltip: 'Kembali',
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DetailSkriningHeaderClipper extends CustomClipper<Path> {
  final double offsetY;
  const _DetailSkriningHeaderClipper({this.offsetY = 0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final h = size.height - offsetY;
    path.lineTo(0, h - 22);
    path.quadraticBezierTo(
        size.width * 0.25, h + 6, size.width * 0.52, h - 14);
    path.quadraticBezierTo(size.width * 0.80, h - 32, size.width, h - 10);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _DetailSkriningHeaderClipper oldClipper) =>
      oldClipper.offsetY != offsetY;
}