import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import '../settings/settings_model.dart' show FaithTier, parseFaithTier, faithTierToString;

enum AppThemeMode {
  light,
  dark,
  system,
}

class AppSettings {
  // Faith mode setting
  FaithTier faithMode;
  
  // Equipment settings
  bool hasBodyweight;
  bool hasResistanceBands;
  bool hasPullupBar;
  
  // Theme setting
  AppThemeMode themeMode;
  
  // Notification settings
  bool notificationsEnabled;
  int notificationStartHour;
  int notificationStartMinute;
  int notificationEndHour;
  int notificationEndMinute;
  
  // Privacy settings
  bool dataCollectionEnabled;
  bool analyticsEnabled;
  bool crashReportingEnabled;
  
  // Profile settings
  String fullName;
  String timezone;
  
  AppSettings({
    this.faithMode = FaithTier.off,
    this.hasBodyweight = true,
    this.hasResistanceBands = false,
    this.hasPullupBar = false,
    this.themeMode = AppThemeMode.system,
    this.notificationsEnabled = true,
    this.notificationStartHour = 7,
    this.notificationStartMinute = 0,
    this.notificationEndHour = 21,
    this.notificationEndMinute = 0,
    this.dataCollectionEnabled = true,
    this.analyticsEnabled = false,
    this.crashReportingEnabled = true,
    this.fullName = '',
    this.timezone = 'Eastern Time (ET)',
  });

  AppSettings copyWith({
    FaithTier? faithMode,
    bool? hasBodyweight,
    bool? hasResistanceBands,
    bool? hasPullupBar,
    AppThemeMode? themeMode,
    bool? notificationsEnabled,
    int? notificationStartHour,
    int? notificationStartMinute,
    int? notificationEndHour,
    int? notificationEndMinute,
    bool? dataCollectionEnabled,
    bool? analyticsEnabled,
    bool? crashReportingEnabled,
    String? fullName,
    String? timezone,
  }) {
    return AppSettings(
      faithMode: faithMode ?? this.faithMode,
      hasBodyweight: hasBodyweight ?? this.hasBodyweight,
      hasResistanceBands: hasResistanceBands ?? this.hasResistanceBands,
      hasPullupBar: hasPullupBar ?? this.hasPullupBar,
      themeMode: themeMode ?? this.themeMode,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      notificationStartHour: notificationStartHour ?? this.notificationStartHour,
      notificationStartMinute: notificationStartMinute ?? this.notificationStartMinute,
      notificationEndHour: notificationEndHour ?? this.notificationEndHour,
      notificationEndMinute: notificationEndMinute ?? this.notificationEndMinute,
      dataCollectionEnabled: dataCollectionEnabled ?? this.dataCollectionEnabled,
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
      fullName: fullName ?? this.fullName,
      timezone: timezone ?? this.timezone,
    );
  }
}

class SettingsService {
  static const String _faithModeKey = 'faith_mode';
  static const String _hasBodyweightKey = 'has_bodyweight';
  static const String _hasResistanceBandsKey = 'has_resistance_bands';
  static const String _hasPullupBarKey = 'has_pullup_bar';
  static const String _themeModeKey = 'theme_mode';
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _notificationStartHourKey = 'notification_start_hour';
  static const String _notificationStartMinuteKey = 'notification_start_minute';
  static const String _notificationEndHourKey = 'notification_end_hour';
  static const String _notificationEndMinuteKey = 'notification_end_minute';
  static const String _dataCollectionEnabledKey = 'data_collection_enabled';
  static const String _analyticsEnabledKey = 'analytics_enabled';
  static const String _crashReportingEnabledKey = 'crash_reporting_enabled';
  static const String _fullNameKey = 'full_name';
  static const String _timezoneKey = 'timezone';
  static const String _isFirstLaunchKey = 'is_first_launch';

  /// Get default settings for first-time app launch
  static AppSettings getDefaultSettings() {
    return AppSettings(
      faithMode: FaithTier.off,
      hasBodyweight: true,
      hasResistanceBands: false,
      hasPullupBar: false,
      themeMode: AppThemeMode.system,
      notificationsEnabled: true,
      notificationStartHour: 7,
      notificationStartMinute: 0,
      notificationEndHour: 21,
      notificationEndMinute: 0,
      dataCollectionEnabled: true,
      analyticsEnabled: false,
      crashReportingEnabled: true,
      fullName: '',
      timezone: 'Eastern Time (ET)',
    );
  }

  /// Check if this is the first app launch
  static Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isFirstLaunchKey) ?? true;
    } catch (e) {
      debugPrint('Error checking first launch status: $e');
      return true;
    }
  }

  /// Mark that the app has been launched before
  static Future<void> markFirstLaunchComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isFirstLaunchKey, false);
    } catch (e) {
      debugPrint('Error marking first launch complete: $e');
    }
  }

  /// Initialize settings for first-time launch
  static Future<void> initializeFirstLaunchSettings() async {
    try {
      final isFirst = await isFirstLaunch();
      if (isFirst) {
        final defaultSettings = getDefaultSettings();
        await saveSettings(defaultSettings);
        await markFirstLaunchComplete();
        debugPrint('First launch settings initialized');
      }
    } catch (e) {
      debugPrint('Error initializing first launch settings: $e');
    }
  }

  /// Force reset to default settings (for testing/debugging)
  static Future<void> resetToDefaultSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      final defaultSettings = getDefaultSettings();
      await saveSettings(defaultSettings);
      await markFirstLaunchComplete();
      debugPrint('Settings reset to defaults');
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }

  /// Load settings from SharedPreferences
  static Future<AppSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      return AppSettings(
        faithMode: _parseFaithMode(prefs.getString(_faithModeKey)),
        hasBodyweight: prefs.getBool(_hasBodyweightKey) ?? true,
        hasResistanceBands: prefs.getBool(_hasResistanceBandsKey) ?? false,
        hasPullupBar: prefs.getBool(_hasPullupBarKey) ?? false,
        themeMode: _parseThemeMode(prefs.getString(_themeModeKey)),
        notificationsEnabled: prefs.getBool(_notificationsEnabledKey) ?? true,
        notificationStartHour: prefs.getInt(_notificationStartHourKey) ?? 7,
        notificationStartMinute: prefs.getInt(_notificationStartMinuteKey) ?? 0,
        notificationEndHour: prefs.getInt(_notificationEndHourKey) ?? 21,
        notificationEndMinute: prefs.getInt(_notificationEndMinuteKey) ?? 0,
        dataCollectionEnabled: prefs.getBool(_dataCollectionEnabledKey) ?? true,
        analyticsEnabled: prefs.getBool(_analyticsEnabledKey) ?? false,
        crashReportingEnabled: prefs.getBool(_crashReportingEnabledKey) ?? true,
        fullName: prefs.getString(_fullNameKey) ?? '',
        timezone: prefs.getString(_timezoneKey) ?? 'Eastern Time (ET)',
      );
    } catch (e) {
      debugPrint('Error loading settings: $e');
      return getDefaultSettings();
    }
  }

  /// Save settings to SharedPreferences
  static Future<void> saveSettings(AppSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setString(_faithModeKey, faithTierToString(settings.faithMode));
      await prefs.setBool(_hasBodyweightKey, settings.hasBodyweight);
      await prefs.setBool(_hasResistanceBandsKey, settings.hasResistanceBands);
      await prefs.setBool(_hasPullupBarKey, settings.hasPullupBar);
      await prefs.setString(_themeModeKey, settings.themeMode.name);
      await prefs.setBool(_notificationsEnabledKey, settings.notificationsEnabled);
      await prefs.setInt(_notificationStartHourKey, settings.notificationStartHour);
      await prefs.setInt(_notificationStartMinuteKey, settings.notificationStartMinute);
      await prefs.setInt(_notificationEndHourKey, settings.notificationEndHour);
      await prefs.setInt(_notificationEndMinuteKey, settings.notificationEndMinute);
      await prefs.setBool(_dataCollectionEnabledKey, settings.dataCollectionEnabled);
      await prefs.setBool(_analyticsEnabledKey, settings.analyticsEnabled);
      await prefs.setBool(_crashReportingEnabledKey, settings.crashReportingEnabled);
      await prefs.setString(_fullNameKey, settings.fullName);
      await prefs.setString(_timezoneKey, settings.timezone);
      
      debugPrint('Settings saved successfully');
    } catch (e) {
      debugPrint('Error saving settings: $e');
    }
  }

  /// Update specific setting
  static Future<void> updateFaithMode(FaithTier faithMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_faithModeKey, faithTierToString(faithMode));
      debugPrint('Faith mode updated to: ${faithTierToString(faithMode)}');
    } catch (e) {
      debugPrint('Error updating faith mode: $e');
    }
  }

  static Future<void> updateEquipment({
    bool? hasBodyweight,
    bool? hasResistanceBands,
    bool? hasPullupBar,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      if (hasBodyweight != null) {
        await prefs.setBool(_hasBodyweightKey, hasBodyweight);
      }
      if (hasResistanceBands != null) {
        await prefs.setBool(_hasResistanceBandsKey, hasResistanceBands);
      }
      if (hasPullupBar != null) {
        await prefs.setBool(_hasPullupBarKey, hasPullupBar);
      }
      
      debugPrint('Equipment settings updated');
    } catch (e) {
      debugPrint('Error updating equipment settings: $e');
    }
  }

  static Future<void> updateThemeMode(AppThemeMode themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, themeMode.name);
      debugPrint('Theme mode updated to: ${themeMode.name}');
    } catch (e) {
      debugPrint('Error updating theme mode: $e');
    }
  }

  /// Helper methods for parsing enums
  static FaithTier _parseFaithMode(String? value) {
    return parseFaithTier(value);
  }

  static AppThemeMode _parseThemeMode(String? value) {
    if (value == null) return AppThemeMode.system;
    return AppThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => AppThemeMode.system,
    );
  }
}
