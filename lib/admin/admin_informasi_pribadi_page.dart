import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';

class AdminInformasiPribadiPage extends StatefulWidget {
  const AdminInformasiPribadiPage({super.key});

  @override
  State<AdminInformasiPribadiPage> createState() =>
      _AdminInformasiPribadiPageState();
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
          if (data.containsKey('nama')) {
            _namaController.text = data['nama'] ?? '';
          }
          if (data.containsKey('username') &&
              (data['username'] ?? '').toString().isNotEmpty) {
            _usernameController.text = data['username'] ?? '';
          }
          if (data.containsKey('gender')) {
            _genderController.text = data['gender'] ?? '';
          }
          if (data.containsKey('noHp')) {
            _noHpController.text = data['noHp'] ?? '';
          }
          if (data.containsKey('alamat')) {
            _alamatController.text = data['alamat'] ?? '';
          }
          if (data.containsKey('photoBase64')) {
            _base64Image = data['photoBase64'];
          }
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
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 70,
      );

      if (pickedFile != null) {
        final File file = File(pickedFile.path);
        final List<int> imageBytes = await file.readAsBytes();
        final String encoded = base64Encode(imageBytes);

        setState(() {
          _imageFile = file;
          _base64Image = encoded;
        });

        if (!_isEditing) {
          final User? user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(user.uid)
                .set({'photoBase64': encoded}, SetOptions(merge: true));

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Foto profil berhasil diperbarui!'),
                  backgroundColor: Color(0xFF0D9488),
                ),
              );
            }
          }
        }
      }
    } catch (e) {
      debugPrint("Error memilih gambar: $e");
    }
  }

  Future<void> _hapusFoto() async {
    setState(() {
      _imageFile = null;
      _base64Image = null;
    });

    if (!_isEditing) {
      final User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'photoBase64': null}, SetOptions(merge: true));

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil berhasil dihapus.'),
              backgroundColor: Color(0xFF475569),
            ),
          );
        }
      }
    }
  }

  void _showImagePickerModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const Text(
                  'Ubah Foto Profil',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  title: const Text(
                    'Ambil dari Galeri',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCFBF1),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                  title: const Text(
                    'Ambil dari Kamera',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),
                if (_base64Image != null && _base64Image!.isNotEmpty)
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E6),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                    title: const Text(
                      'Hapus Foto Profil',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFE11D48),
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(ctx);
                      _hapusFoto();
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
            backgroundColor: Color(0xFF0D9488),
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
      backgroundColor: const Color(0xFFF3F6FC),
      body: Column(
        children: [
          _buildLiquidHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            )
                : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
              child: Column(
                children: [
                  _buildTopHeaderCard(),
                  const SizedBox(height: 14),
                  _buildDataDiriCard(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _isLoading ? null : _buildBottomActionArea(),
    );
  }

  Widget _buildBottomActionArea() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: _isEditing
            ? Row(
          children: [
            Expanded(
              flex: 2,
              child: Material(
                color: const Color(0xFFF1F5F9),
                shape: const StadiumBorder(
                  side: BorderSide(color: Color(0xFFCBD5E1), width: 1.2),
                ),
                child: InkWell(
                  customBorder: const StadiumBorder(),
                  onTap: _isSaving
                      ? null
                      : () {
                    setState(() {
                      _isEditing = false;
                    });
                    _loadAdminProfile();
                  },
                  child: const SizedBox(
                    height: 48,
                    child: Center(
                      child: Text(
                        'Batal',
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w800,
                          fontSize: 14.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: _buildGradientPillButton(
                label: 'Simpan Perubahan',
                icon: Icons.check_circle_rounded,
                isLoading: _isSaving,
                onTap: _isSaving ? null : _simpanPerubahan,
              ),
            ),
          ],
        )
            : _buildGradientPillButton(
          label: 'Edit Profil',
          icon: Icons.edit_rounded,
          onTap: () {
            setState(() {
              _isEditing = true;
            });
          },
        ),
      ),
    );
  }

  Widget _buildGradientPillButton({
    required String label,
    required IconData icon,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Container(
      height: 50,
      decoration: ShapeDecoration(
        shape: const StadiumBorder(),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF4338CA),
            Color(0xFF4F46E5),
            Color(0xFF3B82F6),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        shadows: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        shape: const StadiumBorder(),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: Center(
            child: isLoading
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.4,
              ),
            )
                : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 19, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 14;

    return Stack(
      children: [
        ClipPath(
          clipper: _InfoPribadiLiquidHeaderClipper(offsetY: 10),
          child: Container(
            width: double.infinity,
            height: topPadding + 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4F46E5).withValues(alpha: 0.22),
                  const Color(0xFF38BDF8).withValues(alpha: 0.22),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        ClipPath(
          clipper: _InfoPribadiLiquidHeaderClipper(offsetY: 0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, topPadding, 16, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4338CA),
                  Color(0xFF4F46E5),
                  Color(0xFF3B82F6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -35,
                  top: -35,
                  child: IgnorePointer(
                    child: Container(
                      width: 145,
                      height: 145,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.24),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -25,
                  bottom: -20,
                  child: IgnorePointer(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF38BDF8).withValues(alpha: 0.30),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: Stack(
                    children: [
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 36),
                          child: Text(
                            'Informasi Pribadi',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'Kembali',
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _showImagePickerModal,
            child: Stack(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFEEF2FF),
                    border: Border.all(
                      color: const Color(0xFFC7D2FE),
                      width: 2.5,
                    ),
                  ),
                  child: ClipOval(child: _buildProfileImage()),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4F46E5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.8),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _namaController.text.isEmpty
                      ? 'Admin Diora'
                      : _namaController.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2.5),
                Text(
                  _emailController.text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 7),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 3.5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_user_rounded,
                        size: 12.5,
                        color: Color(0xFF4F46E5),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Administrator Diora',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataDiriCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.badge_outlined,
                    size: 17,
                    color: Color(0xFF4F46E5),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Data Diri',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const Spacer(),
                if (_isEditing)
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Mode Edit',
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDataRow(
            Icons.person_outline_rounded,
            'Nama Lengkap',
            _namaController,
            hint: 'Masukkan nama',
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDataRow(
            Icons.alternate_email_rounded,
            'Username',
            _usernameController,
            hint: 'Masukkan username',
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildGenderRow(),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDataRow(
            Icons.phone_outlined,
            'No. HP',
            _noHpController,
            hint: '08xxxxxxxxxx',
            keyboardType: TextInputType.phone,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDataRow(
            Icons.email_outlined,
            'Email',
            _emailController,
            readOnly: true,
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          _buildDataRow(
            Icons.location_on_outlined,
            'Alamat',
            _alamatController,
            hint: 'Masukkan alamat',
          ),
        ],
      ),
    );
  }

  Widget _buildGenderRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12.5),
      child: Row(
        children: [
          const Icon(Icons.wc_rounded, size: 18.5, color: Color(0xFF4F46E5)),
          const SizedBox(width: 11),
          const Text(
            'Jenis Kelamin',
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _isEditing
                ? DropdownButtonFormField<String>(
              initialValue: ['Laki-laki', 'Perempuan']
                  .contains(_genderController.text)
                  ? _genderController.text
                  : null,
              isDense: true,
              alignment: AlignmentDirectional.centerEnd,
              hint: const Text(
                'Pilih',
                style: TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF94A3B8),
                ),
              ),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFC7D2FE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFC7D2FE)),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Laki-laki',
                  child: Text('Laki-laki'),
                ),
                DropdownMenuItem(
                  value: 'Perempuan',
                  child: Text('Perempuan'),
                ),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _genderController.text = val;
                  });
                }
              },
            )
                : Text(
              _genderController.text.trim().isEmpty
                  ? '-'
                  : _genderController.text.trim(),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: _genderController.text.trim().isEmpty
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRow(
      IconData icon,
      String label,
      TextEditingController controller, {
        bool readOnly = false,
        String hint = '-',
        TextInputType keyboardType = TextInputType.text,
      }) {
    final bool canEdit = _isEditing && !readOnly;
    final String displayValue = controller.text.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12.5),
      child: Row(
        children: [
          Icon(icon, size: 18.5, color: const Color(0xFF4F46E5)),
          const SizedBox(width: 11),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: canEdit
                ? TextField(
              controller: controller,
              keyboardType: keyboardType,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
              decoration: InputDecoration(
                isDense: true,
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFC7D2FE)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFC7D2FE)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: Color(0xFF4F46E5),
                    width: 1.4,
                  ),
                ),
              ),
            )
                : Text(
              displayValue.isEmpty ? '-' : displayValue,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: displayValue.isEmpty
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF334155),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage() {
    if (_imageFile != null) {
      return Image.file(_imageFile!, fit: BoxFit.cover);
    } else if (_base64Image != null && _base64Image!.isNotEmpty) {
      try {
        final cleanBase64 = _base64Image!.contains(',')
            ? _base64Image!.split(',').last
            : _base64Image!;
        return Image.memory(
          base64Decode(cleanBase64),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => const Icon(
            Icons.person_rounded,
            size: 36,
            color: Color(0xFF4F46E5),
          ),
        );
      } catch (_) {}
    }
    return const Icon(Icons.person_rounded, size: 36, color: Color(0xFF4F46E5));
  }
}

class _InfoPribadiLiquidHeaderClipper extends CustomClipper<Path> {
  final double offsetY;

  _InfoPribadiLiquidHeaderClipper({this.offsetY = 0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final h = size.height - offsetY;

    path.lineTo(0, h - 22);

    path.quadraticBezierTo(
      size.width * 0.25,
      h + 6,
      size.width * 0.52,
      h - 14,
    );

    path.quadraticBezierTo(
      size.width * 0.80,
      h - 32,
      size.width,
      h - 10,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _InfoPribadiLiquidHeaderClipper oldClipper) {
    return oldClipper.offsetY != offsetY;
  }
}