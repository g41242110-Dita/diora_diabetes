import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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

  // ---------------------------------------------------------------------------
  // DIALOG EDIT PROFIL DOKTER (TERSIMPAN KE FIRESTORE DOCTORS/{ID})
  // ---------------------------------------------------------------------------
  void _showEditProfilSheet(
      BuildContext context,
      Map<String, dynamic> currentData,
      ) {
    final namaCtrl = TextEditingController(
      text: (currentData['nama'] ?? 'dr. Amanda Putri, Sp.PD').toString(),
    );
    final spesialisCtrl = TextEditingController(
      text: (currentData['spesialis'] ?? 'Dokter Spesialis Penyakit Dalam')
          .toString(),
    );
    final almamaterCtrl = TextEditingController(
      text: (currentData['almamater'] ?? currentData['pendidikan'] ?? 'FK UI')
          .toString(),
    );
    final pengalamanCtrl = TextEditingController(
      text: (currentData['pengalamanTahun'] ?? currentData['pengalaman'] ?? '5')
          .toString(),
    );
    final bioCtrl = TextEditingController(
      text: (currentData['deskripsi'] ??
          currentData['tentangDokter'] ??
          'Berfokus pada deteksi dini, edukasi gaya hidup sehat, serta pendampingan kontrol gula darah dan risiko metabolik pasien.')
          .toString(),
    );
    final sipCtrl = TextEditingController(
      text: (currentData['sip'] ?? '446/SIP/2024').toString(),
    );
    final strCtrl = TextEditingController(
      text: (currentData['str'] ?? '33.1.1.100.2.21.09876').toString(),
    );
    final klinikCtrl = TextEditingController(
      text: (currentData['klinikUtama'] ?? 'Klinik Sehat Sentosa').toString(),
    );

    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.88,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 14, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Edit Profil & Kredensial',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Perubahan langsung tersimpan ke data dokter',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          icon: const Icon(Icons.close_rounded,
                              color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        16,
                        20,
                        MediaQuery.of(context).viewInsets.bottom + 24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildEditField(
                            label: 'Nama Lengkap & Gelar',
                            controller: namaCtrl,
                            icon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildEditField(
                            label: 'Spesialisasi',
                            controller: spesialisCtrl,
                            icon: Icons.medical_services_outlined,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildEditField(
                                  label: 'Almamater / Kampus',
                                  controller: almamaterCtrl,
                                  icon: Icons.school_outlined,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildEditField(
                                  label: 'Pengalaman (Thn)',
                                  controller: pengalamanCtrl,
                                  icon: Icons.work_history_outlined,
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildEditField(
                            label: 'Tentang Dokter / Fokus Klinis',
                            controller: bioCtrl,
                            icon: Icons.description_outlined,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 12),
                          _buildEditField(
                            label: 'Nomor SIP',
                            controller: sipCtrl,
                            icon: Icons.assignment_ind_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildEditField(
                            label: 'Nomor STR',
                            controller: strCtrl,
                            icon: Icons.verified_user_outlined,
                          ),
                          const SizedBox(height: 12),
                          _buildEditField(
                            label: 'Klinik Dinas Utama',
                            controller: klinikCtrl,
                            icon: Icons.local_hospital_outlined,
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                if (namaCtrl.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Nama dokter tidak boleh kosong.'),
                                    ),
                                  );
                                  return;
                                }

                                setModalState(() => isSaving = true);
                                try {
                                  final expClean = pengalamanCtrl.text
                                      .trim()
                                      .replaceAll(
                                      RegExp(r'[^0-9]'), '');
                                  await FirebaseFirestore.instance
                                      .collection('doctors')
                                      .doc(_activeDoctorId)
                                      .set({
                                    'nama': namaCtrl.text.trim(),
                                    'spesialis': spesialisCtrl.text.trim(),
                                    'almamater': almamaterCtrl.text.trim(),
                                    'pendidikan':
                                    almamaterCtrl.text.trim(),
                                    'pengalamanTahun':
                                    expClean.isEmpty ? '5' : expClean,
                                    'deskripsi': bioCtrl.text.trim(),
                                    'tentangDokter': bioCtrl.text.trim(),
                                    'sip': sipCtrl.text.trim(),
                                    'str': strCtrl.text.trim(),
                                    'klinikUtama': klinikCtrl.text.trim(),
                                    'updatedAt':
                                    FieldValue.serverTimestamp(),
                                  }, SetOptions(merge: true));

                                  if (sheetContext.mounted) {
                                    Navigator.pop(sheetContext);
                                  }
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            'Profil dokter berhasil diperbarui.'),
                                        backgroundColor:
                                        Color(0xFF059669),
                                        behavior:
                                        SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } catch (e) {
                                  setModalState(() => isSaving = false);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                        content: Text(
                                            'Gagal menyimpan profil: $e'),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: isSaving
                                  ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                                  : const Icon(Icons.save_rounded,
                                  color: Colors.white, size: 18),
                              label: Text(
                                isSaving
                                    ? 'Menyimpan...'
                                    : 'Simpan Perubahan Profil',
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F46E5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: Color(0xFF334155),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF4F46E5)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
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
              borderSide:
              const BorderSide(color: Color(0xFF4F46E5), width: 1.4),
            ),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DIALOG KONFIRMASI LOGOUT
  // ---------------------------------------------------------------------------
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
            final String rating = (data['rating'] ?? '4.8').toString();
            final String ulasan = (data['ulasan'] ?? '324').toString();
            final String skriningCount =
            (data['totalSkrining'] ?? '186+').toString();
            final String sip = (data['sip'] ?? '446/SIP/2024').toString();
            final String str =
            (data['str'] ?? '33.1.1.100.2.21.09876').toString();
            final String klinikUtama =
            (data['klinikUtama'] ?? 'Klinik Sehat Sentosa').toString();
            final String tentangDokter = (data['deskripsi'] ??
                data['tentangDokter'] ??
                'Berfokus pada deteksi dini risiko diabetes, konsultasi gejala metabolik, serta evaluasi hasil skrining mandiri pasien secara terarah.')
                .toString();

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // -----------------------------------------------------------
                  // 1. HEADER JUDUL + TOMBOL EDIT PROFIL
                  // -----------------------------------------------------------
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Expanded(
                        child: Column(
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
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () => _showEditProfilSheet(context, data),
                        icon: const Icon(
                          Icons.edit_rounded,
                          size: 15,
                          color: Color(0xFF4F46E5),
                        ),
                        label: const Text(
                          'Edit Profil',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFFC7D2FE)),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // -----------------------------------------------------------
                  // 2. KARTU UTAMA PROFIL DOKTER
                  // -----------------------------------------------------------
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
                          height: 72,
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
                                      child: const CircleAvatar(
                                        radius: 36,
                                        backgroundColor: Color(0xFFEEF2FF),
                                        child: Icon(
                                          Icons.person,
                                          color: Color(0xFF4F46E5),
                                          size: 42,
                                        ),
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
                                const SizedBox(height: 16),
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

                  // -----------------------------------------------------------
                  // 3. TENTANG DOKTER & RINGKASAN PRAKTIK
                  // -----------------------------------------------------------
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

                  // -----------------------------------------------------------
                  // 4. SEKSI LEGALITAS DAN KREDENSIAL DOKTER
                  // -----------------------------------------------------------
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

                  // -----------------------------------------------------------
                  // 5. TOMBOL KELUAR PORTAL DOKTER
                  // -----------------------------------------------------------
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