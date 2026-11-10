import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/diabetes_decision_tree.dart';
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
  bool? seringBAK;
  bool? seringHaus;
  bool? seringLemas;
  bool? rambutRontok;
  bool? lukaSulitSembuh;
  bool? mudahMarah;
  bool? kakuOtot;
  bool? obesitas;

  bool _isLoading = false;
  bool _showError = false;

  void _prosesSkriningAI() async {
    if (seringBAK == null ||
        seringHaus == null ||
        seringLemas == null ||
        rambutRontok == null ||
        lukaSulitSembuh == null ||
        mudahMarah == null ||
        kakuOtot == null ||
        obesitas == null) {
      setState(() {
        _showError = true;
      });
      return;
    }

    setState(() {
      _showError = false;
      _isLoading = true;
    });

    int umurInt = int.tryParse(widget.umur) ?? 30;
    bool isMale = widget.jenisKelamin == 'Laki-laki';

    String hasilPrediksi = DiabetesDecisionTree.predictDiabetes(
      umur: umurInt,
      isMale: isMale,
      seringBAK: seringBAK!,
      seringHaus: seringHaus!,
      seringLemas: seringLemas!,
      rambutRontok: rambutRontok!,
      lukaSulitSembuh: lukaSulitSembuh!,
      mudahMarah: mudahMarah!,
      kakuOtot: kakuOtot!,
      obesitas: obesitas!,
    );

    bool isPositif = hasilPrediksi == "Positif Diabetes";
    String newDocId = '';

    try {
      var docRef = await FirebaseFirestore.instance.collection('screening_results').add({
        'nama': widget.nama,
        'umur': umurInt,
        'jenisKelamin': widget.jenisKelamin,
        'seringBAK': seringBAK,
        'seringHaus': seringHaus,
        'seringLemas': seringLemas,
        'rambutRontok': rambutRontok,
        'lukaSulitSembuh': lukaSulitSembuh,
        'mudahMarah': mudahMarah,
        'kakuOtot': kakuOtot,
        'obesitas': obesitas,
        'hasilPrediksi': hasilPrediksi,
        'waktuSkrining': FieldValue.serverTimestamp(),
      });
      newDocId = docRef.id;
    } catch (e) {
      debugPrint("Gagal simpan Firestore: $e");
    }

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    // Penulisan variabel tanpa tipe generik rumit agar tidak memicu error syntax
    var answersTableData = [
      {'q': 'Apakah Anda sering buang air kecil (BAK)?', 'a': seringBAK! ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda sering merasa haus / dahaga?', 'a': seringHaus! ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda sering merasa lemas atau mudah lelah?', 'a': seringLemas! ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda mengalami rambut rontok?', 'a': rambutRontok! ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda memiliki luka yang sulit sembuh?', 'a': lukaSulitSembuh! ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda merasa mudah marah atau emosional?', 'a': mudahMarah! ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda sering mengalami kaku otot?', 'a': kakuOtot! ? 'Ya' : 'Tidak'},
      {'q': 'Apakah Anda mengalami obesitas / kelebihan BB?', 'a': obesitas! ? 'Ya' : 'Tidak'},
    ];

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => HasilSkriningPage(
          docId: newDocId,
          nama: widget.nama,
          umur: widget.umur,
          jenisKelamin: widget.jenisKelamin,
          isPositif: isPositif,
          tableData: answersTableData,
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
        children: [
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
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Skrining Gejala Diabetes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 1.0,
                          minHeight: 7,
                          backgroundColor: Color(0x33FFFFFF),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'Pertanyaan Gejala Diabetes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Jawablah pertanyaan di bawah ini sesuai kondisi yang kamu rasakan.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),
                if (_showError)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5), width: 1),
                    ),
                    child: const Text(
                      'Mohon jawab semua pertanyaan gejala terlebih dahulu.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                  ),
                _buildQuestionCard(
                  number: 1,
                  question: "Apakah kamu sering buang air kecil (BAK)?",
                  value: seringBAK,
                  onChanged: (val) => setState(() => seringBAK = val),
                ),
                _buildQuestionCard(
                  number: 2,
                  question: "Apakah kamu sering merasa haus?",
                  value: seringHaus,
                  onChanged: (val) => setState(() => seringHaus = val),
                ),
                _buildQuestionCard(
                  number: 3,
                  question: "Apakah kamu sering merasa lemas atau mudah lelah?",
                  value: seringLemas,
                  onChanged: (val) => setState(() => seringLemas = val),
                ),
                _buildQuestionCard(
                  number: 4,
                  question: "Apakah kamu mengalami rambut rontok?",
                  value: rambutRontok,
                  onChanged: (val) => setState(() => rambutRontok = val),
                ),
                _buildQuestionCard(
                  number: 5,
                  question: "Apakah kamu mengalami luka yang sulit sembuh?",
                  value: lukaSulitSembuh,
                  onChanged: (val) => setState(() => lukaSulitSembuh = val),
                ),
                _buildQuestionCard(
                  number: 6,
                  question: "Apakah kamu merasa mudah marah atau emosional?",
                  value: mudahMarah,
                  onChanged: (val) => setState(() => mudahMarah = val),
                ),
                _buildQuestionCard(
                  number: 7,
                  question: "Apakah kamu sering mengalami kaku otot?",
                  value: kakuOtot,
                  onChanged: (val) => setState(() => kakuOtot = val),
                ),
                _buildQuestionCard(
                  number: 8,
                  question: "Apakah kamu mengalami obesitas / kelebihan BB?",
                  value: obesitas,
                  onChanged: (val) => setState(() => obesitas = val),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6679F4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    onPressed: _isLoading ? null : _prosesSkriningAI,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Cek Hasil Skrining AI',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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

  Widget _buildQuestionCard({
    required int number,
    required String question,
    required bool? value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "$number. $question",
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Iya', style: TextStyle(fontSize: 13)),
                  value: true,
                  groupValue: value,
                  activeColor: const Color(0xFF6679F4),
                  contentPadding: EdgeInsets.zero,
                  onChanged: onChanged,
                ),
              ),
              Expanded(
                child: RadioListTile<bool>(
                  title: const Text('Tidak', style: TextStyle(fontSize: 13)),
                  value: false,
                  groupValue: value,
                  activeColor: const Color(0xFF6679F4),
                  contentPadding: EdgeInsets.zero,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}