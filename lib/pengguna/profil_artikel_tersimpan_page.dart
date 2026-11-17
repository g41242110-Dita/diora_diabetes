import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detail_artikel_page.dart';

class ArtikelTersimpanPage extends StatefulWidget {
  const ArtikelTersimpanPage({super.key});

  @override
  State<ArtikelTersimpanPage> createState() => _ArtikelTersimpanPageState();
}

class _ArtikelTersimpanPageState extends State<ArtikelTersimpanPage> {
  final TextEditingController _searchController = TextEditingController();

  // ignore: prefer_final_fields
  String _searchQuery = '';
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _showTopNotification(String title, String message) {
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 12,
        left: 24,
        right: 24,
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: const Color(0xFFF43F5E).withValues(alpha: 0.2),
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
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFF43F5E), Color(0xFFFB7185)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bookmark_remove_rounded,
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
    );

    Overlay.of(context).insert(_overlayEntry!);

    Future.delayed(const Duration(milliseconds: 2200), () {
      _overlayEntry?.remove();
      _overlayEntry = null;
    });
  }

  Future<void> _removeBookmark(String docId) async {
    try {
      await FirebaseFirestore.instance
          .collection('saved_articles')
          .doc(docId)
          .delete();

      if (mounted) {
        _showTopNotification(
          'Bookmark Dihapus',
          'Artikel dikeluarkan dari daftar simpanan',
        );
      }
    } catch (e) {
      debugPrint("Gagal menghapus bookmark: $e");
    }
  }

  Widget _buildCardImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        height: 120,
        color: const Color(0xFFEEF2FF),
        child: const Center(
          child: Icon(
            Icons.medical_information_rounded,
            size: 38,
            color: Color(0xFF5B4AF4),
          ),
        ),
      );
    }

    if (imageUrl.startsWith('data:image')) {
      try {
        final bytes = base64Decode(imageUrl.split(',').last);
        return Image.memory(
          bytes,
          width: double.infinity,
          height: 120,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Container(
          height: 120,
          color: const Color(0xFFEEF2FF),
          child: const Center(
            child: Icon(
              Icons.broken_image_rounded,
              size: 38,
              color: Color(0xFF5B4AF4),
            ),
          ),
        );
      }
    }

    return Image.network(
      imageUrl,
      width: double.infinity,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: 120,
        color: const Color(0xFFEEF2FF),
        child: const Center(
          child: Icon(
            Icons.medical_information_rounded,
            size: 38,
            color: Color(0xFF5B4AF4),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          // HEADER LIQUID WAVE SENADA DENGAN KONSULTASI
          ClipPath(
            clipper: _SavedLiquidClipper(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, topPadding, 16, 52),
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
              ),
              child: Column(
                children: [
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
                            icon: const Icon(
                              Icons.arrow_back_rounded,
                              color: Colors.white,
                              size: 22,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 36),
                            child: Text(
                              'Artikel Tersimpan',
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
                  const SizedBox(height: 16),

                  // SEARCH BAR CAPSULE RAMPING
                  Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                        BoxShadow(
                          color: const Color(0xFF5B4AF4).withValues(alpha: 0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontSize: 12.5),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: 'Cari topik atau judul artikel...',
                        hintStyle: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12.5,
                        ),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF5B4AF4),
                          size: 18,
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 38,
                          minHeight: 40,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.cancel_rounded,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                              _searchQuery = '';
                            });
                          },
                        )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // KONTEN UTAMA (JIKA BELUM LOGIN / SUDAH LOGIN)
          Expanded(
            child: user == null
                ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: const BoxDecoration(
                        color: Color(0xFFEEF2FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        size: 34,
                        color: Color(0xFF5B4AF4),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Akses Terbatas',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Silakan login terlebih dahulu untuk melihat daftar artikel tersimpan Anda.',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('saved_articles')
                  .where('userId', isEqualTo: user.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                    CircularProgressIndicator(color: Color(0xFF5B4AF4)),
                  );
                }

                if (!snapshot.hasData ||
                    snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: const BoxDecoration(
                            color: Color(0xFFEEF2FF),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.bookmark_border_rounded,
                            size: 34,
                            color: Color(0xFF5B4AF4),
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada artikel tersimpan',
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final title =
                  (data['title'] ?? '').toString().toLowerCase();
                  final snippet =
                  (data['snippet'] ?? '').toString().toLowerCase();
                  return title.contains(_searchQuery.toLowerCase()) ||
                      snippet.contains(_searchQuery.toLowerCase());
                }).toList();

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Daftar Bacaan Anda',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${docs.length} Artikel',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5B4AF4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding:
                        const EdgeInsets.fromLTRB(16, 2, 16, 20),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final doc = docs[index];
                          final data =
                          doc.data() as Map<String, dynamic>;
                          final docId = doc.id;
                          final title = data['title'] ?? '';
                          final snippet = data['snippet'] ?? '';
                          final content = data['content'] ?? '';
                          final imageUrl = data['imageUrl'] ?? '';
                          final inlineImages = data['inline_images'];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.04),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                              border: Border.all(
                                  color: const Color(0xFFF1F5F9)),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          DetailArtikelPage(
                                            title: title,
                                            content: content,
                                            imageUrl: imageUrl,
                                            inlineImages: inlineImages,
                                          ),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius:
                                      const BorderRadius.vertical(
                                        top: Radius.circular(20),
                                      ),
                                      child: _buildCardImage(imageUrl),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(14),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment
                                                  .start,
                                              children: [
                                                Text(
                                                  title,
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: Color(
                                                        0xFF0F172A),
                                                    height: 1.25,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                ),
                                                const SizedBox(
                                                    height: 5),
                                                Text(
                                                  snippet,
                                                  style: const TextStyle(
                                                    fontSize: 11.5,
                                                    color: Color(
                                                        0xFF64748B),
                                                    height: 1.35,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow
                                                      .ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          InkWell(
                                            borderRadius:
                                            BorderRadius.circular(
                                                12),
                                            onTap: () =>
                                                _removeBookmark(docId),
                                            child: Container(
                                              padding:
                                              const EdgeInsets.all(
                                                  8),
                                              decoration: BoxDecoration(
                                                color: const Color(
                                                    0xFFEEF2FF),
                                                borderRadius:
                                                BorderRadius
                                                    .circular(10),
                                              ),
                                              child: const Icon(
                                                Icons.bookmark_rounded,
                                                color: Color(0xFF5B4AF4),
                                                size: 18,
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
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedLiquidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 40);

    var firstControlPoint = Offset(size.width * 0.25, size.height);
    var firstEndPoint = Offset(size.width * 0.5, size.height - 30);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.75, size.height - 60);
    var secondEndPoint = Offset(size.width, size.height - 20);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}