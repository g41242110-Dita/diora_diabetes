import 'package:flutter/material.dart';
import 'dokter_curved_nav_bar.dart';

class DokterBerandaPage extends StatefulWidget {
  const DokterBerandaPage({super.key});

  @override
  State<DokterBerandaPage> createState() => _DokterBerandaPageState();
}

class _DokterBerandaPageState extends State<DokterBerandaPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 5 Halaman Utama Dokter
    final List<Widget> pages = [
      const _DokterDashboardView(), // Tampilan Dashboard Utama Dokter
      const Center(child: Text('Halaman Hasil Skrining Pasien')),
      const Center(child: Text('Halaman Konsultasi Chat')),
      const Center(child: Text('Halaman Lokasi Praktek / Faskes')),
      const Center(child: Text('Halaman Profil Dokter')),
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

// Widget Khusus Tampilan Dashboard Dokter
class _DokterDashboardView extends StatelessWidget {
  const _DokterDashboardView();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Menyapa Dokter
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Selamat Datang, 👋',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'dr. Amanda Putri',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Icon(
                    Icons.person_rounded,
                    color: Color(0xFF4F46E5),
                    size: 28,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Kartu Ringkasan Statistik
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Pasien',
                    count: '24',
                    icon: Icons.people_alt_rounded,
                    color: const Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Perlu Review',
                    count: '5',
                    icon: Icons.assignment_late_rounded,
                    color: const Color(0xFFF59E0B),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Judul Bagian Konsultasi
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Konsultasi Terbaru',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF4F46E5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Item Daftar Pasien Konsultasi
            _buildPatientItem(
              name: 'Budi Santoso',
              desc: 'Hasil gula darah puasa: 180 mg/dL',
              time: '10:30 WIB',
              statusColor: Colors.red,
            ),
            _buildPatientItem(
              name: 'Siti Rahma',
              desc: 'Minta penyesuaian dosis obat harian',
              time: '09:15 WIB',
              statusColor: Colors.orange,
            ),
            _buildPatientItem(
              name: 'Ahmad Dahlan',
              desc: 'Skrining mingguan selesai',
              time: 'Kemarin',
              statusColor: Colors.green,
            ),
          ],
        ),
      ),
    );
  }

  // Helper Card Statistik
  Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            count,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper List Item Pasien
  Widget _buildPatientItem({
    required String name,
    required String desc,
    required String time,
    required Color statusColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: statusColor.withValues(alpha: 0.12),
            child: Text(
              name[0],
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }
}