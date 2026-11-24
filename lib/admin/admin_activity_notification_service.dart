import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminActivityNotificationService {
  AdminActivityNotificationService._();
  static final AdminActivityNotificationService instance =
  AdminActivityNotificationService._();

  static const String _keyMasterNotif = 'admin_aktifkan_notifikasi';
  static const String _keyUserActivityNotif = 'admin_notifikasi_aktivitas_user';
  static const String _keyKnownUserIds = 'admin_known_user_ids';
  static const String _keyKnownScreeningIds = 'admin_known_screening_ids';

  static const String _channelId = 'diora_admin_activity_channel';
  static const String _channelName = 'Aktivitas Pengguna Admin';
  static const String _channelDescription =
      'Notifikasi saat ada pendaftaran atau skrining baru di Diora';

  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  StreamSubscription<QuerySnapshot>? _usersSub;
  StreamSubscription<QuerySnapshot>? _screeningsSub;

  bool _isLocalNotifInitialized = false;
  bool _aktifkanNotifikasi = true;
  bool _notifikasiAktivitasUser = true;

  Set<String> _knownUserIds = {};
  Set<String> _knownScreeningIds = {};
  bool _hasLoadedKnownUsers = false;
  bool _hasLoadedKnownScreenings = false;

  int _notificationIdCounter = 1000;

  bool get aktifkanNotifikasi => _aktifkanNotifikasi;
  bool get notifikasiAktivitasUser => _notifikasiAktivitasUser;

  Future<void> _initLocalNotifications() async {
    if (_isLocalNotifInitialized) return;

    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _localNotifications.initialize(initSettings);

    final androidPlugin =
    _localNotifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );
    await androidPlugin?.createNotificationChannel(channel);

    _isLocalNotifInitialized = true;
  }

  Future<void> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _aktifkanNotifikasi = prefs.getBool(_keyMasterNotif) ?? true;
    _notifikasiAktivitasUser = prefs.getBool(_keyUserActivityNotif) ?? true;

    final savedUsers = prefs.getStringList(_keyKnownUserIds);
    if (savedUsers != null) {
      _knownUserIds = savedUsers.toSet();
      _hasLoadedKnownUsers = true;
    }

    final savedScreenings = prefs.getStringList(_keyKnownScreeningIds);
    if (savedScreenings != null) {
      _knownScreeningIds = savedScreenings.toSet();
      _hasLoadedKnownScreenings = true;
    }
  }

  Future<void> _saveKnownIds() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_keyKnownUserIds, _knownUserIds.toList());
    await prefs.setStringList(
        _keyKnownScreeningIds, _knownScreeningIds.toList());
  }

  Future<void> setPreferences({
    required bool aktifkanNotifikasi,
    required bool notifikasiAktivitasUser,
  }) async {
    _aktifkanNotifikasi = aktifkanNotifikasi;
    _notifikasiAktivitasUser = notifikasiAktivitasUser;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMasterNotif, aktifkanNotifikasi);
    await prefs.setBool(_keyUserActivityNotif, notifikasiAktivitasUser);
  }

  void attachContext(BuildContext context) {}

  void startListening() async {
    await _initLocalNotifications();
    await loadPreferences();

    _usersSub ??= FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .listen((snapshot) async {
      if (!_hasLoadedKnownUsers) {
        _knownUserIds = snapshot.docs.map((d) => d.id).toSet();
        _hasLoadedKnownUsers = true;
        await _saveKnownIds();
        return;
      }

      bool hasNew = false;
      for (final doc in snapshot.docs) {
        if (_knownUserIds.contains(doc.id)) continue;

        _knownUserIds.add(doc.id);
        hasNew = true;

        if (!_aktifkanNotifikasi || !_notifikasiAktivitasUser) continue;

        final data = doc.data() as Map<String, dynamic>? ?? {};
        final role =
        (data['role'] ?? 'pengguna').toString().trim().toLowerCase();
        if (role == 'admin') continue;

        final nama = (data['nama'] ?? data['name'] ?? '').toString().trim();
        final email = (data['email'] ?? '').toString().trim();
        final displayUser = nama.isNotEmpty
            ? nama
            : (email.contains('@') ? email.split('@').first : 'Pengguna baru');

        await _showSystemNotification(
          title: 'Pendaftaran Baru',
          body: '$displayUser baru saja mendaftar di aplikasi Diora.',
        );
      }

      if (hasNew) {
        await _saveKnownIds();
      }
    });

    _screeningsSub ??= FirebaseFirestore.instance
        .collection('screening_results')
        .snapshots()
        .listen((snapshot) async {
      if (!_hasLoadedKnownScreenings) {
        _knownScreeningIds = snapshot.docs.map((d) => d.id).toSet();
        _hasLoadedKnownScreenings = true;
        await _saveKnownIds();
        return;
      }

      bool hasNew = false;
      for (final doc in snapshot.docs) {
        if (_knownScreeningIds.contains(doc.id)) continue;

        _knownScreeningIds.add(doc.id);
        hasNew = true;

        if (!_aktifkanNotifikasi || !_notifikasiAktivitasUser) continue;

        final data = doc.data() as Map<String, dynamic>? ?? {};
        final nama = (data['nama'] ??
            data['userName'] ??
            data['patientName'] ??
            data['name'] ??
            '')
            .toString()
            .trim();
        final email =
        (data['email'] ?? data['userEmail'] ?? '').toString().trim();
        final displayUser = nama.isNotEmpty
            ? nama
            : (email.contains('@') ? email.split('@').first : 'Pengguna');

        final hasil =
        (data['hasilPrediksi'] ?? data['status'] ?? data['hasil'] ?? '')
            .toString()
            .trim();

        final statusText = hasil.isNotEmpty ? ' ($hasil)' : '';

        await _showSystemNotification(
          title: 'Skrining Diabetes Baru',
          body: '$displayUser telah menyelesaikan skrining$statusText.',
        );
      }

      if (hasNew) {
        await _saveKnownIds();
      }
    });
  }

  Future<void> _showSystemNotification({
    required String title,
    required String body,
  }) async {
    await _initLocalNotifications();

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'Notifikasi Admin Diora',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );

    _notificationIdCounter++;
    await _localNotifications.show(
      _notificationIdCounter,
      title,
      body,
      details,
    );
  }

  void dispose() {
    _usersSub?.cancel();
    _screeningsSub?.cancel();
    _usersSub = null;
    _screeningsSub = null;
  }
}