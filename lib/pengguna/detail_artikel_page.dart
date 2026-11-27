import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailArtikelPage extends StatefulWidget {
  final String title;
  final String content;
  final String imageUrl;
  final dynamic inlineImages;

  const DetailArtikelPage({
    super.key,
    required this.title,
    required this.content,
    required this.imageUrl,
    this.inlineImages,
  });

  @override
  State<DetailArtikelPage> createState() => _DetailArtikelPageState();
}

class _DetailArtikelPageState extends State<DetailArtikelPage> {
  double _fontSize = 14.5;
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

    final articleId =
    widget.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
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
      if (_fontSize < 22.0) _fontSize += 1.5;
    });
  }

  void _zoomOut() {
    setState(() {
      if (_fontSize > 12.0) _fontSize -= 1.5;
    });
  }

  void _showTopNotification({
    required String title,
    required String message,
    required bool isSuccess,
  }) {
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutBack,
            tween: Tween(begin: 0.0, end: 1.0),
            builder: (context, value, child) {
              return Transform.translate(
                offset: Offset(0, -16 * (1 - value)),
                child: Opacity(
                  opacity: value.clamp(0.0, 1.0),
                  child: child,
                ),
              );
            },
            child: Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: isSuccess
                            ? const Color(0xFF5B4AF4).withValues(alpha: 0.2)
                            : const Color(0xFFF43F5E).withValues(alpha: 0.2),
                        width: 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isSuccess
                                  ? [
                                const Color(0xFF5B4AF4),
                                const Color(0xFF388BFF)
                              ]
                                  : [
                                const Color(0xFFF43F5E),
                                const Color(0xFFFB7185)
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSuccess
                                ? Icons.bookmark_added_rounded
                                : Icons.bookmark_remove_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              Text(
                                message,
                                style: const TextStyle(
                                  color: Color(0xFF64748B),
                                  fontSize: 10.5,
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
        message: 'Silakan login untuk menyimpan artikel.',
        isSuccess: false,
      );
      return;
    }

    final articleId =
    widget.title.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '_');
    final docId = '${user.uid}_$articleId';
    final docRef =
    FirebaseFirestore.instance.collection('saved_articles').doc(docId);

    setState(() {
      _isBookmarked = !_isBookmarked;
    });

    if (_isBookmarked) {
      _showTopNotification(
        title: 'Tersimpan ke Bookmark',
        message: 'Masuk ke daftar bacaan Anda',
        isSuccess: true,
      );
    } else {
      _showTopNotification(
        title: 'Bookmark Dihapus',
        message: 'Dihapus dari daftar simpanan',
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
          'inline_images': widget.inlineImages,
          'saved_at': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }
    } catch (e) {
      debugPrint("Error database bookmark: $e");
    }
  }

  TextSpan _buildFormattedTextSpan(String rawText, TextStyle baseStyle) {
    final RegExp tokenRegex = RegExp(
      r'(\*\*\*[\s\S]+?\*\*\*|\*\*[\s\S]+?\*\*|\*[^*\n]+?\*|<u>[\s\S]+?<\/u>)',
    );

    final List<InlineSpan> spans = [];
    int currentIndex = 0;

    for (final match in tokenRegex.allMatches(rawText)) {
      if (match.start > currentIndex) {
        spans.add(
          TextSpan(
            text: rawText.substring(currentIndex, match.start),
            style: baseStyle,
          ),
        );
      }

      final String token = match.group(0)!;

      if (token.startsWith('***') &&
          token.endsWith('***') &&
          token.length > 6) {
        final String inner = token.substring(3, token.length - 3);
        spans.add(
          _buildFormattedTextSpan(
            inner,
            baseStyle.copyWith(
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        );
      } else if (token.startsWith('**') &&
          token.endsWith('**') &&
          token.length > 4) {
        final String inner = token.substring(2, token.length - 2);
        spans.add(
          _buildFormattedTextSpan(
            inner,
            baseStyle.copyWith(fontWeight: FontWeight.bold),
          ),
        );
      } else if (token.startsWith('*') &&
          token.endsWith('*') &&
          token.length > 2) {
        final String inner = token.substring(1, token.length - 1);
        spans.add(
          _buildFormattedTextSpan(
            inner,
            baseStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (token.startsWith('<u>') &&
          token.endsWith('</u>') &&
          token.length > 7) {
        final String inner = token.substring(3, token.length - 4);
        spans.add(
          _buildFormattedTextSpan(
            inner,
            baseStyle.copyWith(decoration: TextDecoration.underline),
          ),
        );
      } else {
        spans.add(TextSpan(text: token, style: baseStyle));
      }

      currentIndex = match.end;
    }

    if (currentIndex < rawText.length) {
      spans.add(
        TextSpan(
          text: rawText.substring(currentIndex),
          style: baseStyle,
        ),
      );
    }

    return TextSpan(style: baseStyle, children: spans);
  }

  Widget _buildFormattedTextWidget(String text) {
    final style = TextStyle(
      fontSize: _fontSize,
      color: const Color(0xFF334155),
      height: 1.75,
    );
    return RichText(
      text: _buildFormattedTextSpan(text, style),
    );
  }

  Widget _renderImageWidget(String imageSrc) {
    String cleanSrc = imageSrc.trim();

    if (cleanSrc.startsWith('[IMAGE:') && cleanSrc.endsWith(']')) {
      cleanSrc = cleanSrc.substring(7, cleanSrc.length - 1).trim();
    }

    Widget img;
    if (cleanSrc.startsWith('data:image')) {
      try {
        final bytes = base64Decode(cleanSrc.split(',').last);
        img = Image.memory(
          bytes,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return const SizedBox();
      }
    } else {
      img = Image.network(
        cleanSrc,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => const SizedBox(),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: img,
      ),
    );
  }

  Widget _buildContentWithImages(String rawContent) {
    List<Widget> widgets = [];
    Map<String, String> imagesMap = {};

    if (widget.inlineImages != null && widget.inlineImages is Map) {
      imagesMap = Map<String, String>.from(
        (widget.inlineImages as Map)
            .map((k, v) => MapEntry(k.toString(), v.toString())),
      );
    }

    RegExp exp = RegExp(r'(\[FOTO_\d+\]|\[IMAGE:\s*[^\]]+\])');
    Iterable<RegExpMatch> matches = exp.allMatches(rawContent);

    int lastIndex = 0;
    for (RegExpMatch match in matches) {
      if (match.start > lastIndex) {
        String textSegment =
        rawContent.substring(lastIndex, match.start).trim();
        if (textSegment.isNotEmpty) {
          widgets.add(_buildFormattedTextWidget(textSegment));
          widgets.add(const SizedBox(height: 10));
        }
      }

      String token = match.group(0)!;
      if (imagesMap.containsKey(token)) {
        widgets.add(_renderImageWidget(imagesMap[token]!));
      } else if (token.startsWith('[IMAGE:')) {
        widgets.add(_renderImageWidget(token));
      }

      lastIndex = match.end;
    }

    if (lastIndex < rawContent.length) {
      String remainingText = rawContent.substring(lastIndex).trim();
      if (remainingText.isNotEmpty) {
        widgets.add(_buildFormattedTextWidget(remainingText));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 10;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyHeaderDelegate(
              minHeight: topPadding + 52.0,
              maxHeight: topPadding + 56.0,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF3B0066),
                      Color(0xFF5B4AF4),
                      Color(0xFF388BFF),
                    ],
                    stops: [0.0, 0.5, 1.0],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16, topPadding, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: _zoomOut,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'A-',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _zoomIn,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 32,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'A+',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _toggleBookmark,
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 32,
                            width: 34,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: Colors.white,
                              size: 19,
                            ),
                          ),
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
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
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
                    Text(
                      widget.title,
                      style: TextStyle(
                        fontSize: _fontSize + 3.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0F172A),
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Color(0xFFF1F5F9), thickness: 1),
                    const SizedBox(height: 12),
                    _buildContentWithImages(widget.content),
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
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(child: child);
  }
}