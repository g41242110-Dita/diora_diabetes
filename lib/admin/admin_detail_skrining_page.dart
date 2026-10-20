import 'package:flutter/material.dart';

class AdminDetailSkriningPage extends StatelessWidget {
  final String patientName;
  final String status;
  final String date;

  const AdminDetailSkriningPage({
    Key? key,
    this.patientName = 'Aurelia Prisilla',
    this.status = 'Positif',
    this.date = '01 September 2026, 10.35',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isPositive = status == 'Positif';

    // Data Dummy Pertanyaan & Jawaban (Kolom Kiri)
    final List<Map<String, String>> answersLeft = [
      {'q': '1. Sering BAP?', 'a': 'Ya'},
      {'q': '2. Sering merasa haus?', 'a': 'Ya'},
      {'q': '3. Berat badan turun drastis?', 'a': 'Tidak'},
      {'q': '4. Sering kesemutan / linu / pegal', 'a': 'Ya'},
      {'q': '5. Sering lapar meskipun sudah makan?', 'a': 'Ya'},
      {'q': '6. Infeksi jamur disekitar area genital?', 'a': 'Ya'},
      {'q': '7. Penglihatan kabur?', 'a': 'Tidak'},
    ];

    // Data Dummy Pertanyaan & Jawaban (Kolom Kanan)
    final List<Map<String, String>> answersRight = [
      {'q': '8. Gatal-gatal pada kulit?', 'a': 'Ya'},
      {'q': '9. Mudah marah/perubahan suasana hati?', 'a': 'Ya'},
      {'q': '10. Luka sulit sembuh?', 'a': 'Tidak'},
      {'q': '11. Kelemahan pada sebagian tubuh?', 'a': 'Ya'},
      {'q': '12. Kaku atau tegang otot', 'a': 'Ya'},
      {'q': '13. Kerontokan rambut', 'a': 'Tidak'},
      {'q': '14. Obesitas?', 'a': 'Ya'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Detail Hasil Skrining', style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.blueAccent),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Data Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.amber,
                      child: Icon(Icons.person, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Data Pengguna', style: TextStyle(fontSize: 10, color: Colors.grey)),
                          Text(patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 12, color: Colors.grey),
                              const Text(' 22 Tahun ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              const Icon(Icons.female, size: 12, color: Colors.grey),
                              const Text(' Perempuan ', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                              Expanded(
                                child: Text(' $date', style: const TextStyle(fontSize: 10, color: Colors.grey), overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Result Banner Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isPositive ? Colors.red.shade100 : Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isPositive)
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: Colors.red.shade300, borderRadius: BorderRadius.circular(10)),
                        child: const Text('Perlu Pemeriksaan Lanjut', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                  Row(
                    children: [
                      Icon(isPositive ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                          color: isPositive ? Colors.red : Colors.green, size: 36),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Hasil Skrining', style: TextStyle(color: isPositive ? Colors.red : Colors.green, fontSize: 12)),
                          Text(status, style: TextStyle(color: isPositive ? Colors.red : Colors.green, fontSize: 20, fontWeight: FontWeight.bold)),
                          Text(isPositive ? 'Terdeteksi Risiko Diabetes' : 'Tidak Terdeteksi Risiko Diabetes',
                              style: TextStyle(color: isPositive ? Colors.red : Colors.green, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPositive
                        ? 'Hasil skrining menunjukkan adanya beberapa faktor/gejala yang mengarah pada risiko diabetes. Disarankan untuk melakukan pemeriksaan lebih lanjut di fasilitas kesehatan.'
                        : 'Hasil skrining menunjukkan kondisi Anda saat ini dalam batas aman/normal. Tetap jaga pola hidup sehat.',
                    style: TextStyle(color: isPositive ? Colors.red : Colors.green, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Table Ringkasan Jawaban
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.assignment, color: Colors.blueAccent, size: 20),
                        SizedBox(width: 8),
                        Text('Ringkasan Jawaban', style: TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Table(
                      columnWidths: const {
                        0: FlexColumnWidth(3),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(3),
                        3: FlexColumnWidth(1),
                      },
                      border: TableBorder.all(color: Colors.grey.shade300),
                      children: [
                        const TableRow(
                          decoration: BoxDecoration(color: Colors.black12),
                          children: [
                            Padding(padding: EdgeInsets.all(4), child: Text('Pertanyaan', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(4), child: Text('Jawaban', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(4), child: Text('Pertanyaan', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                            Padding(padding: EdgeInsets.all(4), child: Text('Jawaban', textAlign: TextAlign.center, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold))),
                          ],
                        ),
                        for (int i = 0; i < answersLeft.length; i++)
                          TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(4), child: Text(answersLeft[i]['q']!, style: const TextStyle(fontSize: 9))),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: answersLeft[i]['a'] == 'Ya' ? Colors.red.shade100 : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(answersLeft[i]['a']!, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: answersLeft[i]['a'] == 'Ya' ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                                ),
                              ),
                              Padding(padding: const EdgeInsets.all(4), child: Text(answersRight[i]['q']!, style: const TextStyle(fontSize: 9))),
                              Padding(
                                padding: const EdgeInsets.all(4),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: answersRight[i]['a'] == 'Ya' ? Colors.red.shade100 : Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(answersRight[i]['a']!, textAlign: TextAlign.center, style: TextStyle(fontSize: 9, color: answersRight[i]['a'] == 'Ya' ? Colors.red : Colors.green, fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}