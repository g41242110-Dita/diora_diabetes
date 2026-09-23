import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'detail_dokter_page.dart';

class KonsultasiPage extends StatefulWidget {
  final String namaUser;

  const KonsultasiPage({
    super.key,
    this.namaUser = 'Pengguna',
  });

  @override
  State<KonsultasiPage> createState() => _KonsultasiPageState();
}

class _KonsultasiPageState extends State<KonsultasiPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Doctor> doctors = [
    Doctor(
      nama: 'dr. Amanda Putri, Sp. PD',
      spesialis: 'Dokter Spesialis Penyakit Dalam',
      rating: '4.9',
      ulasan: '324 ulasan',
      statusJam: 'Tersedia hari ini',
      isOnline: true,
      jadwalPraktik: 'Senin - Jumat, 10.00 - 18.00',
      pasienDitangani: '1152+ Pasien',
      tentangDokter:
      'Berpengalaman dalam menangani penyakit dalam, termasuk diabetes, hipertensi, dan gangguan metabolik lainnya.',
    ),
    Doctor(
      nama: 'dr. Budi Santoso, Sp. PD',
      spesialis: 'Dokter Spesialis Penyakit Dalam',
      rating: '4.8',
      ulasan: '214 ulasan',
      statusJam: 'Tersedia hari ini',
      isOnline: true,
      jadwalPraktik: 'Senin - Sabtu, 08.00 - 15.00',
      pasienDitangani: '890+ Pasien',
      tentangDokter:
      'Spesialis penyakit dalam dengan fokus pada kesehatan pencernaan dan penyakit metabolik.',
    ),
    Doctor(
      nama: 'dr. Sari Dewi, Sp. GK',
      spesialis: 'Dokter Spesialis Gizi Klinik',
      rating: '4.7',
      ulasan: '190 ulasan',
      statusJam: 'Tersedia besok',
      isOnline: false,
      jadwalPraktik: 'Selasa - Kamis, 13.00 - 17.00',
      pasienDitangani: '540+ Pasien',
      tentangDokter:
      'Membantu konseling gizi, diet klinis, serta manajemen pola makan untuk penderita diabetes.',
    ),
  ];

  // List penampung hasil filter pencarian
  List<Doctor> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    // Default awal menampilkan semua dokter
    filteredDoctors = doctors;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fungsi untuk memfilter list dokter berdasarkan input teks
  void _filterDoctors(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredDoctors = doctors;
      } else {
        filteredDoctors = doctors.where((doctor) {
          final nameLower = doctor.nama.toLowerCase();
          final spesialisLower = doctor.spesialis.toLowerCase();
          final searchLower = query.toLowerCase();

          return nameLower.contains(searchLower) ||
              spesialisLower.contains(searchLower);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Konsultasi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Pilih dokter yang sesuai dengan kebutuhanmu.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar dengan fungsi filter terhubung
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterDoctors,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.search, color: Colors.grey, size: 20),
                    hintText: 'Cari Dokter atau Spesialis ...',
                    hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                    border: InputBorder.none,
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                      icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _filterDoctors('');
                      },
                    )
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // List Dokter Hasil Filter
              Expanded(
                child: filteredDoctors.isEmpty
                    ? const Center(
                  child: Text(
                    'Dokter tidak ditemukan.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                )
                    : ListView.builder(
                  itemCount: filteredDoctors.length,
                  itemBuilder: (context, index) {
                    final doctor = filteredDoctors[index];
                    return _buildDoctorCard(context, doctor);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCard(BuildContext context, Doctor doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailDokterPage(
                doctor: doctor,
                namaUser: widget.namaUser,
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
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
                    Text(
                      doctor.nama,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      doctor.spesialis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text(
                          doctor.rating,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '(${doctor.ulasan})',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.statusJam,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: doctor.isOnline
                      ? const Color(0xFFE6F4EA)
                      : const Color(0xFFFFEBF0),
                  borderRadius: BorderRadius.circular(12),
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
        ),
      ),
    );
  }
}