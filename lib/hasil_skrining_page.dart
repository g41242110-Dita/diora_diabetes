import 'package:flutter/material.dart';

class HasilSkriningPage extends StatelessWidget {
  const HasilSkriningPage({super.key});

  @override
  Widget build(BuildContext context) {
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
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hasil Skrining Diabetes',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              SizedBox(height: 4),
                              Text('Hasil : Positif', style: TextStyle(fontSize: 12)),
                              Text('Pukul Skrining : 10:30', style: TextStyle(fontSize: 12)),
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
                              content: const [
                                'Nama : Aurelia Prisilla',
                                'Tanggal Lahir : 21 September 2003',
                                'Usia : 22 Tahun',
                                'Jenis Kelamin : Perempuan',
                                'Tanggal Skrining : 01 September 2026',
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Ringkasan Hasil
                          Expanded(
                            child: _buildInfoCard(
                              title: 'Ringkasan Hasil',
                              bodyText:
                              'Berdasarkan hasil skrining, Anda memiliki kemungkinan tinggi mengalami diabetes. Kami menyarankan untuk melakukan pemeriksaan lebih lanjut di fasilitas kesehatan.',
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
                      _buildQuestionsTable(),
                      const SizedBox(height: 16),

                      // Banner Hasil Skrining Positif
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA8A8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Center(
                          child: Text(
                            'Hasil Skrining : Positif',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rekomendasi
                      const Text(
                        'Rekomendasi',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text('• Cek kadar gula darah puasa', style: TextStyle(fontSize: 11)),
                      const Text('• Cek gula darah 2 jam setelah makan', style: TextStyle(fontSize: 11)),
                      const Text('• HbA1c (jika diperlukan)', style: TextStyle(fontSize: 11)),
                      const Text('• Konsultasi dengan dokter spesialis penyakit dalam / endokrin', style: TextStyle(fontSize: 11)),
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
                                    'Hasil skrining ini bukan pemeriksaan terakhir. Untuk hasil yang lebih akurat, harap melakukan pemeriksaan langsung di fasilitas kesehatan.',
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

  // Helper Widget Tabel Pertanyaan
  Widget _buildQuestionsTable() {
    final List<Map<String, String>> data = [
      {'q': '1. Apakah kamu sering buang air kecil (BAK)?', 'a': 'Iya'},
      {'q': '2. Apakah kamu sering merasa haus?', 'a': 'Iya'},
      {'q': '3. Apakah berat badan kamu turun secara drastis tanpa sebab yang jelas?', 'a': 'Tidak'},
      {'q': '4. Apakah kamu sering merasa lemas atau mudah lelah?', 'a': 'Iya'},
      {'q': '5. Apakah kamu sering merasa lapar meskipun sudah makan?', 'a': 'Iya'},
      {'q': '6. Apakah kamu sering mengalami infeksi jamur, terutama di area genital?', 'a': 'Iya'},
      {'q': '7. Apakah penglihatan kamu sering terasa kabur?', 'a': 'Tidak'},
      {'q': '8. Apakah kamu sering mengalami gatal-gatal pada kulit?', 'a': 'Iya'},
      {'q': '9. Apakah kamu mudah merasa marah atau mengalami perubahan suasana hati?', 'a': 'Iya'},
      {'q': '10. Apakah luka pada tubuh kamu sulit sembuh?', 'a': 'Tidak'},
      {'q': '11. Apakah kamu pernah mengalami kelemahan pada sebagian tubuh?', 'a': 'Iya'},
      {'q': '12. Apakah kamu sering mengalami kaku atau tegang pada otot?', 'a': 'Iya'},
      {'q': '13. Apakah kamu mengalami kerontokan rambut yang tidak biasa?', 'a': 'Tidak'},
      {'q': '14. Apakah berat badan kamu termasuk berlebih/obesitas?', 'a': 'Iya'},
    ];

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
            verticalInside: BorderSide(color: Colors.black87, width: 1),
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
                      item['q']!,
                      style: const TextStyle(fontSize: 8.5),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 8),
                    child: Text(
                      item['a']!,
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