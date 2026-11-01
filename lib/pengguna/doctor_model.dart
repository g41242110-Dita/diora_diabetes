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
    required this.slots,
  });
}