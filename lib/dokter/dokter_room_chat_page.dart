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
  final Set<String> _markedReadIds = {};

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

  Future<void> _tandaiPesanPasienDibaca(List<QueryDocumentSnapshot> docs) async {
    for (final doc in docs) {
      if (_markedReadIds.contains(doc.id)) continue;
      final data = doc.data() as Map<String, dynamic>? ?? {};
      final String sender =
      (data['senderId'] ?? data['sender_id'] ?? '').toString();
      final bool isRead = data['isRead'] == true;
      if (sender.isNotEmpty && sender != widget.doctorId && !isRead) {
        _markedReadIds.add(doc.id);
        try {
          await doc.reference.set({'isRead': true}, SetOptions(merge: true));
        } catch (_) {
          _markedReadIds.remove(doc.id);
        }
      }
    }
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
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Gagal mengirim pesan: $e');
    }
  }

  void _showDetailLaporanDialog(
      Map<String, dynamic> data, String timeFormatted) {
    final String laporanText = (data['text'] ?? '').toString();
    final String tingkatRisiko =
    (data['tingkatRisiko'] ?? 'Hasil Skrining Pasien').toString();
    final String fileName = (data['fileName'] ??
        'Laporan_Skrining_${widget.namaPasien.replaceAll(' ', '_')}.pdf')
        .toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.picture_as_pdf_rounded,
                  color: Colors.redAccent, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13.5, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    '$tingkatRisiko • $timeFormatted WIB',
                    style: const TextStyle(
                        fontSize: 10.5, color: Color(0xFF64748B)),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              laporanText,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF0F172A),
                height: 1.45,
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Tutup',
              style: TextStyle(
                  color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showAkhiriKonsultasiDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Ringkasan Konsultasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Catatan Diagnosa / Anjuran Dokter:',
                    style:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _catatanDokterController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Lakukan tes Gula Darah...',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Resep Digital / Obat (Opsional):',
                    style:
                    TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                TextField(
                  controller: _resepController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: 'Contoh: Metformin 500mg',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
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
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5)),
              child: const Text('Simpan & Akhiri',
                  style: TextStyle(color: Colors.white)),
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
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Konsultasi Selesai',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          content: const Text('Ringkasan medis telah dikirim ke pasien.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
          actions: [
            ElevatedButton(
              onPressed: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5)),
              child: const Text('Ke Beranda',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReadCheckIcon({
    required bool isDokter,
    required bool isRead,
    required bool isCardLight,
  }) {
    if (!isDokter) return const SizedBox.shrink();
    final Color checkColor = isRead
        ? (isCardLight ? const Color(0xFF0284C7) : const Color(0xFF38BDF8))
        : (isCardLight ? const Color(0xFF94A3B8) : Colors.white70);

    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Icon(
        Icons.done_all_rounded,
        size: 14,
        color: checkColor,
      ),
    );
  }

  Widget _buildPdfScreeningBubble(
      Map<String, dynamic> data, bool isDokter, String timeFormatted) {
    final String textContent = (data['text'] ?? '').toString();
    final String tingkatRisiko =
    (data['tingkatRisiko'] ?? 'Laporan Skrining').toString();
    final bool isPositif = tingkatRisiko.toLowerCase().contains('positif') ||
        tingkatRisiko.toLowerCase().contains('tinggi');
    final bool isRead = data['isRead'] == true;
    final String fileName = (data['fileName'] ??
        'Hasil_Skrining_Diabetes_${widget.namaPasien.replaceAll(' ', '_')}.pdf')
        .toString();

    return Align(
      alignment: isDokter ? Alignment.centerRight : Alignment.centerLeft,
      child: InkWell(
        onTap: () => _showDetailLaporanDialog(data, timeFormatted),
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(18),
          topRight: const Radius.circular(18),
          bottomLeft: Radius.circular(isDokter ? 18 : 4),
          bottomRight: Radius.circular(isDokter ? 4 : 18),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.82,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(18),
              topRight: const Radius.circular(18),
              bottomLeft: Radius.circular(isDokter ? 18 : 4),
              bottomRight: Radius.circular(isDokter ? 4 : 18),
            ),
            border: Border.all(
              color: isPositif
                  ? const Color(0xFFFECACA)
                  : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: isPositif
                      ? const Color(0xFFFEF2F2)
                      : const Color(0xFFEEF2FF),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(17),
                    topRight: Radius.circular(17),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf_rounded,
                        color: Color(0xFFEF4444),
                        size: 21,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fileName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Dokumen PDF • $tingkatRisiko',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isPositif
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF4F46E5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (textContent.isNotEmpty)
                      Text(
                        textContent,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF334155),
                          height: 1.4,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Ketuk untuk buka laporan',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              timeFormatted,
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            _buildReadCheckIcon(
                              isDokter: isDokter,
                              isRead: isRead,
                              isCardLight: true,
                            ),
                          ],
                        ),
                      ],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEEF2FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        titleSpacing: 4,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFEEF2FF),
              child: Icon(
                Icons.person_rounded,
                size: 20,
                color: Color(0xFF4F46E5),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.namaPasien,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Text(
                    'Sesi ${widget.jamSesi}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              onPressed: _showAkhiriKonsultasiDialog,
              icon: const Icon(Icons.check_circle_outline_rounded,
                  color: Colors.redAccent, size: 18),
              label: const Text(
                'Akhiri',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w800,
                  fontSize: 12.5,
                ),
              ),
            ),
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
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
                  );
                }
                final docs = snapshot.data!.docs;
                if (docs.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada pesan dalam sesi ini.',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _tandaiPesanPasienDibaca(docs);
                });

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final bool isDokter = data['senderId'] == widget.doctorId;
                    final bool isRead = data['isRead'] == true;
                    final timeFormatted =
                    _formatjam(data['timestamp'] as Timestamp?);

                    final bool isPdfLaporan =
                        data['isScreeningSummary'] == true ||
                            data['type'] == 'pdf';

                    if (isPdfLaporan) {
                      return _buildPdfScreeningBubble(
                          data, isDokter, timeFormatted);
                    }

                    return Align(
                      alignment: isDokter
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.78,
                        ),
                        decoration: BoxDecoration(
                          gradient: isDokter
                              ? const LinearGradient(
                            colors: [
                              Color(0xFF5B4AF4),
                              Color(0xFF4338CA),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                              : null,
                          color: isDokter ? null : Colors.white,
                          border: isDokter
                              ? null
                              : Border.all(
                              color: const Color(0xFFE2E8F0), width: 1),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: Radius.circular(isDokter ? 18 : 3),
                            bottomRight: Radius.circular(isDokter ? 3 : 18),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: isDokter
                                  ? const Color(0xFF4F46E5)
                                  .withValues(alpha: 0.18)
                                  : const Color(0xFF0F172A)
                                  .withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: isDokter
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['text'] ?? '',
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.38,
                                color: isDokter
                                    ? Colors.white
                                    : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(height: 5),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  timeFormatted,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: isDokter
                                        ? Colors.white70
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                                _buildReadCheckIcon(
                                  isDokter: isDokter,
                                  isRead: isRead,
                                  isCardLight: false,
                                ),
                              ],
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
            padding: EdgeInsets.fromLTRB(
                12, 10, 12, MediaQuery.of(context).padding.bottom + 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(fontSize: 13.5),
                    decoration: InputDecoration(
                      hintText: 'Tulis balasan untuk pasien...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF94A3B8),
                      ),
                      fillColor: const Color(0xFFF1F5F9),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 21,
                  backgroundColor: const Color(0xFF4F46E5),
                  child: IconButton(
                    icon: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 18),
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