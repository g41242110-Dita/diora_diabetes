import 'package:flutter/material.dart';

class LokasiPage extends StatefulWidget {
  const LokasiPage({super.key});

  @override
  State<LokasiPage> createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  bool isPrecise = true; // True untuk Lokasi Akurat, False untuk Lokasi Sekitar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green.shade200, width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),
                  // Icon PIN Lokasi
                  const Icon(
                    Icons.location_on_outlined,
                    size: 36,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),

                  // Teks Deskripsi
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                        children: [
                          TextSpan(text: 'Izinkan '),
                          TextSpan(
                            text: 'Redera',
                            style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text: ' mengakses lokasi kamu untuk menemukan klinik terdekat.',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Opsi Pilihan Gambar (Akurat vs Sekitar)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Opsi Lokasi Akurat
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPrecise = true;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFE8F0FE),
                                border: Border.all(
                                  color: isPrecise ? const Color(0xFF6679F4) : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: Center(
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFFE8F0FE),
                                  ),
                                  child: const Icon(
                                    Icons.location_on,
                                    color: Color(0xFF3B82F6),
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Lokasi Akurat',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 24),

                      // Opsi Lokasi Sekitar
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isPrecise = false;
                          });
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFF7ED),
                                border: Border.all(
                                  color: !isPrecise ? const Color(0xFF6679F4) : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.map_outlined,
                                  color: Colors.orange,
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Lokasi Sekitar',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Pembatas Garis & Tombol Pilihan Paling Bawah
                  const Divider(height: 1, thickness: 1),
                  _buildOptionButton(
                    text: 'Izinkan',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(height: 1, thickness: 1),
                  _buildOptionButton(
                    text: 'Izinkan saat aplikasi digunakan',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                  const Divider(height: 1, thickness: 1),
                  _buildOptionButton(
                    text: 'Jangan izinkan',
                    onTap: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({required String text, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ),
    );
  }
}