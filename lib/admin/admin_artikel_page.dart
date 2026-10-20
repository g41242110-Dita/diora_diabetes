import 'package:flutter/material.dart';

class AdminArtikelPage extends StatefulWidget {
  final VoidCallback? onBackToBeranda;

  const AdminArtikelPage({Key? key, this.onBackToBeranda}) : super(key: key);

  @override
  State<AdminArtikelPage> createState() => _AdminArtikelPageState();
}

class _AdminArtikelPageState extends State<AdminArtikelPage> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'Artikel Draf';

  final List<Map<String, String>> _articles = [
    {
      'title': 'Diabetes dan Prediabetes',
      'description':
          'Diabetes muncul ketika tubuh tidak dapat memproduksi cukup insulin (diabetes tipe 1) atau ketika tubuh memproduksi insulin tetapi tidak dapat menggunakannya...',
    },
    {
      'title': 'Memahami dan menjalani hidup dengan Diabetes',
      'description':
          'Anda mungkin telah mengidap diabetes sejak lama jika muncul gejala seperti sering merasa haus, tenggorokan terasa kering, dan sudah makan teratur tetapi berat...',
    },
    {
      'title': '11 Cara Mencegah Diabetes yang Bisa Dimulai Hari Ini!',
      'description':
          'Penyakit diabetes melitus ditandai oleh naiknya kadar gula di dalam darah. Penyebabnya bisa berkaitan dengan faktor keturunan hingga obesitas.',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER KUSTOM DENGAN TOMBOL BACK
              Row(
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (widget.onBackToBeranda != null) {
                        widget.onBackToBeranda!();
                      }
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(right: 12.0, top: 4.0, bottom: 4.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xFF2563EB),
                        size: 26,
                      ),
                    ),
                  ),
                  const Text(
                    'Artikel',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Tombol Tambah Artikel
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF536DFE),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Tambah Artikel',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari artikel ....',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Dropdown Filter
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFilter,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                    items: <String>['Artikel Draf', 'Artikel Dipublikasi']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontStyle: FontStyle.italic,
                            fontSize: 14,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedFilter = newValue!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Daftar Artikel
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _articles.length,
                itemBuilder: (context, index) {
                  final article = _articles[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.image_outlined, color: Colors.grey[400], size: 28),
                              const SizedBox(height: 4),
                              Text(
                                'Gambar',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                article['title']!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                article['description']!,
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {},
                                    child: const Icon(Icons.edit, size: 18, color: Colors.black87),
                                  ),
                                  const SizedBox(width: 16),
                                  InkWell(
                                    onTap: () {},
                                    child: const Icon(Icons.delete, size: 18, color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}