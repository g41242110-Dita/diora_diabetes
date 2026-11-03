class Doctor {
  final String id;
  final String nama;
  final String spesialis;
  final int jamMulai;
  final int jamSelesai;
  final bool isOnline;
  final bool isBusyInChat;
  final String rating;
  final String ulasan;
  final String? deskripsi;

  Doctor({
    required this.id,
    required this.nama,
    required this.spesialis,
    required this.jamMulai,
    required this.jamSelesai,
    required this.isOnline,
    required this.isBusyInChat,
    required this.rating,
    required this.ulasan,
    this.deskripsi,
  });

  /// Getter alias agar tidak error di detail_dokter_page.dart
  String get tentangDokter =>
      deskripsi ?? 'Spesialis berpengalaman menangani berbagai kasus medis.';

  /// Mengenerasikan slot waktu interval 20 menit berdasarkan shift dokter
  List<String> get availableSlots {
    List<String> slots = [];
    int startMinute = jamMulai * 60;
    int endMinute = jamSelesai * 60;

    // Shift 3 (23.00 - 07.00) melintasi tengah malam
    if (endMinute <= startMinute) {
      endMinute += 24 * 60;
    }

    for (int current = startMinute; current < endMinute; current += 20) {
      int startH = (current ~/ 60) % 24;
      int startM = current % 60;

      int next = current + 20;
      int endH = (next ~/ 60) % 24;
      int endM = next % 60;

      String startStr =
          "${startH.toString().padLeft(2, '0')}.${startM.toString().padLeft(2, '0')}";
      String endStr =
          "${endH.toString().padLeft(2, '0')}.${endM.toString().padLeft(2, '0')}";

      slots.add("$startStr - $endStr");
    }
    return slots;
  }

  factory Doctor.fromFirestore(Map<String, dynamic> data, String docId) {
    return Doctor(
      id: docId,
      nama: data['nama'] ?? '',
      spesialis: data['spesialis'] ?? '',
      jamMulai: int.tryParse(data['jamMulai']?.toString() ?? '') ?? 7,
      jamSelesai: int.tryParse(data['jamSelesai']?.toString() ?? '') ?? 15,
      isOnline: data['isOnline'] == true,
      isBusyInChat: data['isBusyInChat'] == true,
      rating: data['rating']?.toString() ?? '5.0',
      ulasan: data['ulasan']?.toString() ?? '0',
      deskripsi: data['deskripsi'] ?? data['tentangDokter'],
    );
  }
}