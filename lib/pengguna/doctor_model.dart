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
  final String namaShiftHariIni;
  final bool isShiftActiveToday;
  final bool isPenggantiHariIni;
  final String menggantikanDokter;

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
    this.namaShiftHariIni = 'Shift Praktik',
    this.isShiftActiveToday = true,
    this.isPenggantiHariIni = false,
    this.menggantikanDokter = '',
  });

  String get tentangDokter =>
      deskripsi ?? 'Spesialis berpengalaman menangani berbagai kasus medis.';

  int get breakHour {
    if (jamMulai == 7) return 12; // Shift 1: 12.00 - 13.00 WIB
    if (jamMulai == 15) return 18; // Shift 2: 18.00 - 19.00 WIB
    if (jamMulai == 23) return 3; // Shift 3: 03.00 - 04.00 WIB
    return (jamMulai + 4) % 24;
  }

  String get breakTimeRange {
    final int start = breakHour;
    final int end = (start + 1) % 24;
    return '${start.toString().padLeft(2, '0')}.00 - ${end.toString().padLeft(2, '0')}.00 WIB';
  }

  /// Mengenerasikan slot waktu interval 20 menit dengan mengecualikan 1 jam istirahat dokter
  List<String> get availableSlots {
    if (!isShiftActiveToday || (jamMulai == 0 && jamSelesai == 0)) {
      return [];
    }

    final List<String> slots = [];
    final int istirahatJam = breakHour;
    int startMinute = jamMulai * 60;
    int endMinute = jamSelesai * 60;

    if (endMinute <= startMinute) {
      endMinute += 24 * 60;
    }

    for (int current = startMinute; current + 20 <= endMinute; current += 20) {
      final int startH = (current ~/ 60) % 24;

      if (startH == istirahatJam) {
        continue; // Lewati 1 jam istirahat dokter
      }

      final int startM = current % 60;
      final int next = current + 20;
      final int endH = (next ~/ 60) % 24;
      final int endM = next % 60;

      final String startStr =
          '${startH.toString().padLeft(2, '0')}.${startM.toString().padLeft(2, '0')}';
      final String endStr =
          '${endH.toString().padLeft(2, '0')}.${endM.toString().padLeft(2, '0')}';

      slots.add('$startStr - $endStr');
    }
    return slots;
  }

  static String _namaHariSekarang() {
    const hariMap = {
      1: 'Senin',
      2: 'Selasa',
      3: 'Rabu',
      4: 'Kamis',
      5: 'Jumat',
      6: 'Sabtu',
      7: 'Minggu',
    };
    return hariMap[DateTime.now().weekday] ?? 'Senin';
  }

  factory Doctor.fromFirestore(Map<String, dynamic> data, String docId) {
    final String hariIni = _namaHariSekarang();
    final Map<String, dynamic> jadwalShift =
        (data['jadwal_shift'] as Map<String, dynamic>?) ?? {};

    int mulai = int.tryParse(data['jamMulai']?.toString() ?? '') ?? 7;
    int selesai = int.tryParse(data['jamSelesai']?.toString() ?? '') ?? 15;
    String namaShift = 'Shift Praktik';
    bool shiftAktif = data['isOnline'] == true;
    bool isPengganti = false;
    String menggantikan = '';

    if (jadwalShift.isNotEmpty) {
      final shiftHariIni = jadwalShift[hariIni] as Map<String, dynamic>?;
      if (shiftHariIni != null) {
        mulai = (shiftHariIni['jamMulai'] as num?)?.toInt() ?? mulai;
        selesai = (shiftHariIni['jamSelesai'] as num?)?.toInt() ?? selesai;
        namaShift = (shiftHariIni['namaShift'] ?? 'Shift Praktik').toString();
        shiftAktif = shiftHariIni['isActive'] == true;
        isPengganti = shiftHariIni['isPengganti'] == true;
        menggantikan =
            (shiftHariIni['menggantikanDokter'] ?? '').toString();
      } else {
        mulai = 0;
        selesai = 0;
        namaShift = 'Libur Rotasi';
        shiftAktif = false;
      }
    }

    return Doctor(
      id: docId,
      nama: (data['nama'] ?? '').toString(),
      spesialis: (data['spesialis'] ?? '').toString(),
      jamMulai: mulai,
      jamSelesai: selesai,
      isOnline: shiftAktif,
      isBusyInChat: data['isBusyInChat'] == true,
      rating: data['rating']?.toString() ?? '5.0',
      ulasan: data['ulasan']?.toString() ?? '0',
      deskripsi: (data['deskripsi'] ?? data['tentangDokter'])?.toString(),
      namaShiftHariIni: namaShift,
      isShiftActiveToday: shiftAktif,
      isPenggantiHariIni: isPengganti,
      menggantikanDokter: menggantikan,
    );
  }
}