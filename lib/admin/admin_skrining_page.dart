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
      bool matchesSearch = item['name'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Data Skrining', style: TextStyle(color: Color(0xFF4C63E6), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Navigator.canPop(context)
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF4C63E6)),
          onPressed: () => Navigator.pop(context),
        )
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              onChanged: (val) => setState(() => searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Cari nama pengguna .....',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Tab Filter Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['Semua', 'Positif', 'Negatif'].map((filter) {
                bool isSelected = selectedFilter == filter;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected ? const Color(0xFF4C63E6) : Colors.white,
                        foregroundColor: isSelected ? Colors.white : Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      onPressed: () => setState(() => selectedFilter = filter),
                      child: Text(filter),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // List Data
            Expanded(
              child: ListView.builder(
                itemCount: filteredList.length,
                itemBuilder: (context, index) {
                  var item = filteredList[index];
                  bool isPositive = item['status'] == 'Positif';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFFDCE4FF),
                            child: Icon(Icons.person, color: Color(0xFF4C63E6)),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(item['date'], style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isPositive ? Colors.red.shade100 : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              item['status'],
                              style: TextStyle(
                                color: isPositive ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFDCE4FF),
                              foregroundColor: const Color(0xFF4C63E6),
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                            child: const Text('Lihat', style: TextStyle(fontSize: 12)),
                          )
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
    );
  }
}