import 'package:flutter/material.dart';
import 'skrining2_page.dart';

class SkriningPage extends StatefulWidget {
  final VoidCallback? onBackToHome; // Callback untuk berpindah ke tab Beranda

  const SkriningPage({super.key, this.onBackToHome});

  @override
  State<SkriningPage> createState() => _SkriningPageState();
}

class _SkriningPageState extends State<SkriningPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _umurController = TextEditingController();
  String? _jenisKelamin;

  @override
  void dispose() {
    _namaController.dispose();
    _umurController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengecek validasi sebelum pindah ke Skrining 2
  void _validateAndNavigate() {
    String nama = _namaController.text.trim();
    String umur = _umurController.text.trim();

    if (nama.isEmpty || umur.isEmpty || _jenisKelamin == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                'Data Belum Lengkap',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Harap isi Nama, Umur, dan Jenis Kelamin terlebih dahulu!',
            style: TextStyle(fontSize: 13.5, color: Color(0xFF475569)),
          ),
          actionsPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6679F4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Mengerti',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Skrining2Page(
          nama: nama,
          umur: umur,
          jenisKelamin: _jenisKelamin!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FE),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. HEADER ESTETIK DENGAN GRADIENT & TOMBOL KEMBALI
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
                        if (widget.onBackToHome != null) {
                          widget.onBackToHome!(); // Pindah ke tab Beranda
                        } else if (Navigator.canPop(context)) {
                          Navigator.pop(context);
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
                      'Skrining Gejala Diabetes',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // PROGRESS BAR ESTETIK
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: const LinearProgressIndicator(
                          value: 0.5,
                          minHeight: 8,
                          backgroundColor: Color(0x33FFFFFF),
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      '1/2',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. KONTEN UTAMA DIBUNGKUS KARTU PUTIH BERSIH
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6679F4).withOpacity(0.06),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(
                    color: const Color(0xFFEEF2F6),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Data Diri',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Yuk, lengkapi data diri terlebih dahulu untuk memulai skrining.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 22),

                    // Input Nama Lengkap
                    _buildLabel('Nama Lengkap'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _namaController,
                      hintText: 'Masukkan nama Anda',
                    ),
                    const SizedBox(height: 18),

                    // Input Umur
                    _buildLabel('Umur'),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _umurController,
                      hintText: 'Masukkan umur Anda',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 18),

                    // Dropdown Jenis Kelamin
                    _buildLabel('Jenis Kelamin'),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: _jenisKelamin,
                        dropdownColor: Colors.white,
                        hint: const Text(
                          'Pilih jenis kelamin',
                          style: TextStyle(color: Colors.grey, fontSize: 13.5),
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          border: InputBorder.none,
                        ),
                        items: const [
                          DropdownMenuItem(
                              value: 'Laki-laki', child: Text('Laki-laki')),
                          DropdownMenuItem(
                              value: 'Perempuan', child: Text('Perempuan')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            _jenisKelamin = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tombol Lanjutkan
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6679F4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _validateAndNavigate,
                        child: const Text(
                          'Lanjutkan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1E293B),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13.5),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}