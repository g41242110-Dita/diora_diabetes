import 'package:flutter/material.dart';
import 'doctor_model.dart';

class DetailDokterPage extends StatelessWidget {
  final Doctor doctor;

  const DetailDokterPage({super.key, required this.doctor});

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
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    // Avatar Dokter
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Color(0xFFE2E7FF),
                      child: Icon(Icons.person, size: 60, color: Color(0xFF6679F4)),
                    ),
                    const SizedBox(height: 12),

                    // Nama & Spesialis
                    Text(
                      doctor.nama,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.spesialis,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),

                    // Rating
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(doctor.rating, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(width: 4),
                        Text('(${doctor.ulasan})', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Status Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(doctor.statusJam, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: doctor.isOnline ? const Color(0xFFE6F4EA) : const Color(0xFFFFEBF0),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            doctor.isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: doctor.isOnline ? const Color(0xFF2E7D32) : const Color(0xFFE53E3E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Card Jadwal & Pasien
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.calendar_today_outlined, color: Colors.grey),
                            title: const Text('Jadwal Praktik', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            subtitle: Text(doctor.jadwalPraktik, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.people_outline, color: Colors.grey),
                            title: const Text('Pasien Ditangani', style: TextStyle(fontSize: 12, color: Colors.grey)),
                            subtitle: Text(doctor.pasienDitangani, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black)),
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
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Tentang Dokter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text(doctor.tentangDokter, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Tombol Konsultasi
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: doctor.isOnline ? const Color(0xFF5D83EC) : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: doctor.isOnline
                      ? () {
                    // Aksi saat tombol ditekan
                  }
                      : null, // Disabled otomatis jika offline
                  child: Text(
                    doctor.isOnline ? 'Konsultasi Sekarang' : 'Dokter Sedang Offline',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
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