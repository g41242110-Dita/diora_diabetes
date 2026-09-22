import 'dart:async';
import 'package:flutter/material.dart';
import 'hasil_skrining_page.dart'; // Mengarah ke file HasilSkriningPage gabungan

class ProsesSkriningPage extends StatefulWidget {
  final bool isPositif; // Kirim true jika hasil perhitungan positif, false jika negatif

  const ProsesSkriningPage({super.key, this.isPositif = true});

  @override
  State<ProsesSkriningPage> createState() => _ProsesSkriningPageState();
}

class _ProsesSkriningPageState extends State<ProsesSkriningPage> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _mulaiProsesLoading();
  }

  void _mulaiProsesLoading() {
    // Jalankan timer untuk memperbarui progress bar
    _timer = Timer.periodic(const Duration(milliseconds: 40), (timer) {
      if (!mounted) return; // Mencegah error jika widget sudah di-dispose

      setState(() {
        _progress += 0.02; // Menambah 2% setiap 40ms (~2 detik total)
        if (_progress >= 1.0) {
          _progress = 1.0;
          _timer?.cancel();

          // Pindah ke HasilSkriningPage dan hapus halaman loading dari stack
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => HasilSkriningPage(
                  isPositif: widget.isPositif,
                ),
              ),
            );
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int persen = (_progress * 100).toInt();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // ILUSTRASI MENGANALISIS
              Image.network(
                'https://cdn-icons-png.flaticon.com/512/3209/3209265.png',
                height: 160,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.assignment_turned_in_rounded,
                  size: 130,
                  color: Color(0xFF6679F4),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Menganalisis Jawaban. . .',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Mohon tunggu sebentar, ya.\nKami sedang memproses hasil skrining Anda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              // PROGRESS BAR
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
    );
  }
}