import 'package:shared_preferences/shared_preferences.dart';
import 'settings_model.dart';

class SettingsService {
  static const _kFaithTier = 'settings.faithTier';
  static const _kNotif = 'settings.notifications';
  static const _kEqBody = 'settings.eq.body';
  static const _kEqBand = 'settings.eq.band';
  static const _kEqPull = 'settings.eq.pull';
  static const _kTz = 'settings.timezone';
  static const _kTheme = 'settings.themeMode';
  static const _kHideFaith = 'settings.hideFaithOverlaysInMind';

  Future<AppSettings> load() async {
    final p = await SharedPreferences.getInstance();
    final faith = parseFaithTier(p.getString(_kFaithTier));
    final notif = p.getBool(_kNotif) ?? AppSettings.defaults.notificationsEnabled;
    final eqBody = p.getBool(_kEqBody) ?? AppSettings.defaults.equipmentBodyweight;
    final eqBand = p.getBool(_kEqBand) ?? AppSettings.defaults.equipmentBands;
    final eqPull = p.getBool(_kEqPull) ?? AppSettings.defaults.equipmentPullup;
    final tz = p.getString(_kTz) ?? AppSettings.defaults.timezone;
    final theme = _parseThemeMode(p.getString(_kTheme));
    final hideFaith = p.getBool(_kHideFaith) ?? AppSettings.defaults.hideFaithOverlaysInMind;
    return AppSettings(
      faithTier: faith,
      notificationsEnabled: notif,
      equipmentBodyweight: eqBody,
      equipmentBands: eqBand,
      equipmentPullup: eqPull,
      timezone: tz,
      themeMode: theme,
      hideFaithOverlaysInMind: hideFaith,
    );
  }

  Future<void> save(AppSettings s) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kFaithTier, faithTierToString(s.faithTier));
    await p.setBool(_kNotif, s.notificationsEnabled);
    await p.setBool(_kEqBody, s.equipmentBodyweight);
    await p.setBool(_kEqBand, s.equipmentBands);
    await p.setBool(_kEqPull, s.equipmentPullup);
    await p.setString(_kTz, s.timezone);
    await p.setString(_kTheme, _themeModeToString(s.themeMode));
    await p.setBool(_kHideFaith, s.hideFaithOverlaysInMind);
  }

  AppThemeMode _parseThemeMode(String? raw) {
    switch (raw) {
      case 'light': return AppThemeMode.light;
      case 'dark': return AppThemeMode.dark;
      case 'system': return AppThemeMode.system;
      default: return AppSettings.defaults.themeMode;
    }
  }

  String _themeModeToString(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light: return 'light';
      case AppThemeMode.dark: return 'dark';
      case AppThemeMode.system: return 'system';
    }
  }
}
