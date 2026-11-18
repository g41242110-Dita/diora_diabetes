// ignore_for_file: spelling

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_detail_skrining_page.dart';

typedef SkriningMap = Map<String, dynamic>;

class AdminSkriningPage extends StatefulWidget {
  final VoidCallback? onBack;
  final String initialFilter;

  const AdminSkriningPage({
    super.key,
    this.onBack,
    this.initialFilter = 'Semua',
  });

  @override
  State<AdminSkriningPage> createState() => _AdminSkriningPageState();
}

class _AdminSkriningPageState extends State<AdminSkriningPage> {
  String _searchQuery = '';
  bool _isSearching = false;
  late String _activeStatusFilter;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _activeStatusFilter = widget.initialFilter;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _openSearch() {
    setState(() {
      _isSearching = true;
    });
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) _searchFocusNode.requestFocus();
    });
  }

  void _closeSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
  }

  void _handleBack() {
    if (_isSearching || _searchQuery.isNotEmpty) {
      _closeSearch();
      return;
    }

    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
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
      // Coba parse string standar ISO atau format Date parse biasa
      final parsed = DateTime.tryParse(raw.trim());
      if (parsed != null) return parsed;

      // Jika format teks seperti "November 18, 2026 at 10:03:00..."
      // Kita coba bersihkan kata "at" agar bisa dibaca atau fallback ke string
      try {
        final cleanStr = raw.trim().replaceAll(' at ', ' ');
        final parsedClean = DateTime.tryParse(cleanStr);
        if (parsedClean != null) return parsedClean;
      } catch (_) {}
    }
    return null;
  }

  String _formatDateTime(DateTime? dt, dynamic rawFallback) {
    if (dt == null) {
      if (rawFallback != null && rawFallback.toString().trim().isNotEmpty) {
        return rawFallback.toString().trim();
      }
      return 'Waktu tidak tercatat';
    }

    const bulan = [
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
    final day = dt.day.toString().padLeft(2, '0');
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day ${bulan[dt.month]} ${dt.year} • $hour:$minute';
  }

  bool _isPositiveResult(SkriningMap data) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, usersSnapshot) {
          final Map<String, String> userNameByUid = {};
          final Map<String, String> userEmailByUid = {};
          final Map<String, String> userNameByEmail = {};

          for (final doc in (usersSnapshot.data?.docs ?? [])) {
            final uData = doc.data() as SkriningMap;
            final rawNama =
            (uData['nama'] ?? uData['name'] ?? '').toString().trim();
            final email = (uData['email'] ?? '').toString().trim();
            final displayNama = rawNama.isNotEmpty
                ? rawNama
                : (email.contains('@') ? email.split('@').first : 'Pengguna');

            userNameByUid[doc.id] = displayNama;
            if (email.isNotEmpty) {
              userEmailByUid[doc.id] = email;
              userNameByEmail[email.toLowerCase()] = displayNama;
            }
          }

          return StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('screening_results')
                .snapshots(),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];

              int totalTes = 0;
              int totalPositif = 0;
              int totalNegatif = 0;

              final List<SkriningMap> allResults = [];

              for (final doc in docs) {
                final data = doc.data() as SkriningMap;

                final uid =
                (data['userId'] ?? data['uid'] ?? data['user_id'] ?? '')
                    .toString()
                    .trim();
                final rawEmail = (data['email'] ?? data['userEmail'] ?? '')
                    .toString()
                    .trim();
                final resolvedEmail = rawEmail.isNotEmpty
                    ? rawEmail
                    : (userEmailByUid[uid] ?? '-');

                final directName = (data['nama'] ??
                    data['userName'] ??
                    data['patientName'] ??
                    data['name'] ??
                    '')
                    .toString()
                    .trim();

                final resolvedName = directName.isNotEmpty
                    ? directName
                    : (userNameByUid[uid] ??
                    userNameByEmail[resolvedEmail.toLowerCase()] ??
                    (resolvedEmail.contains('@')
                        ? resolvedEmail.split('@').first
                        : 'Pengguna'));

                final bool isPositif = _isPositiveResult(data);

                // Mencakup field waktuSkrining dari database Firestore Anda
                final rawTime = data['waktuSkrining'] ??
                    data['created_at'] ??
                    data['createdAt'] ??
                    data['tanggal'] ??
                    data['timestamp'];

                final DateTime? parsedDate = _parseDateTime(rawTime);
                final String formattedTime =
                _formatDateTime(parsedDate, rawTime);

                totalTes++;
                if (isPositif) {
                  totalPositif++;
                } else {
                  totalNegatif++;
                }

                allResults.add({
                  'id': doc.id,
                  'nama': resolvedName,
                  'email': resolvedEmail,
                  'isPositif': isPositif,
                  'hasilLabel': isPositif ? 'Positif' : 'Negatif',
                  'waktu': formattedTime,
                  'dateTime':
                  parsedDate ?? DateTime.fromMillisecondsSinceEpoch(0),
                  'rawData': data,
                });
              }

              // Mengurutkan dari waktu terbaru ke terlama
              allResults.sort((a, b) {
                final DateTime dtA = a['dateTime'] as DateTime;
                final DateTime dtB = b['dateTime'] as DateTime;
                return dtB.compareTo(dtA);
              });

              final filteredResults = allResults.where((item) {
                final matchesStatus = _activeStatusFilter == 'Semua' ||
                    item['hasilLabel'] == _activeStatusFilter;

                final q = _searchQuery.trim().toLowerCase();
                final matchesSearch = q.isEmpty ||
                    item['nama'].toString().toLowerCase().contains(q) ||
                    item['hasilLabel'].toString().toLowerCase().contains(q) ||
                    item['waktu'].toString().toLowerCase().contains(q);

                return matchesStatus && matchesSearch;
              }).toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLiquidHeader(context),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSearchBar(),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildAestheticStatCard(
                                      label: 'Total Tes',
                                      count: '$totalTes',
                                      primaryColor: const Color(0xFF4F46E5),
                                      softColor: const Color(0xFFE0E7FF),
                                      onTap: () => setState(
                                              () => _activeStatusFilter = 'Semua'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildAestheticStatCard(
                                      label: 'Positif',
                                      count: '$totalPositif',
                                      primaryColor: const Color(0xFFE11D48),
                                      softColor: const Color(0xFFFFE4E6),
                                      onTap: () => setState(
                                              () => _activeStatusFilter = 'Positif'),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildAestheticStatCard(
                                      label: 'Negatif',
                                      count: '$totalNegatif',
                                      primaryColor: const Color(0xFF0D9488),
                                      softColor: const Color(0xFFCCFBF1),
                                      onTap: () => setState(
                                              () => _activeStatusFilter = 'Negatif'),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        width: 4,
                                        height: 16,
                                        margin: const EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4F46E5),
                                          borderRadius:
                                          BorderRadius.circular(4),
                                        ),
                                      ),
                                      Text(
                                        'Riwayat Skrining $_activeStatusFilter (${filteredResults.length})',
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (_searchQuery.isNotEmpty ||
                                      _activeStatusFilter != 'Semua')
                                    GestureDetector(
                                      onTap: () {
                                        _closeSearch();
                                        setState(() {
                                          _activeStatusFilter = 'Semua';
                                        });
                                      },
                                      child: const Text(
                                        'Tampilkan Semua',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF4F46E5),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    )
                  else if (filteredResults.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 36),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.assignment_late_outlined,
                                size: 46,
                                color: Color(0xFF94A3B8),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Belum ada riwayat pemeriksaan skrining.',
                                style: TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                              (context, index) {
                            return _buildScreeningCard(
                              context,
                              filteredResults[index],
                            );
                          },
                          childCount: filteredResults.length,
                        ),
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildLiquidHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Stack(
      children: [
        ClipPath(
          clipper: _SkriningLiquidHeaderClipper(offsetY: 10),
          child: Container(
            width: double.infinity,
            height: topPadding + 88,
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
          clipper: _SkriningLiquidHeaderClipper(offsetY: 0),
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
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 36,
              child: Stack(
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 36),
                      child: Text(
                        'Pemeriksaan & Skrining',
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
                      tooltip: (_isSearching || _searchQuery.isNotEmpty)
                          ? 'Reset Pencarian'
                          : 'Kembali ke Beranda',
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        size: 22,
                        color: Colors.white,
                      ),
                      onPressed: _handleBack,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    if (!_isSearching && _searchQuery.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            onTap: _openSearch,
            borderRadius: BorderRadius.circular(28),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 13, horizontal: 16),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Cari nama pasien...',
                      style: TextStyle(
                        fontSize: 13.5,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.65),
          width: 1.3,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: 'Ketik nama pasien...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF4F46E5), size: 20),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 18, color: Color(0xFF94A3B8)),
            onPressed: _closeSearch,
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildAestheticStatCard({
    required String label,
    required String count,
    required Color primaryColor,
    required Color softColor,
    required VoidCallback onTap,
  }) {
    final bool isSelected = _activeStatusFilter == label ||
        (_activeStatusFilter == 'Semua' && label == 'Total Tes');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? primaryColor
                : primaryColor.withValues(alpha: 0.22),
            width: isSelected ? 1.8 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: primaryColor.withValues(alpha: isSelected ? 0.15 : 0.07),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                count,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                  isSelected ? FontWeight.w900 : FontWeight.w700,
                  color:
                  isSelected ? const Color(0xFF0F172A) : const Color(0xFF475569),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreeningCard(BuildContext context, SkriningMap item) {
    final String nama = item['nama'].toString();
    final bool isPositif = item['isPositif'] as bool;
    final String hasilLabel = item['hasilLabel'].toString();
    final String waktu = item['waktu'].toString();

    final Color accentColor =
    isPositif ? const Color(0xFFE11D48) : const Color(0xFF0D9488);
    final Color softBg =
    isPositif ? const Color(0xFFFFE4E6) : const Color(0xFFCCFBF1);

    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.16), width: 1.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AdminDetailSkriningPage(
                    docId: item['id'].toString(),
                    nama: nama,
                    email: item['email'].toString(),
                    isPositif: isPositif,
                    waktu: waktu,
                    rawData: item['rawData'] as SkriningMap,
                  ),
                ),
              );
            },
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(width: 4.5, color: accentColor),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 13, 12, 13),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: softBg,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              isPositif
                                  ? Icons.warning_amber_rounded
                                  : Icons.health_and_safety_rounded,
                              size: 22,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  nama,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Row(
                                  children: [
                                    const Icon(Icons.schedule_rounded,
                                        size: 13.5, color: Color(0xFF94A3B8)),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        waktu,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF64748B),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 11),
                            decoration: BoxDecoration(
                              color: softBg,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              hasilLabel,
                              style: TextStyle(
                                color: accentColor,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded,
                              size: 20, color: Color(0xFF94A3B8)),
                        ],
                      ),
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
}

class _SkriningLiquidHeaderClipper extends CustomClipper<Path> {
  final double offsetY;
  const _SkriningLiquidHeaderClipper({this.offsetY = 0});

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
  bool shouldReclip(covariant _SkriningLiquidHeaderClipper oldClipper) =>
      oldClipper.offsetY != offsetY;
}