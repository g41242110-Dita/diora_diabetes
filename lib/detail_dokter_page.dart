import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'chat_konsultasi_page.dart';

class DetailDokterPage extends StatelessWidget {
  final Doctor doctor;
  final String namaUser;

  const DetailDokterPage({
    super.key,
    required this.doctor,
    this.namaUser = 'Pengguna',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  children: [
                    // Gambar/Avatar Dokter Besar
                    const CircleAvatar(
                      radius: 55,
                      backgroundColor: Color(0xFFE2E7FF),
                      child: Icon(Icons.person, size: 70, color: Color(0xFF6679F4)),
                    ),
                    const SizedBox(height: 12),

                    // Nama Dokter & Spesialis
                    Text(
                      doctor.nama,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.spesialis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Rating & Badge Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${doctor.ulasan})',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: doctor.isOnline
                                ? const Color(0xFFE6F4EA)
                                : const Color(0xFFFFEBF0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            doctor.isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: doctor.isOnline
                                  ? const Color(0xFF2E7D32)
                                  : const Color(0xFFE53E3E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Card Jadwal Praktik & Pasien
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Jadwal Praktik',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 16, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                doctor.jadwalPraktik,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          const Text(
                            'Pasien Ditangani',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.people_outline,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                doctor.pasienDitangani,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Card Tentang Dokter
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tentang Dokter',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            doctor.tentangDokter,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol "Konsultasi Sekarang" di Bagian Bawah
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: doctor.isOnline
                        ? const Color(0xFF5D83EC)
                        : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    elevation: 0,
                  ),
                  onPressed: doctor.isOnline
                      ? () {
                    // Pindah ke KONSUL 2 (Chat) dengan meneruskan namaUser
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatKonsultasiPage(
                          doctor: doctor,
                          namaUser: namaUser,
                        ),
                      ),
                    );
                  }
                      : null,
                  child: Text(
                    doctor.isOnline
                        ? 'Konsultasi Sekarang'
                        : 'Dokter Sedang Offline',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}