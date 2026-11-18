// ignore_for_file: spell_check_on_only_sample_attachments

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_detail_pengguna_page.dart';

typedef UserMap = Map<String, dynamic>;

class AdminPenggunaPage extends StatefulWidget {
  final VoidCallback? onBack;

  const AdminPenggunaPage({
    super.key,
    this.onBack,
  });

  @override
  State<AdminPenggunaPage> createState() => _AdminPenggunaPageState();
}

class _AdminPenggunaPageState extends State<AdminPenggunaPage> {
  String? _selectedRole;
  String _searchQuery = '';
  bool _isSearching = false;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  String _normalizeRole(dynamic rawRole, String nama) {
    final val = (rawRole ?? '').toString().trim().toLowerCase();
    final lowerName = nama.trim().toLowerCase();

    if (val == 'dokter' ||
        val == 'doctor' ||
        val == 'tenaga_medis' ||
        lowerName.startsWith('dr.') ||
        lowerName.startsWith('dr ')) {
      return 'Dokter';
    }
    return 'Pengguna';
  }

  String _normalizeGender(dynamic raw) {
    final val = (raw ?? '').toString().trim().toLowerCase();
    if (val.startsWith('l') || val == 'pria' || val == 'male') {
      return 'Laki - Laki';
    }
    if (val.startsWith('p') || val == 'wanita' || val == 'female') {
      return 'Perempuan';
    }
    return raw != null && raw.toString().trim().isNotEmpty
        ? raw.toString().trim()
        : '-';
  }

  String _normalizeStatus(dynamic raw) {
    final val = (raw ?? 'Aktif').toString().trim().toLowerCase();
    if (val == 'nonaktif' ||
        val == 'non-aktif' ||
        val == 'inactive' ||
        val == 'blokir' ||
        val == 'false') {
      return 'Nonaktif';
    }
    return 'Aktif';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          final docs = snapshot.data?.docs ?? [];

          int totalUsers = 0;
          int activeUsers = 0;
          int inactiveUsers = 0;

          int countPengguna = 0;
          int countDokter = 0;

          final List<UserMap> allUsers = [];

          for (final doc in docs) {
            final data = doc.data() as UserMap;
            final rawRole = (data['role'] ?? 'pengguna')
                .toString()
                .trim()
                .toLowerCase();

            if (rawRole == 'admin') continue;

            final email = (data['email'] ?? '-').toString().trim();
            final rawNama =
            (data['nama'] ?? data['name'] ?? '').toString().trim();
            final nama = rawNama.isNotEmpty
                ? rawNama
                : (email.contains('@') ? email.split('@').first : 'Pengguna');

            final roleLabel = _normalizeRole(data['role'], nama);
            final gender =
            _normalizeGender(data['gender'] ?? data['jenisKelamin']);
            final status = _normalizeStatus(data['status']);

            totalUsers++;
            if (status == 'Aktif') {
              activeUsers++;
            } else {
              inactiveUsers++;
            }

            if (roleLabel == 'Dokter') {
              countDokter++;
            } else {
              countPengguna++;
            }

            allUsers.add({
              'uid': doc.id,
              'nama': nama,
              'role': roleLabel,
              'username': (data['username'] ?? '').toString(),
              'email': email,
              'gender': gender,
              'status': status,
              'tglLahir': (data['tglLahir'] ?? data['tanggalLahir'] ?? '-')
                  .toString(),
              'noHp': (data['noHp'] ?? data['phone'] ?? '-').toString(),
              'alamat': (data['alamat'] ?? '-').toString(),
              'pekerjaan': (data['pekerjaan'] ?? '-').toString(),
              'instansi': (data['instansi'] ?? '-').toString(),
              'alergi': (data['alergi'] ?? 'Tidak Ada').toString(),
              'photoBase64': (data['photoBase64'] ?? '').toString(),
            });
          }

          final filteredUsers = allUsers.where((u) {
            final matchesRole =
                _selectedRole == null || u['role'] == _selectedRole;

            final q = _searchQuery.trim().toLowerCase();
            final matchesSearch = q.isEmpty ||
                u['nama'].toString().toLowerCase().contains(q) ||
                u['email'].toString().toLowerCase().contains(q) ||
                u['noHp'].toString().toLowerCase().contains(q);

            return matchesRole && matchesSearch;
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
                          _buildSearchButtonOrField(),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _buildAestheticStatCard(
                                  label: 'Total Akun',
                                  count: '$totalUsers',
                                  primaryColor: const Color(0xFF4F46E5),
                                  softColor: const Color(0xFFE0E7FF),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildAestheticStatCard(
                                  label: 'Aktif',
                                  count: '$activeUsers',
                                  primaryColor: const Color(0xFF0D9488),
                                  softColor: const Color(0xFFCCFBF1),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _buildAestheticStatCard(
                                  label: 'Nonaktif',
                                  count: '$inactiveUsers',
                                  primaryColor: const Color(0xFFE11D48),
                                  softColor: const Color(0xFFFFE4E6),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _buildRoleToggleButton(
                                label: 'Pengguna',
                                count: countPengguna,
                                icon: Icons.person_rounded,
                              ),
                              const SizedBox(width: 10),
                              _buildRoleToggleButton(
                                label: 'Dokter',
                                count: countDokter,
                                icon: Icons.medical_services_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Daftar ${_selectedRole ?? 'Semua Akun'} (${filteredUsers.length})',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              if (_selectedRole != null ||
                                  _searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _closeSearch();
                                    setState(() {
                                      _selectedRole = null;
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
                    child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  ),
                )
              else if (filteredUsers.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person_search_rounded,
                            size: 46,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tidak ada data akun yang cocok.',
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
                        return _buildUserCard(context, filteredUsers[index]);
                      },
                      childCount: filteredUsers.length,
                    ),
                  ),
                ),
            ],
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
          clipper: _PenggunaLiquidHeaderClipper(offsetY: 10),
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
          clipper: _PenggunaLiquidHeaderClipper(offsetY: 0),
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
                        'Data Pengguna',
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

  Widget _buildSearchButtonOrField() {
    if (!_isSearching && _searchQuery.isEmpty) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _openSearch,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF94A3B8),
            side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.2),
            padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 18),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          icon: const Icon(Icons.search_rounded,
              size: 19, color: Color(0xFF94A3B8)),
          label: const Text(
            'Cari akun pengguna atau dokter...',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.6),
          width: 1.2,
        ),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (val) => setState(() => _searchQuery = val),
        style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155)),
        decoration: InputDecoration(
          hintText: 'Ketik nama atau email akun...',
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF94A3B8), size: 19),
          suffixIcon: IconButton(
            icon: const Icon(Icons.close_rounded,
                size: 18, color: Color(0xFF94A3B8)),
            onPressed: _closeSearch,
          ),
          contentPadding:
          const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.22),
          width: 1.1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: -24,
              child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      softColor.withValues(alpha: 0.95),
                      softColor.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
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
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF475569),
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

  Widget _buildRoleToggleButton({
    required String label,
    required int count,
    required IconData icon,
  }) {
    final bool isSelected = _selectedRole == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedRole = isSelected ? null : label;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
              colors: [Color(0xFF4338CA), Color(0xFF4F46E5)],
            )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? Colors.transparent : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : const Color(0xFF4F46E5),
              ),
              const SizedBox(width: 6),
              Text(
                '$label ($count)',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? Colors.white : const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserAvatar(String nama, String photoBase64) {
    if (photoBase64.isNotEmpty) {
      try {
        final cleanBase64 = photoBase64.contains(',')
            ? photoBase64.split(',').last
            : photoBase64;
        return ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.memory(
            base64Decode(cleanBase64),
            width: 46,
            height: 46,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _buildInitialBox(nama),
          ),
        );
      } catch (_) {}
    }
    return _buildInitialBox(nama);
  }

  Widget _buildInitialBox(String nama) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E7FF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      alignment: Alignment.center,
      child: Text(
        _getInitials(nama),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: Color(0xFF4F46E5),
        ),
      ),
    );
  }

  Widget _buildUserCard(BuildContext context, UserMap user) {
    final String nama = user['nama'].toString();
    final String email = user['email'].toString();
    final String status = user['status'].toString();
    final String photoBase64 = user['photoBase64'].toString();

    final bool isAktif = status == 'Aktif';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AdminDetailPenggunaPage(
                  userData: user.map((k, v) => MapEntry(k, v.toString())),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                _buildUserAvatar(nama, photoBase64),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      const SizedBox(height: 3),
                      Text(
                        email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 9),
                  decoration: BoxDecoration(
                    color: isAktif
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: isAktif
                          ? const Color(0xFF15803D)
                          : const Color(0xFFEF4444),
                      fontSize: 10.5,
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
      ),
    );
  }
}

class _PenggunaLiquidHeaderClipper extends CustomClipper<Path> {
  final double offsetY;
  const _PenggunaLiquidHeaderClipper({this.offsetY = 0});

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
  bool shouldReclip(covariant _PenggunaLiquidHeaderClipper oldClipper) =>
      oldClipper.offsetY != offsetY;
}