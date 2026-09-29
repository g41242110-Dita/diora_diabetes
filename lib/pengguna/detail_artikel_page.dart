import 'package:flutter/material.dart';

class DetailArtikelPage extends StatefulWidget {
  final String title;
  final String content;
  final String imageUrl;

  const DetailArtikelPage({
    super.key,
    required this.title,
    required this.content,
    required this.imageUrl,
  });

  @override
  State<DetailArtikelPage> createState() => _DetailArtikelPageState();
}

class _DetailArtikelPageState extends State<DetailArtikelPage> {
  double _fontSize = 15.0;
  bool _isBookmarked = false;
  bool _showBanner = false;
  String _bannerTitle = '';
  String _bannerSubtitle = '';
  bool _isSuccessBanner = true;

  void _zoomIn() {
    setState(() {
      if (_fontSize < 22.0) _fontSize += 2.0;
    });
  }

  void _zoomOut() {
    setState(() {
      if (_fontSize > 12.0) _fontSize -= 2.0;
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      _showBanner = true;

      if (_isBookmarked) {
        _isSuccessBanner = true;
        _bannerTitle = 'Berhasil Disimpan!';
        _bannerSubtitle = 'Artikel telah ditambahkan ke bookmark.';
      } else {
        _isSuccessBanner = false;
        _bannerTitle = 'Bookmark Dibatalkan!';
        _bannerSubtitle = 'Artikel telah dihapus dari bookmark.';
      }
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showBanner = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // 1. HEADER BERWARNA YANG DIAM DI TEMPAT (STICKY) SAAT DI-SCROLL
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  minHeight: 110.0,
                  maxHeight: 140.0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6679F4), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 40, 16, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.text_decrease_rounded, color: Colors.white, size: 20),
                              onPressed: _zoomOut,
                              tooltip: 'Kecilkan Teks',
                            ),
                            IconButton(
                              icon: const Icon(Icons.text_increase_rounded, color: Colors.white, size: 20),
                              onPressed: _zoomIn,
                              tooltip: 'Besarkan Teks',
                            ),
                            IconButton(
                              icon: Icon(
                                _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                              onPressed: _toggleBookmark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. KONTEN DI BAWAHNYA (GAMBAR & PENJELASAN) YANG BISA DIGULIR
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar di Atas Penjelasan
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.imageUrl,
                            height: 220,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              height: 220,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(Icons.image_rounded, size: 48, color: Color(0xFF6679F4)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Card Konten / Penjelasan Artikel
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Divider(color: Colors.grey.shade200, thickness: 1),
                            const SizedBox(height: 12),
                            Text(
                              widget.content,
                              style: TextStyle(
                                fontSize: _fontSize,
                                color: const Color(0xFF334155),
                                height: 1.8,
                                fontWeight: FontWeight.w400,
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
          ),

          // Banner Notifikasi Mengambang
          if (_showBanner)
            Positioned(
              top: 50,
              left: 20,
              right: 20,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: _isSuccessBanner ? const Color(0xFFF0FDF4) : const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                    border: Border.all(
                      color: _isSuccessBanner ? const Color(0xFF86EFAC) : const Color(0xFFFCA5A5),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _isSuccessBanner ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isSuccessBanner ? Icons.check_rounded : Icons.close_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _bannerTitle,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: _isSuccessBanner ? const Color(0xFF166534) : const Color(0xFF991B1B),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _bannerSubtitle,
                              style: TextStyle(
                                fontSize: 11.5,
                                color: _isSuccessBanner ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _showBanner = false;
                          });
                        },
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Helper Class untuk Membuat Header Berwarna Menjadi Diam di Tempat (Sticky)
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double minHeight;
  final double maxHeight;
  final Widget child;

  _StickyHeaderDelegate({
    required this.minHeight,
    required this.maxHeight,
    required this.child,
  });

  @override
  double get minExtent => minHeight;

  @override
  double get maxExtent => maxHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }

  @override
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }
}