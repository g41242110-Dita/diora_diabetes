// ignore_for_file: spelling

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_pengguna_page.dart';
import 'admin_skrining_page.dart';
import 'admin_artikel_page.dart';

class AdminBerandaPage extends StatefulWidget {
  final VoidCallback? onNavigateToPengguna;
  final VoidCallback? onNavigateToSkrining;
  final VoidCallback? onNavigateToArtikel;
  final bool isActive;

  const AdminBerandaPage({
    super.key,
    this.onNavigateToPengguna,
    this.onNavigateToSkrining,
    this.onNavigateToArtikel,
    this.isActive = true,
  });

  @override
  State<AdminBerandaPage> createState() => _AdminBerandaPageState();
}

class _AdminBerandaPageState extends State<AdminBerandaPage> {
  int? _selectedMonthIndex; // Null = tampilkan data keseluruhan

  // Cache stream & bytes foto agar avatar tidak berkedip saat pindah tab
  Stream<DocumentSnapshot>? _adminProfileStream;
  String? _lastBase64String;
  Uint8List? _cachedAvatarBytes;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _adminProfileStream = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots();
    }
  }

  @override
  void didUpdateWidget(covariant AdminBerandaPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isActive != widget.isActive && _selectedMonthIndex != null) {
      setState(() {
        _selectedMonthIndex = null;
      });
    }
  }

  @override
  void deactivate() {
    _selectedMonthIndex = null;
    super.deactivate();
  }

  void _resetFilterToAll() {
    if (_selectedMonthIndex != null && mounted) {
      setState(() {
        _selectedMonthIndex = null;
      });
    }
  }

  Uint8List? _getDecodedAvatarBytes(String? photoBase64) {
    if (photoBase64 == null || photoBase64.isEmpty) {
      _lastBase64String = null;
      _cachedAvatarBytes = null;
      return null;
    }

    if (_lastBase64String == photoBase64 && _cachedAvatarBytes != null) {
      return _cachedAvatarBytes;
    }

    try {
      final cleanBase64 = photoBase64.contains(',')
          ? photoBase64.split(',').last
          : photoBase64;
      _cachedAvatarBytes = base64Decode(cleanBase64);
      _lastBase64String = photoBase64;
      return _cachedAvatarBytes;
    } catch (_) {
      return null;
    }
  }

  Future<void> _openPengguna() async {
    _resetFilterToAll();
    if (widget.onNavigateToPengguna != null) {
      widget.onNavigateToPengguna!();
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminPenggunaPage()),
      );
      _resetFilterToAll();
    }
  }

  Future<void> _openSkrining({String filter = 'Semua'}) async {
    _resetFilterToAll();
    if (filter == 'Semua' && widget.onNavigateToSkrining != null) {
      widget.onNavigateToSkrining!();
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => AdminSkriningPage(initialFilter: filter),
        ),
      );
      _resetFilterToAll();
    }
  }

  Future<void> _openArtikel() async {
    _resetFilterToAll();
    if (widget.onNavigateToArtikel != null) {
      widget.onNavigateToArtikel!();
    } else {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminArtikelPage()),
      );
      _resetFilterToAll();
    }
  }

  /// Pengecekan status positif/negatif yang akurat berdasarkan field `hasilPrediksi`
  bool _isPositiveStatus(Map<String, dynamic> data) {
    final hasilPrediksi = (data['hasilPrediksi'] ?? '').toString().toLowerCase();

    if (hasilPrediksi.contains('negatif') ||
        hasilPrediksi.contains('negative') ||
        hasilPrediksi.contains('tidak') ||
        hasilPrediksi.contains('rendah')) {
      return false;
    }

    if (hasilPrediksi.contains('positif') ||
        hasilPrediksi.contains('positive') ||
        hasilPrediksi.contains('diabetes') ||
        hasilPrediksi.contains('tinggi')) {
      return true;
    }

    if (data['isPositive'] == true ||
        data['is_positive'] == true ||
        data['prediction'] == 1 ||
        data['result'] == 1) {
      return true;
    }

    final rawStatus = (data['status'] ??
        data['hasil'] ??
        data['result'] ??
        data['prediction'] ??
        data['risk_level'] ??
        data['summary'] ??
        data['ringkasan'] ??
        data['keterangan'] ??
        '')
        .toString()
        .toLowerCase();

    if (rawStatus.contains('tidak terindikasi') ||
        rawStatus.contains('risiko rendah') ||
        rawStatus.contains('negatif') ||
        rawStatus.contains('negative') ||
        rawStatus == '0' ||
        rawStatus == 'false') {
      return false;
    }

    return rawStatus.contains('positif') ||
        rawStatus.contains('positive') ||
        rawStatus.contains('tinggi') ||
        rawStatus.contains('high') ||
        rawStatus.contains('diabetes') ||
        rawStatus.contains('terindikasi memiliki risiko') ||
        rawStatus == '1' ||
        rawStatus == 'true';
  }

  DateTime? _extractDocumentDate(Map<String, dynamic> data) {
    final candidates = [
      data['created_at'],
      data['createdAt'],
      data['timestamp'],
      data['tanggal'],
      data['date'],
      data['waktu'],
      data['updated_at'],
    ];

    for (final raw in candidates) {
      if (raw == null) continue;
      if (raw is Timestamp) return raw.toDate();
      if (raw is DateTime) return raw;
      if (raw is int) {
        return raw > 100000000000
            ? DateTime.fromMillisecondsSinceEpoch(raw)
            : DateTime.fromMillisecondsSinceEpoch(raw * 1000);
      }
      if (raw is String && raw.trim().isNotEmpty) {
        final parsed = DateTime.tryParse(raw.trim());
        if (parsed != null) return parsed;

        final slashParts = raw.split('/');
        if (slashParts.length == 3) {
          final d = int.tryParse(slashParts[0]);
          final m = int.tryParse(slashParts[1]);
          final y = int.tryParse(slashParts[2].split(' ').first);
          if (d != null && m != null && y != null) {
            return DateTime(y, m, d);
          }
        }
      }
    }
    return null;
  }

  bool _matchesSelectedMonth(
      Map<String, dynamic> data,
      int targetMonth,
      int targetYear, {
        required bool isLatestMonthSlot,
      }) {
    final dt = _extractDocumentDate(data);
    if (dt == null) {
      return isLatestMonthSlot;
    }
    return dt.month == targetMonth && dt.year == targetYear;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<int> monthIndices = List.generate(
      6,
          (i) => DateTime(now.year, now.month - (5 - i), 1).month,
    );
    final List<int> yearIndices = List.generate(
      6,
          (i) => DateTime(now.year, now.month - (5 - i), 1).year,
    );

    const monthShort = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    const monthFull = [
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

    final bool hasFilter = _selectedMonthIndex != null;
    final int? activeMonth =
    hasFilter ? monthIndices[_selectedMonthIndex!] : null;
    final int? activeYear =
    hasFilter ? yearIndices[_selectedMonthIndex!] : null;
    final String periodBadge = hasFilter
        ? '${monthShort[activeMonth!]} $activeYear'
        : 'Keseluruhan';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      body: Column(
        children: [
          _buildLiquidHeader(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('users')
                              .snapshots(),
                          builder: (context, snapshot) {
                            int totalUsers = 0;
                            if (snapshot.hasData) {
                              totalUsers = snapshot.data!.docs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                final role = (data['role'] ?? 'pengguna')
                                    .toString()
                                    .trim()
                                    .toLowerCase();
                                if (role == 'admin') return false;

                                if (!hasFilter) return true;
                                return _matchesSelectedMonth(
                                  data,
                                  activeMonth!,
                                  activeYear!,
                                  isLatestMonthSlot: _selectedMonthIndex == 5,
                                );
                              }).length;
                            }

                            return _buildAestheticStatCard(
                              title: 'Total Pengguna',
                              periodLabel: periodBadge,
                              value: snapshot.connectionState ==
                                  ConnectionState.waiting
                                  ? '...'
                                  : '$totalUsers',
                              primaryColor: const Color(0xFF4F46E5),
                              softColor: const Color(0xFFE0E7FF),
                              icon: Icons.people_alt_rounded,
                              onTap: _openPengguna,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('screening_results')
                              .snapshots(),
                          builder: (context, snapshot) {
                            int totalSkrining = 0;
                            if (snapshot.hasData) {
                              totalSkrining = snapshot.data!.docs.where((doc) {
                                if (!hasFilter) return true;
                                final data = doc.data() as Map<String, dynamic>;
                                return _matchesSelectedMonth(
                                  data,
                                  activeMonth!,
                                  activeYear!,
                                  isLatestMonthSlot: _selectedMonthIndex == 5,
                                );
                              }).length;
                            }

                            return _buildAestheticStatCard(
                              title: 'Total Skrining',
                              periodLabel: periodBadge,
                              value: snapshot.connectionState ==
                                  ConnectionState.waiting
                                  ? '...'
                                  : '$totalSkrining',
                              primaryColor: const Color(0xFF0D9488),
                              softColor: const Color(0xFFCCFBF1),
                              icon: Icons.monitor_heart_rounded,
                              onTap: () => _openSkrining(filter: 'Semua'),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Row(
                    children: [
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('screening_results')
                              .snapshots(),
                          builder: (context, snapshot) {
                            int positifCount = 0;
                            if (snapshot.hasData) {
                              positifCount = snapshot.data!.docs.where((doc) {
                                final data = doc.data() as Map<String, dynamic>;
                                if (!_isPositiveStatus(data)) return false;

                                if (!hasFilter) return true;
                                return _matchesSelectedMonth(
                                  data,
                                  activeMonth!,
                                  activeYear!,
                                  isLatestMonthSlot: _selectedMonthIndex == 5,
                                );
                              }).length;
                            }

                            return _buildAestheticStatCard(
                              title: 'Skrining Positif',
                              periodLabel: periodBadge,
                              value: snapshot.connectionState ==
                                  ConnectionState.waiting
                                  ? '...'
                                  : '$positifCount',
                              primaryColor: const Color(0xFFE11D48),
                              softColor: const Color(0xFFFFE4E6),
                              icon: Icons.warning_amber_rounded,
                              onTap: () => _openSkrining(filter: 'Positif'),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('articles')
                              .snapshots(),
                          builder: (context, snapshot) {
                            int totalArtikel = 0;
                            if (snapshot.hasData) {
                              totalArtikel = snapshot.data!.docs.where((doc) {
                                if (!hasFilter) return true;
                                final data = doc.data() as Map<String, dynamic>;
                                return _matchesSelectedMonth(
                                  data,
                                  activeMonth!,
                                  activeYear!,
                                  isLatestMonthSlot: _selectedMonthIndex == 5,
                                );
                              }).length;
                            }

                            return _buildAestheticStatCard(
                              title: 'Total Artikel',
                              periodLabel: periodBadge,
                              value: snapshot.connectionState ==
                                  ConnectionState.waiting
                                  ? '...'
                                  : '$totalArtikel',
                              primaryColor: const Color(0xFF2563EB),
                              softColor: const Color(0xFFDBEAFE),
                              icon: Icons.article_rounded,
                              onTap: _openArtikel,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),
                  Expanded(
                    child: _buildInteractiveTrendChartCard(
                      monthIndices: monthIndices,
                      yearIndices: yearIndices,
                      monthShort: monthShort,
                      monthFull: monthFull,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiquidHeader() {
    final topPadding = MediaQuery.of(context).padding.top;
    final user = FirebaseAuth.instance.currentUser;

    return StreamBuilder<DocumentSnapshot>(
      stream: _adminProfileStream ?? const Stream.empty(),
      builder: (context, snapshot) {
        String adminName = 'Admin';
        String? adminPhotoBase64;

        if (user?.email != null && user!.email!.isNotEmpty) {
          adminName = user.email!.split('@').first;
        }

        if (snapshot.hasData && snapshot.data?.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final nama = (data['nama'] ?? '').toString().trim();
          if (nama.isNotEmpty) {
            adminName = nama.split(' ').first;
          }
          adminPhotoBase64 = data['photoBase64']?.toString();
        }

        return Stack(
          children: [
            ClipPath(
              clipper: _LiquidHeaderClipper(offsetY: 10),
              child: Container(
                width: double.infinity,
                height: topPadding + 190,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF4F46E5).withValues(alpha: 0.22),
                      const Color(0xFF38BDF8).withValues(alpha: 0.22),
                    ],
                  ),
                ),
              ),
            ),
            ClipPath(
              clipper: _LiquidHeaderClipper(offsetY: 0),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, topPadding + 12, 20, 38),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF4338CA),
                      Color(0xFF4F46E5),
                      Color(0xFF3B82F6),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2.5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Colors.white,
                                Colors.white.withValues(alpha: 0.45),
                              ],
                            ),
                          ),
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            child: ClipOval(
                              child: _buildAdminAvatar(
                                photoBase64: adminPhotoBase64,
                                adminName: adminName,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Text(
                                  'DASHBOARD ADMIN',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                'Halo, $adminName 👋',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 21,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 9),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.24),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pemantauan & Edukasi Diabetes',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Kelola data pengguna, riwayat skrining, dan artikel edukasi.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.92),
                              fontSize: 11,
                              height: 1.25,
                              fontWeight: FontWeight.w500,
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
      },
    );
  }

  Widget _buildAdminAvatar({
    required String? photoBase64,
    required String adminName,
  }) {
    final bytes = _getDecodedAvatarBytes(photoBase64);
    if (bytes != null) {
      return Image.memory(
        bytes,
        width: 52,
        height: 52,
        fit: BoxFit.cover,
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _buildInitialsFallback(adminName),
      );
    }
    return _buildInitialsFallback(adminName);
  }

  Widget _buildInitialsFallback(String adminName) {
    final initial =
    adminName.trim().isNotEmpty ? adminName.trim()[0].toUpperCase() : 'A';
    return Container(
      color: const Color(0xFFEEF2FF),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Color(0xFF4F46E5),
          ),
        ),
      ),
    );
  }

  Widget _buildAestheticStatCard({
    required String title,
    required String periodLabel,
    required String value,
    required Color primaryColor,
    required Color softColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final bool isFiltered = _selectedMonthIndex != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isFiltered
              ? primaryColor.withValues(alpha: 0.45)
              : const Color(0xFFE2E8F0),
          width: isFiltered ? 1.4 : 1.0,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(22),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(13, 12, 13, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              primaryColor,
                              primaryColor.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, size: 16, color: Colors.white),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isFiltered ? primaryColor : softColor,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          periodLabel,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: isFiltered ? Colors.white : primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 3.5,
                        height: 22,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: Text(
                          value,
                          key: ValueKey('$title-$value-$periodLabel'),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            height: 1.0,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveTrendChartCard({
    required List<int> monthIndices,
    required List<int> yearIndices,
    required List<String> monthShort,
    required List<String> monthFull,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('screening_results')
            .snapshots(),
        builder: (context, snapshot) {
          final List<double> monthlyTotals = List.filled(6, 0);
          final List<int> monthlyPositives = List.filled(6, 0);
          final List<int> monthlyNegatives = List.filled(6, 0);

          if (snapshot.hasData) {
            final docs = snapshot.data!.docs;
            for (final doc in docs) {
              final data = doc.data() as Map<String, dynamic>;
              final bool isPos = _isPositiveStatus(data);

              for (int i = 0; i < 6; i++) {
                if (_matchesSelectedMonth(
                  data,
                  monthIndices[i],
                  yearIndices[i],
                  isLatestMonthSlot: i == 5,
                )) {
                  monthlyTotals[i] += 1;
                  if (isPos) {
                    monthlyPositives[i] += 1;
                  } else {
                    monthlyNegatives[i] += 1;
                  }
                  break;
                }
              }
            }
          }

          final labels = monthIndices.map((m) => monthShort[m]).toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF4F46E5),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Trend Skrining Diabetes',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  if (_selectedMonthIndex != null)
                    GestureDetector(
                      onTap: _resetFilterToAll,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 9, vertical: 3.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Reset',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 11, vertical: 6.5),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      size: 14.5,
                      color: Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        _selectedMonthIndex != null
                            ? '${monthFull[monthIndices[_selectedMonthIndex!]]} ${yearIndices[_selectedMonthIndex!]} (${monthlyPositives[_selectedMonthIndex!]} Positif · ${monthlyNegatives[_selectedMonthIndex!]} Negatif)'
                            : 'Ketuk bulan untuk memfilter 4 kartu statistik di atas',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(4, 6, 4, 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFCFDFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapDown: (details) {
                          final dx = details.localPosition.dx;
                          final width = constraints.maxWidth;
                          const horizontalPad = 20.0;
                          final usableWidth =
                          (width - horizontalPad * 2).clamp(1.0, width);
                          final step = usableWidth / 5;
                          final rawIndex =
                          ((dx - horizontalPad) / step).round();
                          final tappedIndex = rawIndex.clamp(0, 5);

                          setState(() {
                            _selectedMonthIndex =
                            _selectedMonthIndex == tappedIndex
                                ? null
                                : tappedIndex;
                          });
                        },
                        child: CustomPaint(
                          size:
                          Size(constraints.maxWidth, constraints.maxHeight),
                          painter: _InteractiveSmoothTrendPainter(
                            values: monthlyTotals,
                            labels: labels,
                            selectedIndex: _selectedMonthIndex,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _InteractiveSmoothTrendPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final int? selectedIndex;

  _InteractiveSmoothTrendPainter({
    required this.values,
    required this.labels,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    const double leftPad = 20;
    const double rightPad = 20;
    const double topPad = 12;
    const double bottomPad = 24;

    final double chartWidth =
    (size.width - leftPad - rightPad).clamp(1.0, size.width);
    final double chartHeight =
    (size.height - topPad - bottomPad).clamp(1.0, size.height);

    final double rawMax = values.reduce((a, b) => a > b ? a : b);
    final double maxVal = rawMax <= 0 ? 4.0 : rawMax * 1.12;

    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0).withValues(alpha: 0.75)
      ..strokeWidth = 1;

    for (int g = 0; g <= 3; g++) {
      final double y = topPad + (chartHeight * g / 3);
      canvas.drawLine(
        Offset(leftPad - 6, y),
        Offset(size.width - rightPad + 6, y),
        gridPaint,
      );
    }

    final List<Offset> points = [];
    for (int i = 0; i < values.length; i++) {
      final double x = leftPad + (chartWidth * i / (values.length - 1));
      final double normalized = (values[i] / maxVal).clamp(0.0, 1.0);
      final double y = topPad + chartHeight - (normalized * chartHeight);
      points.add(Offset(x, y));
    }

    final Path linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final ctrlX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(ctrlX, p0.dy, ctrlX, p1.dy, p1.dx, p1.dy);
    }

    final Path areaPath = Path.from(linePath)
      ..lineTo(points.last.dx, topPad + chartHeight)
      ..lineTo(points.first.dx, topPad + chartHeight)
      ..close();

    final areaPaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(0, topPad),
        Offset(0, topPad + chartHeight),
        [
          const Color(0xFF4F46E5).withValues(alpha: 0.18),
          const Color(0xFF4F46E5).withValues(alpha: 0.01),
        ],
      );
    canvas.drawPath(areaPath, areaPaint);

    if (selectedIndex != null &&
        selectedIndex! >= 0 &&
        selectedIndex! < points.length) {
      final selPt = points[selectedIndex!];
      final guidePaint = Paint()
        ..color = const Color(0xFF4F46E5).withValues(alpha: 0.30)
        ..strokeWidth = 1.2;
      canvas.drawLine(
        Offset(selPt.dx, topPad),
        Offset(selPt.dx, topPad + chartHeight),
        guidePaint,
      );
    }

    final strokePaint = Paint()
      ..color = const Color(0xFF4F46E5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, strokePaint);

    for (int i = 0; i < points.length; i++) {
      final pt = points[i];
      final bool isSelected = selectedIndex == i;

      if (isSelected) {
        final haloPaint = Paint()
          ..color = const Color(0xFF4F46E5).withValues(alpha: 0.22);
        canvas.drawCircle(pt, 9.5, haloPaint);
      }

      canvas.drawCircle(
        pt,
        isSelected ? 5.5 : 4.5,
        Paint()..color = Colors.white,
      );

      canvas.drawCircle(
        pt,
        isSelected ? 3.5 : 2.8,
        Paint()..color = const Color(0xFF4F46E5),
      );

      if (isSelected) {
        final valuePainter = TextPainter(
          text: TextSpan(
            text: '${values[i].toInt()}',
            style: const TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF4F46E5),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        final double labelY = (pt.dy - 18).clamp(2.0, topPad + chartHeight - 16);
        valuePainter.paint(
          canvas,
          Offset(pt.dx - valuePainter.width / 2, labelY),
        );
      }

      final labelPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected
                ? const Color(0xFF4F46E5)
                : const Color(0xFF475569),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      if (isSelected) {
        final pillRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(pt.dx, size.height - 9.5),
            width: labelPainter.width + 12,
            height: 17,
          ),
          const Radius.circular(6),
        );
        canvas.drawRRect(
          pillRect,
          Paint()..color = const Color(0xFFEEF2FF),
        );
      }

      labelPainter.paint(
        canvas,
        Offset(pt.dx - labelPainter.width / 2, size.height - 16),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _InteractiveSmoothTrendPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.selectedIndex != selectedIndex;
  }
}

class _LiquidHeaderClipper extends CustomClipper<Path> {
  final double offsetY;
  const _LiquidHeaderClipper({this.offsetY = 0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final h = size.height - offsetY;
    path.lineTo(0, h - 22);
    path.quadraticBezierTo(
        size.width * 0.25, h + 6, size.width * 0.52, h - 14);
    path.quadraticBezierTo(size.width * 0.80, h - 32, size.width, h - 10);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _LiquidHeaderClipper oldClipper) {
    return oldClipper.offsetY != offsetY;
  }
}