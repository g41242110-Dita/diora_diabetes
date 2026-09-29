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
  double _fontSize = 14.0;
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
      if (_fontSize > 10.0) _fontSize -= 2.0;
    });
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
      _showBanner = true;

      if (_isBookmarked) {
        _isSuccessBanner = true;
        _bannerTitle = 'Berhasil Disimpan!';
        _bannerSubtitle = 'Artikel telah ditambahkan ke bookmark Anda.';
      } else {
        _isSuccessBanner = false;
        _bannerTitle = 'Bookmark Dibatalkan!';
        _bannerSubtitle = 'Artikel telah dihapus dari bookmark Anda.';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF6679F4), size: 16),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          // Tombol Perkecil Teks
          IconButton(
            icon: const Icon(Icons.text_decrease_rounded, color: Color(0xFF64748B), size: 20),
            onPressed: _zoomOut,
            tooltip: 'Perkecil Teks',
          ),
          // Tombol Perbesar Teks
          IconButton(
            icon: const Icon(Icons.text_increase_rounded, color: Color(0xFF64748B), size: 20),
            onPressed: _zoomIn,
            tooltip: 'Perbesar Teks',
          ),
          // Tombol Bookmark
          Container(
            margin: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
            decoration: BoxDecoration(
              color: _isBookmarked ? const Color(0xFFEEF2FF) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isBookmarked ? const Color(0xFF6679F4) : const Color(0xFFE2E8F0),
              ),
            ),
            child: IconButton(
              icon: Icon(
                _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: const Color(0xFF6679F4),
                size: 20,
              ),
              onPressed: _toggleBookmark,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul Artikel Utama
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      height: 1.25,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Gambar Header Estetik Tanpa Kotak Pembatas
                  ClipRRect(
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
                  const SizedBox(height: 24),

                  // Isi Konten Artikel Bersih & Nyaman Dibaca
                  Text(
                    widget.content,
                    style: TextStyle(
                      fontSize: _fontSize,
                      color: const Color(0xFF334155),
                      height: 1.7,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),

            // Banner Notifikasi Mengambang
            if (_showBanner)
              Positioned(
                top: 10,
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
      ),
    );
  }
}