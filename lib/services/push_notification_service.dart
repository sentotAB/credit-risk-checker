import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:credit_risk_v1/services/notification_service.dart';
import 'package:flutter/foundation.dart';

/// Handler top-level (WAJIB top-level function, bukan method instance) yang
/// dipanggil secara native saat pesan FCM datang ketika app berada di
/// background atau sudah ditutup (terminated).
///
/// Catatan platform: di Android/iOS, handler ini benar-benar dijalankan oleh
/// Dart di background isolate terpisah. Di web, background message justru
/// ditangani oleh `web/firebase-messaging-sw.js` (JS service worker) —
/// handler Dart ini tetap perlu didaftarkan lewat `onBackgroundMessage` agar
/// API-nya konsisten lintas platform, tapi eksekusi aktualnya di web
/// dilakukan oleh service worker tersebut, bukan oleh fungsi ini.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Firebase perlu di-init ulang karena ini berjalan di isolate terpisah
  // (khusus mobile; di web pemanggilan ini tidak berdampak apa-apa karena
  // background handling sudah diambil alih oleh service worker).
  await Firebase.initializeApp();
  await NotificationService.instance.showRemoteMessage(message);
}

/// Wrapper untuk push notification: pesan status kredit dikirim dari SERVER
/// ke perangkat nasabah via Firebase Cloud Messaging (FCM), termasuk saat
/// aplikasi sedang di-background atau ditutup sepenuhnya.
///
/// PENTING — bagian yang perlu disiapkan DI LUAR kode client ini:
/// 1. Jalankan `flutterfire configure` di root project agar file
///    `firebase_options.dart` ter-generate dan project terhubung ke project
///    Firebase yang benar.
/// 2. Kirim `fcmToken` (lihat getter [fcmToken]) ke backend Anda, dikaitkan
///    dengan SK_ID_CURR nasabah, agar backend tahu ke device mana push
///    harus dikirim.
/// 3. Saat keputusan kredit dibuat di backend (mis. via Cloud Function),
///    kirim push berisi judul & isi dari `NextStepMessage` — lihat contoh
///    Cloud Function di `docs/push_notification_backend_example.md`.
///
/// CATATAN WEB: seluruh isi [init] dibungkus try-catch. Di browser, hal-hal
/// berikut wajar terjadi dan TIDAK BOLEH sampai melempar exception ke
/// main() (kalau lolos, runApp() tidak akan pernah terpanggil -> UI blank):
/// - User menolak izin notifikasi browser (permission denied).
/// - Browser tidak mendukung Notification API / service worker sama sekali.
/// - `firebase-messaging-sw.js` gagal register (mis. akses via file:// atau
///   HTTP non-secure selain localhost).
/// - `getToken()` gagal karena VAPID key salah/kadaluarsa.
class PushNotificationService {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  FirebaseMessaging? _messaging;

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  /// true jika inisialisasi berhasil penuh (permission diberikan & token
  /// didapat). Bisa dipakai UI untuk menyembunyikan fitur terkait push
  /// notifikasi bila false, tanpa mengganggu bagian app lainnya.
  bool _isReady = false;
  bool get isReady => _isReady;

  Future<void> init() async {
    try {
      // Firebase.initializeApp() already called in main.dart before this runs.
      _messaging = FirebaseMessaging.instance;

      // Beberapa browser (mis. Edge dengan pop-up permission yang sudah
      // di-mute/di-block sebelumnya di level browser) tidak pernah
      // menampilkan dialog "Allow/Block". Kalau itu terjadi, Promise dari
      // requestPermission() bisa menggantung tanpa resolve maupun reject
      // sama sekali. Timeout ini memastikan init() tetap lanjut (dianggap
      // permission tidak diberikan) alih-alih membuat seluruh app macet.
      final settings = await _messaging!
          .requestPermission(
            alert: true,
            badge: true,
            sound: true,
          )
          .timeout(
            const Duration(seconds: 5),
            onTimeout: () async => _messaging!.getNotificationSettings(),
          );

      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        // User menolak izin (umum terjadi di browser). Jangan lempar error,
        // cukup keluar lebih awal dan biarkan sisa app tetap jalan tanpa
        // push notification.
        debugPrint('PushNotificationService: izin notifikasi ditolak user.');
        return;
      }

      _fcmToken = await _messaging!.getToken(
        vapidKey: kIsWeb
            ? 'BCuvtta_IcLPPVaehOSubXGcY4QDrz9l83-gnDayc9yiyrsyyhDu9-qRkkJZz9HBbYslIkMCWeX4h_E3O4Cy1sc'
            : null,
      );

      // await api.registerDeviceToken(nasabahId: ..., token: _fcmToken);

      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // FCM tidak otomatis menampilkan notifikasi system tray saat app aktif
      // (foreground) di Android, jadi kita tampilkan manual sbg local
      // notification supaya perilakunya konsisten dengan kondisi
      // background/terminated. (Di web, showRemoteMessage akan langsung
      // return karena flutter_local_notifications tidak support web.)
      FirebaseMessaging.onMessage.listen((message) {
        NotificationService.instance.showRemoteMessage(message);
      });

      FirebaseMessaging.onMessageOpenedApp.listen((message) {
        // TODO: arahkan user ke halaman detail nasabah terkait bila
        // diperlukan, mis. Navigator.push ke halaman dengan SK_ID_CURR dari
        // message.data.
      });

      _isReady = true;
    } catch (e, st) {
      // Jangan biarkan kegagalan push notification (izin ditolak, browser
      // tidak support, VAPID key salah, dsb) menghentikan seluruh app.
      debugPrint('PushNotificationService init gagal: $e');
      debugPrintStack(stackTrace: st);
      _isReady = false;
    }
  }
}