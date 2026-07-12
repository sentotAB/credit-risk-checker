import 'package:shared_preferences/shared_preferences.dart';

/// Wrapper tipis di atas `shared_preferences` untuk menyimpan status login
/// secara lokal di perangkat (local storage).
///
/// Dipakai supaya user tidak perlu login ulang setiap kali aplikasi
/// dibuka/refresh — SplashPage akan mengecek [isLoggedIn] terlebih dahulu
/// sebelum memutuskan mengarahkan ke LoginPage atau langsung ke HomePage.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const String _keyIsLoggedIn = 'is_logged_in';
  static const String _keyUserName = 'user_name';

  /// Menyimpan status login = true beserta nama user, dipanggil setelah
  /// login berhasil di [LoginPage].
  Future<void> saveLoginSession({required String userName}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsLoggedIn, true);
    await prefs.setString(_keyUserName, userName);
  }

  /// Mengecek apakah user masih dalam sesi login (tersimpan di local
  /// storage). Dipanggil dari [SplashPage] untuk menentukan halaman tujuan.
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Mengambil nama user yang tersimpan, untuk ditampilkan di HomePage
  /// tanpa perlu login ulang.
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// Menghapus sesi login, dipanggil saat user menekan tombol logout.
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyIsLoggedIn);
    await prefs.remove(_keyUserName);
  }
}