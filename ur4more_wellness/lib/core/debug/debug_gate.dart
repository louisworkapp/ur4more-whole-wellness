import 'package:shared_preferences/shared_preferences.dart';

class DebugGate {
  static const _kKey = 'debug_mode_enabled';
  static const _code = '4433';

  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kKey) ?? false;
  }

  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kKey, value);
  }

  static Future<bool> enableWithCode(String code) async {
    if (code == _code) {
      await setEnabled(true);
      return true;
    }
    return false;
  }
}
