import 'package:flutter/foundation.dart';

enum FaithTier { off, light, disciple, kingdom }

/// Extension for FaithTier with convenient flags
extension FaithFlags on FaithTier {
  bool get isOff => this == FaithTier.off;
  bool get isActivated => this != FaithTier.off;
  bool get isDeep => this == FaithTier.disciple || this == FaithTier.kingdom;
}

/// Parse FaithTier from string (canonical conversion)
/// Accepts lowercase strings: "off", "light", "disciple", "kingdom"
/// Returns FaithTier.off for invalid/null inputs
FaithTier parseFaithTier(String? raw) {
  if (raw == null) return FaithTier.off;
  switch (raw.toLowerCase().trim()) {
    case 'light': return FaithTier.light;
    case 'disciple': return FaithTier.disciple;
    case 'kingdom': return FaithTier.kingdom;
    case 'off': default: return FaithTier.off;
  }
}

/// Convert FaithTier to canonical string representation
/// Returns lowercase strings: "off", "light", "disciple", "kingdom"
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
  final bool hideFaithOverlaysInMind;

  const AppSettings({
    required this.faithTier,
    required this.notificationsEnabled,
    required this.equipmentBodyweight,
    required this.equipmentBands,
    required this.equipmentPullup,
    required this.timezone,
    required this.themeMode,
    required this.hideFaithOverlaysInMind,
  });

  static const defaults = AppSettings(
    faithTier: FaithTier.off,
    notificationsEnabled: true,
    equipmentBodyweight: true,
    equipmentBands: false,
    equipmentPullup: false,
    timezone: 'Eastern Time (ET)',
    themeMode: AppThemeMode.dark,
    hideFaithOverlaysInMind: false,
  );

  AppSettings copyWith({
    FaithTier? faithTier,
    bool? notificationsEnabled,
    bool? equipmentBodyweight,
    bool? equipmentBands,
    bool? equipmentPullup,
    String? timezone,
    AppThemeMode? themeMode,
    bool? hideFaithOverlaysInMind,
  }) {
    return AppSettings(
      faithTier: faithTier ?? this.faithTier,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      equipmentBodyweight: equipmentBodyweight ?? this.equipmentBodyweight,
      equipmentBands: equipmentBands ?? this.equipmentBands,
      equipmentPullup: equipmentPullup ?? this.equipmentPullup,
      timezone: timezone ?? this.timezone,
      themeMode: themeMode ?? this.themeMode,
      hideFaithOverlaysInMind: hideFaithOverlaysInMind ?? this.hideFaithOverlaysInMind,
    );
  }
}
