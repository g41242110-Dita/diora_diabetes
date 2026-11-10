import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// IMPORT SELURUH HALAMAN DOKTER SESUAI STRUKTUR FOLDER
import 'dokter_curved_nav_bar.dart';
import 'dokter_skrining_page.dart';
import 'dokter_konsultasi_page.dart';
import 'dokter_lokasi_page.dart';
import 'dokter_profil_page.dart';
import 'dokter_room_chat_page.dart';

class DokterBerandaPage extends StatefulWidget {
  final String? doctorId; // Bisa menerima ID dokter dari luar jika diperlukan

  const DokterBerandaPage({super.key, this.doctorId});

  @override
  State<DokterBerandaPage> createState() => _DokterBerandaPageState();
}

class _DokterBerandaPageState extends State<DokterBerandaPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // ATUR ID DOKTER DI SINI:
    // Gunakan widget.doctorId jika ada, atau default ke '4' (dr. Budi Santoso) / '1' (dr. Amanda Putri)
    final String activeDoctorId = widget.doctorId ?? '1';

    final List<Widget> pages = [
      _DokterDashboardContentView(doctorId: activeDoctorId), // Index 0: Beranda/Dashboard
      const DokterSkriningPage(),                           // Index 1: Skrining Pasien
      DokterKonsultasiPage(doctorId: activeDoctorId),         // Index 2: Konsultasi Chat
      const DokterLokasiPage(),                             // Index 3: Lokasi Praktik
      const DokterProfilPage(),                             // Index 4: Profil Dokter
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: DokterCurvedNavBar(
        selectedIndex: _currentIndex,
        onItemTapped: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _DokterDashboardContentView extends StatelessWidget {
  final String doctorId;
  const _DokterDashboardContentView({required this.doctorId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      // Mengambil data profil dokter secara dinamis berdasarkan doctorId dari Firestore
      future: FirebaseFirestore.instance.collection('doctors').doc(doctorId).get(),
      builder: (context, doctorSnapshot) {
        String namaDokter = 'Dokter Medis';
        String spesialisasi = 'Spesialis Penyakit Dalam';

        if (doctorSnapshot.hasData && doctorSnapshot.data!.exists) {
          final docData = doctorSnapshot.data!.data() as Map<String, dynamic>;
          namaDokter = docData['nama'] ?? namaDokter;
          spesialisasi = docData['spesialis'] ?? spesialisasi;
        }

        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // -----------------------------------------------------------------
              // 1. HEADER + FLOATING BANNER
              // -----------------------------------------------------------------
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(
                      top: 68.0,
                      left: 20.0,
                      right: 20.0,
                      bottom: 80.0,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(28),
                        bottomRight: Radius.circular(28),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFFEEF2FF),
                            child: Icon(Icons.person, color: Color(0xFF4F46E5), size: 26),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Halo, $namaDokter',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$spesialisasi • Klinik Sentosa',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFFE0E7FF),
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Card Melayang
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: -40,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEEF2FF),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Panel Kendali Dokter',
                                  style: TextStyle(
                                    color: Color(0xFF4F46E5),
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'SIP : 446/SIP/2024',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Sistem pemantauan pasien aktif dan terhubung langsung ke database.',
                            style: TextStyle(
                              color: Color(0xFF334155),
                              fontSize: 12,
                              height: 1.35,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 36),

              // -----------------------------------------------------------------
              // 2. GRID KARTU STATISTIK DOKTER
              // -----------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.35,
                  children: [
                    _buildStatGridCard(
                      icon: Icons.chat_bubble_rounded,
                      accentColor: const Color(0xFF6366F1),
                      bgGradient: const [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
                      count: 'Chat',
                      title: 'Konsultasi Aktif',
                      subtitle: 'Real-time Chat',
                    ),
                    _buildStatGridCard(
                      icon: Icons.assignment_turned_in_rounded,
                      accentColor: const Color(0xFF8B5CF6),
                      bgGradient: const [Color(0xFFF3E8FF), Color(0xFFFAF5FF)],
                      count: 'Lab',
                      title: 'Verifikasi Medis',
                      subtitle: 'Hasil Skrining',
                    ),
                    _buildStatGridCard(
                      icon: Icons.groups_rounded,
                      accentColor: const Color(0xFF0EA5E9),
                      bgGradient: const [Color(0xFFE0F2FE), Color(0xFFF0F9FF)],
                      count: 'Klinik',
                      title: 'Klinik Sentosa',
                      subtitle: 'Poli Penyakit Dalam',
                    ),
                    _buildStatGridCard(
                      icon: Icons.calendar_today_rounded,
                      accentColor: const Color(0xFFEC4899),
                      bgGradient: const [Color(0xFFFCE7F3), Color(0xFFFDF2F8)],
                      count: 'Shift',
                      title: 'Jadwal Praktik',
                      subtitle: 'WIB',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // -----------------------------------------------------------------
              // 3. ANTREAN KONSULTASI PASIEN (DARI FIREBASE)
              // -----------------------------------------------------------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Antrean Konsultasi Pasien',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // StreamBuilder mengambil data booking asli dari sub-koleksi booking_slots dokter ini
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('doctors')
                    .doc(doctorId)
                    .collection('booking_slots')
                    .where('isBooked', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Center(
                        child: Text(
                          'Belum ada pasien yang melakukan booking pada dokter ini.',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final namaPasien = data['bookedByUserId'] ?? 'Pasien';
                      final jamSesi = data['slotWaktu'] ?? docs[index].id.split('_').last;
                      final tanggal = data['tanggal'] ?? 'Hari ini';

                      return InkWell(
                        onTap: () {
                          final String roomId = '${namaPasien}_${doctorId}_${jamSesi.replaceAll(' ', '')}';
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DokterRoomChatPage(
                                roomId: roomId,
                                doctorId: doctorId,
                                namaPasien: namaPasien,
                                genderAge: 'Pasien Terdaftar',
                                jamSesi: jamSesi,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.025),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          namaPasien,
                                          style: const TextStyle(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                        Text(
                                          jamSesi,
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: Color(0xFF4F46E5),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text(
                                          'Terkonfirmasi',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '• Tanggal: $tanggal',
                                          style: const TextStyle(
                                            fontSize: 10.5,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    const Text(
                                      'Ketuk untuk membuka ruang chat konsultasi.',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF4F46E5),
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatGridCard({
    required IconData icon,
    required Color accentColor,
    required List<Color> bgGradient,
    required String count,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: bgGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.15),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: accentColor, size: 18),
              ),
              Text(
                count,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: accentColor,
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 1),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}