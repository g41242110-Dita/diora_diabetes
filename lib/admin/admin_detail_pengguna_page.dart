import 'package:flutter/material.dart';

class AdminDetailPenggunaPage extends StatelessWidget {
  final Map<String, dynamic> userData;

  const AdminDetailPenggunaPage({super.key, required this.userData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4C63E6)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Pengguna',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4C63E6),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Card Header User
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 36, color: Color(0xFF5B71F5)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userData['nama'],
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          userData['email'],
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF818CF8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      userData['status'],
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Section Data Diri
            _buildSectionCard('Data Diri', [
              _buildRowItem(Icons.group_outlined, 'Nama Lengkap', userData['nama']),
              _buildRowItem(Icons.calendar_today_outlined, 'Tanggal Lahir', userData['tglLahir']),
              _buildRowItem(Icons.wc_outlined, 'Jenis Kelamin', userData['gender']),
              _buildRowItem(Icons.phone_outlined, 'No. HP', userData['noHp']),
              _buildRowItem(Icons.email_outlined, 'Email', userData['email']),
              _buildRowItem(Icons.location_on_outlined, 'Alamat', userData['alamat']),
            ]),
            const SizedBox(height: 16),

            // Section Informasi Profesi
            _buildSectionCard('Informasi Profesi', [
              _buildRowItem(Icons.work_outline, 'Pekerjaan', userData['pekerjaan']),
              _buildRowItem(Icons.business_outlined, 'Instansi', userData['instansi']),
              _buildRowItem(Icons.block_outlined, 'Riwayat Alergi', userData['alergi']),
            ]),
            const SizedBox(height: 16),

            // Section Riwayat Skrining
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Riwayat Skrining', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Lihat Semua >', style: TextStyle(fontSize: 11, color: Color(0xFF4C63E6))),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_month, color: Color(0xFF4C63E6), size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('01 September 2026', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text('Skrining Diabetes', style: TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF818CF8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text('Positif', style: TextStyle(color: Colors.white, fontSize: 10)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Container(
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildRowItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}