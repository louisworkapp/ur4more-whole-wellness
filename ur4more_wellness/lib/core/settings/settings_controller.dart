import 'package:flutter/foundation.dart';
import 'settings_model.dart';
import 'settings_service.dart';

class SettingsController extends ChangeNotifier {
  final SettingsService _service;
  AppSettings _settings = AppSettings.defaults;
  bool _hydrated = false;
  bool get hydrated => _hydrated;
  AppSettings get value => _settings;

  SettingsController(this._service);

  Future<void> hydrate() async {
    _settings = await _service.load();
    _hydrated = true;
    notifyListeners();
  }

  Future<void> updateFaith(FaithTier tier) async {
    _settings = _settings.copyWith(faithTier: tier);
    notifyListeners();
    await _service.save(_settings);
  }

  Future<void> updateNotifications(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    notifyListeners();
    await _service.save(_settings);
  }

  Future<void> updateEquipment({bool? bodyweight, bool? bands, bool? pullup}) async {
    _settings = _settings.copyWith(
      equipmentBodyweight: bodyweight ?? _settings.equipmentBodyweight,
      equipmentBands: bands ?? _settings.equipmentBands,
      equipmentPullup: pullup ?? _settings.equipmentPullup,
    );
    notifyListeners();
    await _service.save(_settings);
  }

  Future<void> updateTimezone(String tz) async {
    _settings = _settings.copyWith(timezone: tz);
    notifyListeners();
    await _service.save(_settings);
  }

  Future<void> updateThemeMode(AppThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    notifyListeners();
    await _service.save(_settings);
  }
}
