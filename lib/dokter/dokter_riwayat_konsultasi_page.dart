import 'package:flutter/material.dart';

class DokterRiwayatKonsultasiPage extends StatefulWidget {
  const DokterRiwayatKonsultasiPage({super.key});

  @override
  State<DokterRiwayatKonsultasiPage> createState() =>
      _DokterRiwayatKonsultasiPageState();
}

class _DokterRiwayatKonsultasiPageState
    extends State<DokterRiwayatKonsultasiPage> {
  final TextEditingController _searchController = TextEditingController();

  // Data dummy daftar sesi riwayat konsultasi pasien
  final List<Map<String, String>> _riwayatSelesai = [
    {
      'nama': 'Aurelia Priscilla',
      'genderAge': '20 th • Perempuan',
      'tanggal': '14 Feb 2026',
      'jamSesi': '09.40 - 10.00',
      'diagnosa': 'Pre-diabetes, disarankan cek laboratorium HbA1c',
      'resep': 'Metformin 500mg (2x1), Edukasi Pola Makan',
      'statusMedis': 'Positif',
    },
    {
      'nama': 'Budi Hartono',
      'genderAge': '48 th • Laki-Laki',
      'tanggal': '14 Feb 2026',
      'jamSesi': '10.00 - 10.30',
      'diagnosa': 'Diabetes Mellitus Tipe 2 terkontrol',
      'resep': 'Glimepiride 2mg (1x1 pagi)',
      'statusMedis': 'Positif',
    },
    {
      'nama': 'Dewi Lestari',
      'genderAge': '30 th • Perempuan',
      'tanggal': '12 Feb 2026',
      'jamSesi': '10.30 - 11.00',
      'diagnosa': 'Gejala dispepsia ringan, gula darah normal',
      'resep': 'Antasida Doen (3x1 sebelum makan)',
      'statusMedis': 'Negatif',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Riwayat Konsultasi Pasien',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF0F172A),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Search Bar Pasien
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari nama pasien atau diagnosa...',
                hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4F46E5)),
                fillColor: Colors.white,
                filled: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // List Card Riwayat
            Expanded(
              child: ListView.builder(
                itemCount: _riwayatSelesai.length,
                itemBuilder: (context, index) {
                  final item = _riwayatSelesai[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              item['nama']!,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              item['tanggal']!,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: item['statusMedis'] == 'Positif'
                                    ? Colors.redAccent
                                    : Colors.green,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              item['statusMedis']!,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: item['statusMedis'] == 'Positif'
                                    ? Colors.redAccent
                                    : Colors.green,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '• ${item['genderAge']} • Sesi ${item['jamSesi']}',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20, thickness: 0.8),

                        // Diagnosa
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.medical_information_outlined,
                                size: 14, color: Color(0xFF4F46E5)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Diagnosa: ${item['diagnosa']}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF334155),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Resep
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.medication_outlined,
                                size: 14, color: Color(0xFF16A34A)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Resep/Anjuran: ${item['resep']}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF166534),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}