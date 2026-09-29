import 'package:flutter/material.dart';
<<<<<<< HEAD

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. WAVE HEADER BANNER (SEAMLESS GRADIENT)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6679F4), Color(0xFF8DA0FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(36),
                        bottomRight: Radius.circular(36),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Color(0xFFEEF2FF),
                                    child: Icon(Icons.admin_panel_settings_rounded, color: Color(0xFF6679F4), size: 22),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      'Halo, Admin 👋',
                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    Text(
                                      'Diora Health Portal',
                                      style: TextStyle(fontSize: 12, color: Colors.white70),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 22),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 2. DONUT CHART (BENTUK LINGKARAN - SKRINING POSITIF vs TOTAL)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6679F4).withValues(alpha: 0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Ring Donut Visual
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 80,
                                  height: 80,
                                  child: CircularProgressIndicator(
                                    value: 186 / 968, // Rasio Positif
                                    strokeWidth: 10,
                                    backgroundColor: const Color(0xFFEEF2FF),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF5252)),
                                    strokeCap: StrokeCap.round,
                                  ),
                                ),
                                const Text(
                                  '19%',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFEBEE),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'PERLU PERHATIAN',
                                    style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFFF5252)),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  '186 Skrining Positif',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
                                ),
                                const Text(
                                  'Dari total 968 skrining terselesaikan.',
                                  style: TextStyle(fontSize: 11, color: Colors.black45),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 3. HORIZONTAL PILL CARDS (METRIK KAPSUL MELAYANG)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        _buildPillMetric(
                          icon: Icons.people_alt_rounded,
                          label: 'Pengguna',
                          value: '1.248',
                          color: const Color(0xFF6679F4),
                          bgColor: const Color(0xFFEEF2FF),
                        ),
                        const SizedBox(width: 12),
                        _buildPillMetric(
                          icon: Icons.article_rounded,
                          label: 'Artikel',
                          value: '58',
                          color: const Color(0xFFFF9800),
                          bgColor: const Color(0xFFFFF3E0),
                        ),
                        const SizedBox(width: 12),
                        _buildPillMetric(
                          icon: Icons.bolt_rounded,
                          label: 'Sistem',
                          value: 'Aktif',
                          color: const Color(0xFF2E7D32),
                          bgColor: const Color(0xFFE8F5E9),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 4. TREND SKRINING (FLUID WAVE TANPA BOX CARD)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              'Tren Skrining Diabetes',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            Text(
                              '7 Hari Terakhir',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF6679F4)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Container(
                          height: 90,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF6679F4).withValues(alpha: 0.12),
                                const Color(0xFF6679F4).withValues(alpha: 0.0),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Center(
                            child: Text(
                              '📈 ~~~~~~~~~ [ Seamless Wave Gradient ] ~~~~~~~~~',
                              style: TextStyle(fontSize: 11, color: Color(0xFF6679F4), fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 5. AKTIVITAS TERBARU (CHAT-BUBBLE / NOTIFICATION STYLE)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Aktivitas Terkini',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 14),
                        _buildBubbleActivity(
                          name: 'Siti Aisyah',
                          action: 'Melakukan skrining gejala diabetes',
                          time: '14:32',
                          icon: Icons.assignment_turned_in_rounded,
                          accentColor: Colors.purple,
                        ),
                        const SizedBox(height: 10),
                        _buildBubbleActivity(
                          name: 'Rina Marlina',
                          action: 'Membaca artikel "Pola Makan Diabetes"',
                          time: '10:56',
                          icon: Icons.import_contacts_rounded,
                          accentColor: Colors.blue,
                        ),
                        const SizedBox(height: 10),
                        _buildBubbleActivity(
                          name: 'Bimo Setiawan',
                          action: 'Mengirimkan pesan konsultasi baru',
                          time: '09:13',
                          icon: Icons.mark_chat_read_rounded,
                          accentColor: Colors.orange,
                        ),
                      ],
                    ),
=======
import 'package:firebase_auth/firebase_auth.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Dashboard Admin Diora',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Menyapa Admin
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6679F4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selamat Datang, Admin!',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Kelola data pengguna, daftar dokter, dan rekam medis di sini.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
>>>>>>> a2061b79939bf4aebe654aabdc77eba41f7cb22e
                  ),
                ],
              ),
            ),
<<<<<<< HEAD

            // 6. FLOATING ISLAND NAVIGATION
            Positioned(
              left: 20,
              right: 20,
              bottom: 20,
              child: Container(
                height: 60,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(Icons.grid_view_rounded, 0),
                    _buildNavItem(Icons.people_alt_outlined, 1),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Color(0xFF6679F4),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                    ),
                    _buildNavItem(Icons.article_outlined, 2),
                    _buildNavItem(Icons.person_outline_rounded, 3),
                  ],
                ),
              ),
=======
            const SizedBox(height: 24),

            const Text(
              'Ringkasan Sistem',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // Kartu Ringkasan Statistik
            Row(
              children: [
                _buildStatCard('Total Pasien', '120', Colors.blue),
                const SizedBox(width: 12),
                _buildStatCard('Total Dokter', '8', Colors.green),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatCard('Skrining Hari Ini', '15', Colors.orange),
                const SizedBox(width: 12),
                _buildStatCard('Risiko Tinggi', '4', Colors.red),
              ],
            ),

            const SizedBox(height: 24),
            const Text(
              'Menu Manajemen',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),

            // Menu Pilihan Admin
            _buildAdminMenu(
              icon: Icons.people_alt_rounded,
              title: 'Kelola Data Pengguna',
              subtitle: 'Lihat seluruh daftar pasien registered',
              onTap: () {},
            ),
            _buildAdminMenu(
              icon: Icons.medical_services_rounded,
              title: 'Kelola Data Dokter',
              subtitle: 'Tambah atau nonaktifkan akun dokter',
              onTap: () {},
            ),
            _buildAdminMenu(
              icon: Icons.assignment_rounded,
              title: 'Riwayat Skrining Diabetes',
              subtitle: 'Pantau seluruh rekam medis skrining',
              onTap: () {},
>>>>>>> a2061b79939bf4aebe654aabdc77eba41f7cb22e
            ),
          ],
        ),
      ),
    );
  }

<<<<<<< HEAD
  // WIDGET KAPSUL (PILL METRIC)
  Widget _buildPillMetric({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  // WIDGET GELEMBUNG AKTIVITAS (CHAT BUBBLE STYLE)
  Widget _buildBubbleActivity({
    required String name,
    required String action,
    required String time,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accentColor.withValues(alpha: 0.1),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                Text(action, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
          Text(time, style: const TextStyle(fontSize: 10, color: Colors.black38)),
        ],
=======
  Widget _buildStatCard(String title, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              count,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
>>>>>>> a2061b79939bf4aebe654aabdc77eba41f7cb22e
      ),
    );
  }

<<<<<<< HEAD
  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(icon, color: isSelected ? const Color(0xFF6679F4) : Colors.black38, size: 22),
      onPressed: () => setState(() => _selectedIndex = index),
=======
  Widget _buildAdminMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            // Diganti dengan .withValues(alpha: ...) sesuai rekomendasi Flutter terbaru
            color: const Color(0xFF6679F4).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF6679F4)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: onTap,
      ),
>>>>>>> a2061b79939bf4aebe654aabdc77eba41f7cb22e
    );
  }
}