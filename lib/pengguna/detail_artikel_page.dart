import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    super.dispose();
  }

  Future<void> _checkBookmarkStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final articleId = widget.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final docId = '${user.uid}_$articleId';

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('saved_articles')
          .doc(docId)
          .get();

      if (docSnapshot.exists && mounted) {
        setState(() {
          _isBookmarked = true;
        });
      }
    } catch (e) {
      debugPrint("Error checking bookmark: $e");
    }
  }

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

  // BANNER PERSEGI PRESISI DENGAN ANGLED CORNER (16px)
  void _showTopNotification({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isSuccess
                    ? [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)]
                    : [const Color(0xFFFEF2F2), const Color(0xFFFEE2E2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16), // Bentuk kartu persegi bersudut halus
              border: Border.all(
                color: isSuccess
                    ? const Color(0xFFA7F3D0)
                    : const Color(0xFFFECDD3),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isSuccess ? const Color(0xFF059669) : const Color(0xFFE11D48))
                      .withValues(alpha: 0.12),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                // Ikon Persegi Bersudut Halus
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isSuccess ? const Color(0xFF10B981) : const Color(0xFFF43F5E),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isSuccess ? Icons.bookmark_added_rounded : Icons.bookmark_remove_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),

                // Teks Judul & Pesan
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSuccess ? const Color(0xFF065F46) : const Color(0xFF881337),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        message,
                        style: TextStyle(
                          color: isSuccess ? const Color(0xFF047857) : const Color(0xFF9F1239),
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(milliseconds: 2200), () {
      if (_overlayEntry != null) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  Future<void> _toggleBookmark() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showTopNotification(
        title: 'Akses Terbatas',
        message: 'Silakan login terlebih dahulu untuk menyimpan artikel.',
        isSuccess: false,
      );
      return;
    }

    final articleId = widget.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final docId = '${user.uid}_$articleId';
    final docRef = FirebaseFirestore.instance.collection('saved_articles').doc(docId);

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    if (_isBookmarked) {
      _showTopNotification(
        title: 'Tersimpan ke Bookmark',
        message: 'Artikel telah masuk ke daftar bacaan Anda.',
        isSuccess: true,
      );
    } else {
      _showTopNotification(
        title: 'Bookmark Dihapus',
        message: 'Artikel dikeluarkan dari daftar simpanan.',
        isSuccess: false,
      );
    }

    try {
      if (_isBookmarked) {
        await docRef.set({
          'userId': user.uid,
          'articleId': articleId,
          'title': widget.title,
          'snippet': widget.content.length > 100
              ? '${widget.content.substring(0, 100)}...'
              : widget.content,
          'content': widget.content,
          'imageUrl': widget.imageUrl,
          'saved_at': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }
    } catch (e) {
      debugPrint("Error database bookmark: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
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
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.text_decrease_rounded,
                              color: Colors.white, size: 20),
                          onPressed: _zoomOut,
                          tooltip: 'Kecilkan Teks',
                        ),
                        IconButton(
                          icon: const Icon(Icons.text_increase_rounded,
                              color: Colors.white, size: 20),
                          onPressed: _zoomIn,
                          tooltip: 'Besarkan Teks',
                        ),
                        IconButton(
                          icon: Icon(
                            _isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
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
                          child: const Icon(Icons.image_rounded,
                              size: 48, color: Color(0xFF6679F4)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
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
    );
  }
}

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
  bool shouldRebuild(_StickyHeaderDelegate oldDelegate) {
    return maxHeight != oldDelegate.maxHeight ||
        minHeight != oldDelegate.minHeight ||
        child != oldDelegate.child;
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }
}