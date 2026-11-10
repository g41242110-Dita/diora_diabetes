import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DokterRoomChatPage extends StatefulWidget {
  final String roomId;
  final String doctorId;
  final String namaPasien;
  final String genderAge;
  final String jamSesi;

  const DokterRoomChatPage({
    super.key,
    required this.roomId,
    required this.doctorId,
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

  @override
  void dispose() {
    _messageController.dispose();
    _catatanDokterController.dispose();
    _resepController.dispose();
    super.dispose();
  }

  String _formatjam(Timestamp? timestamp) {
    if (timestamp == null) {
      final now = DateTime.now();
      return '${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}';
    }
    final date = timestamp.toDate();
    return '${date.hour.toString().padLeft(2, '0')}.${date.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _messageController.clear();

    try {
      await FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.roomId)
          .collection('messages')
          .add({
        'senderId': widget.doctorId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Gagal mengirim pesan: $e');
    }
  }

  void _showAkhiriKonsultasiDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ringkasan Konsultasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Catatan Diagnosa / Anjuran Dokter:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _catatanDokterController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Lakukan tes Gula Darah...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Resep Digital / Obat (Opsional):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _resepController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Metformin 500mg',
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
              onPressed: () async {
                Navigator.pop(context);
                try {
                  // Menyimpan status selesai dan resep ke database
                  await FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.roomId)
                      .set({
                    'isEnded': true,
                    'endedAt': FieldValue.serverTimestamp(),
                    'diagnosa': _catatanDokterController.text.trim(),
                    'resep': _resepController.text.trim(),
                  }, SetOptions(merge: true));
                } catch (e) {
                  debugPrint('Gagal mengakhiri konsultasi: $e');
                }
                _showKonfirmasiSelesaiDialog();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
              child: const Text('Simpan & Akhiri', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showKonfirmasiSelesaiDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Konsultasi Selesai', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: const Text('Ringkasan medis telah dikirim ke pasien.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F46E5)),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.namaPasien, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
            Text('Sesi ${widget.jamSesi}', style: const TextStyle(fontSize: 10, color: Color(0xFF64748B))),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _showAkhiriKonsultasiDialog,
            icon: const Icon(Icons.check_circle_outline_rounded, color: Colors.redAccent, size: 18),
            label: const Text('Akhiri', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('chats')
                  .doc(widget.roomId)
                  .collection('messages')
                  .orderBy('timestamp', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFF4F46E5)));
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(child: Text('Belum ada pesan dalam sesi ini.', style: TextStyle(fontSize: 12, color: Colors.grey)));
                }

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.all(16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final bool isDokter = data['senderId'] == widget.doctorId;
                    final timeFormatted = _formatjam(data['timestamp'] as Timestamp?);

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
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(data['text'] ?? '', style: TextStyle(fontSize: 12.5, color: isDokter ? Colors.white : const Color(0xFF0F172A))),
                            const SizedBox(height: 4),
                            Text(timeFormatted, style: TextStyle(fontSize: 9.5, color: isDokter ? Colors.white70 : const Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                    );
                  },
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
                      fillColor: const Color(0xFFF1F5F9),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
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