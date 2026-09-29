import 'package:flutter/material.dart';
import 'hasil_skrining_page.dart';

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
  // Map jawaban (true = Iya, false = Tidak)
  final Map<int, bool?> _jawaban = {
    for (int i = 1; i <= 14; i++) i: null,
  };

  // Teks pertanyaan lengkap
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

  bool _isDataDiriComplete() {
    return widget.nama.trim().isNotEmpty &&
        widget.umur.trim().isNotEmpty &&
        widget.jenisKelamin.trim().isNotEmpty;
  }

  bool _isAllQuestionsAnswered() {
    for (int i = 1; i <= 14; i++) {
      if (_jawaban[i] == null) return false;
    }
    return true;
  }

  void _showWarningDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                'Data Belum Lengkap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(message, style: const TextStyle(fontSize: 14)),
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

  void _finishSkrining() {
    if (!_isDataDiriComplete()) {
      _showWarningDialog('Data diri belum lengkap!');
      return;
    }

    if (!_isAllQuestionsAnswered()) {
      _showWarningDialog('Harap jawab seluruh pertanyaan skrining!');
      return;
    }

    int totalIya = _jawaban.values.where((val) => val == true).length;
    bool isPositif = totalIya >= 5;

    List<Map<String, String>> formattedTableData = [];
    _pertanyaanText.forEach((no, qText) {
      formattedTableData.add({
        'q': qText,
        'a': _jawaban[no] == true ? 'Iya' : 'Tidak',
      });
    });

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Judul Utama
              const Center(
                child: Text(
                  'Skrining Gejala Diabetes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Progress Bar (2/2 - Full)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 1.0, // Diubah ke 1.0 agar penuh 100%
                        minHeight: 8,
                        backgroundColor: Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6679F4)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '2/2',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Sub-Judul
              const Text(
                'Pertanyaan Gejala Diabetes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Jawablah 14 pertanyaan di bawah ini sesuai kondisi yang kamu rasakan.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // 4. Daftar Pertanyaan 1 - 14
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 14,
                itemBuilder: (context, index) {
                  int no = index + 1;
                  return _buildQuestionItem(no, _pertanyaanText[no]!);
                },
              ),

              const SizedBox(height: 24),

              // 5. Tombol Selesai & Lihat Hasil
              SizedBox(
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
                  onPressed: _finishSkrining,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Selesai & Lihat Hasil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Pertanyaan
  Widget _buildQuestionItem(int no, String pertanyaan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pertanyaan,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          RadioGroup<bool>(
            groupValue: _jawaban[no],
            onChanged: (val) {
              setState(() {
                _jawaban[no] = val;
              });
            },
            child: Row(
              children: [
                // Pilihan "Iya"
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _jawaban[no] = true;
                      });
                    },
                    child: const Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          activeColor: Color(0xFF6679F4),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Iya',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),

                // Pilihan "Tidak"
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _jawaban[no] = false;
                      });
                    },
                    child: const Row(
                      children: [
                        Radio<bool>(
                          value: false,
                          activeColor: Color(0xFF6679F4),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Tidak',
                          style: TextStyle(fontSize: 13, color: Colors.black87),
                        ),
                      ],
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
}