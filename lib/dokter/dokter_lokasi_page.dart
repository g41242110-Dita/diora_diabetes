import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DokterLokasiPage extends StatefulWidget {
  final VoidCallback? onBackToHome;
  final String? doctorId;

  const DokterLokasiPage({
    super.key,
    this.onBackToHome,
    this.doctorId,
  });

  @override
  State<DokterLokasiPage> createState() => _DokterLokasiPageState();
}

class _DokterLokasiPageState extends State<DokterLokasiPage> {
  String _selectedFilter = 'Semua'; // 'Semua', 'Utama', 'Buka'

  String get _activeDoctorId =>
      (widget.doctorId != null && widget.doctorId!.trim().isNotEmpty)
          ? widget.doctorId!.trim()
          : '1';

  // Pemetaan fasyankes asli dari koleksi 'clinics' (38 fasyankes) per dokter
  // agar tiap dokter punya fasyankes berbeda dan tidak saling sama.
  static const _faskesPerDokter = {
    '1': [
      'Rumah Sakit Perkebunan Jember Klinik',
      'Klinik Rolas Medika Jember',
      'Klinik Unej Medical Center',
    ],
    '2': [
      'Rumah Sakit Umum Daerah dr. Soebandi',
      'Laboratorium Klinik Parahita Jember',
      'Puskesmas Sumbersari',
    ],
    '3': [
      'Rumah Sakit Bina Sehat Jember',
      'Laboratorium Klinik Prodia Jember',
      'Puskesmas Kaliwates',
    ],
    '4': [
      'Siloam Hospitals Jember',
      'Klinik Kimia Farma Jember',
      'Puskesmas Patrang',
    ],
  };

  static const _fallbackPool = [
    [
      'Rumah Sakit Baladhika Husada Jember',
      'Klinik Muhammadiyah Jember',
      'Puskesmas Mangli',
    ],
    [
      'Rumah Sakit Citra Husada Jember',
      'Klinik Nuansa Medika Jember',
      'Puskesmas Gladak Pakem',
    ],
  ];

  List _getDefaultFaskesUntukDokter(String docId) {
    if (_faskesPerDokter.containsKey(docId)) {
      return _faskesPerDokter[docId]!;
    }
    final numVal = int.tryParse(docId) ?? docId.hashCode.abs();
    return _fallbackPool[numVal % _fallbackPool.length];
  }

  List _extractFaskesList(Map doctorData, String docId) {
    final rawList = doctorData['fasyankes_mitra'];
    if (rawList is List && rawList.isNotEmpty) {
      return rawList.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
    }
    return _getDefaultFaskesUntukDokter(docId);
  }

  String _namaHariSekarang() {
    const hariMap = {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
      7: 'Minggu',
    };
    return hariMap[DateTime.now().weekday] ?? 'Senin';
  }

  String _cekInfoJadwalHariIni(Map doctorData) {
    final hariIni = _namaHariSekarang();
    final jadwalShift = doctorData['jadwal_shift'];
    if (jadwalShift is Map) {
      final shiftHari = jadwalShift[hariIni];
      if (shiftHari is Map) {
        final aktif = shiftHari['isActive'] == true;
        final mulai = (shiftHari['jamMulai'] ?? 7).toString().padLeft(2, '0');
        final selesai = (shiftHari['jamSelesai'] ?? 15).toString().padLeft(2, '0');
        final namaShift = (shiftHari['namaShift'] ?? 'Shift').toString();
        if (!aktif) {
          return 'Shift $hariIni NONAKTIF — aman untuk konsultasi aplikasi tanpa bentrok dinas.';
        }
        return '$namaShift ($mulai.00 - $selesai.00 WIB) • Atur slot konsultasi di luar jam dinas fasyankes.';
      }
    }
    return 'Pastikan jam dinas fisik & slot konsultasi aplikasi tidak tumpang tindih.';
  }

  bool _isShiftAktifHariIni(Map doctorData) {
    final hariIni = _namaHariSekarang();
    final jadwalShift = doctorData['jadwal_shift'];
    if (jadwalShift is Map && jadwalShift[hariIni] is Map) {
      return (jadwalShift[hariIni] as Map)['isActive'] == true;
    }
    return false;
  }

  List _getFasilitasDiabetes(String namaFaskes) {
    final lower = namaFaskes.toLowerCase();
    if (lower.contains('rumah sakit') || lower.contains('siloam')) {
      return [
        'Poli Spesialis Penyakit Dalam & Metabolik',
        'Laboratorium Cek HbA1c, GDP & GDS',
        'Instalasi Gawat Darurat & Rawat Inap Terpadu',
      ];
    } else if (lower.contains('puskesmas')) {
      return [
        'Layanan Skrining & Pemeriksaan Glukosa Rutin',
        'Program Pengelolaan Penyakit Kronis (Prolanis)',
        'Konsultasi Kesehatan Primer & Edukasi Gizi',
      ];
    }
    return [
      'Pemeriksaan Glukosa Darah & Skrining Risiko',
      'Konsultasi Rawat Jalan & Edukasi Gaya Hidup',
      'Layanan Penunjang Kesehatan Terpadu',
    ];
  }

  Future<void> _setFaskesDinasUtama(String namaFaskes) async {
    try {
      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(_activeDoctorId)
          .set({
        'klinikUtama': namaFaskes,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Faskes dinas utama diperbarui ke $namaFaskes'),
          backgroundColor: const Color(0xFF4F46E5),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memperbarui faskes dinas: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _showEditFaskesSheet(
      BuildContext context, {
        required DocumentReference? docRef,
        required Map faskes,
      }) {
    final String nama = (faskes['name'] ?? '').toString();
    final jamCtrl = TextEditingController(
      text: (faskes['jam'] ?? '08.00 - 20.00').toString(),
    );
    final catatanCtrl = TextEditingController(
      text: (faskes['catatanLab'] ??
          'Layanan pemeriksaan glukosa darah & skrining metabolik.')
          .toString(),
    );
    String statusDipilih =
    (faskes['status'] ?? 'Buka').toString().toLowerCase() == 'tutup'
        ? 'Tutup'
        : 'Buka';
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              padding: EdgeInsets.fromLTRB(
                20,
                14,
                20,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Edit Operasional Fasyankes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              nama,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF4F46E5),
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
                  const Divider(height: 14, color: Color(0xFFF1F5F9)),
                  const Text(
                    'Status Operasional (Sinkron ke Pengguna)',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Buka', 'Tutup'].map((opsi) {
                      final aktif = statusDipilih == opsi;
                      final warna = opsi == 'Buka'
                          ? const Color(0xFF059669)
                          : Colors.redAccent;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: opsi == 'Buka' ? 8 : 0,
                              left: opsi == 'Tutup' ? 8 : 0),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: () =>
                                setModalState(() => statusDipilih = opsi),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: aktif
                                    ? warna.withValues(alpha: 0.12)
                                    : const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: aktif
                                      ? warna
                                      : const Color(0xFFE2E8F0),
                                  width: aktif ? 1.5 : 1.0,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                opsi,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w800,
                                  color: aktif
                                      ? warna
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Jam Operasional',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: jamCtrl,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.access_time_rounded,
                          size: 18, color: Color(0xFF4F46E5)),
                      hintText: 'Contoh: 08.00 - 20.00 atau 24 Jam',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Catatan Layanan Lab & Skrining Diabetes',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF334155),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: catatanCtrl,
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12.5),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.biotech_outlined,
                          size: 18, color: Color(0xFF4F46E5)),
                      hintText:
                      'Contoh: Tersedia cek HbA1c & puasa setiap pagi...',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: isSaving
                          ? null
                          : () async {
                        setModalState(() => isSaving = true);
                        try {
                          if (docRef != null) {
                            await docRef.update({
                              'status': statusDipilih,
                              'jam': jamCtrl.text.trim(),
                              'catatanLab': catatanCtrl.text.trim(),
                            });
                          } else {
                            final snap = await FirebaseFirestore.instance
                                .collection('clinics')
                                .where('name', isEqualTo: nama)
                                .limit(1)
                                .get();
                            if (snap.docs.isNotEmpty) {
                              await snap.docs.first.reference.update({
                                'status': statusDipilih,
                                'jam': jamCtrl.text.trim(),
                                'catatanLab': catatanCtrl.text.trim(),
                              });
                            }
                          }

                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Data fasyankes disimpan & tersinkron ke pengguna.'),
                                backgroundColor: Color(0xFF059669),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          setModalState(() => isSaving = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal menyimpan: $e'),
                                backgroundColor: Colors.redAccent,
                              ),
                            );
                          }
                        }
                      },
                      icon: isSaving
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.save_rounded,
                          color: Colors.white, size: 18),
                      label: Text(
                        isSaving ? 'Menyimpan...' : 'Simpan Perubahan',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
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

  void _salinInfoRujukan(Map faskes) {
    final catatan = (faskes['catatanLab'] ?? '').toString().trim();
    final teksRujukan = 'Rujukan Pemeriksaan Laboratorium Diabetes:\n'
        '• Faskes: ${faskes['name']}\n'
        '• Alamat: ${faskes['address']}\n'
        '• Jam Operasional: ${faskes['jam']} WIB (${faskes['status']})\n'
        '• Telepon: ${faskes['phone']}'
        '${catatan.isNotEmpty ? '\n• Catatan Lab: $catatan' : ''}';

    Clipboard.setData(ClipboardData(text: teksRujukan));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
            'Info rujukan fasyankes disalin! Siap ditempel di chat pasien.'),
        backgroundColor: Color(0xFF059669),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Widget _buildTopSummaryCard(
      String namaDokter,
      String faskesUtama,
      int jumlahFaskes,
      int jumlahBuka,
      String infoJadwal,
      bool shiftAktif,
      ) {
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
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.hub_rounded, color: Colors.white, size: 19),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Fasyankes • $namaDokter',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$jumlahBuka/$jumlahFaskes Buka',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6EE7B7),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Dinas Utama: $faskesUtama',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFFE0E7FF),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  shiftAktif
                      ? Icons.event_available_rounded
                      : Icons.verified_user_outlined,
                  size: 15,
                  color: shiftAktif
                      ? const Color(0xFFFDE047)
                      : const Color(0xFF6EE7B7),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    infoJadwal,
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterRow(int total) {
    final filters = [
      {'key': 'Semua', 'label': 'Semua ($total)'},
      {'key': 'Utama', 'label': 'Dinas Utama'},
      {'key': 'Buka', 'label': 'Sedang Buka'},
    ];

    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final item = filters[index];
          final String key = item['key'] as String;
          final String label = item['label'] as String;
          final bool selected = _selectedFilter == key;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(label),
              selected: selected,
              onSelected: (_) => setState(() => _selectedFilter = key),
              selectedColor: const Color(0xFF4F46E5),
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: selected ? Colors.white : const Color(0xFF475569),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: selected
                      ? const Color(0xFF4F46E5)
                      : const Color(0xFFE2E8F0),
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
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed:
          widget.onBackToHome ?? () => Navigator.of(context).maybePop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokasi Praktik dan Faskes',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 2),
            Text(
              'Fasyankes mitra per dokter & sinkronisasi jadwal dinas',
              style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doctors')
            .doc(_activeDoctorId)
            .snapshots(),
        builder: (context, doctorSnap) {
          final Map doctorData =
          (doctorSnap.hasData && doctorSnap.data!.exists)
              ? (doctorSnap.data!.data() as Map)
              : {};

          final String namaDokter =
          (doctorData['nama'] ?? 'Dokter').toString();
          final List targetNames = _extractFaskesList(doctorData, _activeDoctorId);
          final String defaultUtama = targetNames.isNotEmpty
              ? targetNames.first.toString()
              : 'Rumah Sakit Perkebunan Jember Klinik';
          final String savedUtama =
          (doctorData['klinikUtama'] ?? '').toString().trim();
          final String faskesUtamaDokter =
          savedUtama.isNotEmpty ? savedUtama : defaultUtama;
          final String infoJadwal = _cekInfoJadwalHariIni(doctorData);
          final bool shiftAktif = _isShiftAktifHariIni(doctorData);

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('clinics')
                .snapshots(),
            builder: (context, clinicSnap) {
              final items = List.empty(growable: true);

              if (clinicSnap.hasData && clinicSnap.data!.docs.isNotEmpty) {
                for (final namaTarget in targetNames) {
                  final targetStr = namaTarget.toString().trim();
                  final match = clinicSnap.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return (data['name'] ?? '').toString().trim() == targetStr;
                  }).toList();

                  if (match.isNotEmpty) {
                    final doc = match.first;
                    final data = doc.data() as Map<String, dynamic>;
                    items.add({
                      ...data,
                      '_docRef': doc.reference,
                    });
                  } else {
                    items.add({
                      'name': targetStr,
                      'category': targetStr.toLowerCase().contains('rumah sakit')
                          ? 'Rumah Sakit'
                          : (targetStr.toLowerCase().contains('puskesmas')
                          ? 'Puskesmas'
                          : 'Klinik'),
                      'address': 'Kabupaten Jember',
                      'phone': '-',
                      'jam': '08.00 - 16.00',
                      'status': 'Buka',
                      'jarak': '-',
                      'catatanLab':
                      'Layanan pemeriksaan glukosa darah & skrining metabolik.',
                    });
                  }
                }
              } else {
                for (final namaTarget in targetNames) {
                  final targetStr = namaTarget.toString().trim();
                  items.add({
                    'name': targetStr,
                    'category': targetStr.toLowerCase().contains('rumah sakit')
                        ? 'Rumah Sakit'
                        : (targetStr.toLowerCase().contains('puskesmas')
                        ? 'Puskesmas'
                        : 'Klinik'),
                    'address': 'Kabupaten Jember',
                    'phone': '-',
                    'jam': '08.00 - 16.00',
                    'status': 'Buka',
                    'jarak': '-',
                    'catatanLab':
                    'Layanan pemeriksaan glukosa darah & skrining metabolik.',
                  });
                }
              }

              int jumlahBuka = 0;
              for (final item in items) {
                final st =
                ((item as Map)['status'] ?? 'Buka').toString().toLowerCase();
                if (st == 'buka') jumlahBuka++;
              }

              final filteredItems = items.where((item) {
                final map = item as Map;
                final nama = (map['name'] ?? '').toString();
                final status = (map['status'] ?? 'Buka').toString();
                final isUtama =
                    faskesUtamaDokter.toLowerCase() == nama.toLowerCase();
                final isBuka = status.toLowerCase() == 'buka';

                if (_selectedFilter == 'Utama' && !isUtama) return false;
                if (_selectedFilter == 'Buka' && !isBuka) return false;
                return true;
              }).toList();

              return ListView(
                padding: const EdgeInsets.all(16.0),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildTopSummaryCard(
                    namaDokter,
                    faskesUtamaDokter,
                    items.length,
                    jumlahBuka,
                    infoJadwal,
                    shiftAktif,
                  ),
                  const SizedBox(height: 12),
                  _buildFilterRow(items.length),
                  const SizedBox(height: 14),
                  ...filteredItems.map((item) {
                    final faskes = item as Map;
                    final String nama = (faskes['name'] ?? '').toString();
                    final String category =
                    (faskes['category'] ?? 'Klinik').toString();
                    final String alamat = (faskes['address'] ?? '').toString();
                    final String jarak = (faskes['jarak'] ?? '-').toString();
                    final String telepon = (faskes['phone'] ?? '-').toString();
                    final String jam = (faskes['jam'] ?? '-').toString();
                    final String status =
                    (faskes['status'] ?? 'Buka').toString();
                    final String catatanLab =
                    (faskes['catatanLab'] ?? '').toString().trim();
                    final DocumentReference? docRef =
                    faskes['_docRef'] as DocumentReference?;

                    final bool isDinasAktif =
                        faskesUtamaDokter.toLowerCase() == nama.toLowerCase();
                    final bool isBuka = status.toLowerCase() == 'buka';
                    final List fasilitasList = _getFasilitasDiabetes(nama);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isDinasAktif
                              ? const Color(0xFF4F46E5)
                              : const Color(0xFFE2E8F0),
                          width: isDinasAktif ? 1.5 : 1.0,
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
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: category == 'Rumah Sakit'
                                      ? const Color(0xFFE0F2FE)
                                      : const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  category == 'Rumah Sakit'
                                      ? Icons.local_hospital_rounded
                                      : Icons.medical_services_rounded,
                                  color: category == 'Rumah Sakit'
                                      ? const Color(0xFF0284C7)
                                      : const Color(0xFF4F46E5),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      nama,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Color(0xFF0F172A)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      alamat,
                                      style: const TextStyle(
                                          fontSize: 11.5,
                                          color: Color(0xFF64748B)),
                                    ),
                                  ],
                                ),
                              ),
                              if (isDinasAktif)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFDCFCE7),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: const Color(0xFF86EFAC)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle,
                                          size: 6, color: Color(0xFF166534)),
                                      SizedBox(width: 4),
                                      Text(
                                        'Dinas Aktif',
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF166534)),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isBuka
                                        ? const Color(0xFFDCFCE7)
                                        : const Color(0xFFFEE2E2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isBuka
                                          ? const Color(0xFF15803D)
                                          : const Color(0xFFB91C1C),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.near_me_outlined,
                                    size: 13, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(jarak,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B))),
                                const SizedBox(width: 12),
                                const Icon(Icons.phone_outlined,
                                    size: 13, color: Color(0xFF64748B)),
                                const SizedBox(width: 4),
                                Text(telepon,
                                    style: const TextStyle(
                                        fontSize: 11,
                                        color: Color(0xFF64748B))),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(11),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border:
                              Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded,
                                        size: 14, color: Color(0xFF4F46E5)),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        'Jam Operasional: $jam WIB',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF4F46E5)),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () => _showEditFaskesSheet(
                                        context,
                                        docRef: docRef,
                                        faskes: faskes,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFEEF2FF),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.edit_rounded,
                                                size: 11,
                                                color: Color(0xFF4F46E5)),
                                            SizedBox(width: 3),
                                            Text(
                                              'Edit',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF4F46E5),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (catatanLab.isNotEmpty) ...[
                                  const SizedBox(height: 6),
                                  Text(
                                    catatanLab,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF475569),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Layanan dan Fasilitas Terpadu:',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF475569)),
                          ),
                          const SizedBox(height: 4),
                          ...fasilitasList.map(
                                (fItem) => Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Row(
                                children: [
                                  const Text('• ',
                                      style: TextStyle(
                                          color: Color(0xFF94A3B8),
                                          fontSize: 11)),
                                  Expanded(
                                    child: Text(
                                      fItem.toString(),
                                      style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 38,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _salinInfoRujukan(faskes),
                                    icon: const Icon(Icons.copy_rounded,
                                        size: 14, color: Color(0xFF4F46E5)),
                                    label: const Text(
                                      'Salin Rujukan',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF4F46E5),
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                          color: Color(0xFFC7D2FE)),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                          BorderRadius.circular(12)),
                                    ),
                                  ),
                                ),
                              ),
                              if (!isDinasAktif) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: SizedBox(
                                    height: 38,
                                    child: ElevatedButton(
                                      onPressed: () =>
                                          _setFaskesDinasUtama(nama),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                        const Color(0xFF4F46E5),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(12)),
                                      ),
                                      child: const Text(
                                        'Set Dinas Utama',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}