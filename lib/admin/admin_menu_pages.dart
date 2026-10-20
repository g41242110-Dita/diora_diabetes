import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Daftar semua pengguna (role selain admin) dari Firestore.
class AdminPenggunaPage extends StatelessWidget {
  const AdminPenggunaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Gagal memuat data pengguna.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data!.docs.where((d) {
          final role =
          (d.data()['role'] ?? 'pengguna').toString().trim().toLowerCase();
          return role != 'admin';
        }).toList();

        if (docs.isEmpty) {
          return const Center(child: Text('Belum ada pengguna.'));
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final data = docs[i].data();
            final nama = (data['nama'] ?? '-').toString();
            final email = (data['email'] ?? '-').toString();

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.black12),
              ),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFDCE4FF),
                  child: Icon(Icons.person_rounded, color: Color(0xFF4C63E6)),
                ),
                title: Text(nama,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(email),
              ),
            );
          },
        );
      },
    );
  }
}

/// Halaman sementara untuk menu yang belum dibuat.
class AdminPlaceholderPage extends StatelessWidget {
  final IconData icon;
  final String nama;

  const AdminPlaceholderPage({
    super.key,
    required this.icon,
    required this.nama,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 72, color: const Color(0xFF5B71F5)),
          const SizedBox(height: 12),
          Text(nama,
              style:
              const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          const Text('Halaman ini belum dibuat.',
              style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}