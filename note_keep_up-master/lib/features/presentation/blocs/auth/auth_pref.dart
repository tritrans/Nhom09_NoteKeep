import 'package:shared_preferences/shared_preferences.dart';

class AuthPref {
  static Future<bool> getAuthEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('auth_enabled') ?? true; // mặc định bật
  }

  static Future<void> setAuthEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_enabled', value);
  }
}
