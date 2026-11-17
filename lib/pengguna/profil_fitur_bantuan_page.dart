import 'package:flutter/material.dart';

// ==========================================
// 1. HALAMAN HUBUNGI KAMI
// ==========================================
class HubungiKamiPage extends StatelessWidget {
  const HubungiKamiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          ClipPath(
            clipper: _SubHelpLiquidClipper(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, topPadding, 16, 42),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3B0066),
                    Color(0xFF5B4AF4),
                    Color(0xFF388BFF),
                  ],
                  stops: [0.0, 0.5, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 36),
                        child: Text(
                          'Hubungi Kami',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    'Tim kami siap membantu apabila ada pertanyaan seputar konsultasi.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card Kontak
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        _buildContactRow(
                          icon: Icons.phone_outlined,
                          title: 'Telepon',
                          subtitle: '(021) 5000 1234',
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildContactRow(
                          icon: Icons.chat_outlined,
                          title: 'WhatsApp',
                          subtitle: '0882 8741 7638',
                        ),
                        const Divider(height: 1, color: Color(0xFFF1F5F9)),
                        _buildContactRow(
                          icon: Icons.email_outlined,
                          title: 'Email',
                          subtitle: 'Diorakonsultasi@gmail.com',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Card Informasi Operasional & Alamat
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.access_time_rounded,
                                size: 18,
                                color: Color(0xFF5B4AF4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Jam Operasional',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Senin - Jumat, 08.00 - 17.00 WIB',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEEF2FF),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: Color(0xFF5B4AF4),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'Alamat',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'Jl. Mastrip, Jember 68121',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
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
        ],
      ),
    );
  }

  Widget _buildContactRow({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF2FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: const Color(0xFF5B4AF4)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
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

// ==========================================
// 2. HALAMAN KRITIK DAN SARAN
// ==========================================
class KritikDanSaranPage extends StatefulWidget {
  const KritikDanSaranPage({super.key});

  @override
  State<KritikDanSaranPage> createState() => _KritikDanSaranPageState();
}

class _KritikDanSaranPageState extends State<KritikDanSaranPage> {
  int _selectedRating = 0;
  final TextEditingController _kategoriController = TextEditingController();
  final TextEditingController _pesanController = TextEditingController();
  bool _showSuccessAlert = false;

  @override
  void dispose() {
    _kategoriController.dispose();
    _pesanController.dispose();
    super.dispose();
  }

  void _kirimMasukkan() {
    setState(() {
      _showSuccessAlert = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 16;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          ClipPath(
            clipper: _SubHelpLiquidClipper(),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(16, topPadding, 16, 42),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF3B0066),
                    Color(0xFF5B4AF4),
                    Color(0xFF388BFF),
                  ],
                  stops: [0.0, 0.5, 1.0],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 40,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 36),
                        child: Text(
                          'Kritik dan Saran',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_showSuccessAlert)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0), width: 1),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF16A34A), size: 18),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Kritik dan Saran Berhasil Dikirim!',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showSuccessAlert = false;
                        });
                      },
                      child: const Icon(Icons.close_rounded,
                          size: 16, color: Color(0xFF166534)),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    'Beri masukkan kepada kami agar layanan terus membaik.',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF64748B),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Card Rating Bintang
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFF1F5F9)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Seberapa puas Anda?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: List.generate(5, (index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedRating = index + 1;
                                });
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Icon(
                                  index < _selectedRating
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 30,
                                  color: index < _selectedRating
                                      ? const Color(0xFFF59E0B)
                                      : const Color(0xFFCBD5E1),
                                ),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Input Kategori
                  const Text(
                    'Kategori',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _kategoriController,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Misal: Saran Fitur / Kendala',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        isDense: true,
                        contentPadding:
                        EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Input Pesan Anda
                  const Text(
                    'Pesan Anda',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      controller: _pesanController,
                      maxLines: null,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Tulis kritik atau saran Anda di sini...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        contentPadding: EdgeInsets.all(14),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(
                16, 10, 16, MediaQuery.of(context).padding.bottom + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5B4AF4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                onPressed: _kirimMasukkan,
                child: const Text(
                  'Kirim Masukkan',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubHelpLiquidClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 35);

    var firstControlPoint = Offset(size.width * 0.28, size.height);
    var firstEndPoint = Offset(size.width * 0.55, size.height - 25);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    var secondControlPoint = Offset(size.width * 0.8, size.height - 50);
    var secondEndPoint = Offset(size.width, size.height - 18);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}