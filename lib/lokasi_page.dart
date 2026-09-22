import 'package:flutter/material.dart';
import 'daftar_klinik_page.dart';

class LokasiPage extends StatefulWidget {
  const LokasiPage({super.key});

  @override
  State<LokasiPage> createState() => _LokasiPageState();
}

class _LokasiPageState extends State<LokasiPage> {
  // Option 0: Lokasi Akurat, Option 1: Lokasi Sekitar
  int _selectedOption = 0;

  void _navigateToDaftarKlinik(bool isGranted) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DaftarKlinikPage(isLocationGranted: isGranted),
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF5A75F6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFA8E0BA), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 24),

                  // Pin Header Icon
                  const Icon(
                    Icons.location_on_outlined,
                    size: 36,
                    color: Colors.black54,
                  ),
                  const SizedBox(height: 16),

                  // Teks Deskripsi Permission
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          height: 1.3,
                        ),
                        children: [
                          TextSpan(text: 'Izinkan '),
                          TextSpan(
                            text: 'Redera ',
                            style: TextStyle(color: Color(0xFFC07060), fontWeight: FontWeight.w500),
                          ),
                          TextSpan(text: 'mengakses lokasi kamu untuk menemukan klinik terdekat.'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Pilihan Ilustrasi Lokasi (Akurat vs Sekitar)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Pilihan 1: Lokasi Akurat
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedOption = 0;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 95,
                                height: 95,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedOption == 0
                                        ? const Color(0xFF1A73E8)
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: ClipOval(
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=300',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFFE8F0FE),
                                        child: const Icon(Icons.my_location, color: Color(0xFF1A73E8)),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Lokasi Akurat',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Pilihan 2: Lokasi Sekitar
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedOption = 1;
                            });
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 95,
                                height: 95,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: _selectedOption == 1
                                        ? const Color(0xFF1A73E8)
                                        : Colors.transparent,
                                    width: 2.5,
                                  ),
                                ),
                                padding: const EdgeInsets.all(3),
                                child: ClipOval(
                                  child: Image.network(
                                    'https://images.unsplash.com/photo-1569336415962-a4bd9f69cd83?q=80&w=300',
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: const Color(0xFFFFF3E0),
                                        child: const Icon(Icons.map, color: Colors.orange),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Lokasi Sekitar',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Divider Pembatas Atas Tombol Pilihan
                  const Divider(height: 1, thickness: 1, color: Color(0xFFD1D5DB)),

                  // Tombol 1: Izinkan
                  InkWell(
                    onTap: () => _navigateToDaftarKlinik(true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: const Text(
                        'Izinkan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFD1D5DB)),

                  // Tombol 2: Izinkan saat aplikasi digunakan
                  InkWell(
                    onTap: () => _navigateToDaftarKlinik(true),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: const Text(
                        'Izinkan saat aplikasi digunakan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1, thickness: 1, color: Color(0xFFD1D5DB)),

                  // Tombol 3: Jangan izinkan
                  InkWell(
                    onTap: () => _navigateToDaftarKlinik(false),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      alignment: Alignment.center,
                      child: const Text(
                        'Jangan izinkan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}