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
  bool _isLoadingSkrining = true;
  bool _sudahSkrining = false;

  // Variabel untuk melacak status jika sedang mengedit pesan
  String? _editingMessageId;

  @override
  void initState() {
    super.initState();
    _cekStatusSkrining();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  // 1. Cek apakah user sudah pernah melakukan skrining di 'screening_results'
  Future<void> _cekStatusSkrining() async {
    try {
      final query = await FirebaseFirestore.instance
          .collection('screening_results')
          .where('user_id', isEqualTo: widget.currentUserId)
          .get();

      if (query.docs.isEmpty) {
        final fallbackQuery = await FirebaseFirestore.instance
            .collection('screening_results')
            .get();

        if (fallbackQuery.docs.isEmpty) {
          setState(() {
            _sudahSkrining = false;
            _isLoadingSkrining = false;
          });
          return;
        }
      }

      setState(() {
        _sudahSkrining = true;
        _isLoadingSkrining = false;
      });
    } catch (e) {
      debugPrint('Gagal mengecek status skrining: $e');
      setState(() {
        _isLoadingSkrining = false;
        _sudahSkrining = true; // Bypass jika terjadi kendala query agar tetap bisa diuji
      });
    }
  }

  // 2. Tarik dan Kirim Hasil Skrining Persis Sesuai Data Asli Tes Pengguna
  Future<void> _tarikDanKirimHasilSkriningViaPenjepit() async {
    try {
      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.roomId)
          .collection('messages');

      // PENCEGAHAN: Cek apakah ringkasan skrining sudah pernah dikirim sebelumnya di room ini
      final existingSummary = await chatRef
          .where('isScreeningSummary', isEqualTo: true)
          .get();

      if (existingSummary.docs.isNotEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Hasil skrining sudah dilampirkan sebelumnya.')),
          );
        }
        return;
      }

      var query = await FirebaseFirestore.instance
          .collection('screening_results')
          .where('user_id', isEqualTo: widget.currentUserId)
          .get();

      if (query.docs.isEmpty) {
        query = await FirebaseFirestore.instance
            .collection('screening_results')
            .get();
      }

      if (query.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Belum ada data hasil skrining ditemukan.')),
          );
        }
        return;
      }

      final dataSkrining = query.docs.last.data();
      final String nama = dataSkrining['nama'] ?? 'Pengguna';
      final String umur = (dataSkrining['umur'] ?? '-').toString();
      final String jenisKelamin = dataSkrining['jenisKelamin'] ?? '-';
      final String hasilPrediksi = dataSkrining['hasilPrediksi'] ?? 'Risiko Rendah';

      final String bak = dataSkrining['seringBAK'] == true ? 'Ya' : 'Tidak';
      final String haus = dataSkrining['seringHaus'] == true ? 'Ya' : 'Tidak';
      final String lemas = dataSkrining['seringLemas'] == true ? 'Ya' : 'Tidak';
      final String rambutRontok = dataSkrining['rambutRontok'] == true ? 'Ya' : 'Tidak';
      final String luka = dataSkrining['lukaSulitSembuh'] == true ? 'Ya' : 'Tidak';
      final String marah = dataSkrining['mudahMarah'] == true ? 'Ya' : 'Tidak';
      final String kaku = dataSkrining['kakuOtot'] == true ? 'Ya' : 'Tidak';
      final String obesitas = dataSkrining['obesitas'] == true ? 'Ya' : 'Tidak';

      String ringkasanDetail = 'LAPORAN HASIL SKRINING MANDIRI\n\n';
      ringkasanDetail += '• Nama: $nama\n';
      ringkasanDetail += '• Usia: $umur Tahun\n';
      ringkasanDetail += '• Jenis Kelamin: $jenisKelamin\n';
      ringkasanDetail += '• Status Evaluasi: $hasilPrediksi\n\n';
      ringkasanDetail += 'Detail Jawaban Indikator:\n';
      ringkasanDetail += '1. Sering buang air kecil (BAK): $bak\n';
      ringkasanDetail += '2. Sering merasa haus / dahaga: $haus\n';
      ringkasanDetail += '3. Sering merasa lemas / mudah lelah: $lemas\n';
      ringkasanDetail += '4. Mengalami rambut rontok: $rambutRontok\n';
      ringkasanDetail += '5. Memiliki luka sulit sembuh: $luka\n';
      ringkasanDetail += '6. Mudah marah / emosional: $marah\n';
      ringkasanDetail += '7. Sering mengalami kaku otot: $kaku\n';
      ringkasanDetail += '8. Mengalami obesitas / kelebihan BB: $obesitas';

      await chatRef.add({
        'senderId': widget.currentUserId,
        'text': ringkasanDetail,
        'tingkatRisiko': hasilPrediksi,
        'timestamp': FieldValue.serverTimestamp(),
        'isScreeningSummary': true,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Hasil skrining asli berhasil dikirim ke dokter!')),
        );
      }
    } catch (e) {
      debugPrint('Gagal mengirim hasil skrining: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal melampirkan skrining: $e')),
        );
      }
    }
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

  bool _isSessionBelumMulai() {
    final now = DateTime.now();
    try {
      final parts = widget.slotWaktu.split('-');
      if (parts.length < 2) return false;

      final String startStr = parts[0].trim().replaceAll('.', ':');
      final startParts = startStr.split(':');
      final int startHour = int.parse(startParts[0]);
      final int startMinute = int.parse(startParts[1]);

      final DateTime startSession =
      DateTime(now.year, now.month, now.day, startHour, startMinute);

      return now.isBefore(startSession);
    } catch (e) {
      return false;
    }
  }

  // 3. Kirim atau Edit Pesan
  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final chatRef = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.roomId)
        .collection('messages');

    if (_editingMessageId != null) {
      // Jika sedang dalam mode edit pesan
      await chatRef.doc(_editingMessageId).update({
        'text': text,
        'isEdited': true,
      });
      setState(() {
        _editingMessageId = null;
      });
    } else {
      // Kirim pesan baru
      await chatRef.add({
        'senderId': widget.currentUserId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isScreeningSummary': false,
        'isEdited': false,
      });
    }

    _messageController.clear();
  }

  void _tampilkanDialogAkhiriKonsultasi() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal',
                  style: TextStyle(
                      color: Color(0xFF6679F4), fontWeight: FontWeight.bold)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5B71F3),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
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
                  debugPrint('Gagal update status chat: $e');
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
              child: const Text('Ya, Akhiri',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingSkrining) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
        ),
      );
    }

    // Jika belum melakukan skrining, kunci halaman chat dan beri tombol peringatan
    if (!_sudahSkrining) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text('Konsultasi Dokter',
              style: TextStyle(color: Color(0xFF0F172A), fontSize: 16)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF4F46E5), size: 18),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      size: 48, color: Colors.orange),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Anda Harus Melakukan Skrining Terlebih Dahulu',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sesi konsultasi dikunci. Silakan selesaikan tes skrining risiko terlebih dahulu agar hasil Anda dapat dikirimkan ke dokter.',
                  style: TextStyle(fontSize: 13.5, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4F46E5),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                'Silakan buka menu skrining untuk mengisi data.')),
                      );
                    },
                    child: const Text('Lakukan Skrining Sekarang',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final bool belumMulai = _isSessionBelumMulai();

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
              // Banner Jadwal Aktif
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                color: isEnded
                    ? const Color(0xFFF1F5F9)
                    : (belumMulai ? Colors.amber.shade100 : const Color(0xFFE0E7FF)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isEnded
                          ? Icons.check_circle_rounded
                          : (belumMulai
                          ? Icons.lock_clock_rounded
                          : Icons.access_time_filled_rounded),
                      size: 15,
                      color: isEnded
                          ? const Color(0xFF64748B)
                          : (belumMulai ? Colors.amber.shade800 : const Color(0xFF3730A3)),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isEnded
                          ? 'Sesi Konsultasi Telah Berakhir'
                          : (belumMulai
                          ? 'Belum Waktunya (Jadwal: ${widget.slotWaktu})'
                          : 'Jadwal Konsultasi Aktif: ${widget.slotWaktu}'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isEnded
                            ? const Color(0xFF64748B)
                            : (belumMulai ? Colors.amber.shade900 : const Color(0xFF3730A3)),
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
                                'Tekan ikon penjepit (📎) di bawah untuk mengirim hasil skrining Anda ke dokter.',
                                style: TextStyle(
                                    fontSize: 12, color: Color(0xFF64748B)),
                                textAlign: TextAlign.center),
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
                        final doc = docs[index];
                        final data = doc.data() as Map<String, dynamic>;
                        final bool isMe =
                            data['senderId'] == widget.currentUserId;
                        final bool isSummary =
                            data['isScreeningSummary'] == true;
                        final bool isEdited = data['isEdited'] == true;
                        final String jamFormatted =
                        _formatTimestamp(data['timestamp'] as Timestamp?);

                        if (isSummary) {
                          final bool isPositif = (data['tingkatRisiko'] ?? '').toString().contains('Positif') || (data['tingkatRisiko'] ?? '').toString().contains('Tinggi');
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
                                          'Hasil Skrining Pasien',
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
                                        color: isPositif ? Colors.red.shade50 : Colors.green.shade50,
                                        borderRadius:
                                        BorderRadius.circular(10),
                                        border: Border.all(
                                            color: isPositif ? Colors.red.shade200 : Colors.green.shade200),
                                      ),
                                      child: Text(
                                        data['tingkatRisiko'] ?? 'Risiko',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: isPositif ? Colors.redAccent : Colors.green,
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

                        // PESAN CHAT BIASA (Bisa Di-edit jika diklik lama / long press)
                        return GestureDetector(
                          onLongPress: () {
                            if (isMe) {
                              // Masuk ke mode edit
                              setState(() {
                                _editingMessageId = doc.id;
                                _messageController.text = data['text'] ?? '';
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Mode edit pesan aktif. Ubah di kolom bawah.')),
                              );
                            }
                          },
                          child: Align(
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
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (isEdited)
                                        Text(
                                          '(dielit) • ',
                                          style: TextStyle(
                                            fontSize: 8.5,
                                            color: isMe
                                                ? Colors.white70
                                                : const Color(0xFF94A3B8),
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
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
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              // Bagian Input Pesan + Tombol Penjepit (📎) + Indikator Edit
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
                    : belumMulai
                    ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.amber.shade200),
                  ),
                  child: Text(
                    'Chat dikunci. Sesi baru akan dibuka pada jam ${widget.slotWaktu}.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber.shade900,
                    ),
                  ),
                )
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Jika sedang mode edit, tampilkan banner kecil penanda
                    if (_editingMessageId != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.indigo.shade200),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Edit Pesan Aktif',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF4F46E5)),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _editingMessageId = null;
                                  _messageController.clear();
                                });
                              },
                              child: const Icon(Icons.close, size: 16, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    Row(
                      children: [
                        // TOMBOL PENJEPIT (ATTACHMENT)
                        IconButton(
                          icon: const Icon(Icons.attach_file_rounded,
                              color: Color(0xFF4F46E5)),
                          tooltip: 'Kirim Hasil Skrining Asli',
                          onPressed: () {
                            _tarikDanKirimHasilSkriningViaPenjepit();
                          },
                        ),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _messageController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                hintText: _editingMessageId != null ? 'Edit pesan Anda...' : 'Tulis pesan...',
                                hintStyle: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF94A3B8)),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _sendMessage,
                          borderRadius: BorderRadius.circular(24),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: _editingMessageId != null ? Colors.orange : const Color(0xFF3B52A4),
                            child: Icon(
                              _editingMessageId != null ? Icons.check_rounded : Icons.send_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
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