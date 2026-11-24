// ignore_for_file: spell_check_on_only_sample_attachments, depend_on_referenced_packages, avoid_types_as_parameter_names

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminDetailPenggunaPage extends StatefulWidget {
  final Map<String, String> userData;

  const AdminDetailPenggunaPage({
    super.key,
    required this.userData,
  });

  @override
  State<AdminDetailPenggunaPage> createState() =>
      _AdminDetailPenggunaPageState();
}

class _AdminDetailPenggunaPageState extends State<AdminDetailPenggunaPage> {
  bool _showAllScreenings = false;

  static const _possibleCollections = [
    'screening_results',
    'screenings',
    'skrining',
    'riwayat_skrining',
    'hasil_skrining',
    'screening_history',
  ];

  final _docsBySource = <String, dynamic>{};
  final _subscriptions = <StreamSubscription>[];
  bool _isLoadingScreenings = true;
  String? _streamError;

  @override
  void initState() {
    super.initState();
    _listenAllScreeningSources();
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.dispose();
  }

  String _resolveUserId() {
    final candidates = [
      widget.userData['uid'],
      widget.userData['id'],
      widget.userData['userId'],
      widget.userData['user_id'],
      widget.userData['docId'],
    ];
    for (final c in candidates) {
      if (c != null && c.trim().isNotEmpty && c.trim() != '-') {
        return c.trim();
      }
    }
    return '';
  }

  void _attachStream(String sourceKey, Stream queryStream) {
    final sub = queryStream.listen(
          (snapshot) {
        if (!mounted) return;
        setState(() {
          _docsBySource[sourceKey] = snapshot.docs;
          _isLoadingScreenings = false;
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _streamError = e.toString();
          _isLoadingScreenings = false;
        });
      },
    );
    _subscriptions.add(sub);
  }

  void _listenAllScreeningSources() {
    final firestore = FirebaseFirestore.instance;
    final uid = _resolveUserId();

    for (final col in _possibleCollections) {
      _attachStream('root_$col', firestore.collection(col).snapshots());
    }

    if (uid.isNotEmpty) {
      const subCollections = [
        'screening_results',
        'screenings',
        'skrining',
        'riwayat_skrining',
        'hasil_skrining',
      ];
      for (final subCol in subCollections) {
        _attachStream(
          'sub_$subCol',
          firestore
              .collection('users')
              .doc(uid)
              .collection(subCol)
              .snapshots(),
        );
      }
    }
  }

  String _val(String key, {String fallback = '-'}) {
    final raw = (widget.userData[key] ?? '').trim();
    return raw.isEmpty ? fallback : raw;
  }

  String _getInitials(String name) {
    final cleaned = name.trim();
    if (cleaned.isEmpty || cleaned == '-') return 'U';
    final parts = cleaned.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  DateTime? _parseDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is int) {
      return raw > 100000000000
          ? DateTime.fromMillisecondsSinceEpoch(raw)
          : DateTime.fromMillisecondsSinceEpoch(raw * 1000);
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return DateTime.tryParse(raw.trim());
    }
    return null;
  }

  String _formatDate(dynamic raw) {
    if (raw == null) return '-';
    final dt = _parseDateTime(raw);
    if (dt == null) {
      return raw is String && raw.trim().isNotEmpty ? raw.trim() : '-';
    }

    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember'
    ];
    final day = dt.day.toString().padLeft(2, '0');
    return '$day ${bulan[dt.month]} ${dt.year}';
  }

  bool _isPositiveResult(Map data) {
    final raw = (data['status'] ??
        data['hasil'] ??
        data['result'] ??
        data['prediction'] ??
        data['prediksi'] ??
        data['risk_level'] ??
        data['riskLevel'] ??
        data['kategori'] ??
        data['diagnosis'] ??
        '')
        .toString()
        .toLowerCase();

    return raw.contains('positif') ||
        raw.contains('positive') ||
        raw.contains('tinggi') ||
        raw.contains('high') ||
        raw.contains('berisiko') ||
        raw == '1' ||
        raw == 'true';
  }

  bool _belongsToUser(
      Map data, {
        required bool isFromSubcollection,
        required String uid,
        required String email,
        required String nama,
      }) {
    if (isFromSubcollection) return true;

    final userMap = data['user'] is Map ? data['user'] as Map : null;

    final docUid = (data['userId'] ??
        data['uid'] ??
        data['user_id'] ??
        data['idUser'] ??
        data['id_user'] ??
        data['penggunaId'] ??
        userMap?['uid'] ??
        userMap?['id'] ??
        '')
        .toString()
        .trim();

    final docEmail = (data['email'] ??
        data['userEmail'] ??
        data['user_email'] ??
        userMap?['email'] ??
        '')
        .toString()
        .trim()
        .toLowerCase();

    final docNama = (data['nama'] ??
        data['name'] ??
        data['userName'] ??
        data['namaLengkap'] ??
        userMap?['nama'] ??
        userMap?['name'] ??
        '')
        .toString()
        .trim()
        .toLowerCase();

    final matchUid = uid.isNotEmpty && docUid == uid;
    final matchEmail = email.isNotEmpty &&
        email != '-' &&
        docEmail.isNotEmpty &&
        docEmail == email.toLowerCase();
    final matchNama = docUid.isEmpty &&
        docEmail.isEmpty &&
        nama.isNotEmpty &&
        nama != 'Pengguna' &&
        docNama == nama.toLowerCase();

    return matchUid || matchEmail || matchNama;
  }

  List _getMergedUserScreenings({
    required String uid,
    required String email,
    required String nama,
  }) {
    final uniqueItems = <String, Map>{};

    _docsBySource.forEach((sourceKey, docs) {
      final isSub = sourceKey.startsWith('sub_');
      if (docs is Iterable) {
        for (final doc in docs) {
          final rawData = doc.data();
          if (rawData is Map) {
            if (_belongsToUser(
              rawData,
              isFromSubcollection: isSub,
              uid: uid,
              email: email,
              nama: nama,
            )) {
              uniqueItems['${sourceKey}_${doc.id}'] = rawData;
            }
          }
        }
      }
    });

    final resultList = uniqueItems.values.toList();

    resultList.sort((a, b) {
      final dtA = _parseDateTime(
        a['created_at'] ??
            a['createdAt'] ??
            a['tanggal'] ??
            a['date'] ??
            a['timestamp'],
      ) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      final dtB = _parseDateTime(
        b['created_at'] ??
            b['createdAt'] ??
            b['tanggal'] ??
            b['date'] ??
            b['timestamp'],
      ) ??
          DateTime.fromMillisecondsSinceEpoch(0);
      return dtB.compareTo(dtA);
    });

    return resultList;
  }

  @override
  Widget build(BuildContext context) {
    final String uid = _resolveUserId();
    final String nama = _val('nama', fallback: 'Pengguna');
    final String email = _val('email');
    final String role = _val('role', fallback: 'Pengguna');
    final String status = _val('status', fallback: 'Aktif');
    final String tglLahir = _val('tglLahir');
    final String gender = _val('gender');
    final String noHp = _val('noHp');
    final String alamat = _val('alamat');
    final String pekerjaan = _val('pekerjaan');
    final String instansi = _val('instansi');
    final String alergi = _val('alergi', fallback: 'Tidak Ada');
    final String photoBase64 = _val('photoBase64', fallback: '');

    final bool isAktif = status.toLowerCase() == 'aktif';
    final bool isDokter = role.toLowerCase() == 'dokter';

    final userScreenings = _getMergedUserScreenings(
      uid: uid,
      email: email,
      nama: nama,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _buildLiquidHeader(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildProfileSummaryCard(
                  nama: nama,
                  email: email,
                  role: role,
                  status: status,
                  isAktif: isAktif,
                  isDokter: isDokter,
                  photoBase64: photoBase64,
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Data Diri',
                  icon: Icons.badge_rounded,
                  iconBg: const Color(0xFFE0E7FF),
                  iconColor: const Color(0xFF4F46E5),
                  rows: [
                    _InfoRowData(
                      icon: Icons.person_outline_rounded,
                      label: 'Nama Lengkap',
                      value: nama,
                    ),
                    _InfoRowData(
                      icon: Icons.calendar_today_rounded,
                      label: 'Tanggal Lahir',
                      value: tglLahir,
                    ),
                    _InfoRowData(
                      icon: Icons.wc_rounded,
                      label: 'Jenis Kelamin',
                      value: gender,
                    ),
                    _InfoRowData(
                      icon: Icons.phone_outlined,
                      label: 'No. HP',
                      value: noHp,
                    ),
                    _InfoRowData(
                      icon: Icons.mail_outline_rounded,
                      label: 'Email',
                      value: email,
                    ),
                    _InfoRowData(
                      icon: Icons.location_on_outlined,
                      label: 'Alamat',
                      value: alamat,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildSectionCard(
                  title: 'Informasi Profesi',
                  icon: Icons.work_outline_rounded,
                  iconBg: const Color(0xFFCCFBF1),
                  iconColor: const Color(0xFF0D9488),
                  rows: [
                    _InfoRowData(
                      icon: Icons.business_center_outlined,
                      label: 'Pekerjaan',
                      value: pekerjaan,
                    ),
                    _InfoRowData(
                      icon: Icons.apartment_rounded,
                      label: 'Instansi',
                      value: instansi,
                    ),
                    _InfoRowData(
                      icon: Icons.block_rounded,
                      label: 'Riwayat Alergi',
                      value: alergi,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildScreeningHistoryCard(userScreenings),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Stack(
      children: [
        ClipPath(
          clipper: _DetailLiquidHeaderClipper(offsetY: 10),
          child: Container(
            width: double.infinity,
            height: topPadding + 88,
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
          clipper: _DetailLiquidHeaderClipper(offsetY: 0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, topPadding, 16, 36),
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
                Positioned(
                  left: -25,
                  bottom: -20,
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
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          tooltip: 'Kembali',
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 36),
                          child: Text(
                            'Detail Pengguna',
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

  Widget _buildProfileAvatar(String nama, String photoBase64) {
    if (photoBase64.isNotEmpty) {
      try {
        final cleanBase64 = photoBase64.contains(',')
            ? photoBase64.split(',').last
            : photoBase64;
        return ClipOval(
          child: Image.memory(
            base64Decode(cleanBase64),
            width: 64,
            height: 64,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitialCircle(nama),
          ),
        );
      } catch (_) {}
    }
    return _buildInitialCircle(nama);
  }

  Widget _buildInitialCircle(String nama) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitials(nama),
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildProfileSummaryCard({
    required String nama,
    required String email,
    required String role,
    required String status,
    required bool isAktif,
    required bool isDokter,
    required String photoBase64,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.18),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: _buildProfileAvatar(nama, photoBase64),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nama,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16.5,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isDokter
                                ? Icons.medical_services_rounded
                                : Icons.person_rounded,
                            size: 12,
                            color: const Color(0xFF4F46E5),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            role,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isAktif
                            ? const Color(0xFFDCFCE7)
                            : const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isAktif
                              ? const Color(0xFF15803D)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required List rows,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: iconColor),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          ...List.generate(rows.length, (index) {
            final item = rows[index] as _InfoRowData;
            final bool isLast = index == rows.length - 1;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.icon,
                        size: 17,
                        color: const Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 108,
                        child: Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          item.value,
                          textAlign: TextAlign.right,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScreeningHistoryCard(List userDocs) {
    final displayedDocs =
    _showAllScreenings ? userDocs : userDocs.take(2).toList();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.monitor_heart_rounded,
                      size: 17,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Riwayat Skrining',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              if (userDocs.length > 2)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _showAllScreenings = !_showAllScreenings;
                    });
                  },
                  child: Text(
                    _showAllScreenings
                        ? 'Sembunyikan'
                        : 'Lihat Semua (${userDocs.length})',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (_isLoadingScreenings && userDocs.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFF4F46E5),
                  ),
                ),
              ),
            )
          else if (userDocs.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Text(
                _streamError != null
                    ? 'Tidak dapat memuat riwayat skrining. Periksa aturan akses Firestore.'
                    : 'Pengguna ini belum memiliki riwayat skrining.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else
            Column(
              children: displayedDocs.map((rawItem) {
                final data = rawItem as Map;
                final dateText = _formatDate(
                  data['created_at'] ??
                      data['createdAt'] ??
                      data['tanggal'] ??
                      data['date'] ??
                      data['timestamp'],
                );
                final isPositive = _isPositiveResult(data);

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0E7FF),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: const Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dateText,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Skrining Diabetes',
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: isPositive
                              ? const Color(0xFFFEE2E2)
                              : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isPositive ? 'Positif' : 'Negatif',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: isPositive
                                ? const Color(0xFFDC2626)
                                : const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class _InfoRowData {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRowData({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _DetailLiquidHeaderClipper extends CustomClipper<Path> {
  final double offsetY;

  _DetailLiquidHeaderClipper({this.offsetY = 0});

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
  bool shouldReclip(covariant _DetailLiquidHeaderClipper oldClipper) {
    return oldClipper.offsetY != offsetY;
  }
}