import 'package:flutter/material.dart';

class CurvedNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const CurvedNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<CurvedNavBar> createState() => _CurvedNavBarState();
}

class _CurvedNavBarState extends State<CurvedNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _curveAnimation;

  // Urutan indeks sesuai tata letak visual tombol kiri ke kanan:
  // [0: Beranda, 2: Konsultasi, 1: Skrining, 3: Artikel, 4: Profil]
  static const List<int> _menuOrder = [0, 2, 1, 3, 4];

  static const List<_NavItemData> _items = [
    _NavItemData(
      index: 0,
      label: 'Beranda',
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
    ),
    _NavItemData(
      index: 2,
      label: 'Konsultasi',
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    _NavItemData(
      index: 1,
      label: 'Skrining',
      icon: Icons.auto_awesome_outlined,
      activeIcon: Icons.auto_awesome_rounded,
    ),
    _NavItemData(
      index: 3,
      label: 'Artikel',
      icon: Icons.article_outlined,
      activeIcon: Icons.article_rounded,
    ),
    _NavItemData(
      index: 4,
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  double _previousX = 0;
  double _targetX = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _curveAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack,
    );
  }

  @override
  void didUpdateWidget(covariant CurvedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    _previousX = _targetX;
    _animationController.reset();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 65.0;
    const double fabSize = 48.0;
    final double screenWidth = MediaQuery.sizeOf(context).width;

    // Menghitung indeks visual posisi saat ini (0 sampai 4)
    int visualIndex = _menuOrder.indexOf(widget.selectedIndex);
    if (visualIndex == -1) visualIndex = 0; // Fallback aman

    final double itemWidth = screenWidth / _menuOrder.length;
    _targetX = (visualIndex + 0.5) * itemWidth;

    if (_previousX == 0) _previousX = _targetX;

    // Mengambil ikon aktif berdasarkan selectedIndex secara presisi
    final activeItemData = _items.firstWhere(
          (e) => e.index == widget.selectedIndex,
      orElse: () => _items.first,
    );

    return AnimatedBuilder(
      animation: _curveAnimation,
      builder: (context, child) {
        final double currentX =
            _previousX + (_targetX - _previousX) * _curveAnimation.value;

        return Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            // Background lekukan canvas
            CustomPaint(
              size: Size(screenWidth, barHeight),
              painter: _FluidNavBarPainter(centerX: currentX),
            ),

            // Tombol Melayang (Floating Active Button)
            Positioned(
              left: currentX - (fabSize / 2),
              top: -fabSize / 2 + 2,
              child: Container(
                width: fabSize,
                height: fabSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6679F4), Color(0xFF8DA0FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6679F4).withValues(alpha: 0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Icon(
                  activeItemData.activeIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),

            // Baris Item Navigasi
            SizedBox(
              height: barHeight,
              child: Row(
                children: _items.map((item) {
                  final bool isSelected = widget.selectedIndex == item.index;

                  return Expanded(
                    child: InkWell(
                      onTap: () => widget.onItemTapped(item.index),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 150),
                            opacity: isSelected ? 0.0 : 1.0,
                            child: Icon(
                              item.icon,
                              color: const Color(0xFF94A3B8),
                              size: 22,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF6679F4)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NavItemData {
  final int index;
  final String label;
  final IconData icon;
  final IconData activeIcon;

  const _NavItemData({
    required this.index,
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
}

class _FluidNavBarPainter extends CustomPainter {
  final double centerX;

  const _FluidNavBarPainter({required this.centerX});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    const double notchRadius = 32.0;
    const double notchDepth = 28.0;

    path.moveTo(0, 0);
    path.lineTo(centerX - notchRadius - 10, 0);

    path.cubicTo(
      centerX - notchRadius,
      0,
      centerX - notchRadius * 0.5,
      notchDepth,
      centerX,
      notchDepth,
    );
    path.cubicTo(
      centerX + notchRadius * 0.5,
      notchDepth,
      centerX + notchRadius,
      0,
      centerX + notchRadius + 10,
      0,
    );

    path.lineTo(w, 0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.06), 6.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FluidNavBarPainter oldDelegate) {
    return oldDelegate.centerX != centerX;
  }
}