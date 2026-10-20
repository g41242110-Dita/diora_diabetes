import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'detail_dokter_page.dart';
import 'beranda_page.dart';

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

  // DAFTAR 7 DOKTER LENGKAP (3 ONLINE SHIFT 24 JAM & 4 OFFLINE)
  final List<Doctor> doctors = [
    // --- 3 DOKTER ONLINE (3 SHIFT) ---
    Doctor(
      nama: 'dr. Amanda Putri, Sp. PD',
      spesialis: 'Dokter Spesialis Penyakit Dalam',
      rating: '4.9',
      ulasan: '324 ulasan',
      statusJam: 'Shift 1 (07.00 - 15.00)',
      isOnline: true,
      jadwalPraktik: 'Senin - Jumat, 07.00 - 15.00',
      pasienDitangani: '1152+ Pasien',
      tentangDokter:
      'Berpengalaman dalam menangani penyakit dalam, termasuk diabetes, hipertensi, dan gangguan metabolik.',
    ),
    Doctor(
      nama: 'dr. Asila Salsavea Gunawan, Sp. PD',
      spesialis: 'Dokter Spesialis Penyakit Dalam',
      rating: '4.8',
      ulasan: '210 ulasan',
      statusJam: 'Shift 2 (15.00 - 23.00)',
      isOnline: true,
      jadwalPraktik: 'Senin - Jumat, 15.00 - 23.00',
      pasienDitangani: '890+ Pasien',
      tentangDokter:
      'Fokus pada manajemen diabetes melitus tipe 1 & 2 serta pencegahan komplikasi kronis.',
    ),
    Doctor(
      nama: 'dr. Ryan Ramadhani, Sp. GK',
      spesialis: 'Dokter Spesialis Gizi Klinik',
      rating: '4.9',
      ulasan: '185 ulasan',
      statusJam: 'Shift 3 (23.00 - 07.00)',
      isOnline: true,
      jadwalPraktik: 'Senin - Jumat, 23.00 - 07.00',
      pasienDitangani: '740+ Pasien',
      tentangDokter:
      'Spesialis konsultasi pola makan, diet diabetes, dan pengaturan indeks glikemik harian.',
    ),

    // --- 4 DOKTER OFFLINE ---
    Doctor(
      nama: 'dr. Budi Santoso, Sp. PD',
      spesialis: 'Dokter Spesialis Penyakit Dalam',
      rating: '4.7',
      ulasan: '150 ulasan',
      statusJam: 'Offline Hari Ini',
      isOnline: false,
      jadwalPraktik: 'Sabtu - Minggu, 08.00 - 12.00',
      pasienDitangani: '620+ Pasien',
      tentangDokter:
      'Menangani konsultasi penyakit dalam dan edukasi pemantauan gula darah mandiri.',
    ),
    Doctor(
      nama: 'dr. Sari Dewi, Sp. GK',
      spesialis: 'Dokter Spesialis Gizi Klinik',
      rating: '4.8',
      ulasan: '190 ulasan',
      statusJam: 'Offline Hari Ini',
      isOnline: false,
      jadwalPraktik: 'Sabtu - Minggu, 13.00 - 17.00',
      pasienDitangani: '510+ Pasien',
      tentangDokter:
      'Pakar terapi nutrisi klinis untuk penderita diabetes dengan riwayat komplikasi.',
    ),
    Doctor(
      nama: 'dr. Natashia Luvicia, Sp. PD',
      spesialis: 'Dokter Spesialis Penyakit Dalam',
      rating: '4.9',
      ulasan: '230 ulasan',
      statusJam: 'Offline Hari Ini',
      isOnline: false,
      jadwalPraktik: 'Sabtu - Minggu, 09.00 - 15.00',
      pasienDitangani: '930+ Pasien',
      tentangDokter:
      'Ahli penanganan diabetes tipe 2, sindrom metabolik, dan manajemen gaya hidup sehat.',
    ),
    Doctor(
      nama: 'dr. Rizki Fatur, Sp. PD',
      spesialis: 'Dokter Spesialis Penyakit Dalam',
      rating: '4.6',
      ulasan: '115 ulasan',
      statusJam: 'Offline Hari Ini',
      isOnline: false,
      jadwalPraktik: 'Sabtu - Minggu, 16.00 - 20.00',
      pasienDitangani: '410+ Pasien',
      tentangDokter:
      'Konsultasi kesehatan penyakit dalam, skrining komorbid, dan evaluasi hasil laboratorium.',
    ),
  ];

  List<Doctor> filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    filteredDoctors = doctors;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => BerandaPage(
                    namaUser: widget.namaUser,
                  ),
                ),
              );
            }
          },
        ),
        title: const Text(
          'Konsultasi',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pilih dokter yang sesuai dengan kebutuhanmu.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
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

            // List Dokter
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
            color: Colors.black.withValues(alpha: 0.02),
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
                      style: TextStyle(
                        fontSize: 10,
                        color: doctor.isOnline ? const Color(0xFF2E7D32) : Colors.grey,
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