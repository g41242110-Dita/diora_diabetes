class ChatMessage {
  final String text;
  final String time;
  final bool isMe; // true jika dikirim oleh Pasien, false jika dikirim oleh Dokter

  ChatMessage({
    required this.text,
    required this.time,
    required this.isMe,
  });
}