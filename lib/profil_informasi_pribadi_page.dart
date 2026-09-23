import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InformasiPribadiPage extends StatefulWidget {
  const InformasiPribadiPage({super.key});

  @override
  State<InformasiPribadiPage> createState() => _InformasiPribadiPageState();
}

class _InformasiPribadiPageState extends State<InformasiPribadiPage> {
  bool _showSuccessAlert = false;
  bool _isLoading = true;

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _tglLahirController = TextEditingController(text: '12 Maret 2003');
  final TextEditingController _genderController = TextEditingController(text: 'Perempuan');
  final TextEditingController _noHpController = TextEditingController(text: '0812 3456 7850');
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController(text: 'Jl. Mastrip 84');
  final TextEditingController _pekerjaanController = TextEditingController(text: 'Mahasiswa');
  final TextEditingController _instansiController = TextEditingController(text: 'Jl. Mastrip 84');
  final TextEditingController _alergiController = TextEditingController(text: 'Tidak Ada');

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _tglLahirController.dispose();
    _genderController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    _pekerjaanController.dispose();
    _instansiController.dispose();
    _alergiController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _emailController.text = user.email ?? '';
      _namaController.text = user.email?.split('@').first ?? '';

      try {
        final DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('nama')) _namaController.text = data['nama'];
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _simpanPerubahan() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'nama': _namaController.text.trim(),
        });
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _showSuccessAlert = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0, // Mencegah perubahan warna AppBar saat di-scroll
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Informasi Pribadi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF6679F4)),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              if (_showSuccessAlert)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF81C784), width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Color(0xFF2E7D32),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Perubahan Berhasil Disimpan !',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _showSuccessAlert = false;
                            });
                          },
                          child: const Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Header Foto Profil & Nama
              Row(
                children: [
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: const Color(0xFFFCE3CE),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/avatar.png',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 45, color: Color(0xFF8D6E63)),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.black87, width: 1),
                          ),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            size: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _namaController.text,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _emailController.text,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Kartu Data Diri
              _buildSectionCard(
                title: 'Data Diri',
                items: [
                  _DataRowItem(
                    icon: Icons.group_outlined,
                    label: 'Nama Lengkap',
                    controller: _namaController,
                  ),
                  _DataRowItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Tanggal Lahir',
                    controller: _tglLahirController,
                  ),
                  _DataRowItem(
                    icon: Icons.female_outlined,
                    label: 'Jenis Kelamin',
                    controller: _genderController,
                  ),
                  _DataRowItem(
                    icon: Icons.phone_outlined,
                    label: 'No. HP',
                    controller: _noHpController,
                  ),
                  _DataRowItem(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    controller: _emailController,
                    readOnly: true,
                  ),
                  _DataRowItem(
                    icon: Icons.location_on_outlined,
                    label: 'Alamat',
                    controller: _alamatController,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kartu Informasi Profesi
              _buildSectionCard(
                title: 'Informasi Profesi',
                items: [
                  _DataRowItem(
                    icon: Icons.work_outline,
                    label: 'Pekerjaan',
                    controller: _pekerjaanController,
                  ),
                  _DataRowItem(
                    icon: Icons.business_outlined,
                    label: 'Instansi',
                    controller: _instansiController,
                  ),
                  _DataRowItem(
                    icon: Icons.block_outlined,
                    label: 'Riwayat Alergi',
                    controller: _alergiController,
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),

      // Tombol Simpan Perubahan Melayang di Bawah
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6679F4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 0,
              ),
              onPressed: _simpanPerubahan,
              child: const Text(
                'Simpan Perubahan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<_DataRowItem> items,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEBF2FE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(15),
                topRight: Radius.circular(15),
              ),
            ),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFE2E8F0)),
            itemBuilder: (context, index) {
              final item = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Icon(
                      item.icon,
                      size: 20,
                      color: const Color(0xFF475569),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      width: 110,
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: item.controller,
                        readOnly: item.readOnly,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                        decoration: const InputDecoration(
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _DataRowItem {
  final IconData icon;
  final String label;
  final TextEditingController controller;
  final bool readOnly;

  _DataRowItem({
    required this.icon,
    required this.label,
    required this.controller,
    this.readOnly = false,
  });
}