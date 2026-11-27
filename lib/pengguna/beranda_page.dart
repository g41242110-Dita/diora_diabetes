import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
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

class _BerandaPageState extends State<BerandaPage>
    with SingleTickerProviderStateMixin {
  late int _selectedIndex;
  late PageController _pageController;
  late AnimationController _bgAnimController;

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
      viewportFraction: 1.0,
    );

    _bgAnimController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
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
    _bgAnimController.dispose();
    super.dispose();
  }

  Widget _buildArticleThumbnail(String imageUrl, {required double height}) {
    if (imageUrl.isEmpty) {
      return Container(
        height: height,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFEEF2FF), Color(0xFFDBEAFE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Icon(
          Icons.auto_awesome_rounded,
          color: Color(0xFF5B4AF4),
          size: 32,
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
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Konfirmasi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Color(0xFF0F172A),
          ),
        ),
        content: const Text(
          'Apakah anda yakin ingin keluar dari aplikasi?',
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF475569),
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
                        borderRadius: BorderRadius.circular(16),
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
                        borderRadius: BorderRadius.circular(16),
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
        backgroundColor: const Color(0xFFF3F5FC),
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
    final media = MediaQuery.of(context);
    final double statusBar = media.padding.top;
    final double screenW = media.size.width;
    final double screenH = media.size.height;

    final double hPad = (screenW * 0.05).clamp(16.0, 22.0);
    final double topPad = statusBar + (screenH * 0.016).clamp(10.0, 18.0);
    final double waveHeight = topPad + (screenH * 0.215).clamp(162.0, 192.0);
    final double heroTop = topPad + (screenH * 0.072).clamp(54.0, 68.0);
    final double afterWaveGap = (screenH * 0.015).clamp(10.0, 16.0);
    final double sectionGap = (screenH * 0.012).clamp(8.0, 12.0);

    return Stack(
      children: [
        // 1. ANIMASI LATAR BELAKANG (FLOATING GLOW ORBS + PARTIKEL SPARKLE)
        AnimatedBuilder(
          animation: _bgAnimController,
          builder: (context, child) {
            final double t = _bgAnimController.value;
            final double dy1 = math.sin(t * math.pi * 2) * 18;
            final double dx1 = math.cos(t * math.pi) * 20;
            final double dy2 = math.cos(t * math.pi * 2) * 18;
            final double pulse = 0.90 + (math.sin(t * math.pi) * 0.20);

            return Stack(
              children: [
                Positioned(
                  top: screenH * 0.34 + dy1,
                  left: -screenW * 0.14 + dx1,
                  child: Transform.scale(
                    scale: pulse,
                    child: Container(
                      width: screenW * 0.64,
                      height: screenW * 0.64,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF5B4AF4).withValues(alpha: 0.18),
                            const Color(0xFF5B4AF4).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: screenH * 0.52 + dy2,
                  right: -screenW * 0.16 - dx1 * 0.8,
                  child: Transform.scale(
                    scale: 2.0 - pulse,
                    child: Container(
                      width: screenW * 0.68,
                      height: screenW * 0.68,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF388BFF).withValues(alpha: 0.18),
                            const Color(0xFF388BFF).withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: IgnorePointer(
                    child: CustomPaint(
                      painter: _AmbientSparklePainter(progress: t),
                    ),
                  ),
                ),
              ],
            );
          },
        ),

        // 2. LAYOUT STAY (TANPA SCROLL)
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER GELOMBANG DENGAN ILUSTRASI SAMAR + KARTU UTAMA BENING
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipPath(
                  clipper: _BerandaTopWaveClipper(),
                  child: Container(
                    height: waveHeight,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF28004D),
                          Color(0xFF5B4AF4),
                          Color(0xFF388BFF),
                        ],
                        stops: [0.0, 0.54, 1.0],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Opacity(
                          opacity: 0.36,
                          child: Image.asset(
                            'assets/images/bg_header_diora.jpg',
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                            errorBuilder: (context, error, stackTrace) =>
                                CustomPaint(
                                  painter: _HeaderHealthWatermarkPainter(),
                                ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFF28004D).withValues(alpha: 0.45),
                                Colors.transparent,
                                const Color(0xFF388BFF).withValues(alpha: 0.18),
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(hPad, topPad, hPad, 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: _bukaHalamanProfil,
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(2.5),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black
                                                  .withValues(alpha: 0.16),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            ),
                                          ],
                                        ),
                                        child: CircleAvatar(
                                          radius: 21,
                                          backgroundColor:
                                          const Color(0xFFEEF2FF),
                                          backgroundImage:
                                          (_currentBase64Image != null &&
                                              _currentBase64Image!
                                                  .isNotEmpty)
                                              ? MemoryImage(base64Decode(
                                              _currentBase64Image!))
                                              : null,
                                          child: (_currentBase64Image ==
                                              null ||
                                              _currentBase64Image!
                                                  .isEmpty)
                                              ? const Icon(
                                              Icons.person_rounded,
                                              color: Color(0xFF5B4AF4),
                                              size: 25)
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              'Halo, $_currentNamaUser 👋',
                                              style: const TextStyle(
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                letterSpacing: -0.2,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            const Text(
                                              'Selamat Datang di Diora',
                                              style: TextStyle(
                                                fontSize: 11.5,
                                                color: Colors.white70,
                                              ),
                                              maxLines: 1,
                                              overflow:
                                              TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color:
                                    Colors.white.withValues(alpha: 0.25),
                                  ),
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const NotifikasiPage(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // KARTU FITUR UTAMA BENING (HANYA TOMBOL PANAH PUTIH YANG BISA DIKLIK)
                Positioned(
                  top: heroTop,
                  left: hPad,
                  right: hPad,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 13, 14, 13),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.22),
                              Colors.white.withValues(alpha: 0.10),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.42),
                            width: 1.3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1E1B4B)
                                  .withValues(alpha: 0.14),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
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
                                        horizontal: 10, vertical: 3),
                                    decoration: BoxDecoration(
                                      color:
                                      Colors.white.withValues(alpha: 0.22),
                                      borderRadius: BorderRadius.circular(99),
                                      border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.25),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: const Text(
                                      'FITUR UTAMA',
                                      style: TextStyle(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.6,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  const Text(
                                    'Skrining Gejala Diabetes',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      letterSpacing: -0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Cek potensi risiko kesehatanmu dalam beberapa langkah mudah.',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white70,
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
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                      Colors.black.withValues(alpha: 0.16),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Color(0xFF5B4AF4),
                                  size: 22,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: afterWaveGap),

            // LAYANAN & MENU
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layanan & Menu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAestheticMenuCard(
                          icon: Icons.chat_bubble_rounded,
                          label: 'Konsultasi',
                          color: const Color(0xFFF43F5E),
                          bgColor: const Color(0xFFFFF1F2),
                          onTap: () {
                            setState(() {
                              _selectedIndex = 2;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildAestheticMenuCard(
                          icon: Icons.location_on_rounded,
                          label: 'Lokasi',
                          color: const Color(0xFF10B981),
                          bgColor: const Color(0xFFECFDF5),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const LokasiPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAestheticMenuCard(
                          icon: Icons.article_rounded,
                          label: 'Artikel',
                          color: const Color(0xFF5B4AF4),
                          bgColor: const Color(0xFFEEF2FF),
                          onTap: () {
                            setState(() {
                              _selectedIndex = 3;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildAestheticMenuCard(
                          icon: Icons.assignment_rounded,
                          label: 'Hasil Tes',
                          color: const Color(0xFFF59E0B),
                          bgColor: const Color(0xFFFFFBEB),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                  const HasilSkriningPage()),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: sectionGap),

            // PROGRES KESEHATAN
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B0066), Color(0xFF5B4AF4)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF5B4AF4)
                              .withValues(alpha: 0.22),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.insights_rounded,
                            color: Color(0xFF5B4AF4),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Progres Kesehatan',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Pantau catatan dan tren grafik kesehatanmu.',
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: Colors.white70,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(height: sectionGap),

            // HEADER ARTIKEL TERBARU
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Artikel Terbaru',
                    style: TextStyle(
                      fontSize: 14,
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

            const SizedBox(height: 7),

            // ARTIKEL TERBARU: DIBERI JEDA ANTAR-KARTU YANG PAS (TIDAK TERLALU DEKAT)
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad - 8, 0, hPad - 8, 12),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double imageHeight =
                    (constraints.maxHeight * 0.67).clamp(90.0, 148.0);

                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('articles')
                          .orderBy('created_at', descending: true)
                          .limit(5)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF5B4AF4)),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'Belum ada artikel terbaru',
                              style: TextStyle(
                                  color: Color(0xFF64748B), fontSize: 12),
                            ),
                          );
                        }

                        final docs = snapshot.data!.docs;

                        return PageView.builder(
                          controller: _pageController,
                          padEnds: false,
                          itemCount: docs.length * 1000,
                          itemBuilder: (context, index) {
                            final realIndex = index % docs.length;
                            final data = docs[realIndex].data()
                            as Map<String, dynamic>;
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
                                // Jeda horizontal: 8 di kiri & 8 di kanan = 16px jarak antar kartu saat digeser
                                margin: const EdgeInsets.fromLTRB(8, 0, 8, 2),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.98),
                                  borderRadius: BorderRadius.circular(22),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF1E1B4B)
                                          .withValues(alpha: 0.06),
                                      blurRadius: 16,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(22)),
                                      child: _buildArticleThumbnail(
                                        imageUrl,
                                        height: imageHeight,
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 6),
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                fontSize: 14.5,
                                                fontWeight: FontWeight.w800,
                                                color: Color(0xFF0F172A),
                                                height: 1.18,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                  'Baca selengkapnya...',
                                                  style: TextStyle(
                                                    fontSize: 12.0,
                                                    fontWeight: FontWeight.w700,
                                                    color: Color(0xFF5B4AF4),
                                                  ),
                                                ),
                                                SizedBox(width: 4),
                                                Icon(
                                                  Icons
                                                      .arrow_forward_ios_rounded,
                                                  size: 11.0,
                                                  color: Color(0xFF5B4AF4),
                                                ),
                                              ],
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
        ),
      ],
    );
  }

  Widget _buildAestheticMenuCard({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE6EAF5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1E1B4B).withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderHealthWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final fillSoft = Paint()
      ..color = Colors.white.withValues(alpha: 0.22)
      ..style = PaintingStyle.fill;
    final strokeSoft = Paint()
      ..color = Colors.white.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;

    final center1 = Offset(size.width * 0.56, size.height * 0.62);
    canvas.drawCircle(center1, 26, fillSoft);
    canvas.drawCircle(center1, 26, strokeSoft);

    final chartPath = Path()
      ..moveTo(center1.dx - 14, center1.dy + 8)
      ..lineTo(center1.dx - 4, center1.dy - 1)
      ..lineTo(center1.dx + 4, center1.dy + 4)
      ..lineTo(center1.dx + 14, center1.dy - 9);
    canvas.drawPath(chartPath, strokeSoft);

    final meterRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.36, size.height * 0.68),
        width: 36,
        height: 48,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(meterRect, fillSoft);
    canvas.drawRRect(meterRect, strokeSoft);

    final waveLine = Path()
      ..moveTo(size.width * 0.25, size.height * 0.42)
      ..lineTo(size.width * 0.42, size.height * 0.30)
      ..lineTo(size.width * 0.54, size.height * 0.38)
      ..lineTo(size.width * 0.70, size.height * 0.24)
      ..lineTo(size.width * 0.85, size.height * 0.32);
    canvas.drawPath(waveLine, strokeSoft);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AmbientSparklePainter extends CustomPainter {
  final double progress;

  _AmbientSparklePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      (0.14, 0.44, 3.0, const Color(0xFF5B4AF4)),
      (0.86, 0.40, 3.5, const Color(0xFF388BFF)),
      (0.24, 0.68, 2.5, const Color(0xFF818CF8)),
      (0.78, 0.66, 3.0, const Color(0xFF5B4AF4)),
      (0.50, 0.88, 2.8, const Color(0xFF388BFF)),
      (0.90, 0.84, 2.4, const Color(0xFF818CF8)),
    ];

    for (var i = 0; i < points.length; i++) {
      final (dxFactor, dyFactor, radius, color) = points[i];
      final phase = (progress + i * 0.17) % 1.0;
      final offsetY = math.sin(phase * math.pi * 2) * 8;
      final alpha = 0.14 + (math.sin(phase * math.pi) * 0.16);

      final paint = Paint()
        ..color = color.withValues(alpha: alpha.clamp(0.05, 0.32))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(size.width * dxFactor, size.height * dyFactor + offsetY),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AmbientSparklePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _BerandaTopWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 28);

    var firstControlPoint = Offset(size.width * 0.28, size.height);
    var firstEndPoint = Offset(size.width * 0.56, size.height - 22);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.80, size.height - 40);
    var secondEndPoint = Offset(size.width, size.height - 16);
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