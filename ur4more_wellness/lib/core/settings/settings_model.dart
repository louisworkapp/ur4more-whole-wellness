import 'package:flutter/foundation.dart';

enum FaithTier { off, light, disciple, kingdom }

FaithTier parseFaithTier(String? raw) {
  switch (raw) {
    case 'light': return FaithTier.light;
    case 'disciple': return FaithTier.disciple;
    case 'kingdom': return FaithTier.kingdom;
    default: return FaithTier.off;
  }
}

String faithTierToString(FaithTier tier) {
  switch (tier) {
    case FaithTier.light: return 'light';
    case FaithTier.disciple: return 'disciple';
    case FaithTier.kingdom: return 'kingdom';
    case FaithTier.off: default: return 'off';
  }
}

enum AppThemeMode { light, dark, system }

@immutable
class AppSettings {
  final FaithTier faithTier;
  final bool notificationsEnabled;
  final bool equipmentBodyweight;
  final bool equipmentBands;
  final bool equipmentPullup;
  final String timezone;
  final AppThemeMode themeMode;

  const AppSettings({
    required this.faithTier,
    required this.notificationsEnabled,
    required this.equipmentBodyweight,
    required this.equipmentBands,
    required this.equipmentPullup,
    required this.timezone,
    required this.themeMode,
  });

  static const defaults = AppSettings(
    faithTier: FaithTier.off,
    notificationsEnabled: true,
    equipmentBodyweight: true,
    equipmentBands: false,
    equipmentPullup: false,
    timezone: 'Eastern Time (ET)',
    themeMode: AppThemeMode.dark,
  );

  AppSettings copyWith({
    FaithTier? faithTier,
    bool? notificationsEnabled,
    bool? equipmentBodyweight,
    bool? equipmentBands,
    bool? equipmentPullup,
    String? timezone,
    AppThemeMode? themeMode,
  }) {
    return AppSettings(
      faithTier: faithTier ?? this.faithTier,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      equipmentBodyweight: equipmentBodyweight ?? this.equipmentBodyweight,
      equipmentBands: equipmentBands ?? this.equipmentBands,
      equipmentPullup: equipmentPullup ?? this.equipmentPullup,
      timezone: timezone ?? this.timezone,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}
