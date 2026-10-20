import 'package:flutter/material.dart';

class AdminFloatingNavBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  const AdminFloatingNavBar({
    super.key,
    required this.selectedIndex,
    required this.onItemTapped,
  });

  @override
  State<AdminFloatingNavBar> createState() => _AdminFloatingNavBarState();
}

class _AdminFloatingNavBarState extends State<AdminFloatingNavBar> {
  // 6 Menu Admin berurutan dari kiri ke kanan
  static const List<_NavItemData> _items = [
    _NavItemData(
      index: 0,
      label: 'Beranda',
      icon: Icons.grid_view_rounded,
      activeIcon: Icons.grid_view_rounded,
    ),
    _NavItemData(
      index: 1,
      label: 'Pengguna',
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
    ),
    _NavItemData(
      index: 2,
      label: 'Skrining',
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
    ),
    _NavItemData(
      index: 3,
      label: 'Laporan',
      icon: Icons.bar_chart_rounded,
      activeIcon: Icons.bar_chart_rounded,
    ),
    _NavItemData(
      index: 4,
      label: 'Artikel',
      icon: Icons.article_outlined,
      activeIcon: Icons.article_rounded,
    ),
    _NavItemData(
      index: 5,
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    const double barHeight = 65.0;
    const double buttonSize = 42.0; // Ukuran kotak aktif
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double itemWidth = screenWidth / _items.length;

    // Menghitung posisi target X untuk tombol kotak melayang
    final double targetX = (widget.selectedIndex + 0.5) * itemWidth - (buttonSize / 2);

    final activeItemData = _items.firstWhere(
          (e) => e.index == widget.selectedIndex,
      orElse: () => _items.first,
    );

    return Container(
      height: barHeight,
      width: screenWidth,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 1. Indicator Melayang (Kotak Biru/Ungu yang Meluncur Halus)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic, // Animasi meluncur sangat smooth
            left: targetX,
            top: 4, // Sedikit menonjol ke atas
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return ScaleTransition(scale: animation, child: child);
              },
              child: Container(
                key: ValueKey<int>(widget.selectedIndex),
                width: buttonSize,
                height: buttonSize,
                decoration: BoxDecoration(
                  color: const Color(0xFF5B67CA), // Warna utama (Indigo/Ungu seperti di video)
                  borderRadius: BorderRadius.circular(14), // Sudut tumpul kotak
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5B67CA).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
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

          // 2. Teks & Area Sentuh untuk Semua Menu
          Row(
            children: _items.map((item) {
              final bool isSelected = widget.selectedIndex == item.index;

              return Expanded(
                child: InkWell(
                  onTap: () => widget.onItemTapped(item.index),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Ikon non-aktif (Hilang dengan animasi saat menu dipilih)
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isSelected ? 0.0 : 1.0,
                        child: Icon(
                          item.icon,
                          color: const Color(0xFF94A3B8),
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Teks Label
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected
                                ? const Color(0xFF5B67CA)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
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