import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DokterSkriningPage extends StatefulWidget {
  final VoidCallback? onBackToHome;

  const DokterSkriningPage({super.key, this.onBackToHome});

  @override
  State<DokterSkriningPage> createState() => _DokterSkriningPageState();
}

class _DokterSkriningPageState extends State<DokterSkriningPage> {
  String _searchQuery = '';
  String _selectedFilter = 'Semua'; // 'Semua', 'Positif', 'Negatif', 'Pending'

  bool _isPositiveResult(String tingkatRisiko, String laporanText) {
    final gabungan = '$tingkatRisiko $laporanText'.toLowerCase();
    return gabungan.contains('positif') ||
        gabungan.contains('tinggi') ||
        gabungan.contains('berisiko');
  }

  String _extractNamaPasien(Map<String, dynamic> data, String laporanText) {
    if (data['namaPasien'] != null &&
        data['namaPasien'].toString().trim().isNotEmpty) {
      return data['namaPasien'].toString().trim();
    }
    if (data['senderName'] != null &&
        data['senderName'].toString().trim().isNotEmpty) {
      return data['senderName'].toString().trim();
    }
    for (final line in laporanText.split('\n')) {
      final cleanLine = line.trim();
      if (cleanLine.startsWith('• Nama:') || cleanLine.startsWith('Nama:')) {
        return cleanLine
            .replaceFirst('• Nama:', '')
            .replaceFirst('Nama:', '')
            .trim();
      }
    }
    return 'Pasien Terdaftar';
  }

  String _formatWaktu(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final dt = timestamp.toDate();
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final jam = dt.hour.toString().padLeft(2, '0');
    final menit = dt.minute.toString().padLeft(2, '0');
    return '${dt.day} ${bulan[dt.month]} ${dt.year} • $jam:$menit WIB';
  }

  void _bukaPreviewDokumenPdf(
      BuildContext context, {
        required DocumentReference docRef,
        required Map<String, dynamic> data,
        required String namaPasien,
        required bool isPositif,
        required String tingkatRisiko,
        required String waktuKirim,
      }) {
    final String laporanText = (data['text'] ?? '').toString();
    final bool isVerified = data['isVerified'] == true;
    final TextEditingController catatanController = TextEditingController(
      text: (data['catatanVerifikasi'] ?? '').toString(),
    );

    final String fileName = (data['fileName'] ??
        'Laporan_Skrining_${namaPasien.replaceAll(' ', '_')}.pdf')
        .toString();

    final List<String> barisLaporan = laporanText
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (_, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  // Header Dokumen PDF
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 14, 12),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_rounded,
                            color: Colors.redAccent,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fileName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                waktuKirim,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFE2E8F0)),

                  // Isi Kertas Laporan Medis
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(20),
                      children: [
                        // Lembar Putih Ala Dokumen PDF Klinis
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  const Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DIORA HEALTHCARE',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.1,
                                          color: Color(0xFF4F46E5),
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Resume Hasil Skrining Diabetes',
                                        style: TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w900,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isPositif
                                          ? const Color(0xFFFEE2E2)
                                          : const Color(0xFFDCFCE7),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      isPositif
                                          ? 'POSITIF / RISIKO TINGGI'
                                          : 'NEGATIF / RISIKO RENDAH',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w900,
                                        color: isPositif
                                            ? const Color(0xFFB91C1C)
                                            : const Color(0xFF15803D),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Divider(color: Color(0xFFF1F5F9)),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  const Icon(Icons.person_outline_rounded,
                                      size: 16, color: Color(0xFF64748B)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Pasien: $namaPasien',
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.analytics_outlined,
                                      size: 16, color: Color(0xFF64748B)),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Klasifikasi Model: $tingkatRisiko',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isPositif
                                          ? Colors.redAccent
                                          : const Color(0xFF059669),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Text(
                                'Rincian Parameter & Gejala Terlapor:',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF334155),
                                ),
                              ),
                              const SizedBox(height: 8),
                              ...barisLaporan.map((baris) {
                                final isBullet = baris.startsWith('•') ||
                                    baris.startsWith('-');
                                return Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: isBullet
                                        ? const Color(0xFFF8FAFC)
                                        : const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    baris,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: isBullet
                                          ? FontWeight.w600
                                          : FontWeight.w800,
                                      color: const Color(0xFF1E293B),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Catatan Verifikasi Dokter
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Catatan Verifikasi & Tindak Lanjut Dokter',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: catatanController,
                                maxLines: 2,
                                readOnly: isVerified,
                                decoration: InputDecoration(
                                  hintText:
                                  'Contoh: Dianjurkan cek HbA1c & GDP di Klinik Sentosa...',
                                  hintStyle: const TextStyle(fontSize: 11.5),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Tombol Aksi Verifikasi
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isVerified
                                ? null
                                : () async {
                              await docRef.update({
                                'isVerified': true,
                                'catatanVerifikasi':
                                catatanController.text.trim(),
                                'verifiedAt':
                                FieldValue.serverTimestamp(),
                              });
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                              if (mounted) {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Dokumen PDF skrining berhasil diverifikasi.'),
                                    backgroundColor: Color(0xFF059669),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                            icon: Icon(
                              isVerified
                                  ? Icons.verified_rounded
                                  : Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              isVerified
                                  ? 'Dokumen Sudah Terverifikasi'
                                  : 'Verifikasi Hasil Skrining Ini',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isVerified
                                  ? const Color(0xFF059669)
                                  : const Color(0xFF4F46E5),
                              disabledBackgroundColor: const Color(0xFF10B981),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSummaryHeader(
      int total, int totalPositif, int totalNegatif, int belumVerifikasi) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF4F46E5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.22),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.folder_shared_rounded,
                      color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Arsip PDF Skrining Pasien',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$belumVerifikasi Perlu Review',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFDE047),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildMiniStat('Total PDF', '$total', Colors.white),
              const SizedBox(width: 8),
              _buildMiniStat(
                  'Positif / Tinggi', '$totalPositif', const Color(0xFFFCA5A5)),
              const SizedBox(width: 8),
              _buildMiniStat(
                  'Negatif / Rendah', '$totalNegatif', const Color(0xFF6EE7B7)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.11),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: valueColor,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFFE0E7FF),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterRow(
      int total, int totalPositif, int totalNegatif, int belumVerifikasi) {
    final filters = [
      {'key': 'Semua', 'label': 'Semua ($total)'},
      {'key': 'Positif', 'label': 'Positif ($totalPositif)'},
      {'key': 'Negatif', 'label': 'Negatif ($totalNegatif)'},
      {'key': 'Pending', 'label': 'Belum Verifikasi ($belumVerifikasi)'},
    ];

    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final item = filters[index];
          final String key = item['key'] as String;
          final String label = item['label'] as String;
          final bool selected = _selectedFilter == key;

          Color activeColor = const Color(0xFF4F46E5);
          if (key == 'Positif') activeColor = Colors.redAccent;
          if (key == 'Negatif') activeColor = const Color(0xFF059669);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => setState(() => _selectedFilter = key),
              selectedColor: activeColor,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : const Color(0xFF475569),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: selected ? activeColor : const Color(0xFFE2E8F0),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed:
          widget.onBackToHome ?? () => Navigator.of(context).maybePop(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verifikasi Medis & PDF Skrining',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Tinjau & verifikasi laporan PDF hasil skrining pasien',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('messages')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];

          // Ambil semua pesan yang merupakan laporan skrining / PDF
          final List<QueryDocumentSnapshot> pdfDocs = allDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final bool isSummary = data['isScreeningSummary'] == true;
            final String type = (data['type'] ?? '').toString().toLowerCase();
            final String text = (data['text'] ?? '').toString().toLowerCase();
            final String fileName =
            (data['fileName'] ?? '').toString().toLowerCase();

            return isSummary ||
                type == 'pdf' ||
                fileName.endsWith('.pdf') ||
                text.contains('hasil skrining');
          }).toList();

          // Urutkan terbaru di atas
          pdfDocs.sort((a, b) {
            final tsA =
            (a.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            final tsB =
            (b.data() as Map<String, dynamic>)['timestamp'] as Timestamp?;
            if (tsA == null && tsB == null) return 0;
            if (tsA == null) return 1;
            if (tsB == null) return -1;
            return tsB.compareTo(tsA);
          });

          int totalPositif = 0;
          int totalNegatif = 0;
          int belumVerifikasi = 0;

          for (final doc in pdfDocs) {
            final data = doc.data() as Map<String, dynamic>;
            final String text = (data['text'] ?? '').toString();
            final String risiko =
            (data['tingkatRisiko'] ?? 'Risiko Rendah').toString();
            if (_isPositiveResult(risiko, text)) {
              totalPositif++;
            } else {
              totalNegatif++;
            }
            if (data['isVerified'] != true) {
              belumVerifikasi++;
            }
          }

          final filteredDocs = pdfDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final String text = (data['text'] ?? '').toString();
            final String risiko =
            (data['tingkatRisiko'] ?? 'Risiko Rendah').toString();
            final String nama = _extractNamaPasien(data, text);
            final bool isPos = _isPositiveResult(risiko, text);
            final bool isVer = data['isVerified'] == true;

            if (_selectedFilter == 'Positif' && !isPos) return false;
            if (_selectedFilter == 'Negatif' && isPos) return false;
            if (_selectedFilter == 'Pending' && isVer) return false;

            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              return nama.toLowerCase().contains(q) ||
                  text.toLowerCase().contains(q) ||
                  risiko.toLowerCase().contains(q);
            }
            return true;
          }).toList();

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Ringkasan Statistik PDF
              _buildSummaryHeader(
                pdfDocs.length,
                totalPositif,
                totalNegatif,
                belumVerifikasi,
              ),
              const SizedBox(height: 14),

              // 2. Pencarian Pasien
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Cari nama pasien, gejala, atau hasil...',
                    hintStyle:
                    TextStyle(fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: Icon(Icons.search_rounded,
                        color: Color(0xFF4F46E5), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Filter Tab (Semua / Positif / Negatif / Belum Verifikasi)
              _buildFilterRow(
                pdfDocs.length,
                totalPositif,
                totalNegatif,
                belumVerifikasi,
              ),
              const SizedBox(height: 14),

              // 4. Daftar Dokumen PDF
              if (filteredDocs.isEmpty)
                Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.picture_as_pdf_outlined,
                          size: 46, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text(
                        pdfDocs.isEmpty
                            ? 'Belum ada dokumen PDF hasil skrining yang dikirim pasien lewat chat.'
                            : 'Tidak ada dokumen PDF pada kategori filter ini.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredDocs.map((docSnapshot) {
                  final data = docSnapshot.data() as Map<String, dynamic>;
                  final String laporanText = (data['text'] ?? '').toString();
                  final String tingkatRisiko =
                  (data['tingkatRisiko'] ?? 'Risiko Rendah').toString();
                  final bool isVerified = data['isVerified'] == true;
                  final Timestamp? timestamp = data['timestamp'] as Timestamp?;
                  final String waktuKirim = _formatWaktu(timestamp);
                  final String namaPasien =
                  _extractNamaPasien(data, laporanText);
                  final bool isPositif =
                  _isPositiveResult(tingkatRisiko, laporanText);
                  final String fileName = (data['fileName'] ??
                      'Skrining_${namaPasien.replaceAll(' ', '_')}.pdf')
                      .toString();

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPositif
                            ? Colors.redAccent.withValues(alpha: 0.35)
                            : const Color(0xFFE2E8F0),
                        width: isPositif ? 1.3 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(11),
                              decoration: BoxDecoration(
                                color: isPositif
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.picture_as_pdf_rounded,
                                color: isPositif
                                    ? Colors.redAccent
                                    : const Color(0xFF059669),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    namaPasien,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    fileName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF4F46E5),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    waktuKirim,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: isPositif
                                    ? const Color(0xFFFEE2E2)
                                    : const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                isPositif ? 'Positif' : 'Negatif',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  color: isPositif
                                      ? const Color(0xFFB91C1C)
                                      : const Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            laporanText,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF475569),
                              height: 1.35,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  isVerified
                                      ? Icons.verified_rounded
                                      : Icons.pending_actions_rounded,
                                  size: 14,
                                  color: isVerified
                                      ? const Color(0xFF059669)
                                      : Colors.orange.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isVerified
                                      ? 'Terverifikasi Dokter'
                                      : 'Menunggu Verifikasi',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isVerified
                                        ? const Color(0xFF059669)
                                        : Colors.orange.shade800,
                                  ),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () => _bukaPreviewDokumenPdf(
                                context,
                                docRef: docSnapshot.reference,
                                data: data,
                                namaPasien: namaPasien,
                                isPositif: isPositif,
                                tingkatRisiko: tingkatRisiko,
                                waktuKirim: waktuKirim,
                              ),
                              icon: const Icon(Icons.visibility_rounded,
                                  size: 15, color: Colors.white),
                              label: const Text(
                                'Buka PDF',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}