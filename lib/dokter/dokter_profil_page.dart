import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

// SESUAIKAN PATH INI DENGAN FOLDER LOGIN_PAGE KAMU
import '../pengguna/login_page.dart';

class DokterProfilPage extends StatefulWidget {
  final String? doctorId;

  const DokterProfilPage({super.key, this.doctorId});

  @override
  State<DokterProfilPage> createState() => _DokterProfilPageState();
}

class _DokterProfilPageState extends State<DokterProfilPage> {
  String get _activeDoctorId =>
      (widget.doctorId != null && widget.doctorId!.trim().isNotEmpty)
          ? widget.doctorId!.trim()
          : '1';

  Uint8List? _decodePhotoBase64(dynamic rawBase64) {
    if (rawBase64 == null) return null;
    final str = rawBase64.toString().trim();
    if (str.isEmpty) return null;
    try {
      return base64Decode(str);
    } catch (_) {
      return null;
    }
  }

  Widget _buildAvatarWidget({
    required double radius,
    Uint8List? photoBytes,
    String? photoUrl,
  }) {
    if (photoBytes != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFEEF2FF),
        backgroundImage: MemoryImage(photoBytes),
      );
    }
    if (photoUrl != null && photoUrl.trim().isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: const Color(0xFFEEF2FF),
        backgroundImage: NetworkImage(photoUrl.trim()),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: const Color(0xFFEEF2FF),
      child: Icon(
        Icons.person,
        color: const Color(0xFF4F46E5),
        size: radius * 1.15,
      ),
    );
  }

  void _bukaHalamanEditProfil(
      BuildContext context,
      Map<String, dynamic> currentData,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DokterEditProfilPage(
          doctorId: _activeDoctorId,
          initialData: currentData,
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.all(28.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFF0F0), Color(0xFFFFDADA)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF83B3B).withValues(alpha: 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.logout_rounded,
                      color: Color(0xFFE53935),
                      size: 34,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                const Text(
                  'Sesi Akan Berakhir',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Apakah Anda yakin ingin keluar?\nAnda perlu masuk kembali untuk mengakses akun Diora.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                          ),
                          onPressed: () => Navigator.pop(dialogContext),
                          child: const Text(
                            'Batal',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE53935),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            shadowColor:
                            const Color(0xFFE53935).withValues(alpha: 0.3),
                          ),
                          onPressed: () async {
                            Navigator.pop(dialogContext);

                            await FirebaseAuth.instance.signOut();

                            if (!context.mounted) return;

                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginPage(),
                              ),
                                  (route) => false,
                            );
                          },
                          child: const Text(
                            'Keluar',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('doctors')
              .doc(_activeDoctorId)
              .snapshots(),
          builder: (context, snapshot) {
            final Map<String, dynamic> data =
            (snapshot.hasData && snapshot.data!.exists)
                ? (snapshot.data!.data() as Map<String, dynamic>)
                : <String, dynamic>{};

            final String nama =
            (data['nama'] ?? 'dr. Amanda Putri, Sp.PD').toString();
            final String spesialis =
            (data['spesialis'] ?? 'Dokter Spesialis Penyakit Dalam')
                .toString();
            final String almamater =
            (data['almamater'] ?? data['pendidikan'] ?? 'FK UI').toString();
            final String pengalaman = (data['pengalamanTahun'] ??
                data['pengalaman'] ??
                '5')
                .toString();
            final String rating = (data['rating'] ?? '4.9').toString();
            final String ulasan = (data['ulasan'] ?? '348').toString();
            final String skriningCount =
            (data['totalSkrining'] ?? '186+').toString();
            final String sip = (data['sip'] ?? '446/SIP/2024').toString();
            final String str =
            (data['str'] ?? '33.1.1.100.2.21.09876').toString();
            final String klinikUtama = (data['klinikUtama'] ??
                'Rumah Sakit Perkebunan Jember Klinik')
                .toString();
            final String tentangDokter = (data['deskripsi'] ??
                data['tentangDokter'] ??
                'Spesialis penyakit dalam berpengalaman menangani kasus metabolik.')
                .toString();
            final Uint8List? photoBytes = _decodePhotoBase64(data['photoBase64']);
            final String? photoUrl = data['photoUrl']?.toString();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Profil Dokter',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E2761),
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Kredensial medis resmi dan informasi profil',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // KARTU UTAMA PROFIL DOKTER (TOMBOL EDIT DI TENGAH)
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 70,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(24),
                              topRight: Radius.circular(24),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 20),
                          child: Transform.translate(
                            offset: const Offset(0, -36),
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: _buildAvatarWidget(
                                        radius: 36,
                                        photoBytes: photoBytes,
                                        photoUrl: photoUrl,
                                      ),
                                    ),
                                    Positioned(
                                      right: 3,
                                      bottom: 3,
                                      child: Container(
                                        width: 16,
                                        height: 16,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF10B981),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                              color: Colors.white, width: 2.5),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  nama,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  spesialis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$almamater • Pengalaman $pengalaman Tahun',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEEF2FF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.verified,
                                          color: Color(0xFF4F46E5), size: 15),
                                      SizedBox(width: 6),
                                      Text(
                                        'Terverifikasi Resmi IDI & KKI',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4F46E5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Tombol Edit Profil di Tengah -> Membuka Halaman Baru
                                Center(
                                  child: ElevatedButton.icon(
                                    onPressed: () =>
                                        _bukaHalamanEditProfil(context, data),
                                    icon: const Icon(
                                      Icons.edit_rounded,
                                      size: 15,
                                      color: Colors.white,
                                    ),
                                    label: const Text(
                                      'Edit Profil',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF4F46E5),
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 20, vertical: 9),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 14),
                                const Divider(
                                    height: 1, color: Color(0xFFF1F5F9)),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatColumn(
                                      '★ $rating',
                                      '$ulasan Ulasan',
                                      const Color(0xFFF59E0B),
                                    ),
                                    Container(
                                        width: 1,
                                        height: 28,
                                        color: const Color(0xFFE2E8F0)),
                                    _buildStatColumn(
                                      '$pengalaman Thn',
                                      'Pengalaman',
                                      const Color(0xFF4F46E5),
                                    ),
                                    Container(
                                        width: 1,
                                        height: 28,
                                        color: const Color(0xFFE2E8F0)),
                                    _buildStatColumn(
                                      skriningCount,
                                      'Skrining',
                                      const Color(0xFF10B981),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Text(
                    'Tentang Dokter',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      tentangDokter,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Text(
                    'Legalitas dan Kredensial Dokter',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF0F7FF), Color(0xFFF8FAFC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: const Color(0xFF3B82F6).withValues(alpha: 0.15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildCredentialRow(
                          icon: Icons.assignment_ind_rounded,
                          iconColor: const Color(0xFF3B82F6),
                          label: 'Nomor Surat Izin Praktik (SIP)',
                          value: sip,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                        ),
                        _buildCredentialRow(
                          icon: Icons.verified_user_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          label: 'Nomor Registrasi Dokter (STR)',
                          value: str,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, color: Color(0xFFE2E8F0)),
                        ),
                        _buildCredentialRow(
                          icon: Icons.local_hospital_rounded,
                          iconColor: const Color(0xFFEC4899),
                          label: 'Klinik Dinas Utama',
                          value: klinikUtama,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  Center(
                    child: SizedBox(
                      width: 220,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: () => _showLogoutConfirmationDialog(context),
                        icon: const Icon(Icons.logout_rounded,
                            color: Colors.white, size: 18),
                        label: const Text(
                          'Keluar Portal Dokter',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          elevation: 2,
                          shadowColor:
                          const Color(0xFFE53935).withValues(alpha: 0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: valueColor,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildCredentialRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// HALAMAN BARU BERWARNA: EDIT PROFIL & KREDENSIAL DOKTER
// =============================================================================
class DokterEditProfilPage extends StatefulWidget {
  final String doctorId;
  final Map<String, dynamic> initialData;

  const DokterEditProfilPage({
    super.key,
    required this.doctorId,
    required this.initialData,
  });

  @override
  State<DokterEditProfilPage> createState() => _DokterEditProfilPageState();
}

class _DokterEditProfilPageState extends State<DokterEditProfilPage> {
  final ImagePicker _picker = ImagePicker();

  late final TextEditingController _namaCtrl;
  late final TextEditingController _spesialisCtrl;
  late final TextEditingController _almamaterCtrl;
  late final TextEditingController _pengalamanCtrl;
  late final TextEditingController _tentangCtrl;
  late final TextEditingController _sipCtrl;
  late final TextEditingController _strCtrl;
  late final TextEditingController _klinikCtrl;

  Uint8List? _photoBytes;
  String? _photoUrl;
  bool _hapusFoto = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    _namaCtrl = TextEditingController(
      text: (d['nama'] ?? 'dr. Amanda Putri, Sp.PD').toString(),
    );
    _spesialisCtrl = TextEditingController(
      text: (d['spesialis'] ?? 'Dokter Spesialis Penyakit Dalam').toString(),
    );
    _almamaterCtrl = TextEditingController(
      text: (d['almamater'] ?? d['pendidikan'] ?? 'FK UI').toString(),
    );
    _pengalamanCtrl = TextEditingController(
      text: (d['pengalamanTahun'] ?? d['pengalaman'] ?? '5').toString(),
    );
    _tentangCtrl = TextEditingController(
      text: (d['deskripsi'] ??
          d['tentangDokter'] ??
          'Spesialis penyakit dalam berpengalaman menangani kasus metabolik.')
          .toString(),
    );
    _sipCtrl = TextEditingController(
      text: (d['sip'] ?? '446/SIP/2024').toString(),
    );
    _strCtrl = TextEditingController(
      text: (d['str'] ?? '33.1.1.100.2.21.09876').toString(),
    );
    _klinikCtrl = TextEditingController(
      text: (d['klinikUtama'] ?? 'Rumah Sakit Perkebunan Jember Klinik')
          .toString(),
    );

    final rawB64 = d['photoBase64'];
    if (rawB64 != null && rawB64.toString().trim().isNotEmpty) {
      try {
        _photoBytes = base64Decode(rawB64.toString().trim());
      } catch (_) {
        _photoBytes = null;
      }
    }
    final rawUrl = d['photoUrl'];
    if (rawUrl != null && rawUrl.toString().trim().isNotEmpty) {
      _photoUrl = rawUrl.toString().trim();
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _spesialisCtrl.dispose();
    _almamaterCtrl.dispose();
    _pengalamanCtrl.dispose();
    _tentangCtrl.dispose();
    _sipCtrl.dispose();
    _strCtrl.dispose();
    _klinikCtrl.dispose();
    super.dispose();
  }

  Future<void> _pilihFoto(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 640,
        maxHeight: 640,
        imageQuality: 75,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _photoBytes = bytes;
        _hapusFoto = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Gagal membuka ${source == ImageSource.camera ? 'kamera' : 'galeri'}: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _hapusFotoProfil() {
    setState(() {
      _photoBytes = null;
      _photoUrl = null;
      _hapusFoto = true;
    });
  }

  Future<void> _simpanProfil() async {
    if (_namaCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama dokter tidak boleh kosong.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final String pengalamanTeks = _pengalamanCtrl.text.trim();
      final int? pengalamanAngka = int.tryParse(pengalamanTeks);

      final Map<String, dynamic> updates = {
        'nama': _namaCtrl.text.trim(),
        'spesialis': _spesialisCtrl.text.trim(),
        'almamater': _almamaterCtrl.text.trim(),
        'pengalaman': pengalamanAngka ?? pengalamanTeks,
        'pengalamanTahun': pengalamanAngka ?? pengalamanTeks,
        'deskripsi': _tentangCtrl.text.trim(),
        'tentangDokter': _tentangCtrl.text.trim(),
        'sip': _sipCtrl.text.trim(),
        'str': _strCtrl.text.trim(),
        'klinikUtama': _klinikCtrl.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (_hapusFoto) {
        updates['photoBase64'] = FieldValue.delete();
        updates['photoUrl'] = FieldValue.delete();
      } else if (_photoBytes != null) {
        updates['photoBase64'] = base64Encode(_photoBytes!);
      }

      await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .set(updates, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profil dokter berhasil diperbarui.'),
          backgroundColor: Color(0xFF059669),
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan profil: $e'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget _buildTopBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.of(context).padding.top + 12,
        20,
        24,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3730A3), Color(0xFF4F46E5), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pop(context),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(Icons.arrow_back_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Edit Profil Dokter',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Kelola foto, bio medis, & kredensial praktik',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFFE0E7FF),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF6EE7B7).withValues(alpha: 0.5)),
                ),
                child: const Text(
                  'ID Dokter',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF6EE7B7),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditAvatarCard() {
    ImageProvider? imageProvider;
    if (!_hapusFoto && _photoBytes != null) {
      imageProvider = MemoryImage(_photoBytes!);
    } else if (!_hapusFoto && _photoUrl != null && _photoUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_photoUrl!);
    }

    final bool adaFoto = imageProvider != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Colors.white],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFC7D2FE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF06B6D4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                radius: 44,
                backgroundColor: const Color(0xFFEEF2FF),
                backgroundImage: imageProvider,
                child: !adaFoto
                    ? const Icon(
                  Icons.person_rounded,
                  size: 48,
                  color: Color(0xFF4F46E5),
                )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Foto Profil Dokter',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Ambil langsung dari kamera, galeri, atau hapus foto',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () => _pilihFoto(ImageSource.camera),
                icon: const Icon(Icons.camera_alt_rounded,
                    size: 16, color: Colors.white),
                label: const Text(
                  'Kamera',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _pilihFoto(ImageSource.gallery),
                icon: const Icon(Icons.photo_library_rounded,
                    size: 16, color: Colors.white),
                label: const Text(
                  'Galeri',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D9488),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (adaFoto)
                ElevatedButton.icon(
                  onPressed: _hapusFotoProfil,
                  icon: const Icon(Icons.delete_outline_rounded,
                      size: 16, color: Colors.white),
                  label: const Text(
                    'Hapus Foto',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE11D48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldCard({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required Color accentColor,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 17, color: accentColor),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accentColor, width: 1.6),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopBanner(context),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildEditAvatarCard(),
                  const SizedBox(height: 20),
                  _buildSectionTitle(
                    'Informasi Profil',
                    Icons.person_pin_rounded,
                    const Color(0xFF4F46E5),
                  ),
                  const SizedBox(height: 12),
                  _buildFieldCard(
                    label: 'Nama & Gelar Dokter',
                    controller: _namaCtrl,
                    icon: Icons.badge_outlined,
                    accentColor: const Color(0xFF4F46E5),
                  ),
                  const SizedBox(height: 12),
                  _buildFieldCard(
                    label: 'Spesialisasi',
                    controller: _spesialisCtrl,
                    icon: Icons.medical_services_outlined,
                    accentColor: const Color(0xFF0D9488),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildFieldCard(
                          label: 'Almamater',
                          controller: _almamaterCtrl,
                          icon: Icons.school_outlined,
                          accentColor: const Color(0xFF7C3AED),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildFieldCard(
                          label: 'Pengalaman (Thn)',
                          controller: _pengalamanCtrl,
                          icon: Icons.workspace_premium_outlined,
                          accentColor: const Color(0xFFD97706),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFieldCard(
                    label: 'Tentang Dokter',
                    controller: _tentangCtrl,
                    icon: Icons.description_outlined,
                    accentColor: const Color(0xFF4F46E5),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 22),
                  _buildSectionTitle(
                    'Legalitas & Fasyankes',
                    Icons.verified_user_rounded,
                    const Color(0xFF0284C7),
                  ),
                  const SizedBox(height: 12),
                  _buildFieldCard(
                    label: 'Nomor SIP',
                    controller: _sipCtrl,
                    icon: Icons.assignment_ind_outlined,
                    accentColor: const Color(0xFF0284C7),
                  ),
                  const SizedBox(height: 12),
                  _buildFieldCard(
                    label: 'Nomor STR',
                    controller: _strCtrl,
                    icon: Icons.verified_user_outlined,
                    accentColor: const Color(0xFF7C3AED),
                  ),
                  const SizedBox(height: 12),
                  _buildFieldCard(
                    label: 'Klinik Dinas Utama',
                    controller: _klinikCtrl,
                    icon: Icons.local_hospital_outlined,
                    accentColor: const Color(0xFFEC4899),
                  ),
                  const SizedBox(height: 26),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _simpanProfil,
                      icon: _isSaving
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Icon(Icons.save_rounded,
                          color: Colors.white, size: 20),
                      label: Text(
                        _isSaving ? 'Menyimpan Perubahan...' : 'Simpan Perubahan',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        elevation: 4,
                        shadowColor:
                        const Color(0xFF4F46E5).withValues(alpha: 0.35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
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
}