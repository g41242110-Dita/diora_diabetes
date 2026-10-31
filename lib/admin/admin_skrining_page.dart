import 'package:flutter/material.dart';
import 'admin_detail_skrining_page.dart';

class AdminSkriningPage extends StatefulWidget {
  final String initialFilter; // Menampung filter awal (misal: 'Positif')

  const AdminSkriningPage({
    Key? key,
    this.initialFilter = 'Semua', // Default jika dibuka biasa lewat navbar
  }) : super(key: key);

  @override
  State<AdminSkriningPage> createState() => _AdminSkriningPageState();
}

class _AdminSkriningPageState extends State<AdminSkriningPage> {
  late String selectedFilter;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    selectedFilter = widget.initialFilter; // Mengeset filter dari parameter
  }

  final List<Map<String, dynamic>> screeningData = [
  {'id': '1', 'name': 'Aurelia Prisilla', 'date': '01 September 2026', 'status': 'Positif'},
  {'id': '2', 'name': 'Siti Aisyah', 'date': '01 September 2026', 'status': 'Negatif'},
  {'id': '3', 'name': 'Dwi Lestari', 'date': '01 September 2026', 'status': 'Positif'},
  {'id': '4', 'name': 'Budi Hartono', 'date': '01 September 2026', 'status': 'Positif'},
  {'id': '5', 'name': 'Ahmad Faisal', 'date': '01 September 2026', 'status': 'Negatif'},
  ];

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> filteredList = screeningData.where((item) {
      bool matchesFilter = selectedFilter == 'Semua' || item['status'] == selectedFilter;
      bool matchesSearch = item['name'].toString().toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Warna latar belakang bersih (Slate 50)
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER KURVA BERGRADIEN BIRU PENUH (ESTETIK & SERASI) ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            if (Navigator.canPop(context)) {
                              Navigator.pop(context);
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFF2563EB),
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Text(
                          'Data Skrining',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Mini Banner Edukasi di Header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.medical_services_rounded, color: Color(0xFFBFDBFE), size: 22),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Kelola dan pantau hasil skrining kesehatan pengguna secara berkala.',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w500,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // --- KONTEN UTAMA DI BAWAH HEADER ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 20.0),
                child: Column(
                  children: [
                    // Search Bar Estetik
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withValues(alpha: 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                      ),
                      child: TextField(
                        onChanged: (val) => setState(() => searchQuery = val),
                        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          hintText: 'Cari nama pengguna .....',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF2563EB), size: 22),
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Tab Filter Buttons Estetik
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['Semua', 'Positif', 'Negatif'].map((filter) {
                        bool isSelected = selectedFilter == filter;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4.0),
                            child: GestureDetector(
                              onTap: () => setState(() => selectedFilter = filter),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 13),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    if (isSelected)
                                      BoxShadow(
                                        color: const Color(0xFF2563EB).withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        offset: const Offset(0, 4),
                                      ),
                                  ],
                                  border: Border.all(
                                    color: isSelected ? Colors.transparent : const Color(0xFFCBD5E1),
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  filter,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),

                    // List Data Skrining
                    filteredList.isEmpty
                        ? Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Text(
                          'Tidak ada data skrining ditemukan.',
                          style: TextStyle(color: Colors.grey[500], fontSize: 13.5),
                        ),
                      ),
                    )
                        : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        var item = filteredList[index];
                        bool isPositive = item['status'] == 'Positif';

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 16,
                                offset: const Offset(0, 6),
                              ),
                            ],
                            border: Border.all(color: const Color(0xFFF1F5F9)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFFE0E7FF), Color(0xFFBFDBFE)],
                                  ),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.person_rounded, color: Color(0xFF2563EB), size: 22),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['date'],
                                      style: const TextStyle(color: Color(0xFF64748B), fontSize: 11.5),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isPositive ? Colors.red.shade100 : Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  item['status'],
                                  style: TextStyle(
                                    color: isPositive ? Colors.red.shade700 : Colors.green.shade700,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFDBEAFE),
                                  foregroundColor: const Color(0xFF2563EB),
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminDetailSkriningPage(
                                        patientName: item['name'],
                                        status: item['status'],
                                        date: item['date'],
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Lihat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}