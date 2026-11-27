import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin/admin_dashboard_page.dart';
import 'dokter/dokter_beranda_page.dart';
import 'pengguna/beranda_page.dart';

typedef UserMap = Map<String, dynamic>;

class AuthRouter {
  static int _prioritas(String role) {
    if (role == 'admin') return 3;
    if (role == 'dokter') return 2;
    return 1;
  }

  static Future<UserMap?> ambilDataUser(User user) async {
    final users = FirebaseFirestore.instance.collection('users');
    final Map<String, UserMap> kandidat = {};

    // 1. Berdasarkan UID
    try {
      final doc = await users.doc(user.uid).get();
      if (doc.exists && doc.data() != null) kandidat[doc.id] = doc.data()!;
    } catch (e) {
      debugPrint('Baca dokumen UID gagal: $e');
    }
    final String roleUid =
    kandidat.containsKey(user.uid) ? ambilRole(kandidat[user.uid]!) : '';

    // 2. Berdasarkan email
    try {
      final email = user.email?.trim();
      if (email != null && email.isNotEmpty) {
        for (final e in [email, email.toLowerCase()]) {
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

    String idTerpilih =
    kandidat.containsKey(user.uid) ? user.uid : kandidat.keys.first;
    for (final entry in kandidat.entries) {
      if (_prioritas(ambilRole(entry.value)) >
          _prioritas(ambilRole(kandidat[idTerpilih]!))) {
        idTerpilih = entry.key;
      }
    }
    final UserMap hasil = UserMap.from(kandidat[idTerpilih]!);

    for (final data in kandidat.values) {
      for (final key in [
        'nama',
        'spesialisasi',
        'doctorId',
        'doctor_id',
        'docId',
      ]) {
        final v = (hasil[key] ?? '').toString().trim();
        final lain = (data[key] ?? '').toString().trim();
        if (v.isEmpty && lain.isNotEmpty) hasil[key] = data[key];
      }
    }

    if (idTerpilih != user.uid &&
        _prioritas(ambilRole(hasil)) > _prioritas(roleUid)) {
      try {
        await users.doc(user.uid).set({
          ...hasil,
          'uid': user.uid,
          'email': user.email ?? hasil['email'],
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Self-heal gagal: $e');
      }
    }

    debugPrint(
      'ambilDataUser -> uid: ${user.uid}, role: ${ambilRole(hasil)}, '
          'doctorId: ${ambilDoctorId(hasil)}',
    );
    return hasil;
  }

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
          b.writeln(
            'Dokumen via email: id=${d.id}, role = "${ambilRole(d.data())}"',
          );
        }
      }
    } catch (e) {
      b.writeln('Dokumen via email: DITOLAK Security Rules');
    }
    return b.toString();
  }

  static String ambilRole(UserMap data) {
    return (data['role'] ?? '').toString().trim().toLowerCase();
  }

  static String? ambilDoctorId(UserMap data) {
    final raw = (data['doctorId'] ?? data['doctor_id'] ?? data['docId'])
        ?.toString()
        .trim();
    if (raw == null || raw.isEmpty) return null;
    return raw;
  }

  static Future<Widget?> halamanUntuk(User user) async {
    final data = await ambilDataUser(user);
    if (data == null) return null;

    final String role = ambilRole(data);
    final String nama =
    (data['nama'] ?? user.email?.split('@').first ?? 'Pengguna').toString();

    if (role == 'admin') return const AdminDashboardPage();
    if (role == 'dokter') {
      return DokterBerandaPage(doctorId: ambilDoctorId(data));
    }

    if (role.isEmpty || role == 'pengguna' || role == 'user') {
      return BerandaPage(namaUser: nama);
    }
    return null;
  }

  static Future<bool> arahkan(BuildContext context, User user) async {
    final navigator = Navigator.of(context);
    final halaman = await halamanUntuk(user);

    if (halaman == null) {
      await FirebaseAuth.instance.signOut();
      return false;
    }

    navigator.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => halaman),
          (route) => false,
    );
    return true;
  }
}