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
      backgroundColor: const Color(0xFFF4F7FE),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER ESTETIK DENGAN GRADIENT & SEARCH BAR
          Container(
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6679F4), Color(0xFF8DA0FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
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
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 22,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Text(
                      'Konsultasi',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 36.0),
                  child: Text(
                    'Pilih dokter yang sesuai dengan kebutuhanmu.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.white70,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Search Bar Modern
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _filterDoctors,
                    decoration: InputDecoration(
                      hintText: 'Cari Dokter atau Spesialis ...',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF6679F4),
                        size: 22,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.cancel_rounded,
                                size: 18,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _filterDoctors('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 2. LIST DOKTER ESTETIK
          Expanded(
            child: filteredDoctors.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.search_off_rounded,
                            size: 36,
                            color: Color(0xFF6679F4),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Dokter tidak ditemukan.',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filteredDoctors.length,
                    itemBuilder: (context, index) {
                      final doctor = filteredDoctors[index];
                      return _buildAestheticDoctorCard(context, doctor);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAestheticDoctorCard(BuildContext context, Doctor doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6679F4).withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFEEF2F6),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
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
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 28,
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Icon(Icons.person, size: 32, color: Color(0xFF6679F4)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.nama,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                          height: 1.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        doctor.spesialis,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            doctor.rating,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${doctor.ulasan})',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doctor.statusJam,
                        style: TextStyle(
                          fontSize: 10,
                          color: doctor.isOnline
                              ? const Color(0xFF2E7D32)
                              : Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: doctor.isOnline
                        ? const Color(0xFFE6F4EA)
                        : const Color(0xFFFFEBF0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    doctor.isOnline ? 'Online' : 'Offline',
                    style: TextStyle(
                      fontSize: 9.5,
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
      ),
    );
  }
}