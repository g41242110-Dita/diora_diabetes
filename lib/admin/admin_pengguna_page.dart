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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4C63E6)),
          onPressed: () => Navigator.pop(context),
        )
            : null,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Data Pengguna',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4C63E6),
              ),
            ),
            Text(
              'Kelola data pengguna sistem',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Input
            TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari nama .....',
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Filter Pills
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Semua', 'Laki - Laki', 'Perempuan'].map((filter) {
                bool isSelected = selectedFilter == filter;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? const Color(0xFF5B71F5) : Colors.white,
                        foregroundColor: isSelected ? Colors.white : Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onPressed: () => setState(() => selectedFilter = filter),
                      child: Text(filter, style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Table Tampilan Data
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    // Header Table
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      decoration: const BoxDecoration(
                        color: Color(0xFFE2E8FF),
                        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 25, child: Text('No', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Expanded(flex: 2, child: Text('Nama', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Expanded(flex: 3, child: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          Expanded(flex: 2, child: Text('Jenis Kelamin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          SizedBox(width: 55, child: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                          SizedBox(width: 20),
                        ],
                      ),
                    ),

                    // Body List
                    Expanded(
                      child: ListView.separated(
                        itemCount: filteredUsers.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
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
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                              child: Row(
                                children: [
                                  SizedBox(width: 25, child: Text('${index + 1}', style: const TextStyle(fontSize: 11))),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      user['nama'],
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 3,
                                    child: Text(
                                      user['email'],
                                      style: const TextStyle(fontSize: 10, color: Colors.grey),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      user['gender'],
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 55,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 6),
                                      decoration: BoxDecoration(
                                        color: isAktif ? const Color(0xFF818CF8) : const Color(0xFFC084FC),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        user['status'],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                    child: Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}