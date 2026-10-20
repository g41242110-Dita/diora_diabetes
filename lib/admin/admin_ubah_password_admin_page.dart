import 'package:flutter/material.dart';

class UbahPasswordAdminPage extends StatefulWidget {
  const UbahPasswordAdminPage({super.key});

  @override
  State<UbahPasswordAdminPage> createState() => _UbahPasswordAdminPageState();
}

class _UbahPasswordAdminPageState extends State<UbahPasswordAdminPage> {
  final TextEditingController _sandiSaatIniController = TextEditingController();
  final TextEditingController _sandiBaruController = TextEditingController();
  final TextEditingController _konfirmasiSandiController = TextEditingController();

  bool _obscureSaatIni = true;
  bool _obscureBaru = true;
  bool _obscureKonfirmasi = true;

  bool _showSuccessAlert = false;

  @override
  void dispose() {
    _sandiSaatIniController.dispose();
    _sandiBaruController.dispose();
    _konfirmasiSandiController.dispose();
    super.dispose();
  }

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
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3B82F6)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Alert Banner "Perubahan Disimpan !"
            if (_showSuccessAlert)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF81C784), width: 1),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
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
                          'Perubahan Disimpan !',
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
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Judul Halaman
                    const Center(
                      child: Text(
                        'Ubah Password',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.black45, thickness: 1),
                    const SizedBox(height: 16),

                    // Petunjuk Karakter
                    const Text(
                      'Gunakan minimal 8 karakter dengan kombinasi huruf dan angka.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black87,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Input 1: Password Saat Ini
                    _buildPasswordField(
                      label: 'Password Saat Ini',
                      hintText: 'Masukkan password lama',
                      controller: _sandiSaatIniController,
                      isObscure: _obscureSaatIni,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureSaatIni = !_obscureSaatIni;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input 2: Password Baru
                    _buildPasswordField(
                      label: 'Password Baru',
                      hintText: 'Masukkan password baru',
                      controller: _sandiBaruController,
                      isObscure: _obscureBaru,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureBaru = !_obscureBaru;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Input 3: Konfirmasi Password Baru
                    _buildPasswordField(
                      label: 'Konfirmasi Password Baru',
                      hintText: 'Ulangi password baru',
                      controller: _konfirmasiSandiController,
                      isObscure: _obscureKonfirmasi,
                      onToggleVisibility: () {
                        setState(() {
                          _obscureKonfirmasi = !_obscureKonfirmasi;
                        });
                      },
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),

            // Tombol Simpan Password di Bagian Bawah
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF6366F1).withValues(alpha: 0.4),
                  ),
                  onPressed: _simpanPerubahan,
                  child: const Text(
                    'Simpan Password',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hintText,
    required TextEditingController controller,
    required bool isObscure,
    required VoidCallback onToggleVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscure,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black87,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: hintText,
              hintStyle: const TextStyle(
                fontSize: 14,
                color: Colors.black38,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: InputBorder.none,
              suffixIcon: IconButton(
                icon: Icon(
                  isObscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.black54,
                  size: 20,
                ),
                onPressed: onToggleVisibility,
              ),
            ),
          ),
        ),
      ],
    );
  }
}