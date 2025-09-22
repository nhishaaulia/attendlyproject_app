import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String loginKey = "login";
  static const String tokenKey = "token";

  /// Simpan status login = true
  /// Menandai user sudah login, jadi pas buka app bisa auto langsung ke dashboard
  static Future<void> saveLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, true);
  }

  /// Simpan token auth (biasanya Bearer token dari API login/register)
  /// bisa dipakai lagi untuk request API berikutnya tanpa harus login ulang
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  /// Ambil status login (true/false/null)
  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(loginKey);
  }

  /// Ambil token auth yg tersimpan
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  /// Hapus status login
  /// biasanya dipanggil saat logout biar pas buka app lagi harus login
  static Future<void> removeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginKey);
  }

  /// Hapus token auth
  /// bagian dari logout, biar token lama ga dipakai lagi
  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  // ===== Generic key-value (buat simpan jam checkin/checkout) =====
  static Future<void> setString(String key, String value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(key, value);
  }

  static Future<String?> getString(String key) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getString(key);
  }

  static Future<void> remove(String key) async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(key);
  }
}
