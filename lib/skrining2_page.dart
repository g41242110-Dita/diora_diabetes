import 'package:flutter/material.dart';
import 'hasil_skrining_page.dart'; // Import file Hasil Skrining kamu

class Skrining2Page extends StatefulWidget {
  final String nama;
  final String umur;
  final String jenisKelamin;

  const Skrining2Page({
    super.key,
    required this.nama,
    required this.umur,
    required this.jenisKelamin,
  });

  @override
  State<Skrining2Page> createState() => _Skrining2PageState();
}

class _Skrining2PageState extends State<Skrining2Page> {
  // Controller untuk mengatur perpindahan halaman/step
  final PageController _pageController = PageController();
  int _currentStep = 0; // 0 = Step 2/4, 1 = Step 3/4, 2 = Step 4/4

  // Pemetaan nomor pertanyaan untuk tiap step
  final Map<int, List<int>> _stepQuestions = {
    0: [1, 2, 3, 4, 5],      // Step 2/4
    1: [6, 7, 8, 9, 10],     // Step 3/4
    2: [11, 12, 13, 14],     // Step 4/4 (Skrining 5/Selesai)
  };

  // Map untuk menyimpan semua jawaban pertanyaan 1 sampai 14 (true = Iya, false = Tidak)
  final Map<int, bool?> _jawaban = {
    1: null,
    2: null,
    3: null,
    4: null,
    5: null,
    6: null,
    7: null,
    8: null,
    9: null,
    10: null,
    11: null,
    12: null,
    13: null,
    14: null,
  };

  // Teks pertanyaan lengkap untuk dipassing ke halaman hasil
  final Map<int, String> _pertanyaanText = {
    1: '1. Apakah kamu sering buang air kecil (BAK)?',
    2: '2. Apakah kamu sering merasa haus?',
    3: '3. Apakah berat badan kamu turun secara drastis tanpa sebab yang jelas?',
    4: '4. Apakah kamu sering merasa lemas atau mudah lelah?',
    5: '5. Apakah kamu sering merasa lapar meskipun sudah makan?',
    6: '6. Apakah kamu sering mengalami infeksi jamur, terutama di area genital?',
    7: '7. Apakah penglihatan kamu sering terasa kabur?',
    8: '8. Apakah kamu sering mengalami gatal-gatal pada kulit?',
    9: '9. Apakah kamu mudah merasa marah atau mengalami perubahan suasana hati?',
    10: '10. Apakah luka pada tubuh kamu sulit sembuh?',
    11: '11. Apakah kamu pernah mengalami kelemahan pada sebagian tubuh?',
    12: '12. Apakah kamu sering mengalami kaku atau tegang pada otot?',
    13: '13. Apakah kamu mengalami kerontokan rambut yang tidak biasa?',
    14: '14. Apakah berat badan kamu termasuk berlebih/obesitas?',
  };

  // Validasi Data Diri (Nama, Umur, Jenis Kelamin)
  bool _isDataDiriComplete() {
    return widget.nama.trim().isNotEmpty &&
        widget.umur.trim().isNotEmpty &&
        widget.jenisKelamin.trim().isNotEmpty;
  }

  // Validasi Pertanyaan Skrining di step aktif
  bool _isCurrentStepComplete() {
    List<int>? activeQuestions = _stepQuestions[_currentStep];
    if (activeQuestions == null) return false;

    for (int qNo in activeQuestions) {
      if (_jawaban[qNo] == null) {
        return false; // Ada pertanyaan yang belum dijawab
      }
    }
    return true; // Semua pertanyaan di step ini sudah dijawab
  }

  // Fungsi Pop-up Peringatan
  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                'Data Belum Lengkap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            message,
            style: const TextStyle(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6679F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi Berpindah Step atau Memproses Hasil Akhir
  void _nextStep() {
    // 1. Cek Data Diri
    if (!_isDataDiriComplete()) {
      _showWarningDialog('Data diri belum lengkap. Harap isi data diri terlebih dahulu!');
      return;
    }

    // 2. Cek Jawaban Pertanyaan di Step Aktif
    if (!_isCurrentStepComplete()) {
      _showWarningDialog('Harap isi semua pertanyaan pada halaman ini sebelum melanjutkan!');
      return;
    }

    // 3. Jika belum di step terakhir, geser ke step berikutnya
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 4. STEP AKHIR (Skrining 5 / Selesai): Hitung & Pindah ke HasilSkriningPage
      _finishSkrining();
    }
  }

  void _finishSkrining() {
    // Menghitung jumlah jawaban "Iya"
    int totalIya = _jawaban.values.where((val) => val == true).length;
    
    // Penentuan hasil ringkas (contoh: jika jawaban 'Iya' >= 5 dianggap Risiko Tinggi / Positif)
    bool isPositif = totalIya >= 5;

    // Menyiapkan daftar data pertanyaan dan jawaban untuk tabel hasil
    List<Map<String, String>> formattedTableData = [];
    _pertanyaanText.forEach((no, qText) {
      formattedTableData.add({
        'q': qText,
        'a': _jawaban[no] == true ? 'Iya' : 'Tidak',
      });
    });

    // Pindah Langsung Ke HasilSkriningPage
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HasilSkriningPage(
          nama: widget.nama,
          umur: widget.umur,
          jenisKelamin: widget.jenisKelamin,
          isPositif: isPositif,
          tableData: formattedTableData,
        ),
      ),
    );
  }

  // Fungsi Kembali ke Step Sebelumnya
  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final String progressText = '${_currentStep + 2}/4';
    final double progressValue = (_currentStep + 2) / 4;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Fixed
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
                    onPressed: _prevStep,
                  ),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Skrining Gejala Diabetes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        progressText,
                        style: const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progressValue,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF6679F4),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),

            // PageView Pertanyaan
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  // Step 2/4 (Pertanyaan 1-5)
                  _buildStepLayout([
                    _buildQuestionItem(1, _pertanyaanText[1]!),
                    _buildQuestionItem(2, _pertanyaanText[2]!),
                    _buildQuestionItem(3, _pertanyaanText[3]!),
                    _buildQuestionItem(4, _pertanyaanText[4]!),
                    _buildQuestionItem(5, _pertanyaanText[5]!),
                  ]),
                  // Step 3/4 (Pertanyaan 6-10)
                  _buildStepLayout([
                    _buildQuestionItem(6, _pertanyaanText[6]!),
                    _buildQuestionItem(7, _pertanyaanText[7]!),
                    _buildQuestionItem(8, _pertanyaanText[8]!),
                    _buildQuestionItem(9, _pertanyaanText[9]!),
                    _buildQuestionItem(10, _pertanyaanText[10]!),
                  ]),
                  // Step 4/4 / Skrining 5 (Pertanyaan 11-14)
                  _buildStepLayout([
                    _buildQuestionItem(11, _pertanyaanText[11]!),
                    _buildQuestionItem(12, _pertanyaanText[12]!),
                    _buildQuestionItem(13, _pertanyaanText[13]!),
                    _buildQuestionItem(14, _pertanyaanText[14]!),
                  ]),
                ],
              ),
            ),

            // Navigation Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _prevStep,
                      icon: const Icon(Icons.arrow_back, size: 16),
                      label: const Text('Kembali'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6679F4),
                        side: const BorderSide(color: Color(0xFF6679F4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _nextStep,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6679F4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentStep == 2 ? 'Lihat Hasil' : 'Lanjutkan',
                            style: const TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                        ],
                      ),
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

  Widget _buildStepLayout(List<Widget> questions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: questions,
      ),
    );
  }

  Widget _buildQuestionItem(int no, String pertanyaan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pertanyaan,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Iya', style: TextStyle(fontSize: 12)),
                  value: true,
                  groupValue: _jawaban[no],
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF6679F4),
                  onChanged: (val) {
                    setState(() => _jawaban[no] = val);
                  },
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Tidak', style: TextStyle(fontSize: 12)),
                  value: false,
                  groupValue: _jawaban[no],
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: const Color(0xFF6679F4),
                  onChanged: (val) {
                    setState(() => _jawaban[no] = val);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}