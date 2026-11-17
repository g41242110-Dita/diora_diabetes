import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_screen.dart';
import 'konsultasi_page.dart';
import 'skrining_page.dart';
import 'lokasi_page.dart';
import 'progres_kesehatan_page.dart';
import 'artikel_page.dart';
import 'hasil_skrining_page.dart';
import 'detail_artikel_page.dart';
import 'curved_nav_bar.dart';
import 'notifikasi_page.dart';

class BerandaPage extends StatefulWidget {
  final String namaUser;
  final int initialIndex;

  const BerandaPage({
    super.key,
    this.namaUser = 'Pian',
    this.initialIndex = 0,
  });

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  late int _selectedIndex;
  late PageController _pageController;

  String _currentNamaUser = '';
  String? _currentBase64Image;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    _currentNamaUser = widget.namaUser;
    _fetchUserBerandaData();

    _pageController = PageController(
      initialPage: 1000,
      viewportFraction: 0.85,
    );
  }

  Future<void> _fetchUserBerandaData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data() as Map<String, dynamic>;
          if (mounted) {
            setState(() {
              if (data.containsKey('nama') &&
                  data['nama'].toString().isNotEmpty) {
                _currentNamaUser = data['nama'];
              }
              if (data.containsKey('photoBase64')) {
                _currentBase64Image = data['photoBase64'];
              }
            });
          }
        }
      } catch (e) {
        debugPrint("Error load beranda user data: $e");
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Helper untuk menampilkan thumbnail artikel (Base64 atau URL biasa)
  Widget _buildThumbnailWidget(String imageUrl, {double height = 85}) {
    if (imageUrl.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        color: const Color(0xFFEEF2FF),
        child: const Icon(
          Icons.image_not_supported_rounded,
          color: Color(0xFF5B4AF4),
          size: 28,
        ),
      );
    }

    if (imageUrl.startsWith('data:image')) {
      try {
        final bytes = base64Decode(imageUrl.split(',').last);
        return Image.memory(
          bytes,
          height: height,
          width: double.infinity,
          fit: BoxFit.cover,
        );
      } catch (e) {
        return Container(
          height: height,
          width: double.infinity,
          color: const Color(0xFFEEF2FF),
          child: const Icon(
            Icons.broken_image_rounded,
            color: Color(0xFF5B4AF4),
            size: 28,
          ),
        );
      }
    }

    return Image.network(
      imageUrl,
      height: height,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        height: height,
        width: double.infinity,
        color: const Color(0xFFEEF2FF),
        child: const Icon(
          Icons.image_not_supported_rounded,
          color: Color(0xFF5B4AF4),
          size: 28,
        ),
      ),
    );
  }

  void _bukaHalamanProfil() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileScreen(
          namaUser: _currentNamaUser,
          onBackToHome: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
        ),
      ),
    );
    _fetchUserBerandaData();
  }

  void _bukaHalamanSkrining() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  Future<bool> _showExitConfirmationDialog() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Konfirmasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: const Text(
          'Apakah anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
        actionsPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5B4AF4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'IYA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: Color(0xFF5B4AF4), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'TIDAK',
                      style: TextStyle(
                        color: Color(0xFF5B4AF4),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return shouldExit ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildBerandaContent(),
      SkriningPage(
        onBackToHome: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      KonsultasiPage(namaUser: _currentNamaUser),
      ArtikelPage(
        showBackButton: true,
        onBackToHome: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
      ProfileScreen(
        namaUser: _currentNamaUser,
        onBackToHome: () {
          setState(() {
            _selectedIndex = 0;
          });
        },
      ),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;

        if (_selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
          return;
        }

        final bool confirmExit = await _showExitConfirmationDialog();
        if (confirmExit) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: pages[_selectedIndex],
        bottomNavigationBar: CurvedNavBar(
          selectedIndex: _selectedIndex,
          onItemTapped: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index == 0) {
              _fetchUserBerandaData();
            }
          },
        ),
      ),
    );
  }

  Widget _buildBerandaContent() {
    final double topPadding = MediaQuery.of(context).padding.top + 24;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipPath(
              clipper: _BerandaLiquidClipper(),
              child: Container(
                height: topPadding + 140,
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(20, topPadding, 20, 0),
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
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _bukaHalamanProfil,
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: CircleAvatar(
                                radius: 21,
                                backgroundColor: const Color(0xFFEEF2FF),
                                backgroundImage:
                                (_currentBase64Image != null &&
                                    _currentBase64Image!.isNotEmpty)
                                    ? MemoryImage(
                                    base64Decode(_currentBase64Image!))
                                    : null,
                                child: (_currentBase64Image == null ||
                                    _currentBase64Image!.isEmpty)
                                    ? const Icon(Icons.person,
                                    color: Color(0xFF5B4AF4), size: 26)
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Halo, $_currentNamaUser 👋',
                                    style: const TextStyle(
                                      fontSize: 17.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Text(
                                    'Selamat Datang di Diora',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.white70,
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
                    IconButton(
                      icon: const Icon(Icons.notifications_none_rounded,
                          color: Colors.white, size: 25),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotifikasiPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: topPadding + 62,
              left: 16,
              right: 16,
              child: Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFF1F5F9)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEF2FF),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'FITUR UTAMA',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF5B4AF4),
                              ),
                            ),
                          ),
                          const SizedBox(height: 5),
                          const Text(
                            'Skrining Gejala Diabetes',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Cek potensi risiko kesehatanmu dalam beberapa langkah mudah.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              height: 1.25,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: _bukaHalamanSkrining,
                      child: Container(
                        width: 44,
                        height: 44,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: Color(0xFF5B4AF4),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 48),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Layanan & Menu',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuickActionItem(
                    icon: Icons.chat_outlined,
                    label: 'Konsultasi',
                    color: const Color(0xFFFF5252),
                    bgColor: const Color(0xFFFFEBEE),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 2;
                      });
                    },
                  ),
                  _buildQuickActionItem(
                    icon: Icons.location_on_outlined,
                    label: 'Lokasi',
                    color: const Color(0xFF2E7D32),
                    bgColor: const Color(0xFFE8F5E9),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LokasiPage()),
                      );
                    },
                  ),
                  _buildQuickActionItem(
                    icon: Icons.article_outlined,
                    label: 'Artikel',
                    color: const Color(0xFF5B4AF4),
                    bgColor: const Color(0xFFEEF2FF),
                    onTap: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                    },
                  ),
                  _buildQuickActionItem(
                    icon: Icons.assignment_outlined,
                    label: 'Hasil Tes',
                    color: const Color(0xFFF57F17),
                    bgColor: const Color(0xFFFFF8E1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HasilSkriningPage()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ProgresKesehatanPage(username: _currentNamaUser),
                  ),
                );
              },
              child: Ink(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.show_chart_rounded,
                          color: Color(0xFFE65100), size: 20),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progres Kesehatan',
                            style: TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pantau catatan dan tren grafik kesehatanmu.',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF64748B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        color: Colors.black45),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Artikel Terbaru',
                style: TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = 3;
                  });
                },
                child: const Text(
                  'Lihat Semua',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B4AF4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double imageHeight =
                (constraints.maxHeight * 0.52).clamp(60.0, 95.0);

                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('articles')
                      .orderBy('created_at', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF5B4AF4)),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'Belum ada artikel terbaru',
                          style:
                          TextStyle(color: Color(0xFF64748B), fontSize: 12),
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return PageView.builder(
                      controller: _pageController,
                      itemCount: docs.length * 1000,
                      itemBuilder: (context, index) {
                        final realIndex = index % docs.length;
                        final data =
                        docs[realIndex].data() as Map<String, dynamic>;
                        final title = data['title'] ?? '';
                        final content = data['content'] ?? '';
                        final imageUrl =
                            data['thumbnail'] ?? data['imageUrl'] ?? '';
                        final inlineImages = data['inline_images'];

                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailArtikelPage(
                                  title: title,
                                  content: content,
                                  imageUrl: imageUrl,
                                  inlineImages: inlineImages,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border:
                              Border.all(color: const Color(0xFFF1F5F9)),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0F172A)
                                      .withValues(alpha: 0.03),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16)),
                                  child: _buildThumbnailWidget(imageUrl,
                                      height: imageHeight),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 8),
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          title,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          content,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Color(0xFF64748B),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _BerandaLiquidClipper extends CustomClipper<Path> {
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