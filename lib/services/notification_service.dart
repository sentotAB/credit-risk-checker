import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:credit_risk_v1/utils/next_step_message.dart';

/// Wrapper tipis di atas `flutter_local_notifications`.
///
/// CATATAN PLATFORM: flutter_local_notifications tidak punya implementasi
/// untuk web, jadi semua method publik di sini di-guard dengan `kIsWeb`
/// supaya aman dipanggil dari kode yang shared antara mobile & web
/// (mis. dari PushNotificationService yang jalan di semua platform).
///
/// Dipakai untuk 2 hal:
/// 1. Local notification murni — dipicu langsung dari client saat status
///    "Disetujui"/"Ditolak" diketahui (lihat [showStatusNotification]).
///    Ini tetap muncul di perangkat walau aplikasi diminimize/di-background.
/// 2. Menampilkan notifikasi saat pesan FCM (push notification) diterima,
///    baik ketika app aktif (foreground) maupun di background
///    (lihat [showRemoteMessage], dipanggil dari PushNotificationService).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  static const String channelId = 'credit_decision_channel';
  static const String channelName = 'Status Pengajuan Kredit';
  static const String channelDescription =
      'Notifikasi status pengajuan kredit nasabah (disetujui/ditolak)';

  Future<void> init() async {
    if (kIsWeb) return; // tidak ada implementasi web untuk plugin ini
    if (_initialized) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings: settings);
    await _requestPermissions();
    _initialized = true;
  }

  Future<void> _requestPermissions() async {
    // Android 13+ mewajibkan izin POST_NOTIFICATIONS diminta secara eksplisit.
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  NotificationDetails get _defaultDetails => const NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      );

  /// Notifikasi lokal saat status kredit diketahui di client.
  /// (Bentuk teknis: local notification, via flutter_local_notifications)
  Future<void> showStatusNotification({required bool isApproved}) async {
    if (kIsWeb) return; // tidak ada implementasi web untuk plugin ini
    if (!_initialized) await init();
    await _plugin.show(
      id: isApproved ? 1001 : 1002,
      title: NextStepMessage.titleForStatus(isApproved),
      body: NextStepMessage.forStatus(isApproved),
      notificationDetails: _defaultDetails,
    );
  }

  /// Menampilkan notifikasi dari pesan FCM (push notification) yang diterima,
  /// baik saat app di foreground maupun lewat background handler.
  Future<void> showRemoteMessage(RemoteMessage message) async {
    if (kIsWeb) return; // tidak ada implementasi web untuk plugin ini
    if (!_initialized) await init();
    final notification = message.notification;
    await _plugin.show(
      id: message.hashCode,
      title: notification?.title ?? 'Update Pengajuan Kredit',
      body: notification?.body ?? '',
      notificationDetails: _defaultDetails,
    );
  }
}