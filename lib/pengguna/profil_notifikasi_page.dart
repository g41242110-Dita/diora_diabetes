import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ==========================================
// 1. HALAMAN NOTIFIKASI APLIKASI (PROFIL 10)
// ==========================================
class NotifikasiAplikasiPage extends StatefulWidget {
  const NotifikasiAplikasiPage({super.key});

  @override
  State<NotifikasiAplikasiPage> createState() => _NotifikasiAplikasiPageState();
}

class _NotifikasiAplikasiPageState extends State<NotifikasiAplikasiPage> {
  bool _aktifkanNotifikasi = true;
  bool _tipsDanArtikel = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Mengambil status pengaturan dari Firestore saat halaman dibuka
  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          setState(() {
            _aktifkanNotifikasi = data['aktifkan_notifikasi'] ?? true;
            _tipsDanArtikel = data['tips_dan_artikel'] ?? false;
          });
        }
      } catch (e) {
        debugPrint('Error loading settings: $e');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Menyimpan perubahan status ke Firestore
  Future<void> _updateNotificationSetting(String field, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          field: value,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error updating setting: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6679F4)))
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const Text(
                'Notifikasi Aplikasi',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.black87, thickness: 1),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Aktifkan Notifikasi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Terima semua notifikasi dari aplikasi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _aktifkanNotifikasi,
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF6679F4),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFCBD5E1),
                            onChanged: (value) async {
                              setState(() {
                                _aktifkanNotifikasi = value;
                              });
                              await _updateNotificationSetting('aktifkan_notifikasi', value);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Tips & Artikel',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Rekomendasi perawatan dan artikel terbaru',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _tipsDanArtikel,
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF6679F4),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFCBD5E1),
                            onChanged: (value) async {
                              setState(() {
                                _tipsDanArtikel = value;
                              });
                              await _updateNotificationSetting('tips_dan_artikel', value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. HALAMAN NOTIFIKASI EMAIL (PROFIL 11)
// ==========================================
class NotifikasiEmailPage extends StatefulWidget {
  const NotifikasiEmailPage({super.key});

  @override
  State<NotifikasiEmailPage> createState() => _NotifikasiEmailPageState();
}

class _NotifikasiEmailPageState extends State<NotifikasiEmailPage> {
  bool _aktifkanNotifikasiEmail = true;
  bool _hasilSkreening = true;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  // Mengambil status pengaturan email dari Firestore
  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          setState(() {
            _aktifkanNotifikasiEmail = data['aktifkan_notifikasi_email'] ?? true;
            _hasilSkreening = data['hasil_skreening_email'] ?? true;
          });
        }
      } catch (e) {
        debugPrint('Error loading email settings: $e');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  // Menyimpan perubahan status email ke Firestore
  Future<void> _updateNotificationSetting(String field, bool value) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          field: value,
        }, SetOptions(merge: true));
      } catch (e) {
        debugPrint('Error updating email setting: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF6679F4)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF6679F4)))
          : SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const Text(
                'Notifikasi Email',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              const Divider(color: Colors.black87, thickness: 1),
              const SizedBox(height: 24),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Aktifkan Notifikasi Email',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Terima semua pemberitahuan melalui Email',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _aktifkanNotifikasiEmail,
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF6679F4),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFCBD5E1),
                            onChanged: (value) async {
                              setState(() {
                                _aktifkanNotifikasiEmail = value;
                              });
                              await _updateNotificationSetting('aktifkan_notifikasi_email', value);
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Hasil Skreening',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Hasil skreening di kirim melalui Email',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Switch(
                            value: _hasilSkreening,
                            activeThumbColor: Colors.white,
                            activeTrackColor: const Color(0xFF6679F4),
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: const Color(0xFFCBD5E1),
                            onChanged: (value) async {
                              setState(() {
                                _hasilSkreening = value;
                              });
                              await _updateNotificationSetting('hasil_skreening_email', value);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}