import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../pengguna/onboarding_page.dart';

/// Dialog konfirmasi + logout admin. Dipakai di dashboard & halaman profil.
Future<void> logoutAdmin(BuildContext context) async {
  final navigator = Navigator.of(context);
  final messenger = ScaffoldMessenger.of(context);

  final bool? konfirmasi = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Konfirmasi Logout',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: const Text(
        'Apakah Anda yakin ingin keluar dari akun Admin Diora?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: const Text('Batal', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.redAccent,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(dialogContext, true),
          child: const Text('Logout'),
        ),
      ],
    ),
  );

  if (konfirmasi != true) return;

  try {
    await FirebaseAuth.instance.signOut();
    navigator.pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const OnboardingPage()),
          (route) => false,
    );
  } catch (e) {
    messenger.showSnackBar(
      SnackBar(content: Text('Gagal logout: $e'), backgroundColor: Colors.red),
    );
  }
}