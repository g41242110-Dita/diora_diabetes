import 'package:flutter/material.dart';

class DokterLokasiPage extends StatefulWidget {
  const DokterLokasiPage({super.key});

  @override
  State<DokterLokasiPage> createState() => _DokterLokasiPageState();
}

class _DokterLokasiPageState extends State<DokterLokasiPage> {
  // Index lokasi faskes yang sedang aktif dinas hari ini
  int _selectedIndex = 1; // Mengikuti screenshot (Klinik Pratama Medika aktif)

  final List<Map<String, dynamic>> _daftarFaskes = [
    {
      'nama': 'Klinik Sehat Sentosa',
      'alamat': 'Jl. Merdeka No. 15 Jember',
      'jarakWaktu': '1.2 km • 15 menit',
      'rating': '4.8',
      'telepon': '0812-3456-7890',
      'jadwal': 'Jadwal: Senin - Kamis, 08.00 - 14.00 WIB',
      'fasilitas': [
        'Laboratorium Gula Darah',
        'Poli Penyakit Dalam',
        'Apotek Terpadu',
        'Konseling Gizi Diabetes',
      ],
    },
    {
      'nama': 'Klinik Pratama Medika',
      'alamat': 'Jl. Cempaka No. 20 Jember',
      'jarakWaktu': '2.4 km • 15 menit',
      'rating': '4.6',
      'telepon': '0813-9876-5432',
      'jadwal': 'Jadwal: Jumat - Sabtu, 15.00 - 20.00 WIB',
      'fasilitas': [
        'Pemeriksaan Glukosa Cepat',
        'Poli Umum dan Spesialis',
        'Instalasi Gawat Darurat 24 Jam',
      ],
    },
    {
      'nama': 'Klinik Harmoni',
      'alamat': 'Jl. Anggrek No. 7 Jember',
      'jarakWaktu': '4.5 km • 20 menit',
      'rating': '4.9',
      'telepon': '0331-567890',
      'jadwal': 'Jadwal: Rabu & Jumat (Visit Rawat Inap), 07.30 - 12.00 WIB',
      'fasilitas': [
        'Laboratorium Sentral Rujukan',
        'Pusat Endokrinologi & Metabolik',
        'ICU & Rawat Inap Spesialis',
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lokasi Praktik dan Faskes',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Fasilitas kesehatan rujukan skrining & laboratorium glukosa',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Text(
              '${_daftarFaskes.length} Lokasi',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Color(0xFF4F46E5),
              ),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        itemCount: _daftarFaskes.length,
        itemBuilder: (context, index) {
          final faskes = _daftarFaskes[index];
          final bool isDinasAktif = _selectedIndex == index;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDinasAktif
                    ? const Color(0xFF4F46E5)
                    : const Color(0xFFE2E8F0),
                width: isDinasAktif ? 1.5 : 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Nama Faskes & Status Dinas
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.local_hospital_rounded,
                        color: Color(0xFF475569),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faskes['nama'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            faskes['alamat'],
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isDinasAktif)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF86EFAC)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.circle, size: 6, color: Color(0xFF166534)),
                            SizedBox(width: 4),
                            Text(
                              'Dinas Aktif',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF166534),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // Info Meta (Jarak, Rating, Telepon)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      const Icon(Icons.near_me_outlined,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        faskes['jarakWaktu'],
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.star_rounded,
                          size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        faskes['rating'],
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A)),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.phone_outlined,
                          size: 13, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        faskes['telepon'],
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // Jam Jadwal (DIFIX MENGGUNAKAN EXPANDED + ELLIPSIS)
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: Color(0xFF4F46E5)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        faskes['jadwal'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Layanan & Fasilitas Terpadu
                const Text(
                  'Layanan dan Fasilitas Terpadu:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 4),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: (faskes['fasilitas'] as List<String>)
                      .map(
                        (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Row(
                        children: [
                          const Text('• ',
                              style: TextStyle(
                                  color: Color(0xFF94A3B8), fontSize: 11)),
                          Expanded(
                            child: Text(
                              item,
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .toList(),
                ),

                const SizedBox(height: 14),

                // Tombol Pilihan Set Sebagai Faskes Dinas Utama
                if (!isDinasAktif)
                  SizedBox(
                    width: double.infinity,
                    height: 38,
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Faskes dinas utama diubah ke ${faskes['nama']}'),
                            backgroundColor: const Color(0xFF4F46E5),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFCBD5E1)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Set Sebagai Faskes Dinas Utama Hari Ini',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}