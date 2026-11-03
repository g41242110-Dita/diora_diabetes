import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'doctor_model.dart';
import 'konsultasi_selesai_page.dart';

class ChatKonsultasiPage extends StatefulWidget {
  final String roomId;
  final String currentUserId;
  final String dokterNama;
  final int jamMulai;
  final int jamSelesai;
  final String slotWaktu;

  const ChatKonsultasiPage({
    super.key,
    required this.roomId,
    required this.currentUserId,
    required this.dokterNama,
    this.jamMulai = 0,
    this.jamSelesai = 24,
    this.slotWaktu = '20.00 - 20.20',
  });

  @override
  State<ChatKonsultasiPage> createState() => _ChatKonsultasiPageState();
}

class _ChatKonsultasiPageState extends State<ChatKonsultasiPage> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _kirimRingkasanSkriningOtomatis();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return _getJamSekarang();
    final date = timestamp.toDate();
    final jam = date.hour.toString().padLeft(2, '0');
    final menit = date.minute.toString().padLeft(2, '0');
    return '$jam.$menit';
  }

  String _getJamSekarang() {
    final now = DateTime.now();
    final jam = now.hour.toString().padLeft(2, '0');
    final menit = now.minute.toString().padLeft(2, '0');
    return '$jam.$menit';
  }

  Future<void> _kirimRingkasanSkriningOtomatis() async {
    try {
      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.roomId)
          .collection('messages');

      final existingSummary = await chatRef
          .where('isScreeningSummary', isEqualTo: true)
          .limit(1)
          .get();

      if (existingSummary.docs.isNotEmpty) return;

      final skriningSnapshot = await FirebaseFirestore.instance
          .collection('hasil_skrining')
          .where('user_id', isEqualTo: widget.currentUserId)
          .orderBy('created_at', descending: true)
          .limit(1)
          .get();

      String tingkatRisiko = 'Risiko Tinggi';
      String ringkasanDetail =
          'Pasien terindikasi risiko tinggi diabetes. Disarankan verifikasi lab Gula Darah Puasa & HbA1c.';

      if (skriningSnapshot.docs.isNotEmpty) {
        final data = skriningSnapshot.docs.first.data();
        tingkatRisiko =
            data['tingkat_risiko'] ?? data['kategori'] ?? 'Risiko Sedang';
        final skor = data['skor']?.toString() ?? '-';
        final catatan = data['catatan'] ?? 'Skrining mandiri rutin.';

        ringkasanDetail = 'Skor Skrining: $skor\nCatatan: $catatan';
      }

      await chatRef.add({
        'senderId': widget.currentUserId,
        'text': ringkasanDetail,
        'tingkatRisiko': tingkatRisiko,
        'timestamp': FieldValue.serverTimestamp(),
        'isScreeningSummary': true,
      });
    } catch (e) {
      debugPrint('Gagal mengirim ringkasan skrining: $e');
    }
  }

  bool _isSlotSessionActive() {
    final now = DateTime.now();

    try {
      final parts = widget.slotWaktu.split('-');
      if (parts.length < 2) return true;

      final String startStr = parts[0].trim().replaceAll('.', ':');
      final String endStr = parts[1].trim().replaceAll('.', ':');

      final startParts = startStr.split(':');
      final endParts = endStr.split(':');

      final int startHour = int.parse(startParts[0]);
      final int startMinute = int.parse(startParts[1]);

      final int endHour = int.parse(endParts[0]);
      final int endMinute = int.parse(endParts[1]);

      final DateTime startSession =
      DateTime(now.year, now.month, now.day, startHour, startMinute);
      final DateTime endSession =
      DateTime(now.year, now.month, now.day, endHour, endMinute);

      return (now.isAfter(startSession) || now.isAtSameMomentAs(startSession)) &&
          (now.isBefore(endSession) || now.isAtSameMomentAs(endSession));
    } catch (e) {
      return true;
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _messageController.clear();

    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.roomId)
        .collection('messages');

    await chatRef.add({
      'senderId': widget.currentUserId,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
      'isScreeningSummary': false,
    });

    if (!_isSlotSessionActive()) {
      await Future.delayed(const Duration(milliseconds: 500));
      await chatRef.add({
        'senderId': 'system_bot',
        'text':
        'Pesan Anda telah diterima. Dokter ${widget.dokterNama} akan membalas saat sesi konsultasi Anda aktif pada jam ${widget.slotWaktu}.',
        'timestamp': FieldValue.serverTimestamp(),
        'isScreeningSummary': false,
      });
    }
  }

  void _tampilkanDialogAkhiriKonsultasi() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Akhiri Konsultasi?',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: const Text(
            'Sesi percakapan dengan dokter akan diakhiri.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xFF64748B), fontSize: 13.5),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Batal',
                style: TextStyle(
                    color: Color(0xFF6679F4), fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B71F3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.roomId)
                      .set({
                    'isEnded': true,
                    'endedAt': FieldValue.serverTimestamp(),
                  }, SetOptions(merge: true));
                } catch (e) {
                  debugPrint('Gagal update status chat ended: $e');
                }

                final doctorObj = Doctor(
                  id: widget.dokterNama,
                  nama: widget.dokterNama,
                  spesialis: 'Dokter Spesialis',
                  jamMulai: widget.jamMulai,
                  jamSelesai: widget.jamSelesai,
                  isOnline: true,
                  isBusyInChat: false,
                  rating: '4.8',
                  ulasan: '0',
                  deskripsi: '',
                );

                if (!mounted) return;

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => KonsultasiSelesaiPage(
                      doctor: doctorObj,
                      namaUser: widget.currentUserId,
                      roomId: widget.roomId,
                      currentUserId: widget.currentUserId,
                    ),
                  ),
                );
              },
              child: const Text(
                'Ya, Akhiri',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.roomId)
          .snapshots(),
      builder: (context, roomSnapshot) {
        bool isEnded = false;
        if (roomSnapshot.hasData && roomSnapshot.data!.exists) {
          final roomData = roomSnapshot.data!.data() as Map<String, dynamic>?;
          isEnded = roomData?['isEnded'] == true;
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0.5,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF4F46E5), size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFFEEF2FF),
                  child: Icon(Icons.person_rounded,
                      size: 20, color: Color(0xFF4F46E5)),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.dokterNama,
                      style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle,
                            size: 6,
                            color: isEnded
                                ? Colors.grey
                                : const Color(0xFF22C55E)),
                        const SizedBox(width: 4),
                        Text(
                          isEnded ? 'Selesai' : 'Online',
                          style: TextStyle(
                              color: isEnded
                                  ? Colors.grey
                                  : const Color(0xFF22C55E),
                              fontSize: 10,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: isEnded ? const Color(0xFFF1F5F9) : const Color(0xFFE0E7FF),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                        isEnded
                            ? Icons.check_circle_rounded
                            : Icons.access_time_filled_rounded,
                        size: 15,
                        color: isEnded
                            ? const Color(0xFF64748B)
                            : const Color(0xFF3730A3)),
                    const SizedBox(width: 6),
                    Text(
                      isEnded
                          ? 'Sesi Konsultasi Telah Berakhir'
                          : 'Jadwal Konsultasi Terjadwal: ${widget.slotWaktu}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isEnded
                            ? const Color(0xFF64748B)
                            : const Color(0xFF3730A3),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('chats')
                      .doc(widget.roomId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF4F46E5)));
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: const BoxDecoration(
                                  color: Color(0xFFEEF2FF),
                                  shape: BoxShape.circle),
                              child: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: Color(0xFF4F46E5),
                                  size: 36),
                            ),
                            const SizedBox(height: 12),
                            const Text('Belum ada percakapan',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A))),
                            const SizedBox(height: 4),
                            const Text(
                                'Mulai sapa dokter Anda untuk berkonsultasi!',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B))),
                          ],
                        ),
                      );
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final data =
                        docs[index].data() as Map<String, dynamic>;
                        final bool isMe =
                            data['senderId'] == widget.currentUserId;
                        final bool isSummary =
                            data['isScreeningSummary'] == true;
                        final String jamFormatted =
                        _formatTimestamp(data['timestamp'] as Timestamp?);

                        if (isSummary) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: const Color(0xFFE2E8F0)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.025),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.assignment_turned_in,
                                            size: 16,
                                            color: Color(0xFF4F46E5)),
                                        SizedBox(width: 6),
                                        Text(
                                          'Hasil Skrining Anda',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red.shade50,
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        border: Border.all(
                                            color: Colors.red.shade200),
                                      ),
                                      child: Text(
                                        data['tingkatRisiko'] ??
                                            'Risiko Tinggi',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  data['text'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF475569),
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child: Text(
                                    jamFormatted,
                                    style: const TextStyle(
                                        fontSize: 9.5,
                                        color: Color(0xFF94A3B8)),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Align(
                          alignment: isMe
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            constraints: BoxConstraints(
                              maxWidth:
                              MediaQuery.of(context).size.width * 0.78,
                            ),
                            decoration: BoxDecoration(
                              color: isMe
                                  ? const Color(0xFF4F46E5)
                                  : Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(14),
                                topRight: const Radius.circular(14),
                                bottomLeft: isMe
                                    ? const Radius.circular(14)
                                    : Radius.zero,
                                bottomRight: isMe
                                    ? Radius.zero
                                    : const Radius.circular(14),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['text'] ?? '',
                                  style: TextStyle(
                                    color: isMe
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                    fontSize: 13,
                                    height: 1.3,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  jamFormatted,
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    color: isMe
                                        ? Colors.white70
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
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
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: isEnded
                    ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Sesi konsultasi ini telah berakhir.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF64748B),
                    ),
                  ),
                )
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Tulis pesan...',
                                hintStyle: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _sendMessage,
                          borderRadius: BorderRadius.circular(24),
                          child: const CircleAvatar(
                            radius: 20,
                            backgroundColor: Color(0xFF3B52A4),
                            child: Icon(Icons.send_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 44,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B52A4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: _tampilkanDialogAkhiriKonsultasi,
                        child: const Text(
                          'Akhiri Konsultasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}