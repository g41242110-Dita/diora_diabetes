import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  /// Inisialisasi notifikasi (panggil sekali di main.dart atau initState)
  Future<void> initNotification() async {
    tz_data.initializeTimeZones();

    // Set zona waktu default ke WIB (Asia/Jakarta)
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));
    } catch (_) {}

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Minta izin notifikasi & alarm persis di Android 13+
    final androidImplementation =
    _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (androidImplementation != null) {
      await androidImplementation.requestNotificationsPermission();
      await androidImplementation.requestExactAlarmsPermission();
    }
  }

  /// Penjadwalan pengingat 5 menit sebelum sesi dimulai
  Future<void> scheduleReminder({
    required int id,
    required String dokterNama,
    required DateTime waktuMulaiSesi,
  }) async {
    final waktuPengingat = waktuMulaiSesi.subtract(const Duration(minutes: 5));

    // Hanya jadwalkan jika waktu pengingat belum lewat
    if (waktuPengingat.isAfter(DateTime.now())) {
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        'Pengingat Sesi Konsultasi 🩺',
        'Sesi konsultasi Anda dengan $dokterNama akan dimulai dalam 5 menit!',
        tz.TZDateTime.from(waktuPengingat, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'konsultasi_channel',
            'Pengingat Konsultasi',
            channelDescription: 'Notifikasi pengingat sesi konsultasi dokter',
            importance: Importance.high,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  /// Membatalkan notifikasi berdasarkan ID (jika sesi dibatalkan)
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }
}