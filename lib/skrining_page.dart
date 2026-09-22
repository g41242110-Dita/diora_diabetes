import 'package:flutter/material.dart';
import 'skrining2_page.dart';

class SkriningPage extends StatefulWidget {
  const SkriningPage({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul Utama
              const Center(
                child: Text(
                  'Skrining Gejala Diabetes',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Progress Bar (1/4)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.25,
                        minHeight: 8,
                        backgroundColor: Color(0xFFE2E8F0),
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6679F4)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '1/4',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Sub-Judul
              const Text(
                'Data Diri',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Yuk, lengkapi data diri terlebih dahulu untuk memulai skrining.',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),

              // Input Nama
              _buildLabel('Nama Lengkap'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _namaController,
                hintText: 'Masukkan nama Anda',
              ),
              const SizedBox(height: 16),

              // Input Umur
              _buildLabel('Umur'),
              const SizedBox(height: 8),
              _buildTextField(
                controller: _umurController,
                hintText: 'Masukkan umur Anda',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              // Dropdown Jenis Kelamin
              _buildLabel('Jenis Kelamin'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _jenisKelamin,
                hint: const Text(
                  'Pilih jenis kelamin',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFF6679F4), width: 2),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'Laki-laki', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'Perempuan', child: Text('Perempuan')),
                ],
                onChanged: (value) {
                  setState(() {
                    _jenisKelamin = value;
                  });
                },
              ),

              const Spacer(),

              // Tombol Lanjutkan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6679F4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Skrining2Page(
                          nama: _namaController.text,
                          umur: _umurController.text,
                          jenisKelamin: _jenisKelamin ?? '',
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    'Lanjutkan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF6679F4), width: 2),
        ),
      ),
    );
  }
}