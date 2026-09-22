import 'package:flutter/material.dart';

class InformasiPribadiPage extends StatefulWidget {
  const InformasiPribadiPage({super.key});

  @override
  State<InformasiPribadiPage> createState() => _InformasiPribadiPageState();
}

class _InformasiPribadiPageState extends State<InformasiPribadiPage> {
  bool _showSuccessAlert = false;

  final TextEditingController _namaController = TextEditingController(text: 'Aurelia Prisilla');
  final TextEditingController _tglLahirController = TextEditingController(text: '12 Maret 2003');
  final TextEditingController _genderController = TextEditingController(text: 'Perempuan');
  final TextEditingController _noHpController = TextEditingController(text: '0812 3456 7850');
  final TextEditingController _emailController = TextEditingController(text: 'Aurelia.Prisilla@gmail.com');
  final TextEditingController _alamatController = TextEditingController(text: 'Jl. Mastrip 84');
  final TextEditingController _pekerjaanController = TextEditingController(text: 'Mahasiswa');
  final TextEditingController _instansiController = TextEditingController(text: 'Jl. Mastrip 84');
  final TextEditingController _alergiController = TextEditingController(text: 'Tidak Ada');

  void _simpanPerubahan() {
    setState(() {
      _showSuccessAlert = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Informasi Pribadi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (_showSuccessAlert)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        Stack(
                          children: [
                            CircleAvatar(
                              radius: 42,
                              backgroundColor: const Color(0xFFFCE3CE),
                              child: ClipOval(
                                child: Image.asset(
                                  'assets/avatar.png',
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.person, size: 50, color: Color(0xFF8D6E63)),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
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
                              const SizedBox(height: 2),
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
                    const SizedBox(height: 20),
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
                        ),
                        _DataRowItem(
                          icon: Icons.location_on_outlined,
                          label: 'Alamat',
                          controller: _alamatController,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
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
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
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
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Color(0xFFEBF2FE),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
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
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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

  _DataRowItem({
    required this.icon,
    required this.label,
    required this.controller,
  });
}