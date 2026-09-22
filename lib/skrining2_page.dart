import 'package:flutter/material.dart';

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
    2: [11, 12, 13, 14],     // Step 4/4
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

  // Fungsi untuk menampilkan Pop-up Peringatan
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
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Mengerti', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // Fungsi untuk berpindah ke step berikutnya
  void _nextStep() {
    // 1. Cek dulu apakah Data Diri sudah terisi semua
    if (!_isDataDiriComplete()) {
      _showWarningDialog('Data diri (Nama, Umur, Jenis Kelamin) belum lengkap. Harap lengkapi data diri Anda terlebih dahulu!');
      return;
    }

    // 2. Cek apakah semua pertanyaan di step/halaman aktif sudah dijawab
    if (!_isCurrentStepComplete()) {
      _showWarningDialog('Harap isi semua pertanyaan pada halaman ini terlebih dahulu sebelum melanjutkan!');
      return;
    }

    // Jika data diri dan pertanyaan sudah lengkap, baru berpindah halaman
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // AKSI AKHIR: Navigasi ke halaman Hasil / Akhir Skrining
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Skrining Selesai! Memproses hasil...')),
      );
      // Contoh jika mau pindah halaman ke HasilPage:
      // Navigator.push(context, MaterialPageRoute(builder: (context) => HasilPage(jawaban: _jawaban)));
    }
  }

  // Fungsi untuk kembali ke step sebelumnya
  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Jika di step pertama (2/4), tombol kembali akan menutup halaman ini
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Menentukan teks indikator progress (2/4, 3/4, 4/4) dan nilainya
    final String progressText = '${_currentStep + 2}/4';
    final double progressValue = (_currentStep + 2) / 4;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Header Fixed (Tombol Back, Judul, Progress Indicator)
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

            // PageView untuk Pertanyaan (Swipeable / Navigable)
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(), // Mematikan geser manual agar harus lewat tombol
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildStepLayout([
                    _buildQuestionItem(1, '1. Apakah kamu sering buang air kecil (BAK)?'),
                    _buildQuestionItem(2, '2. Apakah kamu sering merasa haus?'),
                    _buildQuestionItem(3, '3. Apakah berat badan kamu turun secara drastis tanpa sebab yang jelas?'),
                    _buildQuestionItem(4, '4. Apakah kamu sering merasa lemas atau mudah lelah?'),
                    _buildQuestionItem(5, '5. Apakah kamu sering merasa lapar meskipun sudah makan?'),
                  ]),
                  _buildStepLayout([
                    _buildQuestionItem(6, '6. Apakah kamu sering mengalami infeksi jamur, terutama di area genital?'),
                    _buildQuestionItem(7, '7. Apakah penglihatan kamu sering terasa kabur?'),
                    _buildQuestionItem(8, '8. Apakah kamu sering mengalami gatal-gatal pada kulit?'),
                    _buildQuestionItem(9, '9. Apakah kamu mudah merasa marah atau mengalami perubahan suasana hati?'),
                    _buildQuestionItem(10, '10. Apakah luka pada tubuh kamu sulit sembuh?'),
                  ]),
                  _buildStepLayout([
                    _buildQuestionItem(11, '11. Apakah kamu pernah mengalami kelemahan pada sebagian tubuh?'),
                    _buildQuestionItem(12, '12. Apakah kamu sering mengalami kaku atau tegang pada otot?'),
                    _buildQuestionItem(13, '13. Apakah kamu mengalami kerontokan rambut yang tidak biasa?'),
                    _buildQuestionItem(14, '14. Apakah berat badan kamu termasuk berlebih/obesitas?'),
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

  // Wrapper SingleChildScrollView untuk daftar pertanyaan per step
  Widget _buildStepLayout(List<Widget> questions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        children: questions,
      ),
    );
  }

  // Helper Widget Pertanyaan Radio
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