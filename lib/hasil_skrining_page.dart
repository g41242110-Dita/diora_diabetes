import 'package:flutter/material.dart';

class HasilSkriningPage extends StatelessWidget {
  final String nama;
  final String umur;
  final String jenisKelamin;
  final bool isPositif;
  final List<Map<String, String>> tableData;

  const HasilSkriningPage({
    super.key,
    this.nama = 'Aurelia Prisilla',
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
  Widget build(BuildContext context) {
    // Mendapatkan tanggal & jam saat ini secara otomatis
    final DateTime now = DateTime.now();
    final String jamSkrining = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final String tanggalSkrining = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

    // Warna & Teks Dinamis sesuai Hasil Skrining
    final Color statusColor = isPositif ? const Color(0xFFFFA8A8) : const Color(0xFFA8FFA8);
    final Color textColor = isPositif ? Colors.red.shade900 : Colors.green.shade900;
    final String statusText = isPositif ? 'Positif' : 'Negatif';
    final String ringkasanText = isPositif
        ? 'Berdasarkan hasil skrining, Anda memiliki kemungkinan tinggi mengalami diabetes. Kami menyarankan untuk melakukan pemeriksaan lebih lanjut di fasilitas kesehatan.'
        : 'Berdasarkan hasil skrining, Anda memiliki kemungkinan rendah mengalami diabetes. Tetap jaga pola makan dan gaya hidup sehat.';

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
        child: Column(
          children: [
            // Header Judul
            const Text(
              'Hasil Skrining',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Konten Sertifikat / Laporan Hasil Skrining
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black87, width: 1.2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Logo & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/logo.png', // Pastikan path logo sesuai
                                height: 50,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.favorite, color: Color(0xFF6679F4), size: 40),
                              ),
                              const SizedBox(width: 8),
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Diora',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF6679F4),
                                    ),
                                  ),
                                  Text(
                                    'Kenali Risiko, Jaga Masa Depanmu',
                                    style: TextStyle(fontSize: 8, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            height: 50,
                            width: 1,
                            color: Colors.grey.shade400,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Hasil Skrining Diabetes',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              const SizedBox(height: 4),
                              Text('Hasil : $statusText', style: const TextStyle(fontSize: 12)),
                              Text('Pukul Skrining : $jamSkrining', style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.black87, thickness: 1),
                      const SizedBox(height: 8),

                      // Judul Laporan
                      const Center(
                        child: Text(
                          'Laporan Hasil Skrining Diabetes',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Box Data Pengguna & Ringkasan Hasil
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Data Pengguna
                          Expanded(
                            child: _buildInfoCard(
                              title: 'Data Pengguna',
                              content: [
                                'Nama : $nama',
                                'Usia : $umur Tahun',
                                'Jenis Kelamin : $jenisKelamin',
                                'Tanggal Skrining : $tanggalSkrining',
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Ringkasan Hasil
                          Expanded(
                            child: _buildInfoCard(
                              title: 'Ringkasan Hasil',
                              bodyText: ringkasanText,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Tabel Hasil Skrining
                      const Text(
                        'Hasil Skrining',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      _buildQuestionsTable(tableData),
                      const SizedBox(height: 16),

                      // Banner Hasil Skrining (Dinamis Positif / Negatif)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'Hasil Skrining : $statusText',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: textColor,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rekomendasi (Menyesuaikan Hasil)
                      const Text(
                        'Rekomendasi',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      if (isPositif) ...const [
                        Text('• Cek kadar gula darah puasa', style: TextStyle(fontSize: 11)),
                        Text('• Cek gula darah 2 jam setelah makan', style: TextStyle(fontSize: 11)),
                        Text('• HbA1c (jika diperlukan)', style: TextStyle(fontSize: 11)),
                        Text('• Konsultasi dengan dokter spesialis penyakit dalam / endokrin', style: TextStyle(fontSize: 11)),
                      ] else ...const [
                        Text('• Pertahankan pola makan gizi seimbang', style: TextStyle(fontSize: 11)),
                        Text('• Rutin melakukan aktivitas fisik/olahraga', style: TextStyle(fontSize: 11)),
                        Text('• Melakukan tes gula darah secara berkala', style: TextStyle(fontSize: 11)),
                      ],
                      const SizedBox(height: 16),

                      // Box Catatan Penting
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFECEEFE),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Color(0xFF6679F4),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.info, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Penting',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Hasil skrining ini bukan pemeriksaan medis resmi. Untuk penegakan diagnosis yang akurat, harap berkonsultasi ke fasilitas kesehatan.',
                                    style: TextStyle(fontSize: 10, color: Colors.black87),
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

            // Tombol Unduh Hasil Skrining
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
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Mengunduh Hasil Skrining...')),
                    );
                  },
                  child: const Text(
                    'Unduh Hasil Skrining',
                    style: TextStyle(
                      fontSize: 16,
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

  // Helper Widget Card Data & Ringkasan
  Widget _buildInfoCard({
    required String title,
    List<String>? content,
    String? bodyText,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          if (content != null)
            ...content.map(
              (text) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(text, style: const TextStyle(fontSize: 9, color: Colors.black87)),
              ),
            ),
          if (bodyText != null)
            Text(
              bodyText,
              style: const TextStyle(fontSize: 9.5, color: Colors.black87, height: 1.3),
            ),
        ],
      ),
    );
  }

  // Helper Widget Tabel Pertanyaan Dinamis
  Widget _buildQuestionsTable(List<Map<String, String>> data) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Table(
          columnWidths: const {
            0: FlexColumnWidth(4),
            1: FlexColumnWidth(1),
          },
          border: TableBorder(
            horizontalInside: BorderSide(color: Colors.grey.shade300, width: 0.5),
            verticalInside: const BorderSide(color: Colors.black87, width: 1),
            top: const BorderSide(color: Colors.black87, width: 1),
            bottom: const BorderSide(color: Colors.black87, width: 1),
          ),
          children: [
            const TableRow(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Text(
                    'Pertanyaan',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                  child: Text(
                    'Jawab',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            ...data.map(
              (item) => TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    child: Text(
                      item['q'] ?? '',
                      style: const TextStyle(fontSize: 8.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    child: Text(
                      item['a'] ?? '',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 8.5),
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