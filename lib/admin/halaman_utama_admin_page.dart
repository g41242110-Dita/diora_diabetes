import 'package:flutter/material.dart';

class HalamanUtamaAdminPage extends StatelessWidget {
  const HalamanUtamaAdminPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin Diora'),
        backgroundColor: const Color(0xFF3B54EE),
      ),
      body: const Center(
        child: Text(
          'Selamat Datang di Halaman Utama Admin',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}