class TimeSlot {
  final String id;
  final String timeText;
  final int startHour;
  final int startMinute;
  final bool isBooked;

  TimeSlot({
    required this.id,
    required this.timeText,
    required this.startHour,
    required this.startMinute,
    this.isBooked = false,
  });

  // Konversi dari JSON / Firestore Map
  factory TimeSlot.fromMap(Map<String, dynamic> map, String docId) {
    return TimeSlot(
      id: docId,
      timeText: map['timeText'] ?? '',
      startHour: map['startHour'] ?? 0,
      startMinute: map['startMinute'] ?? 0,
      isBooked: map['isBooked'] ?? false,
    );
  }

  // Konversi ke Map untuk disimpan ke Firestore
  Map<String, dynamic> toMap() {
    return {
      'timeText': timeText,
      'startHour': startHour,
      'startMinute': startMinute,
      'isBooked': isBooked,
    };
  }
}

class Doctor {
  final String id;
  final String nama;
  final String spesialis;
  final String rating;
  final String ulasan;
  final bool isOnline;
  final bool isBusyInChat;
  final String tentangDokter;
  final int jamMulai;
  final int jamSelesai;
  final List<String> availableSlots;
  final List<TimeSlot> slots;

  Doctor({
    required this.id,
    required this.nama,
    required this.spesialis,
    required this.rating,
    required this.ulasan,
    required this.isOnline,
    this.isBusyInChat = false,
    required this.tentangDokter,
    this.jamMulai = 7,
    this.jamSelesai = 15,
    this.availableSlots = const [
      '07.00 - 07.30',
      '07.30 - 08.00',
      '08.00 - 08.30',
      '08.30 - 09.00',
      '13.00 - 13.30',
      '13.30 - 14.00',
    ],
    this.slots = const [],
  });

  // Factory untuk membuat objek Doctor langsung dari dokumen Firestore
  factory Doctor.fromFirestore(Map<String, dynamic> data, String docId) {
    var rawSlots = data['slots'] as List<dynamic>? ?? [];
    List<TimeSlot> parsedSlots = rawSlots.map((s) {
      if (s is Map<String, dynamic>) {
        return TimeSlot.fromMap(s, s['id'] ?? '');
      }
      return TimeSlot(id: '', timeText: '', startHour: 0, startMinute: 0);
    }).toList();

    return Doctor(
      id: docId,
      nama: data['nama'] ?? data['name'] ?? '',
      spesialis: data['spesialis'] ?? data['specialist'] ?? '',
      rating: data['rating']?.toString() ?? '5.0',
      ulasan: data['ulasan']?.toString() ?? data['reviews']?.toString() ?? '0',
      isOnline: data['isOnline'] ?? false,
      isBusyInChat: data['isBusyInChat'] ?? false,
      tentangDokter: data['tentangDokter'] ?? '',
      jamMulai: data['jamMulai'] ?? 7,
      jamSelesai: data['jamSelesai'] ?? 15,
      availableSlots: List<String>.from(data['availableSlots'] ?? []),
      slots: parsedSlots,
    );
  }

  // Konversi dari Doctor ke Map untuk keperluan Upload / Seeder ke Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'spesialis': spesialis,
      'rating': rating,
      'ulasan': ulasan,
      'isOnline': isOnline,
      'isBusyInChat': isBusyInChat,
      'tentangDokter': tentangDokter,
      'jamMulai': jamMulai,
      'jamSelesai': jamSelesai,
      'availableSlots': availableSlots,
      'slots': slots.map((s) => s.toMap()).toList(),
    };
  }
}