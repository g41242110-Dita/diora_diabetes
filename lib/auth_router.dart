import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin/admin_dashboard_page.dart';
import 'dokter/dokter_beranda_page.dart';
import 'pengguna/beranda_page.dart';

/// Satu-satunya tempat yang menentukan halaman tujuan berdasarkan role.
/// Dipakai oleh main.dart, login pengguna, DAN login admin.
class AuthRouter {
  /// Urutan hak akses role. Makin besar = makin tinggi.
  /// admin > dokter > pengguna (termasuk role kosong / 'user').
  static int _prioritas(String role) {
    if (role == 'admin') return 3;
    if (role == 'dokter') return 2;
    return 1;
  }

  /// Ambil data akun dari koleksi `users`.
  ///
  /// Dokumen dicari lewat UID DAN lewat email, lalu dipakai dokumen dengan
  /// role tertinggi (admin > dokter > pengguna).
  ///
  /// SELF-HEAL: kalau dokumen role tinggi ditemukan lewat email (ID-nya bukan
  /// UID, mis. dibuat manual dengan ID acak), datanya otomatis disalin ke
  /// dokumen ber-ID UID. Jadi login berikutnya tidak lagi bergantung pada
  /// pencarian email, dan role tidak "kembali" jadi pengguna.
  static Future<Map<String, dynamic>?> ambilDataUser(User user) async {
    final users = FirebaseFirestore.instance.collection('users');
    final Map<String, Map<String, dynamic>> kandidat = {}; // id -> data

    // 1. Berdasarkan UID
    try {
      final doc = await users.doc(user.uid).get();
      if (doc.exists && doc.data() != null) kandidat[doc.id] = doc.data()!;
    } catch (e) {
      debugPrint('Baca dokumen UID gagal: $e');
    }
    final String roleUid =
    kandidat.containsKey(user.uid) ? ambilRole(kandidat[user.uid]!) : '';

    // 2. Berdasarkan email (bisa ditolak Security Rules)
    try {
      final email = user.email?.trim();
      if (email != null && email.isNotEmpty) {
        for (final e in <String>{email, email.toLowerCase()}) {
          final query = await users.where('email', isEqualTo: e).get();
          for (final d in query.docs) {
            kandidat[d.id] = d.data();
          }
        }
      }
    } catch (e) {
      debugPrint('Pencarian akun lewat email dilewati: $e');
    }

    if (kandidat.isEmpty) return null;

    // Pilih dokumen dengan role tertinggi (seri -> dokumen UID didahulukan).
    String idTerpilih = kandidat.containsKey(user.uid)
        ? user.uid
        : kandidat.keys.first;
    for (final entry in kandidat.entries) {
      if (_prioritas(ambilRole(entry.value)) >
          _prioritas(ambilRole(kandidat[idTerpilih]!))) {
        idTerpilih = entry.key;
      }
    }
    final Map<String, dynamic> hasil =
    Map<String, dynamic>.from(kandidat[idTerpilih]!);

    // Lengkapi field kosong dari dokumen lain.
    for (final data in kandidat.values) {
      for (final key in ['nama', 'spesialisasi']) {
        final v = (hasil[key] ?? '').toString().trim();
        final lain = (data[key] ?? '').toString().trim();
        if (v.isEmpty && lain.isNotEmpty) hasil[key] = data[key];
      }
    }

    // SELF-HEAL: salin ke dokumen ber-ID UID bila role-nya lebih tinggi.
    if (idTerpilih != user.uid &&
        _prioritas(ambilRole(hasil)) > _prioritas(roleUid)) {
      try {
        await users.doc(user.uid).set({
          ...hasil,
          'uid': user.uid,
          'email': user.email ?? hasil['email'],
        }, SetOptions(merge: true));
        debugPrint('Self-heal: dokumen UID diperbarui ke role '
            '"${ambilRole(hasil)}"');
      } catch (e) {
        debugPrint('Self-heal gagal (Rules menolak tulis): $e');
      }
    }

    debugPrint('ambilDataUser -> uid: ${user.uid}, email: ${user.email}, '
        'jumlah dokumen: ${kandidat.length}, role dipakai: ${ambilRole(hasil)}');
    return hasil;
  }

  /// Teks diagnosa untuk ditampilkan di layar: menunjukkan dokumen mana yang
  /// terbaca dan role-nya, jadi tidak perlu membuka log.
  static Future<String> diagnosa(User user) async {
    final users = FirebaseFirestore.instance.collection('users');
    final b = StringBuffer();
    b.writeln('UID: ${user.uid}');
    b.writeln('Email: ${user.email}');

    try {
      final doc = await users.doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        b.writeln('Dokumen UID: ADA, role = "${ambilRole(doc.data()!)}"');
      } else {
        b.writeln('Dokumen UID: TIDAK ADA');
      }
    } catch (e) {
      b.writeln('Dokumen UID: DITOLAK Rules ($e)');
    }

    try {
      final q = await users.where('email', isEqualTo: user.email).get();
      if (q.docs.isEmpty) {
        b.writeln('Dokumen via email: tidak ada');
      } else {
        for (final d in q.docs) {
          b.writeln('Dokumen via email: id=${d.id}, role = "${ambilRole(d.data())}"');
        }
      }
    } catch (e) {
      b.writeln('Dokumen via email: DITOLAK Security Rules');
    }
    return b.toString();
  }

  static String ambilRole(Map<String, dynamic> data) {
    return (data['role'] ?? '').toString().trim().toLowerCase();
  }

  /// Mengembalikan halaman sesuai role, atau null jika
  /// dokumen tidak ada / role tidak dikenal.
  static Future<Widget?> halamanUntuk(User user) async {
    final data = await ambilDataUser(user);
    if (data == null) return null;

    final String role = ambilRole(data);
    final String nama =
    (data['nama'] ?? user.email?.split('@').first ?? 'Pengguna')
        .toString();

    debugPrint('AuthRouter -> uid: ${user.uid}, email: ${user.email}, role: $role');

    if (role == 'admin') return const AdminDashboardPage();
    if (role == 'dokter') return const DokterBerandaPage();

    // Dokumen lama tanpa field role dianggap pengguna biasa.
    if (role.isEmpty || role == 'pengguna' || role == 'user') {
      return BerandaPage(namaUser: nama);
    }
    return null;
  }

  /// Pindah ke halaman sesuai role. Return false jika gagal (otomatis signOut).
  static Future<bool> arahkan(BuildContext context, User user) async {
    final navigator = Navigator.of(context);
    final halaman = await halamanUntuk(user);

    if (halaman == null) {
      await FirebaseAuth.instance.signOut();
      return false;
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => halaman),
          (route) => false,
    );
    return true;
  }
}