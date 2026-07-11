import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:credit_risk_v1/services/notification_service.dart';
import 'package:credit_risk_v1/services/push_notification_service.dart';
import '../pages/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 1) Local notification: hanya relevan untuk Android/iOS.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //    flutter_local_notifications tidak punya implementasi untuk web,
  //    jadi kalau dipanggil di web akan throw dan runApp() tidak pernah
  //    tercapai -> UI blank di browser.
 if (!kIsWeb) {
    await NotificationService.instance.init();
  }
  // 2) Push notification: inisialisasi Firebase + FCM (token, listener
  //    onMessage, & background handler). Lihat
  //    lib/services/push_notification_service.dart untuk detail & catatan
  //    integrasi backend yang masih perlu disiapkan.
  await PushNotificationService.instance.init();
  runApp(const CreditRiskApp());
}

class CreditRiskApp extends StatelessWidget {
  const CreditRiskApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF1A237E), // Deep Indigo
      brightness: Brightness.light,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Credit Risk Checker',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFFF5F6FA),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: colorScheme.onSurface,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF0F2F8),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      home: const SplashPage(),
    );
  }
}
