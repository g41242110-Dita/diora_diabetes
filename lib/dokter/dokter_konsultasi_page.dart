import 'package:flutter/material.dart';

class DokterKonsultasiPage extends StatefulWidget {
  const DokterKonsultasiPage({Key? key}) : super(key: key);

  @override
  State<DokterKonsultasiPage> createState() => _DokterKonsultasiPageState();
}

class _DokterKonsultasiPageState extends State<DokterKonsultasiPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, String>> _konsulAktif = [
    {
      'nama': 'Aurelia Priscilla',
      'gender': 'Wanita',
      'umur': '23 th',
      'tanggal': '14 Feb 2024',
      'keluhan': 'Dok, saya mengalami mual dan pusing...',
    },
  ];

  final List<Map<String, String>> _konsulMenunggu = [
    {
      'nama': 'Budi Hartono',
      'gender': 'Pria',
      'umur': '40 th',
      'tanggal': '14 Feb 2024',
      'keluhan': 'Dokter, untuk program kesehatan jantung...',
    },
  ];

  final List<Map<String, String>> _konsulSelesai = [
    {
      'nama': 'Dewi Lestari',
      'gender': 'Wanita',
      'umur': '30 th',
      'tanggal': '12 Feb 2024',
      'keluhan': 'Terima kasih atas sarannya dokter...',
    },
    {
      'nama': 'Ahmad Faisal',
      'gender': 'Pria',
      'umur': '28 th',
      'tanggal': '10 Feb 2024',
      'keluhan': 'Obatnya sangat membantu.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Telekonsultasi Pasien',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Komunikasi langsung, saran medis, dan resep digital',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama pasien konsultasi',
                  prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(color: Colors.blueAccent),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TabBar(
                controller: _tabController,
                indicatorColor: Colors.blueAccent,
                labelColor: Colors.blueAccent,
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 3,
                tabs: [
                  Tab(text: 'Sedang Aktif (${_konsulAktif.length})'),
                  Tab(text: 'Menunggu (${_konsulMenunggu.length})'),
                  Tab(text: 'Selesai (${_konsulSelesai.length})'),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildListPasien(_konsulAktif),
                    _buildListPasien(_konsulMenunggu),
                    _buildListPasien(_konsulSelesai),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListPasien(List<Map<String, String>> listData) {
    if (listData.isEmpty) {
      return const Center(child: Text('Tidak ada data konsultasi'));
    }

    return ListView.builder(
      itemCount: listData.length,
      itemBuilder: (context, index) {
        final item = listData[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  item['nama'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  item['tanggal'] ?? '',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  '• ${item['gender']}  • ${item['umur']}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['keluhan'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            trailing: const Icon(
              Icons.chevron_right,
              color: Colors.blueAccent,
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}