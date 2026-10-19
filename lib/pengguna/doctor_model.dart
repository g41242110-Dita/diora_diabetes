class Doctor {
  final String nama;
  final String spesialis;
  final String rating;
  final String ulasan;
  final String statusJam;
  final bool isOnline;
  final String jadwalPraktik;
  final String pasienDitangani;
  final String tentangDokter;

  const Doctor({
    required this.nama,
    required this.spesialis,
    this.rating = '0.0',
    this.ulasan = '0',
    this.statusJam = '',
    this.isOnline = false,
    this.jadwalPraktik = '',
    this.pasienDitangani = '0',
    this.tentangDokter = '',
  });

  /// Konversi dari Map JSON / Firestore ke Object Doctor
  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      nama: map['nama'] ?? '',
      spesialis: map['spesialis'] ?? '',
      rating: map['rating']?.toString() ?? '0.0',
      ulasan: map['ulasan']?.toString() ?? '0',
      statusJam: map['statusJam'] ?? '',
      isOnline: map['isOnline'] ?? false,
      jadwalPraktik: map['jadwalPraktik'] ?? '',
      pasienDitangani: map['pasienDitangani']?.toString() ?? '0',
      tentangDokter: map['tentangDokter'] ?? '',
    );
  }

  /// Konversi dari Object Doctor ke Map JSON
  Map<String, dynamic> toMap() {
    return {
      'nama': nama,
      'spesialis': spesialis,
      'rating': rating,
      'ulasan': ulasan,
      'statusJam': statusJam,
      'isOnline': isOnline,
      'jadwalPraktik': jadwalPraktik,
      'pasienDitangani': pasienDitangani,
      'tentangDokter': tentangDokter,
    };
  }
}

// DAFTAR DATA DOKTER UTAMA
List<Doctor> dummyDoctors = [
  // --- 3 DOKTER ONLINE (DIBAGI 3 SHIFT 24 JAM) ---
  Doctor(
    nama: 'dr. Amanda Putri, Sp. PD',
    spesialis: 'Dokter Spesialis Penyakit Dalam',
    rating: '4.9',
    ulasan: '324 ulasan',
    statusJam: '07.00 - 15.00',
    isOnline: true,
    jadwalPraktik: 'Senin - Jumat, 07.00 - 15.00',
    pasienDitangani: '1152+ Pasien',
    tentangDokter:
    'Berpengalaman dalam menangani penyakit dalam, termasuk diabetes, hipertensi, dan gangguan metabolik.',
  ),
  Doctor(
    nama: 'dr. Asila Salsavea Gunawan, Sp. PD',
    spesialis: 'Dokter Spesialis Penyakit Dalam',
    rating: '4.8',
    ulasan: '210 ulasan',
    statusJam: '15.00 - 23.00',
    isOnline: true,
    jadwalPraktik: 'Senin - Jumat, 15.00 - 23.00',
    pasienDitangani: '890+ Pasien',
    tentangDokter:
    'Fokus pada manajemen diabetes melitus tipe 1 & 2 serta pencegahan komplikasi kronis.',
  ),
  Doctor(
    nama: 'dr. Ryan Ramadhani, Sp. GK',
    spesialis: 'Dokter Spesialis Gizi Klinik',
    rating: '4.9',
    ulasan: '185 ulasan',
    statusJam: '23.00 - 07.00',
    isOnline: true,
    jadwalPraktik: 'Senin - Jumat, 23.00 - 07.00',
    pasienDitangani: '740+ Pasien',
    tentangDokter:
    'Spesialis konsultasi pola makan, diet diabetes, dan pengaturan indeks glikemik harian.',
  ),

  // --- 4 DOKTER OFFLINE ---
  Doctor(
    nama: 'dr. Budi Santoso, Sp. PD',
    spesialis: 'Dokter Spesialis Penyakit Dalam',
    rating: '4.7',
    ulasan: '150 ulasan',
    statusJam: 'Offline',
    isOnline: false,
    jadwalPraktik: 'Sabtu - Minggu, 08.00 - 12.00',
    pasienDitangani: '620+ Pasien',
    tentangDokter:
    'Menangani konsultasi penyakit dalam dan edukasi pemantauan gula darah mandiri.',
  ),
  Doctor(
    nama: 'dr. Sari Dewi, Sp. GK',
    spesialis: 'Dokter Spesialis Gizi Klinik',
    rating: '4.8',
    ulasan: '190 ulasan',
    statusJam: 'Offline',
    isOnline: false,
    jadwalPraktik: 'Sabtu - Minggu, 13.00 - 17.00',
    pasienDitangani: '510+ Pasien',
    tentangDokter:
    'Pakar terapi nutrisi klinis untuk penderita diabetes dengan riwayat komplikasi.',
  ),
  Doctor(
    nama: 'dr. Natashia Luvicia, Sp. PD',
    spesialis: 'Dokter Spesialis Penyakit Dalam',
    rating: '4.9',
    ulasan: '230 ulasan',
    statusJam: 'Offline',
    isOnline: false,
    jadwalPraktik: 'Sabtu - Minggu, 09.00 - 15.00',
    pasienDitangani: '930+ Pasien',
    tentangDokter:
    'Ahli penanganan diabetes tipe 2, sindrom metabolik, dan manajemen gaya hidup sehat.',
  ),
  Doctor(
    nama: 'dr. Rizki Fatur, Sp. PD',
    spesialis: 'Dokter Spesialis Penyakit Dalam',
    rating: '4.6',
    ulasan: '115 ulasan',
    statusJam: 'Offline',
    isOnline: false,
    jadwalPraktik: 'Sabtu - Minggu, 16.00 - 20.00',
    pasienDitangani: '410+ Pasien',
    tentangDokter:
    'Konsultasi kesehatan penyakit dalam, skrining komorbid, dan evaluasi hasil laboratorium.',
  ),
];