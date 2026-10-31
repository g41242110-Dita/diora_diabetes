import 'package:flutter/material.dart';
import 'admin_detail_pengguna_page.dart';

class AdminPenggunaPage extends StatefulWidget {
  const AdminPenggunaPage({super.key});

  @override
  State<AdminPenggunaPage> createState() => _AdminPenggunaPageState();
}

class _AdminPenggunaPageState extends State<AdminPenggunaPage> {
  String selectedFilter = 'Semua';
  String searchQuery = '';

  // Data dummy sesuai tampilan desain
  final List<Map<String, dynamic>> userList = [
  {
  'no': '1',
  'nama': 'Aurelia Prisilla',
  'email': 'Aurelia.Prisilla@gmail.com',
  'gender': 'Perempuan',
  'status': 'Aktif',
  'tglLahir': '12 Maret 2003',
  'noHp': '0812 3456 7890',
  'alamat': 'Jl. Mastrip 84',
  'pekerjaan': 'Mahasiswa',
  'instansi': 'Jl. Mastrip 84',
  'alergi': 'Tidak Ada',
  },
  {
  'no': '2',
  'nama': 'Siti Aisyah',
  'email': 'sitiaisyah@gmail.com',
  'gender': 'Perempuan',
  'status': 'Nonaktif',
  'tglLahir': '15 Juli 2002',
  'noHp': '0813 9876 5432',
  'alamat': 'Jl. Kalimantan 12',
  'pekerjaan': 'Mahasiswa',
  'instansi': 'Universitas Jember',
  'alergi': 'Tidak Ada',
  },
  {
  'no': '3',
  'nama': 'Dwi Lestari',
  'email': 'dwilestari@gmail.com',
  'gender': 'Perempuan',
  'status': 'Aktif',
  'tglLahir': '20 Mei 2001',
  'noHp': '0852 1122 3344',
  'alamat': 'Jl. Riau 05',
  'pekerjaan': 'Swasta',
  'instansi': 'PT Diora Sehat',
  'alergi': 'Obat A',
  },
  {
  'no': '4',
  'nama': 'Budi Hartono',
  'email': 'budihartono@gmail.com',
  'gender': 'Laki - Laki',
  'status': 'Aktif',
  'tglLahir': '10 Agustus 1999',
  'noHp': '0821 5566 7788',
  'alamat': 'Jl. Jawa 45',
  'pekerjaan': 'Wiraswasta',
  'instansi': 'Toko Budi',
  'alergi': 'Tidak Ada',
  },
  {
  'no': '5',
  'nama': 'Ahmad Faisal',
  'email': 'ahmadfaisal@gmail.com',
  'gender': 'Laki - Laki',
  'status': 'Nonaktif',
  'tglLahir': '01 Januari 2000',
  'noHp': '0878 9900 1122',
  'alamat': 'Jl. Sumatra 18',
  'pekerjaan': 'Mahasiswa',
  'instansi': 'Politeknik Negeri Jember',
  'alergi': 'Debu',
  },
  ];

  @override
  Widget build(BuildContext context) {
    // Filter data berdasarkan gender dan search query
    final filteredUsers = userList.where((u) {
      bool matchesFilter = selectedFilter == 'Semua' || u['gender'] == selectedFilter;
      bool matchesSearch = u['nama'].toLowerCase().contains(searchQuery.toLowerCase()) ||
          u['email'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
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
                          'Data Pengguna',
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
                          const Icon(Icons.people_alt_rounded, color: Color(0xFFBFDBFE), size: 22),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Kelola dan pantau seluruh data informasi akun pengguna sistem.',
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
                    // Search Input Estetik
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

                    // Filter Pills Estetik
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: ['Semua', 'Laki - Laki', 'Perempuan'].map((filter) {
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

                    // Table Tampilan Data Estetik
                    Container(
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
                      child: Column(
                        children: [
                          // Header Table
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
                            ),
                            child: const Row(
                              children: [
                                SizedBox(width: 30, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF1E3A8A)))),
                                Expanded(flex: 25, child: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF1E3A8A)))),
                                Expanded(flex: 30, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF1E3A8A)))),
                                Expanded(flex: 25, child: Text('Gender', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF1E3A8A)))),
                                SizedBox(width: 60, child: Text('Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5, color: Color(0xFF1E3A8A)))),
                                SizedBox(width: 16),
                              ],
                            ),
                          ),

                          // Body List
                          filteredUsers.isEmpty
                              ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 30.0),
                            child: Center(
                              child: Text(
                                'Tidak ada data pengguna ditemukan.',
                                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                              ),
                            ),
                          )
                              : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredUsers.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              bool isAktif = user['status'] == 'Aktif';

                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AdminDetailPenggunaPage(userData: user),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Text('${index + 1}', style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                                      ),
                                      Expanded(
                                        flex: 25,
                                        child: Text(
                                          user['nama'],
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 30,
                                        child: Text(
                                          user['email'],
                                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Expanded(
                                        flex: 25,
                                        child: Text(
                                          user['gender'],
                                          style: const TextStyle(fontSize: 11.5, color: Color(0xFF334155)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 60,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 6),
                                          decoration: BoxDecoration(
                                            color: isAktif ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            user['status'],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: isAktif ? const Color(0xFF15803D) : const Color(0xFFEF4444),
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 16,
                                        child: Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
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
            ],
          ),
        ),
      ),
    );
  }
}