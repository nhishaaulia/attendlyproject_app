import 'package:shared_preferences/shared_preferences.dart';

class PreferenceHandler {
  static const String loginKey = "login";
  static const String tokenKey = "token";
  static const String userIdKey = "user_id";

  //Login
  static Future<void> saveLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(loginKey, true);
  }

  static Future<bool?> getLogin() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getBool(loginKey);
    return prefs.getBool(loginKey);
  }

  static Future<void> removeLogin() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(loginKey);
  }

  //Token
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  static getToken() async {
    print(tokenKey);
    final prefs = await SharedPreferences.getInstance();
    prefs.getString(tokenKey);
    return prefs.getString(tokenKey);
  }

  static Future<void> removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }

  //User Id
  static Future<void> saveUserId(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(userIdKey, userId);
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(userIdKey);
  }

  static Future<void> removeUserId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(userIdKey);
  }
}
