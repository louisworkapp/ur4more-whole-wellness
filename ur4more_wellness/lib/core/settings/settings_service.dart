import 'package:shared_preferences/shared_preferences.dart';
import 'settings_model.dart';

class SettingsService {
  static const _kFaithTier = 'settings.faithTier';
  static const _kNotif = 'settings.notifications';
  static const _kEqBody = 'settings.eq.body';
  static const _kEqBand = 'settings.eq.band';
  static const _kEqPull = 'settings.eq.pull';
  static const _kTz = 'settings.timezone';

  Future<AppSettings> load() async {
    final p = await SharedPreferences.getInstance();
    final faith = parseFaithTier(p.getString(_kFaithTier));
    final notif = p.getBool(_kNotif) ?? AppSettings.defaults.notificationsEnabled;
    final eqBody = p.getBool(_kEqBody) ?? AppSettings.defaults.equipmentBodyweight;
    final eqBand = p.getBool(_kEqBand) ?? AppSettings.defaults.equipmentBands;
    final eqPull = p.getBool(_kEqPull) ?? AppSettings.defaults.equipmentPullup;
    final tz = p.getString(_kTz) ?? AppSettings.defaults.timezone;
    return AppSettings(
      faithTier: faith,
      notificationsEnabled: notif,
      equipmentBodyweight: eqBody,
      equipmentBands: eqBand,
      equipmentPullup: eqPull,
      timezone: tz,
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
  }
}
