import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'detail_dokter_page.dart';

class KonsultasiPage extends StatefulWidget {
  final String namaUser;

  const KonsultasiPage({super.key, this.namaUser = 'Pengguna'});

  @override
  State<KonsultasiPage> createState() => _KonsultasiPageState();
}

class _KonsultasiPageState extends State<KonsultasiPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Doctor> _allDoctors = [
    Doctor(
      id: '1',
      nama: 'dr. Amanda Putri, Sp. PD',
      spesialis: 'Dokter Spesialis Penyakit Dalam',
      rating: '4.9',
      ulasan: '324',
      isOnline: true,
      isBusyInChat: true,
      jamMulai: 7,
      jamSelesai: 15,
      tentangDokter: 'Spesialis penyakit dalam berpengalaman menangani kasus metabolik.',
      slots: [
        TimeSlot(id: 's1', timeText: '07.00 - 07.30', startHour: 7, startMinute: 0, isBooked: true),
        TimeSlot(id: 's2', timeText: '07.30 - 08.00', startHour: 7, startMinute: 30, isBooked: true),
        TimeSlot(id: 's3', timeText: '08.00 - 08.30', startHour: 8, startMinute: 0),
        TimeSlot(id: 's4', timeText: '08.30 - 09.00', startHour: 8, startMinute: 30),
      ],
    ),
    Doctor(
      id: '2',
      nama: 'dr. Asila Salsavea Gunawan, Sp. PD',
      spesialis: 'Dokter Spesialis Penyakit Dalam',
      rating: '4.8',
      ulasan: '210',
      isOnline: true,
      isBusyInChat: false,
      jamMulai: 15,
      jamSelesai: 23,
      tentangDokter: 'Spesialis penyakit dalam berfokus pada evaluasi diabetes.',
      slots: [
        TimeSlot(id: 's5', timeText: '15.00 - 15.30', startHour: 15, startMinute: 0),
        TimeSlot(id: 's6', timeText: '15.30 - 16.00', startHour: 15, startMinute: 30),
      ],
    ),
    Doctor(
      id: '3',
      nama: 'dr. Ryan Ramadhani, Sp. GK',
      spesialis: 'Dokter Spesialis Gizi Klinik',
      rating: '4.9',
      ulasan: '185',
      isOnline: false,
      jamMulai: 23,
      jamSelesai: 7,
      tentangDokter: 'Pakar konseling gizi dan manajemen diet khusus.',
      slots: [
        TimeSlot(id: 's7', timeText: '23.00 - 23.30', startHour: 23, startMinute: 0),
      ],
    ),
  ];

  List<Doctor> _filteredDoctors = [];

  @override
  void initState() {
    super.initState();
    _filteredDoctors = List.from(_allDoctors);
  }

  void _filterDoctors(String query) {
    setState(() {
      _filteredDoctors = _allDoctors.where((doc) {
        return doc.nama.toLowerCase().contains(query.toLowerCase()) ||
            doc.spesialis.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1E293B), size: 18),
          onPressed: () => Navigator.maybePop(context),
        ),
        titleSpacing: 0,
        title: const Text(
          'Konsultasi',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Pilih dokter yang sesuai dengan kebutuhanmu.',
                style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 12),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterDoctors,
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                    hintText: 'Cari Dokter atau Spesialis ...',
                    hintStyle: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _filteredDoctors.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final doctor = _filteredDoctors[index];

                  return InkWell(
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
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            backgroundColor: Color(0xFFEEF2FF),
                            child: Icon(Icons.person_rounded, size: 32, color: Color(0xFF4F46E5)),
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
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  doctor.spesialis,
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star_rounded, size: 15, color: Colors.amber),
                                    const SizedBox(width: 2),
                                    Text(
                                      doctor.rating,
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '(${doctor.ulasan} ulasan)',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          if (doctor.isOnline)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: doctor.isBusyInChat
                                    ? const Color(0xFFFFF7ED)
                                    : const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                doctor.isBusyInChat ? 'Dalam Sesi' : 'Online',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: doctor.isBusyInChat
                                      ? const Color(0xFFC2410C)
                                      : const Color(0xFF15803D),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}