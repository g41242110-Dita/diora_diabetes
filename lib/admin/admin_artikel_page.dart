// ignore_for_file: spelling

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'admin_tambah_artikel_page.dart';

class AdminArtikelPage extends StatefulWidget {
  final VoidCallback? onBackToBeranda;

  const AdminArtikelPage({super.key, this.onBackToBeranda});

  @override
  State<AdminArtikelPage> createState() => _AdminArtikelPageState();
}

class _AdminArtikelPageState extends State<AdminArtikelPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _selectedFilter = 'Dipublikasi';
  String _searchQuery = '';
  bool _isSearching = false;

  // State untuk mode Tambah / Edit Artikel
  bool _isFormOpen = false;
  String? _selectedDocId;
  Map<String, dynamic>? _selectedDataArtikel;

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

    if (widget.onBackToBeranda != null) {
      widget.onBackToBeranda!();
    } else if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _bukaFormTambah() {
    setState(() {
      _selectedDocId = null;
      _selectedDataArtikel = null;
      _isFormOpen = true;
    });
  }

  void _bukaFormEdit(String docId, Map<String, dynamic> data) {
    setState(() {
      _selectedDocId = docId;
      _selectedDataArtikel = data;
      _isFormOpen = true;
    });
  }

  String _formatDate(dynamic raw) {
    DateTime? dt;
    if (raw is Timestamp) {
      dt = raw.toDate();
    } else if (raw is DateTime) {
      dt = raw;
    } else if (raw is String) {
      dt = DateTime.tryParse(raw);
    }
    if (dt == null) return 'Baru saja';

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
    return '$day ${bulan[dt.month]} ${dt.year}';
  }

  String _cleanPreviewText(String content) {
    return content
        .replaceAll(RegExp(r'\[FOTO_\d+\]'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<void> _toggleStatusQuick(String docId, String statusSaatIni) async {
    final statusBaru = statusSaatIni == 'Draf' ? 'Publis' : 'Draf';
    try {
      await FirebaseFirestore.instance.collection('articles').doc(docId).update({
        'status': statusBaru,
        'updated_at': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              statusBaru == 'Publis'
                  ? 'Artikel berhasil dipublikasikan!'
                  : 'Artikel dikembalikan ke Draf.',
            ),
            backgroundColor: statusBaru == 'Publis'
                ? const Color(0xFF0D9488)
                : const Color(0xFFD97706),
          ),
        );
      }
    } catch (e) {
      debugPrint('Gagal mengubah status: $e');
    }
  }

  Future<void> _hapusArtikel(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('articles')
          .doc(docId)
          .delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artikel berhasil dihapus.'),
            backgroundColor: Color(0xFFE11D48),
          ),
        );
      }
    } catch (e) {
      debugPrint('Gagal menghapus artikel: $e');
    }
  }

  void _konfirmasiHapus(String docId, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Hapus Artikel',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: Text('Apakah Anda yakin ingin menghapus artikel "$title"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE11D48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.pop(context);
              _hapusArtikel(docId);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholderBanner();
    }

    if (imageUrl.startsWith('data:image') || !imageUrl.startsWith('http')) {
      try {
        final cleanBase64 =
        imageUrl.contains(',') ? imageUrl.split(',').last : imageUrl;
        final bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          width: double.infinity,
          height: 138,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildPlaceholderBanner(),
        );
      } catch (_) {
        return _buildPlaceholderBanner();
      }
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 138,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildPlaceholderBanner(),
    );
  }

  Widget _buildPlaceholderBanner() {
    return Container(
      width: double.infinity,
      height: 124,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF), Color(0xFFDBEAFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -18,
            bottom: -18,
            child: Icon(
              Icons.health_and_safety_rounded,
              size: 96,
              color: const Color(0xFF4F46E5).withValues(alpha: 0.12),
            ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: Color(0xFF4F46E5),
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isFormOpen) {
      return AdminTambahArtikelPage(
        docId: _selectedDocId,
        dataArtikel: _selectedDataArtikel,
        onBack: () {
          setState(() {
            _isFormOpen = false;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('articles')
            .orderBy('created_at', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];

          int countDraf = 0;
          int countPublis = 0;

          for (final doc in docs) {
            final data = doc.data() as Map<String, dynamic>;
            final status = (data['status'] ?? 'Publis').toString();
            if (status == 'Draf') {
              countDraf++;
            } else {
              countPublis++;
            }
          }

          final filteredDocs = docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final status = (data['status'] ?? 'Publis').toString();
            final isDraftFilter = _selectedFilter == 'Draf';
            final isCurrentDocDraft = (status == 'Draf');
            final matchesFilter =
            isDraftFilter ? isCurrentDocDraft : !isCurrentDocDraft;

            final query = _searchQuery.trim().toLowerCase();
            final title = (data['title'] ?? '').toString().toLowerCase();
            final content = (data['content'] ?? '').toString().toLowerCase();
            final matchesSearch =
                query.isEmpty || title.contains(query) || content.contains(query);

            return matchesFilter && matchesSearch;
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
                          _buildCreateArticleBanner(),
                          const SizedBox(height: 14),
                          _buildSearchBar(),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              _buildFilterToggleButton(
                                value: 'Dipublikasi',
                                label: 'Dipublikasi ($countPublis)',
                                icon: Icons.public_rounded,
                              ),
                              const SizedBox(width: 10),
                              _buildFilterToggleButton(
                                value: 'Draf',
                                label: 'Artikel Draf ($countDraf)',
                                icon: Icons.edit_note_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 4,
                                    height: 16,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF4F46E5),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                  Text(
                                    'Daftar Artikel $_selectedFilter (${filteredDocs.length})',
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                              if (_searchQuery.isNotEmpty)
                                GestureDetector(
                                  onTap: _closeSearch,
                                  child: const Text(
                                    'Reset Cari',
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
              else if (filteredDocs.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 46,
                            color: Color(0xFF94A3B8),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Tidak ada artikel pada kategori ini.',
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final doc = filteredDocs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        return _buildEditorialArticleCard(doc.id, data);
                      },
                      childCount: filteredDocs.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCreateArticleBanner() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: _bukaFormTambah,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4338CA), Color(0xFF4F46E5)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.post_add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 13),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Buat Artikel Edukasi Baru',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E1B4B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Tulis & publikasikan informasi kesehatan diabetes',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_rounded, color: Colors.white, size: 16),
                      SizedBox(width: 2),
                      Text(
                        'Tulis',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
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
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Stack(
      children: [
        ClipPath(
          clipper: _ArtikelLiquidHeaderClipper(offsetY: 10),
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
          clipper: _ArtikelLiquidHeaderClipper(offsetY: 0),
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
                        'Kelola Artikel',
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
                      'Cari artikel kesehatan...',
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
          hintText: 'Ketik judul atau isi artikel...',
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

  Widget _buildFilterToggleButton({
    required String value,
    required String label,
    required IconData icon,
  }) {
    final bool isSelected = _selectedFilter == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = value;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 10),
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
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditorialArticleCard(String docId, Map<String, dynamic> data) {
    final title = (data['title'] ?? '').toString();
    final rawContent = (data['content'] ?? '').toString();
    final previewText = _cleanPreviewText(rawContent);
    final imageUrl =
    (data['thumbnail'] ?? data['imageUrl'] ?? '').toString().trim();
    final status = (data['status'] ?? 'Publis').toString();
    final isDraft = status == 'Draf';
    final tanggal = _formatDate(data['updated_at'] ?? data['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _bukaFormEdit(docId, data),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBannerImage(imageUrl),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15.5,
                          color: Color(0xFF0F172A),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        previewText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded,
                              size: 13, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              tanggal,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          _buildActionChip(
                            icon: isDraft
                                ? Icons.publish_rounded
                                : Icons.file_download_outlined,
                            label: isDraft ? 'Terbitkan' : 'Draf',
                            bgColor: isDraft
                                ? const Color(0xFFCCFBF1)
                                : const Color(0xFFFEF3C7),
                            fgColor: isDraft
                                ? const Color(0xFF0D9488)
                                : const Color(0xFFB45309),
                            onTap: () => _toggleStatusQuick(docId, status),
                          ),
                          const SizedBox(width: 6),
                          _buildActionChip(
                            icon: Icons.edit_outlined,
                            label: 'Edit',
                            bgColor: const Color(0xFFEEF2FF),
                            fgColor: const Color(0xFF4F46E5),
                            onTap: () => _bukaFormEdit(docId, data),
                          ),
                          const SizedBox(width: 6),
                          Material(
                            color: const Color(0xFFFFE4E6),
                            borderRadius: BorderRadius.circular(10),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => _konfirmasiHapus(docId, title),
                              child: const Padding(
                                padding: EdgeInsets.all(7),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 16,
                                  color: Color(0xFFE11D48),
                                ),
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
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color fgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: fgColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: fgColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArtikelLiquidHeaderClipper extends CustomClipper<Path> {
  final double offsetY;
  const _ArtikelLiquidHeaderClipper({this.offsetY = 0});

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
  bool shouldReclip(covariant _ArtikelLiquidHeaderClipper oldClipper) =>
      oldClipper.offsetY != offsetY;
}