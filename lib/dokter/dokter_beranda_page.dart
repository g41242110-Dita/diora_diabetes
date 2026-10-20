import 'package:flutter/material.dart';

import 'dokter_profil_page.dart';

/// Halaman utama Dokter: berisi bottom navigation + 4 tab.
class DokterBerandaPage extends StatefulWidget {
  const DokterBerandaPage({super.key});

  @override
  State<DokterBerandaPage> createState() => _DokterBerandaPageState();
}

class _DokterBerandaPageState extends State<DokterBerandaPage> {
  int _currentIndex = 0;

  final List<IconData> _icons = const [
    Icons.home_rounded,
    Icons.groups_rounded,
    Icons.chat_rounded,
    Icons.person_rounded,
  ];

  final List<String> _labels = const [
    'Beranda',
    'Pasien',
    'Konsultasi',
    'Profil',
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
        } else {
          await logoutDokter(context);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: IndexedStack(
          index: _currentIndex,
          children: const [
            _BerandaTab(),
            _PlaceholderTab(
              judul: 'Daftar Pasien',
              ikon: Icons.groups_rounded,
              keterangan: 'Daftar pasien yang Anda tangani akan tampil di sini.',
            ),
            _PlaceholderTab(
              judul: 'Konsultasi',
              ikon: Icons.chat_rounded,
              keterangan: 'Permintaan konsultasi dari pasien akan tampil di sini.',
            ),
            DokterProfilPage(),
          ],
        ),
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 65,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFF8CA0FF), width: 1.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_icons.length, (i) {
          final selected = _currentIndex == i;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _currentIndex = i),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _icons[i],
                  size: 26,
                  color: selected
                      ? const Color(0xFF5B71F5)
                      : const Color(0xFF5B71F5).withValues(alpha: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  _labels[i],
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? const Color(0xFF5B71F5)
                        : const Color(0xFF5B71F5).withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// ============================================================
// TAB BERANDA
// ============================================================
class _BerandaTab extends StatelessWidget {
  const _BerandaTab();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(),
            const SizedBox(height: 20),
            _statGrid(),
            const SizedBox(height: 20),
            _konsultasiCard(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return FutureBuilder<Map<String, dynamic>?>(
      future: ambilDataDokter(),
      builder: (context, snapshot) {
        final nama = (snapshot.data?['nama'] ?? '').toString();
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFDCE4FF),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nama.isEmpty ? 'Hallo, Dokter 👋' : 'Hallo, $nama 👋',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Berikut ringkasan pasien dan konsultasi Anda hari ini.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.medical_information_rounded,
                  size: 64, color: Color(0xFF5B71F5)),
            ],
          ),
        );
      },
    );
  }

  Widget _statGrid() {
    // Data masih contoh (dummy). Ganti dengan query Firestore nanti.
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.groups_rounded,
                label: 'Total Pasien',
                value: '124',
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _statCard(
                icon: Icons.chat_rounded,
                label: 'Konsultasi Baru',
                value: '8',
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _statCard(
                icon: Icons.error_rounded,
                label: 'Skrining Positif',
                value: '19',
                danger: true,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _statCard(
                icon: Icons.check_circle_rounded,
                label: 'Selesai Hari Ini',
                value: '5',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required IconData icon,
    required String label,
    required String value,
    bool danger = false,
  }) {
    final Color warna = danger ? const Color(0xFFFF5252) : const Color(0xFF4C63E6);
    final Color bg = danger ? const Color(0xFFFFE5E5) : const Color(0xFFE2E8FF);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
            child: Icon(icon, color: warna, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _konsultasiCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.chat_rounded,
                    color: Color(0xFF4C63E6), size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Konsultasi Terbaru',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _item('Siti Aisyah', 'Menanyakan hasil skrining diet',
              'Hari ini\n14.32 WIB', true),
          const Divider(height: 20, thickness: 0.5),
          _item('Rina Marlina', 'Konsultasi pola makan',
              'Hari ini\n10.56 WIB', true),
          const Divider(height: 20, thickness: 0.5),
          _item('Bimo Setiawan', 'Konsultasi gula darah',
              'Hari ini\n08.13 WIB', false),
        ],
      ),
    );
  }

  Widget _item(String nama, String aksi, String waktu, bool female) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFDCE4FF),
          child: Icon(
            female ? Icons.face_3_rounded : Icons.face_rounded,
            color: const Color(0xFF4C63E6),
            size: 26,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nama,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                aksi,
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
        ),
        Text(
          waktu,
          textAlign: TextAlign.end,
          style: const TextStyle(fontSize: 10, color: Colors.black45, height: 1.2),
        ),
      ],
    );
  }
}

// ============================================================
// TAB PLACEHOLDER (Pasien & Konsultasi) - isi nanti
// ============================================================
class _PlaceholderTab extends StatelessWidget {
  final String judul;
  final IconData ikon;
  final String keterangan;

  const _PlaceholderTab({
    required this.judul,
    required this.ikon,
    required this.keterangan,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(ikon, size: 80, color: const Color(0xFF5B71F5)),
              const SizedBox(height: 16),
              Text(
                judul,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                keterangan,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}