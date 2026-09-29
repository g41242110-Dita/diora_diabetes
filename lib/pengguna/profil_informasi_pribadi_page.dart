import 'dart:io';
import 'dart:convert'; // Untuk encode Base64
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class InformasiPribadiPage extends StatefulWidget {
  const InformasiPribadiPage({super.key});

  @override
  State<InformasiPribadiPage> createState() => _InformasiPribadiPageState();
}

class _InformasiPribadiPageState extends State<InformasiPribadiPage> {
  bool _showSuccessAlert = false;
  bool _isLoading = true;
  bool _isSaving = false;

  File? _imageFile;
  String? _base64Image; // Menyimpan gambar dalam bentuk teks Base64

  final ImagePicker _picker = ImagePicker();

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

  // Memilih gambar dari Kamera / Galeri dengan resolusi kecil agar hemat storage Firestore
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 300,  // Diperkecil agar ukuran string Base64 ringan
        maxHeight: 300,
        imageQuality: 60,
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        final List<int> imageBytes = await file.readAsBytes();

        setState(() {
          _imageFile = file;
          _base64Image = base64Encode(imageBytes);
        });
      }
    } catch (e) {
      debugPrint("Error memilih gambar: $e");
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Wrap(
              children: [
                const Center(
                  child: Text(
                    'Pilih Foto Profil',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF6679F4)),
                  title: const Text('Ambil dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF6679F4)),
                  title: const Text('Ambil dari Kamera'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Load profile dari Firestore
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
          if (data.containsKey('nama')) _namaController.text = data['nama'] ?? '';
          if (data.containsKey('tglLahir')) _tglLahirController.text = data['tglLahir'] ?? '';
          if (data.containsKey('gender')) _genderController.text = data['gender'] ?? '';
          if (data.containsKey('noHp')) _noHpController.text = data['noHp'] ?? '';
          if (data.containsKey('alamat')) _alamatController.text = data['alamat'] ?? '';
          if (data.containsKey('pekerjaan')) _pekerjaanController.text = data['pekerjaan'] ?? '';
          if (data.containsKey('instansi')) _instansiController.text = data['instansi'] ?? '';
          if (data.containsKey('alergi')) _alergiController.text = data['alergi'] ?? '';
          if (data.containsKey('photoBase64')) _base64Image = data['photoBase64'];
        }
      } catch (e) {
        debugPrint("Gagal memuat profil: $e");
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Simpan data dan string Base64 gambar ke Firestore (Gratis & Bebas Kuota Storage)
  Future<void> _simpanPerubahan() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
      _showSuccessAlert = false;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nama': _namaController.text.trim(),
        'tglLahir': _tglLahirController.text.trim(),
        'gender': _genderController.text.trim(),
        'noHp': _noHpController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'pekerjaan': _pekerjaanController.text.trim(),
        'instansi': _instansiController.text.trim(),
        'alergi': _alergiController.text.trim(),
        'photoBase64': _base64Image,
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _showSuccessAlert = true;
          _isSaving = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal menyimpan data: $e");
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan perubahan: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8FAFC),
        elevation: 0,
        scrolledUnderElevation: 0,
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
                  GestureDetector(
                    onTap: _showImagePickerModal,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFFFCE3CE),
                          child: ClipOval(
                            child: _buildProfileImage(),
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
              onPressed: _isSaving ? null : _simpanPerubahan,
              child: _isSaving
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : const Text(
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

  // Render Foto Profil (File lokal > Base64 dari Firestore > Icon Default)
  Widget _buildProfileImage() {
    if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
      );
    } else if (_base64Image != null && _base64Image!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(_base64Image!),
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.person, size: 45, color: Color(0xFF8D6E63)),
        );
      } catch (_) {}
    }
    return const Icon(Icons.person, size: 45, color: Color(0xFF8D6E63));
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