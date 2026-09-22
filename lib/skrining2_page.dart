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
  // Map untuk menyimpan jawaban pertanyaan (true = Iya, false = Tidak)
  final Map<int, bool?> _jawaban = {
    1: null,
    2: null,
    3: null,
    4: null,
    5: null,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tombol Back
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),

              // Judul
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

              // Indicator Progress (2/4)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: const [
                  Text('2/4', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: 2 / 4,
                backgroundColor: Colors.grey.shade200,
                color: const Color(0xFF6679F4),
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),
              const SizedBox(height: 20),

              // Pertanyaan 1 - 5
              _buildQuestionItem(
                no: 1,
                pertanyaan: '1. Apakah kamu sering buang air kecil (BAK)?',
              ),
              _buildQuestionItem(
                no: 2,
                pertanyaan: '2. Apakah kamu sering merasa haus?',
              ),
              _buildQuestionItem(
                no: 3,
                pertanyaan: '3. Apakah berat badan kamu turun secara drastis tanpa sebab yang jelas?',
              ),
              _buildQuestionItem(
                no: 4,
                pertanyaan: '4. Apakah kamu sering merasa lemas atau mudah lelah?',
              ),
              _buildQuestionItem(
                no: 5,
                pertanyaan: '5. Apakah kamu sering merasa lapar meskipun sudah makan?',
              ),

              const SizedBox(height: 20),

              // Tombol Kembali & Lanjutkan
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
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
                      onPressed: () {
                        // Nanti di sini diarahkan ke Skrining 3
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6679F4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text('Lanjutkan', style: TextStyle(color: Colors.white)),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Helper Pertanyaan Radio
  Widget _buildQuestionItem({required int no, required String pertanyaan}) {
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