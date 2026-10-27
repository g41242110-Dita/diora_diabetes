import 'package:flutter/material.dart';

class DokterRoomChatPage extends StatefulWidget {
  final String namaPasien;
  final String genderAge;
  final String jamSesi;

  const DokterRoomChatPage({
    super.key,
    required this.namaPasien,
    required this.genderAge,
    required this.jamSesi,
  });

  @override
  State<DokterRoomChatPage> createState() => _DokterRoomChatPageState();
}

class _DokterRoomChatPageState extends State<DokterRoomChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _catatanDokterController = TextEditingController();
  final TextEditingController _resepController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      'sender': 'system',
      'text': 'Hasil Skrining Diabetes Pasien: POSITIF (10 gejala khas)',
      'time': '09.15',
    },
    {
      'sender': 'pasien',
      'text':
      'Halo, Dok. Saya ingin berkonsultasi mengenai hasil skrining diabetes yang baru saja saya lakukan. Apakah saya perlu pemeriksaan lebih lanjut?',
      'time': '09.16',
    },
    {
      'sender': 'dokter',
      'text':
      'Halo, selamat pagi. Baik, saya bantu jelaskan ya. Hasil skrining awal menunjukkan indikasi positif, namun diperlukan tes gula darah laboratorium untuk diagnosis pasti.',
      'time': '09.17',
    },
  ];

  @override
  void dispose() {
    _messageController.dispose();
    _catatanDokterController.dispose();
    _resepController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'sender': 'dokter',
        'text': _messageController.text.trim(),
        'time': '09.18',
      });
      _messageController.clear();
    });
  }

  // 1. Form Ringkasan Konsultasi (Diagnosa & Resep/Anjuran)
  void _showAkhiriKonsultasiDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Icon(Icons.assignment_turned_in_rounded, color: Color(0xFF4F46E5)),
              SizedBox(width: 8),
              Text(
                'Ringkasan Konsultasi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Catatan Diagnosa / Anjuran Dokter:',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _catatanDokterController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Lakukan tes Gula Darah Puasa & HbA1c...',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Resep Digital / Obat (Opsional):',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _resepController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Metformin 500mg (2x sehari)',
                    hintStyle: const TextStyle(fontSize: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showKonfirmasiSelesaiDialog();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Simpan & Akhiri', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  // 2. Dialog Pilihan Navigasi (Kembali ke Beranda atau Daftar Konsul)
  void _showKonfirmasiSelesaiDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Konsultasi Selesai',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text(
            'Ringkasan medis telah dikirim ke pasien. Ke mana Anda ingin kembali?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            OutlinedButton(
              onPressed: () {
                Navigator.pop(context); // Tutup dialog
                Navigator.pop(context); // Kembali ke daftar konsultasi
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF4F46E5)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Daftar Konsul', style: TextStyle(color: Color(0xFF4F46E5))),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst); // Balik ke Beranda Utama
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ke Beranda', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.namaPasien,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              '${widget.genderAge} • Sesi ${widget.jamSesi}',
              style: const TextStyle(fontSize: 10, color: Color(0xFF64748B)),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _showAkhiriKonsultasiDialog,
            icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.redAccent, size: 18),
            label: const Text(
              'Akhiri',
              style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
            color: const Color(0xFFEEF2FF),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.access_time_filled_rounded, size: 14, color: Color(0xFF4F46E5)),
                const SizedBox(width: 6),
                Text(
                  'Sesi Berlangsung: Jam ${widget.jamSesi}',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final bool isDokter = msg['sender'] == 'dokter';
                final bool isSystem = msg['sender'] == 'system';

                if (isSystem) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFCA5A5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            msg['text'],
                            style: const TextStyle(fontSize: 11, color: Color(0xFF991B1B), fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Align(
                  alignment: isDokter ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isDokter ? const Color(0xFF4F46E5) : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          msg['text'],
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDokter ? Colors.white : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          msg['time'],
                          style: TextStyle(
                            fontSize: 9.5,
                            color: isDokter ? Colors.white70 : const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tulis balasan untuk pasien...',
                      hintStyle: const TextStyle(fontSize: 12),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      fillColor: const Color(0xFFF1F5F9),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF4F46E5),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}