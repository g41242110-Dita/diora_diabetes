import 'package:flutter/material.dart';

// Model Pertanyaan Kuesioner
class QuestionItem {
  final int number;
  final String question;
  final bool isYes;

  QuestionItem({
    required this.number,
    required this.question,
    required this.isYes,
  });
}

// Model Data Pasien Skrining
class PatientScreening {
  final String id;
  final String name;
  final String gender;
  final int age;
  final bool isPositive;
  final int affirmativeSymptoms;
  final int totalSymptoms;
  final String date;
  final List<QuestionItem> questionnaireAnswers;

  PatientScreening({
    required this.id,
    required this.name,
    required this.gender,
    required this.age,
    required this.isPositive,
    required this.affirmativeSymptoms,
    this.totalSymptoms = 7,
    required this.date,
    required this.questionnaireAnswers,
  });
}

class DokterSkriningPage extends StatefulWidget {
  const DokterSkriningPage({super.key});

  @override
  State<DokterSkriningPage> createState() => _DokterSkriningPageState();
}

class _DokterSkriningPageState extends State<DokterSkriningPage> {
  int selectedFilterIndex = 0;
  String searchQuery = "";

  // Data Dummy lengkap dengan 14 pertanyaan kuesioner
  final List<PatientScreening> allPatients = [
    PatientScreening(
      id: 'GS-20250917-001',
      name: 'Aurelia Prisilla',
      gender: 'Perempuan',
      age: 20,
      isPositive: true,
      affirmativeSymptoms: 5,
      date: '17 September 2025',
      questionnaireAnswers: [
        QuestionItem(number: 1, question: 'Apakah kamu sering buang air kecil (BAK)?', isYes: true),
        QuestionItem(number: 2, question: 'Apakah kamu sering merasa haus?', isYes: true),
        QuestionItem(number: 3, question: 'Apakah berat badan kamu turun secara drastis tanpa sebab yang jelas?', isYes: false),
        QuestionItem(number: 4, question: 'Apakah kamu sering merasa lemas atau mudah lelah?', isYes: true),
        QuestionItem(number: 5, question: 'Apakah kamu sering merasa lapar meskipun sudah makan?', isYes: true),
        QuestionItem(number: 6, question: 'Apakah kamu sering mengalami infeksi jamur, terutama di area genital?', isYes: true),
        QuestionItem(number: 7, question: 'Apakah penglihatan kamu sering terasa kabur?', isYes: false),
        QuestionItem(number: 8, question: 'Apakah kamu sering mengalami gatal-gatal pada kulit?', isYes: true),
        QuestionItem(number: 9, question: 'Apakah kamu mudah merasa marah atau mengalami perubahan suasana hati?', isYes: true),
        QuestionItem(number: 10, question: 'Apakah luka pada tubuh kamu sulit sembuh?', isYes: false),
        QuestionItem(number: 11, question: 'Apakah kamu pernah mengalami kelemahan pada sebagian tubuh?', isYes: true),
        QuestionItem(number: 12, question: 'Apakah kamu sering mengalami kaku atau tegang pada otot?', isYes: true),
        QuestionItem(number: 13, question: 'Apakah kamu mengalami kerontokan rambut yang tidak biasa?', isYes: false),
        QuestionItem(number: 14, question: 'Apakah berat badan kamu termasuk berlebih/obesitas?', isYes: true),
      ],
    ),
    PatientScreening(
      id: 'GS-20250917-002',
      name: 'Budi Hartono',
      gender: 'Laki-laki',
      age: 48,
      isPositive: true,
      affirmativeSymptoms: 6,
      date: '17 September 2025',
      questionnaireAnswers: [
        QuestionItem(number: 1, question: 'Apakah kamu sering buang air kecil (BAK)?', isYes: true),
        QuestionItem(number: 2, question: 'Apakah kamu sering merasa haus?', isYes: true),
        QuestionItem(number: 3, question: 'Apakah berat badan kamu turun secara drastis tanpa sebab yang jelas?', isYes: true),
        QuestionItem(number: 4, question: 'Apakah kamu sering merasa lemas atau mudah lelah?', isYes: true),
        QuestionItem(number: 5, question: 'Apakah kamu sering merasa lapar meskipun sudah makan?', isYes: false),
        QuestionItem(number: 6, question: 'Apakah kamu sering mengalami infeksi jamur, terutama di area genital?', isYes: true),
        QuestionItem(number: 7, question: 'Apakah penglihatan kamu sering terasa kabur?', isYes: true),
        QuestionItem(number: 8, question: 'Apakah kamu sering mengalami gatal-gatal pada kulit?', isYes: false),
        QuestionItem(number: 9, question: 'Apakah kamu mudah merasa marah atau mengalami perubahan suasana hati?', isYes: true),
        QuestionItem(number: 10, question: 'Apakah luka pada tubuh kamu sulit sembuh?', isYes: false),
        QuestionItem(number: 11, question: 'Apakah kamu pernah mengalami kelemahan pada sebagian tubuh?', isYes: false),
        QuestionItem(number: 12, question: 'Apakah kamu sering mengalami kaku atau tegang pada otot?', isYes: false),
        QuestionItem(number: 13, question: 'Apakah kamu mengalami kerontokan rambut yang tidak biasa?', isYes: false),
        QuestionItem(number: 14, question: 'Apakah berat badan kamu termasuk berlebih/obesitas?', isYes: false),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    int positiveCount = allPatients.where((p) => p.isPositive).length;
    int negativeCount = allPatients.where((p) => !p.isPositive).length;

    List<PatientScreening> filteredPatients = allPatients.where((patient) {
      bool matchesSearch = patient.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
          patient.id.toLowerCase().contains(searchQuery.toLowerCase());

      if (!matchesSearch) return false;
      if (selectedFilterIndex == 1) return patient.isPositive;
      if (selectedFilterIndex == 2) return !patient.isPositive;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Triase & Skrining Pasien',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2761)),
                        ),
                        SizedBox(height: 2),
                        Text('Daftar kuesioner risiko diabetes masuk', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: const Color(0xFFEEF2FF), borderRadius: BorderRadius.circular(12)),
                    child: Text('${allPatients.length} Pasien', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF4F46E5))),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFF4F46E5).withOpacity(0.3), width: 1.2),
                ),
                child: TextField(
                  onChanged: (val) => setState(() => searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'Cari nama pasien atau ID Skrining',
                    hintStyle: TextStyle(fontSize: 12.5, color: Colors.grey),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF4F46E5), size: 20),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterTab(0, 'Semua (${allPatients.length})'),
                    const SizedBox(width: 8),
                    _buildFilterTab(1, 'Positif ($positiveCount)'),
                    const SizedBox(width: 8),
                    _buildFilterTab(2, 'Negatif ($negativeCount)'),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: filteredPatients.isEmpty
                    ? const Center(child: Text('Tidak ada data pasien ditemukan', style: TextStyle(color: Colors.grey, fontSize: 13)))
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filteredPatients.length,
                        itemBuilder: (context, index) => _buildPatientCard(filteredPatients[index]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterTab(int index, String label) {
    bool isSelected = selectedFilterIndex == index;
    return GestureDetector(
      onTap: () => setState(() => selectedFilterIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade300),
        ),
        child: Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: isSelected ? Colors.white : Colors.grey.shade700)),
      ),
    );
  }

  Widget _buildPatientCard(PatientScreening patient) {
    Color statusColor = patient.isPositive ? Colors.redAccent : Colors.green;
    String statusText = patient.isPositive ? 'Positif' : 'Negatif';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.name, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                    const SizedBox(height: 2),
                    Text('ID: ${patient.id} • ${patient.gender}, ${patient.age} th', style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
                  ],
                ),
              ),
              Row(
                children: [
                  Container(width: 6, height: 6, decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Prediksi', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 2),
                  Text(statusText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: statusColor)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Gejala Afirmatif', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 2),
                  Text('${patient.affirmativeSymptoms} dari ${patient.totalSymptoms} "YA"', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Tanggal', style: TextStyle(fontSize: 10, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 2),
                  Text(patient.date, style: const TextStyle(fontSize: 11, color: Color(0xFF0F172A))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () => _showScreeningReportModal(context, patient),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4F46E5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Rincian', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF4F46E5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Chat', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showScreeningReportModal(BuildContext context, PatientScreening patient) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(16),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Laporan Hasil Skrining', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E2761))),
                        const SizedBox(height: 2),
                        Text('Nomor Dokumen: ${patient.id}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFFFFE5D0),
                        child: Icon(Icons.person, color: Colors.orange, size: 26),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(patient.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
                            const SizedBox(height: 2),
                            Text('${patient.gender}, ${patient.age} tahun', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: patient.isPositive ? const Color(0xFFFFD8D8) : const Color(0xFFD3F9D8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(width: 5, height: 5, decoration: BoxDecoration(color: patient.isPositive ? Colors.red : Colors.green, shape: BoxShape.circle)),
                            const SizedBox(width: 4),
                            Text(patient.isPositive ? 'Positif' : 'Negatif', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: patient.isPositive ? Colors.red.shade700 : Colors.green.shade700)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text('Tanggal Skrining: ${patient.date}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 10),
                const Text('Rincian Jawaban Kuesioner Pasien (14 Pertanyaan)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
                const SizedBox(height: 8),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: patient.questionnaireAnswers.length,
                    itemBuilder: (context, index) {
                      final item = patient.questionnaireAnswers[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: Colors.grey.shade200,
                              child: Text('${item.number}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(child: Text(item.question, style: const TextStyle(fontSize: 11, color: Colors.black87))),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: item.isYes ? const Color(0xFFFFD8D8) : const Color(0xFFD3F9D8),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                item.isYes ? 'Ya' : 'Tidak',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: item.isYes ? Colors.red.shade700 : Colors.green.shade700),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.black87),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Text('Mulai Chat', style: TextStyle(fontSize: 12, color: Colors.black87)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: SizedBox(
                        height: 38,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailHasilSkriningPage(patient: patient),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4F46E5),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          ),
                          child: const Text('HASIL SKRINING', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// =========================================================================
// HALAMAN DETAIL HASIL SKRINING (Dokumen Lengkap - Tombol Chat Dihapus)
// =========================================================================
class DetailHasilSkriningPage extends StatelessWidget {
  final PatientScreening patient;

  const DetailHasilSkriningPage({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    Color statusColor = patient.isPositive ? Colors.redAccent : Colors.green;
    String statusText = patient.isPositive ? 'Positif' : 'Negatif';

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'HASIL SKRINING',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E2761)),
            ),
            Text(
              '${patient.name} (${patient.id})',
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: patient.isPositive ? const Color(0xFFFFD8D8) : const Color(0xFFD3F9D8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.medical_services, color: Color(0xFF4F46E5), size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Diora',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Hasil Skrining Diabetes', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      Text('Hasil: $statusText • Pukul Skrining : 10:30', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
              const Divider(height: 24),
              const Center(
                child: Text(
                  'Laporan Hasil Skrining Diabetes',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1E2761)),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Data Pengguna', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text('Nama : ${patient.name}', style: const TextStyle(fontSize: 10, color: Colors.black87)),
                          const Text('Tanggal Lahir : 21 September 2003', style: const TextStyle(fontSize: 10, color: Colors.black87)),
                          Text('Usia : ${patient.age} Tahun', style: const TextStyle(fontSize: 10, color: Colors.black87)),
                          Text('Jenis Kelamin : ${patient.gender}', style: const TextStyle(fontSize: 10, color: Colors.black87)),
                          Text('Tanggal Skrining : ${patient.date}', style: const TextStyle(fontSize: 10, color: Colors.black87)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Ringkasan Hasil', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text(
                            'Berdasarkan hasil skrining, Anda memiliki kemungkinan tinggi mengalami diabetes. Kami menyarankan untuk melakukan pemeriksaan lebih lanjut di fasilitas kesehatan.',
                            style: TextStyle(fontSize: 9.5, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Hasil Skrining', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: const {
                  0: FlexColumnWidth(4),
                  1: FlexColumnWidth(1),
                },
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: const [
                      Padding(padding: EdgeInsets.all(8.0), child: Text('Pertanyaan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          'Jawab',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  ...patient.questionnaireAnswers.map((item) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text('${item.number}. ${item.question}', style: const TextStyle(fontSize: 10)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            item.isYes ? 'Iya' : 'Tidak',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: item.isYes ? Colors.red.shade700 : Colors.green.shade700,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: patient.isPositive ? const Color(0xFFFFD8D8) : const Color(0xFFD3F9D8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Hasil Skrining : $statusText',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: patient.isPositive ? Colors.red.shade800 : Colors.green.shade800),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Rekomendasi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('• Cek kadar gula darah puasa', style: TextStyle(fontSize: 10, color: Colors.black87)),
              const Text('• Cek gula darah 2 jam setelah makan', style: TextStyle(fontSize: 10, color: Colors.black87)),
              const Text('• HbA1c (jika diperlukan)', style: TextStyle(fontSize: 10, color: Colors.black87)),
              const Text('• Konsultasi dengan dokter spesialis penyakit dalam / endokrin', style: TextStyle(fontSize: 10, color: Colors.black87)),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(Icons.info, color: Color(0xFF4F46E5), size: 16),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Penting\nHasil skrining ini bukan pemeriksaan terakhir. Untuk hasil yang lebih akurat, harap melakukan pemeriksaan langsung di fasilitas kesehatan.',
                        style: TextStyle(fontSize: 9.5, color: Color(0xFF1E2761)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}