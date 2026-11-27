import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DokterRiwayatKonsultasiPage extends StatefulWidget {
  final String doctorId;

  const DokterRiwayatKonsultasiPage({super.key, required this.doctorId});

  @override
  State<DokterRiwayatKonsultasiPage> createState() =>
      _DokterRiwayatKonsultasiPageState();
}

class _DokterRiwayatKonsultasiPageState
    extends State<DokterRiwayatKonsultasiPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'Semua'; // 'Semua', 'Lengkap', 'Kosong'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTanggal(Timestamp? timestamp) {
    if (timestamp == null) return 'Baru saja';
    final date = timestamp.toDate();
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
    final jam = date.hour.toString().padLeft(2, '0');
    final menit = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${bulan[date.month]} ${date.year} • $jam:$menit';
  }

  String _extractNamaPasien(Map<String, dynamic> data, String roomId) {
    final fromField =
    (data['namaPasien'] ?? data['patientName'] ?? '').toString().trim();
    if (fromField.isNotEmpty) return fromField;

    final parts = roomId.split('_');
    if (parts.isNotEmpty && parts[0].trim().isNotEmpty) {
      return parts[0].trim();
    }
    return 'Pasien';
  }

  String _extractSlotSesi(String roomId) {
    final parts = roomId.split('_');
    if (parts.length >= 3) {
      final rawSlot = parts.sublist(2).join('_').trim();
      if (rawSlot.isNotEmpty) {
        return rawSlot.replaceAll('-', ' - ');
      }
    }
    return '';
  }

  bool _hasMedicalNotes(String diagnosa, String resep) {
    final d = diagnosa.trim();
    final r = resep.trim();
    return (d.isNotEmpty && d != '-') || (r.isNotEmpty && r != '-');
  }

  void _showEditCatatanDialog(
      BuildContext context, {
        required DocumentReference docRef,
        required String namaPasien,
        required String currentDiagnosa,
        required String currentResep,
      }) {
    final diagCtrl = TextEditingController(
      text: currentDiagnosa == '-' ? '' : currentDiagnosa,
    );
    final resepCtrl = TextEditingController(
      text: currentResep == '-' ? '' : currentResep,
    );

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                color: Color(0xFF4F46E5),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Catatan Medis Pasien',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    namaPasien,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Diagnosa / Evaluasi Dokter',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: diagCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'Contoh: Risiko diabetes tipe 2, disarankan cek GDP...',
                  hintStyle: const TextStyle(fontSize: 11.5),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Resep Digital / Anjuran',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: resepCtrl,
                maxLines: 2,
                style: const TextStyle(fontSize: 12.5),
                decoration: InputDecoration(
                  hintText: 'Contoh: Diet rendah gula & kontrol 3 hari lagi',
                  hintStyle: const TextStyle(fontSize: 11.5),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w700),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await docRef.set({
                'diagnosa': diagCtrl.text.trim(),
                'resep': resepCtrl.text.trim(),
                'updatedAt': FieldValue.serverTimestamp(),
              }, SetOptions(merge: true));

              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Catatan medis berhasil diperbarui.'),
                    backgroundColor: Color(0xFF059669),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Simpan Catatan',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBanner(int total, int lengkap, int kosong) {
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
            color: const Color(0xFF4F46E5).withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history_edu_rounded, color: Colors.white, size: 19),
              SizedBox(width: 8),
              Text(
                'Rekam Jejak Konsultasi Selesai',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatBox('Total Sesi', '$total', Colors.white),
              const SizedBox(width: 8),
              _buildStatBox(
                  'Ada Catatan', '$lengkap', const Color(0xFF6EE7B7)),
              const SizedBox(width: 8),
              _buildStatBox(
                  'Belum Diisi', '$kosong', const Color(0xFFFDE047)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color valueColor) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
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

  Widget _buildFilterChips(int total, int lengkap, int kosong) {
    final filters = [
      {'key': 'Semua', 'label': 'Semua ($total)'},
      {'key': 'Lengkap', 'label': 'Ada Catatan ($lengkap)'},
      {'key': 'Kosong', 'label': 'Belum Diisi ($kosong)'},
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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Konsultasi Pasien',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16.5,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              'Arsip diagnosa, resep digital & sesi selesai',
              style: TextStyle(fontSize: 10.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('chats')
            .where('isEnded', isEqualTo: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }

          final allDocs = snapshot.data?.docs ?? [];
          final doctorDocs = allDocs
              .where((doc) => doc.id.contains(widget.doctorId))
              .toList();

          doctorDocs.sort((a, b) {
            final tsA =
            (a.data() as Map<String, dynamic>)['endedAt'] as Timestamp?;
            final tsB =
            (b.data() as Map<String, dynamic>)['endedAt'] as Timestamp?;
            if (tsA == null && tsB == null) return 0;
            if (tsA == null) return 1;
            if (tsB == null) return -1;
            return tsB.compareTo(tsA);
          });

          int lengkapCount = 0;
          int kosongCount = 0;

          for (final doc in doctorDocs) {
            final d = doc.data() as Map<String, dynamic>;
            final diag = (d['diagnosa'] ?? '').toString();
            final resp = (d['resep'] ?? '').toString();
            if (_hasMedicalNotes(diag, resp)) {
              lengkapCount++;
            } else {
              kosongCount++;
            }
          }

          final filteredDocs = doctorDocs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final namaPasien = _extractNamaPasien(data, doc.id);
            final diag = (data['diagnosa'] ?? '').toString();
            final resp = (data['resep'] ?? '').toString();
            final hasNotes = _hasMedicalNotes(diag, resp);

            if (_selectedFilter == 'Lengkap' && !hasNotes) return false;
            if (_selectedFilter == 'Kosong' && hasNotes) return false;

            if (_searchQuery.isNotEmpty) {
              final q = _searchQuery.toLowerCase();
              return namaPasien.toLowerCase().contains(q) ||
                  diag.toLowerCase().contains(q) ||
                  resp.toLowerCase().contains(q);
            }
            return true;
          }).toList();

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatsBanner(
                doctorDocs.length,
                lengkapCount,
                kosongCount,
              ),
              const SizedBox(height: 12),

              // Search Bar
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => setState(() => _searchQuery = val.trim()),
                  decoration: InputDecoration(
                    hintText: 'Cari nama pasien, diagnosa, atau resep...',
                    hintStyle: const TextStyle(
                        fontSize: 12.5, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: Color(0xFF4F46E5),
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          size: 18, color: Color(0xFF94A3B8)),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              _buildFilterChips(
                doctorDocs.length,
                lengkapCount,
                kosongCount,
              ),
              const SizedBox(height: 14),

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
                      Icon(Icons.folder_open_rounded,
                          size: 46, color: Colors.grey.shade300),
                      const SizedBox(height: 10),
                      Text(
                        doctorDocs.isEmpty
                            ? 'Belum ada riwayat konsultasi selesai.'
                            : 'Tidak ada riwayat yang cocok dengan pencarian/filter.',
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
                ...filteredDocs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final namaPasien = _extractNamaPasien(data, doc.id);
                  final slotSesi = _extractSlotSesi(doc.id);
                  final tanggalSelesai =
                  _formatTanggal(data['endedAt'] as Timestamp?);
                  final rawDiag = (data['diagnosa'] ?? '').toString().trim();
                  final rawResep = (data['resep'] ?? '').toString().trim();
                  final hasDiag = rawDiag.isNotEmpty && rawDiag != '-';
                  final hasResep = rawResep.isNotEmpty && rawResep != '-';
                  final inisial = namaPasien.isNotEmpty
                      ? namaPasien[0].toUpperCase()
                      : 'P';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
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
                          children: [
                            CircleAvatar(
                              radius: 21,
                              backgroundColor: const Color(0xFFEEF2FF),
                              child: Text(
                                inisial,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF4F46E5),
                                ),
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
                                      fontWeight: FontWeight.w900,
                                      fontSize: 14,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    slotSesi.isNotEmpty
                                        ? '$tanggalSelesai • Sesi $slotSesi'
                                        : tanggalSelesai,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 9, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFDCFCE7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Selesai',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF15803D),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Kotak Diagnosa
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.medical_information_outlined,
                                      size: 14, color: Color(0xFF4F46E5)),
                                  SizedBox(width: 5),
                                  Text(
                                    'Diagnosa / Evaluasi',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasDiag
                                    ? rawDiag
                                    : 'Belum ada catatan diagnosa',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: hasDiag
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontStyle: hasDiag
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                  color: hasDiag
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Kotak Resep / Anjuran
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(11),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.medication_outlined,
                                      size: 14, color: Color(0xFF15803D)),
                                  SizedBox(width: 5),
                                  Text(
                                    'Resep / Anjuran Dokter',
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF166534),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                hasResep
                                    ? rawResep
                                    : 'Belum ada resep atau anjuran lanjutan',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: hasResep
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontStyle: hasResep
                                      ? FontStyle.normal
                                      : FontStyle.italic,
                                  color: hasResep
                                      ? const Color(0xFF14532D)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: () => _showEditCatatanDialog(
                              context,
                              docRef: doc.reference,
                              namaPasien: namaPasien,
                              currentDiagnosa: rawDiag,
                              currentResep: rawResep,
                            ),
                            icon: const Icon(Icons.edit_rounded,
                                size: 15, color: Color(0xFF4F46E5)),
                            label: Text(
                              _hasMedicalNotes(rawDiag, rawResep)
                                  ? 'Edit Catatan'
                                  : 'Isi Catatan Medis',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                          ),
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