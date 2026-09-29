import 'package:flutter/material.dart';

class DataPenggunaPage extends StatefulWidget {
  const DataPenggunaPage({super.key});

  @override
  State<DataPenggunaPage> createState() => _DataPenggunaPageState();
}

class _DataPenggunaPageState extends State<DataPenggunaPage> {
  String _selectedGender = 'Semua'; // Options: Semua, Laki-Laki, Perempuan
  int _selectedIndex = 1; // Tab Data Pengguna aktif
  final TextEditingController _searchController = TextEditingController();

  // DUMMY DATA PENGGUNA (Ganti/Tambah Sesuai Kebutuhan)
  final List<Map<String, String>> _allUsers = [
    {'nama': 'Budi Santoso', 'email': 'budi@gmail.com', 'gender': 'Laki-Laki'},
    {'nama': 'Siti Rahma', 'email': 'siti@gmail.com', 'gender': 'Perempuan'},
    {'nama': 'Ahmad Fauzi', 'email': 'ahmad@gmail.com', 'gender': 'Laki-Laki'},
    {'nama': 'Dewi Lestari', 'email': 'dewi@gmail.com', 'gender': 'Perempuan'},
    {'nama': 'Rian Pratama', 'email': 'rian@gmail.com', 'gender': 'Laki-Laki'},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // FILTERING DATA BERDASARKAN SEARCH BAR & PILL FILTER
    final filteredUsers = _allUsers.where((user) {
      final query = _searchController.text.toLowerCase();
      final matchesSearch = user['nama']!.toLowerCase().contains(query) ||
          user['email']!.toLowerCase().contains(query);

      bool matchesGender = true;
      if (_selectedGender != 'Semua') {
        matchesGender = user['gender'] == _selectedGender;
      }

      return matchesSearch && matchesGender;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              children: [
                // 1. HEADER HALAMAN
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => Navigator.pop(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Data Pengguna',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Kelola data pengguna sistem Diora',
                            style: TextStyle(fontSize: 12, color: Colors.black45),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // 2. SEARCH BAR (BISA DIKETIK & FILTERING LANGSUNG)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        icon: const Icon(Icons.search_rounded, color: Color(0xFF6679F4)),
                        hintText: 'Cari nama pengguna...',
                        hintStyle: const TextStyle(fontSize: 13, color: Colors.black38),
                        border: InputBorder.none,
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                          icon: const Icon(Icons.clear, size: 18, color: Colors.black38),
                          onPressed: () {
                            setState(() {
                              _searchController.clear();
                            });
                          },
                        )
                            : null,
                      ),
                      onChanged: (val) {
                        setState(() {});
                      },
                    ),
                  ),
                ),

                // 3. PILL FILTER
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    children: [
                      _buildFilterPill('Semua'),
                      const SizedBox(width: 8),
                      _buildFilterPill('Laki-Laki'),
                      const SizedBox(width: 8),
                      _buildFilterPill('Perempuan'),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 4. LIST DATA PENGGUNA
                Expanded(
                  child: filteredUsers.isEmpty
                      ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_off_outlined,
                          size: 64,
                          color: Colors.black12,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Belum ada data pengguna.',
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isPerempuan = user['gender'] == 'Perempuan';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: isPerempuan
                                  ? const Color(0xFFFFEEF0)
                                  : const Color(0xFFEEF2FF),
                              child: Icon(
                                isPerempuan
                                    ? Icons.female_rounded
                                    : Icons.male_rounded,
                                color: isPerempuan
                                    ? const Color(0xFFFF5252)
                                    : const Color(0xFF6679F4),
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user['nama']!,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    user['email']!,
                                    style: const TextStyle(fontSize: 11, color: Colors.black45),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                user['gender']!,
                                style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // 5. FLOATING ISLAND NAVIGATION
            Positioned(
              left: 20,
              right: 20,
              bottom: 12,
              child: SafeArea(
                child: Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6679F4).withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildNavItem(Icons.grid_view_rounded, 0),
                      _buildNavItem(Icons.people_alt_rounded, 1),
                      InkWell(
                        onTap: () {},
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6679F4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
                        ),
                      ),
                      _buildNavItem(Icons.article_outlined, 2),
                      _buildNavItem(Icons.person_outline_rounded, 3),
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

  // WIDGET TOMBOL FILTER
  Widget _buildFilterPill(String label) {
    final isSelected = _selectedGender == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = label;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6679F4) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }

  // WIDGET BOTTOM NAV ITEM
  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedIndex == index;
    return IconButton(
      icon: Icon(icon, color: isSelected ? const Color(0xFF6679F4) : Colors.black38, size: 22),
      onPressed: () {
        if (index == 0) {
          Navigator.pop(context);
        } else {
          setState(() => _selectedIndex = index);
        }
      },
    );
  }
}