import 'package:flutter/material.dart';
import 'doctor_model.dart';
import 'chat_message_model.dart';
import 'konsultasi_selesai_page.dart';

class ChatKonsultasiPage extends StatefulWidget {
  final Doctor doctor;
  final String namaUser;

  const ChatKonsultasiPage({
    super.key,
    required this.doctor,
    this.namaUser = 'Pengguna',
  });

  @override
  State<ChatKonsultasiPage> createState() => _ChatKonsultasiPageState();
}

class _ChatKonsultasiPageState extends State<ChatKonsultasiPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final now = DateTime.now();
    final timeStr =
        "${now.hour.toString().padLeft(2, '0')}.${now.minute.toString().padLeft(2, '0')}";

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        time: timeStr,
        isMe: true,
      ));
    });

    _messageController.clear();
    _scrollToBottom();

    // SIMULASI: Dokter Membalas Otomatis setelah 1.5 detik
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text:
            "Halo, selamat pagi. Tentu, saya bantu jelaskan ya. Untuk mengetahui apakah Anda benar-benar mengalami diabetes atau tidak, hasil skrining saja belum cukup.",
            time: timeStr,
            isMe: false,
          ));
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFFE2E7FF),
              child: Icon(Icons.person, size: 24, color: Color(0xFF6679F4)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.doctor.nama,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F4EA),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Online',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _messages.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble,
                          size: 90,
                          color: const Color(0xFF5D83EC).withValues(alpha: 0.9),
                        ),
                        const Positioned(
                          right: 8,
                          bottom: 8,
                          child: Icon(
                            Icons.chat_bubble,
                            size: 60,
                            color: Color(0xFF91B1FF),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Mulai Percakapan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Tulis pesan untuk mulai\nkonsultasi dengan dokter.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return _buildChatBubble(msg);
                },
              ),
            ),

            // Input Chat Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Tulis pesan...',
                          hintStyle:
                          TextStyle(color: Colors.grey, fontSize: 13),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _sendMessage,
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF5D83EC),
                      child: Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Tombol Akhiri Konsultasi
            if (_messages.isNotEmpty)
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: SizedBox(
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF5D83EC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _showDialogAkhiriKonsultasi(context);
                    },
                    child: const Text(
                      'Akhiri Konsultasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    return Align(
      alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: message.isMe ? const Color(0xFF7190F0) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: message.isMe
              ? null
              : Border.all(color: Colors.grey.shade200, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: TextStyle(
                color: message.isMe ? Colors.white : Colors.black87,
                fontSize: 13,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                message.time,
                style: TextStyle(
                  color: message.isMe ? Colors.white70 : Colors.grey,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialogAkhiriKonsultasi(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Akhiri Konsultasi?'),
        content: const Text('Sesi percakapan dengan dokter akan diakhiri.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF5D83EC),
            ),
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              // Pindah ke Halaman Konsultasi Selesai dengan meneruskan namaUser
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => KonsultasiSelesaiPage(
                    doctor: widget.doctor,
                    namaUser: widget.namaUser,
                  ),
                ),
              );
            },
            child: const Text('Ya, Akhiri', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}