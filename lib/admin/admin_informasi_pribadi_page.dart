import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AdminInformasiPribadiPage extends StatefulWidget {
  const AdminInformasiPribadiPage({super.key});

  @override
  State<AdminInformasiPribadiPage> createState() => _AdminInformasiPribadiPageState();
}

class _AdminInformasiPribadiPageState extends State<AdminInformasiPribadiPage> {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  File? _imageFile;
  String? _base64Image;

  final ImagePicker _picker = ImagePicker();

  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _noHpController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAdminProfile();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _usernameController.dispose();
    _genderController.dispose();
    _noHpController.dispose();
    _emailController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminProfile() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      _emailController.text = user.email ?? '';
      _usernameController.text = user.email?.split('@').first ?? '';

      try {
        final DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('nama')) _namaController.text = data['nama'] ?? '';
          if (data.containsKey('username')) _usernameController.text = data['username'] ?? '';
          if (data.containsKey('gender')) _genderController.text = data['gender'] ?? '';
          if (data.containsKey('noHp')) _noHpController.text = data['noHp'] ?? '';
          if (data.containsKey('alamat')) _alamatController.text = data['alamat'] ?? '';
          if (data.containsKey('photoBase64')) _base64Image = data['photoBase64'];
        }
      } catch (e) {
        debugPrint("Gagal memuat profil admin: $e");
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 300,
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
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Color(0xFF6366F1)),
                  title: const Text('Ambil dari Galeri'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Color(0xFF6366F1)),
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

  Future<void> _simpanPerubahan() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'nama': _namaController.text.trim(),
        'username': _usernameController.text.trim(),
        'gender': _genderController.text.trim(),
        'noHp': _noHpController.text.trim(),
        'alamat': _alamatController.text.trim(),
        'photoBase64': _base64Image,
      }, SetOptions(merge: true));

      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      debugPrint("Gagal menyimpan data: $e");
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4F46E5), size: 26),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Informasi Pribadi',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF4F46E5),
          ),
        ),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Kartu Header Profil Admin
              _buildTopHeaderCard(),
              const SizedBox(height: 20),

              // Kartu Data Diri
              _buildDataDiriCard(),
              const SizedBox(height: 24),

              // Tombol Edit Profil / Simpan
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _isSaving
                      ? null
                      : () {
                    if (_isEditing) {
                      _simpanPerubahan();
                    } else {
                      setState(() {
                        _isEditing = true;
                      });
                    }
                  },
                  child: _isSaving
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    _isEditing ? 'Simpan Perubahan' : 'Edit Profil',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Kartu Atas dengan Foto, Nama Admin, & Logo Diora
  Widget _buildTopHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Foto Profil dengan Ikon Kamera Tambah
          GestureDetector(
            onTap: _isEditing ? _showImagePickerModal : null,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 90,
                    height: 100,
                    color: Colors.white,
                    child: _buildProfileImage(),
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(
                      Icons.add_a_photo_outlined,
                      size: 14,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Nama & Detail Admin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Admin Diora',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _namaController.text.isEmpty ? 'Mustika Cahya' : _namaController.text,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
          // Logo Teks Diora Kanan Atas
          Column(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.water_drop_outlined, color: Color(0xFFEF4444), size: 16),
                  const SizedBox(width: 2),
                  Text(
                    'Diora',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 2. Kartu Tabel Data Diri
  Widget _buildDataDiriCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFC7D2FE), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Judul Data Diri
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Color(0xFFEEF2FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: const Text(
              'Data Diri',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
          ),

          // Baris-Baris Data Diri
          _buildDataRow(Icons.group_outlined, 'Nama Lengkap', _namaController),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          _buildDataRow(Icons.grid_on_outlined, 'Username', _usernameController),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          _buildDataRow(Icons.female_outlined, 'Jenis Kelamin', _genderController),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          _buildDataRow(Icons.phone_outlined, 'No. HP', _noHpController),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          _buildDataRow(Icons.email_outlined, 'Email', _emailController, readOnly: true),
          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          _buildDataRow(Icons.location_on_outlined, 'Alamat', _alamatController),
        ],
      ),
    );
  }

  // Widget Pembantu untuk Baris Data
  Widget _buildDataRow(IconData icon, String label, TextEditingController controller, {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF64748B)),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: _isEditing && !readOnly,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
                color: (readOnly || !_isEditing) ? const Color(0xFF475569) : const Color(0xFF0F172A),
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
  }

  // Widget Gambar Profil
  Widget _buildProfileImage() {
    if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (_base64Image != null && _base64Image!.isNotEmpty) {
      try {
        return Image.memory(
          base64Decode(_base64Image!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.person, size: 50, color: Color(0xFF94A3B8)),
        );
      } catch (_) {}
    }
    return const Icon(Icons.person, size: 50, color: Color(0xFF94A3B8));
  }
}