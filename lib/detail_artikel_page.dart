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
  double _fontSize = 12.0;
  bool _isBookmarked = false;
  bool _showBanner = false;
  String _bannerTitle = '';
  String _bannerSubtitle = '';
  bool _isSuccessBanner = true;

  void _zoomIn() {
    setState(() {
      if (_fontSize < 20.0) _fontSize += 2.0;
    });
  }

  void _zoomOut() {
    setState(() {
      if (_fontSize > 8.0) _fontSize -= 2.0;
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
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 40,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 14.0),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.black87, width: 1),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                widget.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                              const SizedBox(height: 10),

                              Text(
                                widget.content,
                                style: TextStyle(
                                  fontSize: _fontSize,
                                  color: Colors.black87,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  widget.imageUrl,
                                  height: 150,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 150,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image, size: 40, color: Colors.grey),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),

                              const Divider(color: Colors.black45, thickness: 1),
                              const SizedBox(height: 4),

                              Row(
                                children: [
                                  InkWell(
                                    onTap: _zoomIn,
                                    child: const Icon(Icons.zoom_in, color: Colors.grey, size: 26),
                                  ),
                                  InkWell(
                                    onTap: _zoomOut,
                                    child: const Icon(Icons.zoom_out, color: Colors.grey, size: 26),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: _toggleBookmark,
                                    child: Icon(
                                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                      color: _isBookmarked ? const Color(0xFF2D5C52) : Colors.grey,
                                      size: 26,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            if (_showBanner)
              Positioned(
                top: 4,
                left: 16,
                right: 16,
                child: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: _isSuccessBanner ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: _isSuccessBanner ? const Color(0xFF81C784) : const Color(0xFFE57373),
                        width: 1.2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _isSuccessBanner ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            _isSuccessBanner ? Icons.check : Icons.close,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _bannerTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.5,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                _bannerSubtitle,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.black54,
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
                            Icons.close,
                            size: 16,
                            color: Colors.black54,
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