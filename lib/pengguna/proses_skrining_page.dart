import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'hasil_skrining_page.dart';

class ProsesSkriningPage extends StatefulWidget {
  final String userId;
  final Map<String, dynamic> answers; // Berisi 16 data jawaban skrining

  const ProsesSkriningPage({
    super.key,
    required this.userId,
    required this.answers,
  });

  @override
  State<ProsesSkriningPage> createState() => _ProsesSkriningPageState();
}

class _ProsesSkriningPageState extends State<ProsesSkriningPage> {
  double _progress = 0.0;
  StreamSubscription<DocumentSnapshot>? _streamSubscription;

  @override
  void initState() {
    super.initState();
    _kirimDanDengarkanHasil();
  }

  Future<void> _kirimDanDengarkanHasil() async {
    try {
      setState(() => _progress = 0.2);

      // Mapping 16 Fitur (Nama key Wajib SAMA PERSIS dengan di Python Colab)
      final Map<String, dynamic> screeningData = {
        'user_id': widget.userId,
        'status': 'pending',
        'created_at': FieldValue.serverTimestamp(),
        'Umur': int.tryParse(widget.answers['Umur'].toString()) ?? 0,
        'Jenis Kelamin': widget.answers['Jenis Kelamin'] ?? 0,
        'Sering BAK': widget.answers['Sering BAK'] ?? 0,
        'Sering haus': widget.answers['Sering haus'] ?? 0,
        'BB turun drastis': widget.answers['BB turun drastis'] ?? 0,
        'Sering lemas': widget.answers['Sering lemas'] ?? 0,
        'Sering lapar': widget.answers['Sering lapar'] ?? 0,
        'Infeksi Jamur': widget.answers['Infeksi Jamur'] ?? 0,
        'Penglihatan Kabur': widget.answers['Penglihatan Kabur'] ?? 0,
        'Gatal gatal': widget.answers['Gatal gatal'] ?? 0,
        'Mudah marah': widget.answers['Mudah marah'] ?? 0,
        'Luka sulit sembuh': widget.answers['Luka sulit sembuh'] ?? 0,
        'Kelemahan sebagian tubuh': widget.answers['Kelemahan sebagian tubuh'] ?? 0,
        'Kaku otot': widget.answers['Kaku otot'] ?? 0,
        'Rambut rontok': widget.answers['Rambut rontok'] ?? 0,
        'Obesitas': widget.answers['Obesitas'] ?? 0,
      };

      // 1. Simpan dokumen berstatus 'pending' ke Firestore
      DocumentReference docRef = await FirebaseFirestore.instance
          .collection('screening_results')
          .add(screeningData);

      setState(() => _progress = 0.5);

      // 2. Listen perubahan dokumen dari Google Colab secara Realtime
      _streamSubscription = docRef.snapshots().listen((snapshot) {
        if (!snapshot.exists) return;

        final data = snapshot.data() as Map<String, dynamic>?;
        if (data == null) return;

        // Jika Colab sudah selesai memprediksi
        if (data['status'] == 'completed' || data.containsKey('score')) {
          setState(() => _progress = 1.0);

          bool isPositif = (data['score'] == 1);
          _streamSubscription?.cancel();

          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HasilSkriningPage(
                  nama: widget.answers['Nama'] ?? 'Pengguna',
                  umur: widget.answers['Umur'].toString(),
                  jenisKelamin: widget.answers['Jenis Kelamin'] == 1 ? 'Laki-laki' : 'Perempuan',
                  isPositif: isPositif,
                ),
              ),
            );
          }
        }
      });
    } catch (e, stackTrace) {
      // Menggunakan developer.log sebagai pengganti print() untuk production logging
      developer.log(
        'Gagal mengirim atau memproses data skrining',
        error: e,
        stackTrace: stackTrace,
        name: 'ScreeningService',
      );
    }
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int persen = (_progress * 100).toInt();

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                const Icon(
                  Icons.assignment_turned_in_rounded,
                  size: 130,
                  color: Color(0xFF6679F4),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Menganalisis Jawaban . . .',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Mohon tunggu sebentar, ya.\nModel AI sedang memproses hasil skrining Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
                const Spacer(),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: const Color(0xFF6679F4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$persen%',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}