import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UbahPasswordAdminPage extends StatefulWidget {
  const UbahPasswordAdminPage({super.key});

  @override
  State<UbahPasswordAdminPage> createState() => _UbahPasswordAdminPageState();
}

class _UbahPasswordAdminPageState extends State<UbahPasswordAdminPage> {
  final TextEditingController _oldPassController = TextEditingController();
  final TextEditingController _newPassController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  bool _obscureOld = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _oldPassController.dispose();
    _newPassController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _simpanPassword() async {
    final String oldPass = _oldPassController.text.trim();
    final String newPass = _newPassController.text.trim();
    final String confirmPass = _confirmPassController.text.trim();

    if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      _showSnackBar('Semua kolom wajib diisi!', isError: true);
      return;
    }

    if (newPass.length < 6) {
      _showSnackBar('Password baru minimal 6 karakter!', isError: true);
      return;
    }

    if (newPass != confirmPass) {
      _showSnackBar(
        'Konfirmasi password baru tidak sesuai!',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null && user.email != null) {
        final AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPass,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPass);

        if (mounted) {
          _showSnackBar('Password administrator berhasil diperbarui!');
          Navigator.pop(context);
        }
      }
    } on FirebaseAuthException catch (e) {
      String pesanError = 'Gagal mengganti password.';
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        pesanError = 'Password saat ini salah!';
      } else if (e.code == 'weak-password') {
        pesanError = 'Password baru terlalu lemah.';
      }
      if (mounted) {
        _showSnackBar(pesanError, isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Terjadi kesalahan: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String pesan, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pesan),
        backgroundColor:
        isError ? const Color(0xFFE11D48) : const Color(0xFF0D9488),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F6FC),
      body: Column(
        children: [
          _buildLiquidHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF4F46E5),
                          size: 22,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Gunakan kombinasi minimal 6 karakter yang kuat untuk menjaga keamanan akun administrator.',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: Color(0xFF3730A3),
                              height: 1.35,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color:
                          const Color(0xFF0F172A).withValues(alpha: 0.035),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPasswordField(
                          label: 'Password Saat Ini',
                          hint: 'Masukkan password lama',
                          controller: _oldPassController,
                          obscureText: _obscureOld,
                          onToggle: () {
                            setState(() {
                              _obscureOld = !_obscureOld;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          label: 'Password Baru',
                          hint: 'Minimal 6 karakter',
                          controller: _newPassController,
                          obscureText: _obscureNew,
                          onToggle: () {
                            setState(() {
                              _obscureNew = !_obscureNew;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildPasswordField(
                          label: 'Konfirmasi Password Baru',
                          hint: 'Ulangi password baru',
                          controller: _confirmPassController,
                          obscureText: _obscureConfirm,
                          onToggle: () {
                            setState(() {
                              _obscureConfirm = !_obscureConfirm;
                            });
                          },
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
      bottomNavigationBar: _buildBottomActionArea(),
    );
  }

  Widget _buildBottomActionArea() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            gradient: const LinearGradient(
              colors: [
                Color(0xFF4338CA),
                Color(0xFF4F46E5),
                Color(0xFF3B82F6),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            shadows: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            shape: const StadiumBorder(),
            child: InkWell(
              customBorder: const StadiumBorder(),
              onTap: _isLoading ? null : _simpanPassword,
              child: Center(
                child: _isLoading
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.4,
                  ),
                )
                    : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.lock_reset_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Simpan Password Baru',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiquidHeader(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + 14;

    return Stack(
      children: [
        ClipPath(
          clipper: _UbahPassLiquidHeaderClipper(offsetY: 10),
          child: Container(
            width: double.infinity,
            height: topPadding + 84,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4F46E5).withValues(alpha: 0.22),
                  const Color(0xFF38BDF8).withValues(alpha: 0.22),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        ClipPath(
          clipper: _UbahPassLiquidHeaderClipper(offsetY: 0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, topPadding, 16, 32),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF4338CA),
                  Color(0xFF4F46E5),
                  Color(0xFF3B82F6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: -35,
                  top: -35,
                  child: IgnorePointer(
                    child: Container(
                      width: 145,
                      height: 145,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.24),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: -25,
                  bottom: -20,
                  child: IgnorePointer(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF38BDF8).withValues(alpha: 0.30),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: Stack(
                    children: [
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 36),
                          child: Text(
                            'Ubah Password',
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
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          tooltip: 'Kembali',
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF0F172A),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 13.5,
              fontWeight: FontWeight.w400,
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: const Icon(
              Icons.lock_outline_rounded,
              color: Color(0xFF4F46E5),
              size: 20,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF64748B),
                size: 20,
              ),
              onPressed: onToggle,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: Color(0xFF4F46E5),
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UbahPassLiquidHeaderClipper extends CustomClipper<Path> {
  final double offsetY;

  _UbahPassLiquidHeaderClipper({this.offsetY = 0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final h = size.height - offsetY;

    path.lineTo(0, h - 22);

    path.quadraticBezierTo(
      size.width * 0.25,
      h + 6,
      size.width * 0.52,
      h - 14,
    );

    path.quadraticBezierTo(
      size.width * 0.80,
      h - 32,
      size.width,
      h - 10,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _UbahPassLiquidHeaderClipper oldClipper) {
    return oldClipper.offsetY != offsetY;
  }
}