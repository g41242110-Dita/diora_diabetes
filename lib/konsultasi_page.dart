import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'detail_dokter_page.dart';

class KonsultasiPage extends StatefulWidget {
  const KonsultasiPage({super.key});

  @override
  State<KonsultasiPage> createState() => _KonsultasiPageState();
}

class _KonsultasiPageState extends State<KonsultasiPage> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedIndex = 1;

  // List Data Dokter Dinamis
  final List<Doctor> _listDokter = [
    Doctor(
      nama: 'dr. Amanda Putri, Sp. PD',
      spesialis: 'Dokter Spesialis Penyakit Dalam',
      rating: '4.9',
      ulasan: '324 ulasan',
      statusJam: 'Tersedia hari ini',
      isOnline: true,
      jadwalPraktik: 'Senin - Jumat 10.00 - 18.00',
      pasienDitangani: '1152+ Pasien',
      tentangDokter: 'Berpengalaman dalam menangani penyakit dalam, termasuk diabetes, hipertensi, dan gangguan metabolik lainnya.',
    ),
    Doctor(
      nama: 'dr. Budi Santoso, Sp. PD',
      spesialis: 'Dokter Spesialis Penyakit Dalam',
      rating: '4.8',
      ulasan: '214 ulasan',
      statusJam: 'Tersedia hari ini',
      isOnline: true,
      jadwalPraktik: 'Senin - Sabtu 08.00 - 15.00',
      pasienDitangani: '890+ Pasien',
      tentangDokter: 'Spesialis penyakit dalam dengan fokus pada kesehatan pencernaan dan penyakit menular.',
    ),
    Doctor(
      nama: 'dr. Sari Dewi, Sp. GK',
      spesialis: 'Dokter Spesialis Gizi Klinik',
      rating: '4.7',
      ulasan: '190 ulasan',
      statusJam: 'Tersedia besok',
      isOnline: false,
      jadwalPraktik: 'Selasa - Kamis 13.00 - 17.00',
      pasienDitangani: '540+ Pasien',
      tentangDokter: 'Membantu konseling gizi, diet klinis, serta manajemen berat badan untuk gaya hidup sehat.',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Konsultasi', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Text('Pilih dokter yang sesuai dengan kebutuhanmu.', style: TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari Dokter atau Spesialis . . .',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.shade300)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFF6679F4))),
                ),
              ),
              const SizedBox(height: 16),

              // Daftar Dokter Dinamis
              Expanded(
                child: ListView.builder(
                  itemCount: _listDokter.length,
                  itemBuilder: (context, index) {
                    final doctor = _listDokter[index];
                    return _buildDoctorCard(doctor);
                  },
                ),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF6679F4),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), activeIcon: Icon(Icons.chat_bubble), label: 'Konsultasi'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Skrining'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildDoctorCard(Doctor doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // Navigasi membawa data objek dokter ke halaman detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailDokterPage(doctor: doctor),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundColor: Color(0xFFE2E7FF),
                child: Icon(Icons.person, size: 36, color: Color(0xFF6679F4)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(doctor.nama, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: doctor.isOnline ? const Color(0xFFE6F4EA) : const Color(0xFFFFEBF0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            doctor.isOnline ? 'Online' : 'Offline',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: doctor.isOnline ? const Color(0xFF2E7D32) : const Color(0xFFE53E3E),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(doctor.spesialis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(doctor.rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        Text('(${doctor.ulasan})', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                      child: Text(
                        doctor.statusJam,
                        style: TextStyle(fontSize: 10, color: doctor.isOnline ? Colors.green.shade700 : Colors.blue.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}