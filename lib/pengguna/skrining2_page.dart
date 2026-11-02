import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'proses_skrining_page.dart';

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
  final Map<int, bool?> _jawaban = {
    for (int i = 1; i <= 14; i++) i: null,
  };

  bool _showErrorBanner = false;

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

  bool _isAllQuestionsAnswered() {
    for (int i = 1; i <= 14; i++) {
      if (_jawaban[i] == null) return false;
    }
    return true;
  }

  void _finishSkrining() {
    if (!_isAllQuestionsAnswered()) {
      setState(() {
        _showErrorBanner = true;
      });
      return;
    }

    setState(() {
      _showErrorBanner = false;
    });

    final Map<String, dynamic> answersData = {
      'Nama': widget.nama,
      'Umur': int.tryParse(widget.umur) ?? 0,
      'Jenis Kelamin': widget.jenisKelamin.toLowerCase() == 'laki-laki' ? 1 : 0,
      'Sering BAK': _jawaban[1] == true ? 1 : 0,
      'Sering haus': _jawaban[2] == true ? 1 : 0,
      'BB turun drastis': _jawaban[3] == true ? 1 : 0,
      'Sering lemas': _jawaban[4] == true ? 1 : 0,
      'Sering lapar': _jawaban[5] == true ? 1 : 0,
      'Infeksi Jamur': _jawaban[6] == true ? 1 : 0,
      'Penglihatan Kabur': _jawaban[7] == true ? 1 : 0,
      'Gatal gatal': _jawaban[8] == true ? 1 : 0,
      'Mudah marah': _jawaban[9] == true ? 1 : 0,
      'Luka sulit sembuh': _jawaban[10] == true ? 1 : 0,
      'Kelemahan sebagian tubuh': _jawaban[11] == true ? 1 : 0,
      'Kaku otot': _jawaban[12] == true ? 1 : 0,
      'Rambut rontok': _jawaban[13] == true ? 1 : 0,
      'Obesitas': _jawaban[14] == true ? 1 : 0,
    };

    String currentUserId =
        FirebaseAuth.instance.currentUser?.uid ?? 'guest_user';

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ProsesSkriningPage(
          userId: currentUserId,
          answers: answersData,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER GRADIENT
          Container(
            padding: EdgeInsets.fromLTRB(16, topPadding, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6679F4), Color(0xFF8DA0FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 24,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Skrining Gejala Diabetes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // PROGRESS BAR (2/2)
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 1.0,
                          minHeight: 7,
                          backgroundColor: Color(0x33FFFFFF),
                          valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '2/2',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // KONTEN PERTANYAAN
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FONT DIKEMBALIKAN KE UKURAN SEMULA (16.0)
                  const Text(
                    'Pertanyaan Gejala Diabetes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // FONT DIKEMBALIKAN KE UKURAN SEMULA (13.0)
                  const Text(
                    'Jawablah 14 pertanyaan di bawah ini sesuai kondisi yang kamu rasakan.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.3,
                    ),
                  ),

                  // JARAK DIGANTI SANGAT MENEMPET (HANYA 8 PIXEL)
                  const SizedBox(height: 8),

                  // BANNER PERINGATAN KOTAK
                  if (_showErrorBanner)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: const Color(0xFFFCA5A5), width: 1),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFDC2626), size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Pertanyaan belum lengkap! Semua pertanyaan wajib dijawab.',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  // DAFTAR PERTANYAAN (PADDING BISA NOL KARENA SUDAH DIATUR PER ITEM)
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.zero,
                    itemCount: 14,
                    itemBuilder: (context, index) {
                      int no = index + 1;
                      return _buildQuestionItem(no, _pertanyaanText[no]!);
                    },
                  ),

                  const SizedBox(height: 20),

                  // TOMBOL "SELESAI & LIHAT HASIL" (FONT SEMULA 16)
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
                      child: const Text(
                        'Selesai & Lihat Hasil',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET ITEM PERTANYAAN (UKURAN FONT SEMULA 13.5)
  Widget _buildQuestionItem(int no, String pertanyaan) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pertanyaan,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          RadioGroup<bool>(
            groupValue: _jawaban[no],
            onChanged: (bool? val) {
              setState(() {
                _jawaban[no] = val;
                if (_showErrorBanner && _isAllQuestionsAnswered()) {
                  _showErrorBanner = false;
                }
              });
            },
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _jawaban[no] = true;
                        if (_showErrorBanner && _isAllQuestionsAnswered()) {
                          _showErrorBanner = false;
                        }
                      });
                    },
                    child: const Row(
                      children: [
                        Radio<bool>(
                          value: true,
                          activeColor: Color(0xFF6679F4),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Iya',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF334155)),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      setState(() {
                        _jawaban[no] = false;
                        if (_showErrorBanner && _isAllQuestionsAnswered()) {
                          _showErrorBanner = false;
                        }
                      });
                    },
                    child: const Row(
                      children: [
                        Radio<bool>(
                          value: false,
                          activeColor: Color(0xFF6679F4),
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize:
                          MaterialTapTargetSize.shrinkWrap,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Tidak',
                          style: TextStyle(
                              fontSize: 13, color: Color(0xFF334155)),
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