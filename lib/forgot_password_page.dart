import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool emailError = false;

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  void resetPassword() {
    setState(() {
      emailError = emailController.text.trim().isEmpty;
    });

    if (!emailError) {
      // Proses kirim tautan reset password
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tautan reset kata sandi telah dikirim!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Tombol Close (X) di pojok kanan atas
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 10),

              // LOGO APLIKASI
              Center(
                child: Image.asset(
                  'assets/logo.png',
                  height: 130,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 16),

              // JUDUL & SUBJUDUL
              const Text(
                'Lupa Kata Sandi?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Masukkan email yang terdaftar\nuntuk menerima tautan reset kata sandi',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 24),

              // INPUT EMAIL
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                onChanged: (_) {
                  if (emailError) setState(() => emailError = false);
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    size: 20,
                    color: emailError ? Colors.red : Colors.grey.shade600,
                  ),
                  hintText: 'Email',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: emailError ? Colors.red : Colors.grey.shade400,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: emailError ? Colors.red : const Color(0xFF6679F4),
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // TOMBOL KIRIM TAUTAN
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: resetPassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6679F4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text(
                    'Kirim Tautan Reset',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // BOX INFORMASI
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Color(0xFF4F46E5), size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Informasi',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3730A3),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Kami akan mengirimkan tautan untuk mereset kata sandi ke email Anda. Pastikan email yang Anda masukkan aktif dan benar.',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF4338CA),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Divider(color: Color(0xFFE0E0E0), thickness: 1),

              const SizedBox(height: 16),

              // KEMBALI KE LOGIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Kembali ke halaman ',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Masuk',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF558B82),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}