import 'package:flutter/material.dart';

class DokterCurvedNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const DokterCurvedNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<DokterCurvedNavBar> createState() => _DokterCurvedNavBarState();
}

class _DokterCurvedNavBarState extends State<DokterCurvedNavBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _curveAnimation;

  // 5 Menu Utama Dokter
  static const List<_NavItemData> _items = [
    _NavItemData(
      index: 0,
      label: 'Beranda',
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
    ),
    _NavItemData(
      index: 1,
      label: 'Skrining',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
    ),
    _NavItemData(
      index: 2,
      label: 'Konsultasi',
      icon: Icons.chat_bubble_outline_rounded,
      activeIcon: Icons.chat_bubble_rounded,
    ),
    _NavItemData(
      index: 3,
      label: 'Lokasi',
      icon: Icons.location_on_outlined,
      activeIcon: Icons.location_on_rounded,
    ),
    _NavItemData(
      index: 4,
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  double _previousX = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _curveAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void didUpdateWidget(covariant DokterCurvedNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _animationController.reset();
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const double barHeight = 65.0;
    const double fabSize = 44.0;
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double itemWidth = screenWidth / _items.length;

    final double targetX = (widget.selectedIndex + 0.5) * itemWidth;

    if (_previousX == 0) {
      _previousX = targetX;
    }

    final activeItemData = _items.firstWhere(
          (e) => e.index == widget.selectedIndex,
      orElse: () => _items.first,
    );

    return AnimatedBuilder(
      animation: _curveAnimation,
      builder: (context, child) {
        final double currentX =
            _previousX + (targetX - _previousX) * _curveAnimation.value;

        if (_curveAnimation.isCompleted) {
          _previousX = targetX;
        }

        return Stack(
          alignment: Alignment.bottomCenter,
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size(screenWidth, barHeight),
              painter: _DokterNavBarPainter(centerX: currentX),
            ),
            Positioned(
              left: currentX - (fabSize / 2),
              top: -fabSize / 2 + 2,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Container(
                  key: ValueKey<int>(widget.selectedIndex),
                  width: fabSize,
                  height: fabSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    activeItemData.activeIcon,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: barHeight,
              child: Row(
                children: _items.map((item) {
                  final bool isSelected = widget.selectedIndex == item.index;

                  return Expanded(
                    child: InkWell(
                      onTap: () {
                        _previousX = currentX;
                        widget.onItemTapped(item.index);
                      },
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
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isSelected
                                  ? const Color(0xFF4F46E5)
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

class _DokterNavBarPainter extends CustomPainter {
  final double centerX;

  const _DokterNavBarPainter({required this.centerX});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final Path path = Path();
    final double w = size.width;
    final double h = size.height;

    const double notchRadius = 26.0;
    const double notchDepth = 22.0;

    path.moveTo(0, 0);
    path.lineTo(centerX - notchRadius - 8, 0);

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
      centerX + notchRadius + 8,
      0,
    );

    path.lineTo(w, 0);
    path.lineTo(w, h);
    path.lineTo(0, h);
    path.close();

    canvas.drawShadow(path, Colors.black.withValues(alpha: 0.05), 5.0, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _DokterNavBarPainter oldDelegate) {
    return oldDelegate.centerX != centerX;
  }
}