import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DokterRiwayatKonsultasiPage extends StatefulWidget {
  final String doctorId;

  const DokterRiwayatKonsultasiPage({super.key, required this.doctorId});

  @override
  State<DokterRiwayatKonsultasiPage> createState() => _DokterRiwayatKonsultasiPageState();
}

class _DokterRiwayatKonsultasiPageState extends State<DokterRiwayatKonsultasiPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatTanggal(Timestamp? timestamp) {
    if (timestamp == null) return 'Hari ini';
    final date = timestamp.toDate();
    return '${date.day} / ${date.month} / ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Riwayat Konsultasi Pasien', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0F172A))),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari riwayat...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF4F46E5)),
                fillColor: Colors.white,
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('chats')
                    .where('isEnded', isEqualTo: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
                  }

                  // Menyaring berdasarkan ID dokter
                  final docs = snapshot.data!.docs.where((doc) => doc.id.contains(widget.doctorId)).toList();

                  if (docs.isEmpty) {
                    return const Center(child: Text('Belum ada riwayat konsultasi selesai.', style: TextStyle(color: Colors.grey)));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final roomIdParts = docs[index].id.split('_');
                      final namaPasien = roomIdParts.isNotEmpty ? roomIdParts[0] : 'Pasien';
                      final tanggalSelesai = _formatTanggal(data['endedAt'] as Timestamp?);
                      final diagnosa = data['diagnosa'] ?? '-';
                      final resep = data['resep'] ?? '-';

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(namaPasien, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(tanggalSelesai, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                              ],
                            ),
                            const Divider(height: 20),
                            Text('Diagnosa: $diagnosa', style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('Resep/Anjuran: $resep', style: const TextStyle(fontSize: 11.5, color: Color(0xFF166534))),
                          ],
                        ),
                      );
                    },
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