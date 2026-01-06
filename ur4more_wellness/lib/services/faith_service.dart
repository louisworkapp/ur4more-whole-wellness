import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/settings/settings_model.dart';

/// Faith Service for managing faith tier and XP progression
/// Uses canonical FaithTier enum from settings_model.dart

/// Faith progress tracking with XP and streaks
class FaithProgress {
  final int xp;
  final int streakDays;
  final DateTime? lastEarnedDay;
  final bool earnedToday;

  const FaithProgress({
    required this.xp,
    required this.streakDays,
    this.lastEarnedDay,
    required this.earnedToday,
  });

  FaithProgress copyWith({
    int? xp,
    int? streakDays,
    DateTime? lastEarnedDay,
    bool? earnedToday,
  }) {
    return FaithProgress(
      xp: xp ?? this.xp,
      streakDays: streakDays ?? this.streakDays,
      lastEarnedDay: lastEarnedDay ?? this.lastEarnedDay,
      earnedToday: earnedToday ?? this.earnedToday,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'xp': xp,
      'streakDays': streakDays,
      'lastEarnedDay': lastEarnedDay?.toIso8601String(),
      'earnedToday': earnedToday,
    };
  }

  factory FaithProgress.fromJson(Map<String, dynamic> json) {
    return FaithProgress(
      xp: json['xp'] as int? ?? 0,
      streakDays: json['streakDays'] as int? ?? 0,
      lastEarnedDay: json['lastEarnedDay'] != null 
          ? DateTime.parse(json['lastEarnedDay'] as String)
          : null,
      earnedToday: json['earnedToday'] as bool? ?? false,
    );
  }
}

/// Faith Service for managing faith mode and XP progression
class FaithService {
  static const String _faithModeKey = 'faith_mode';
  static const String _faithProgressKey = 'faith_progress';
  
  // Daily XP caps per tier
  static const Map<FaithTier, int> _dailyCaps = {
    FaithTier.off: 0,
    FaithTier.light: 10,
    FaithTier.disciple: 20,
    FaithTier.kingdom: 30,
  };

  // Tier upgrade thresholds
  static const int _lightToDiscipleThreshold = 200;
  static const int _discipleToKingdomThreshold = 600;

  /// Get current faith tier
  static Future<FaithTier> getFaithMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_faithModeKey);
    return _parseFaithMode(modeString);
  }

  /// Set faith tier
  static Future<void> setFaithMode(FaithTier tier) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_faithModeKey, _faithModeToString(tier));
  }

  /// Get faith progress
  static Future<FaithProgress> getFaithProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_faithProgressKey);
    
    if (progressJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(progressJson);
        return FaithProgress.fromJson(json);
      } catch (e) {
        debugPrint('Error parsing faith progress: $e');
      }
    }
    
    return const FaithProgress(xp: 0, streakDays: 0, earnedToday: false);
  }

  /// Award faith XP with daily cap enforcement
  static Future<int> awardFaithXp(int amount, DateTime now) async {
    final mode = await getFaithMode();
    final progress = await getFaithProgress();
    
    // No XP for Off mode
    if (mode == FaithTier.off) {
      return 0;
    }

    // Check daily cap
    final dailyCap = _dailyCaps[mode] ?? 0;
    if (progress.earnedToday && dailyCap > 0) {
      debugPrint('Daily faith XP cap reached for $mode mode');
      return 0;
    }

    // Check if this is a new day
    final today = DateTime(now.year, now.month, now.day);
    final lastEarnedDay = progress.lastEarnedDay != null 
        ? DateTime(
            progress.lastEarnedDay!.year,
            progress.lastEarnedDay!.month,
            progress.lastEarnedDay!.day,
          )
        : null;

    bool isNewDay = lastEarnedDay == null || today.isAfter(lastEarnedDay);
    bool isConsecutiveDay = lastEarnedDay != null && 
        today.difference(lastEarnedDay).inDays == 1;

    // Calculate new streak
    int newStreakDays = progress.streakDays;
    if (isNewDay) {
      if (isConsecutiveDay) {
        newStreakDays = progress.streakDays + 1;
      } else if (lastEarnedDay != null && today.difference(lastEarnedDay).inDays > 1) {
        // Streak broken, reset to 1
        newStreakDays = 1;
      } else {
        // First time earning XP
        newStreakDays = 1;
      }
    }

    // Award XP (respect daily cap)
    final xpToAward = isNewDay ? amount.clamp(0, dailyCap) : 0;
    final newXp = progress.xp + xpToAward;

    // Update progress
    final updatedProgress = progress.copyWith(
      xp: newXp,
      streakDays: newStreakDays,
      lastEarnedDay: isNewDay ? now : progress.lastEarnedDay,
      earnedToday: isNewDay,
    );

    // Save to SharedPreferences
    await _saveFaithProgress(updatedProgress);

    debugPrint('Faith XP awarded: +$xpToAward (total: $newXp, streak: $newStreakDays)');
    return xpToAward;
  }

  /// Save faith progress to SharedPreferences
  static Future<void> _saveFaithProgress(FaithProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_faithProgressKey, jsonEncode(progress.toJson()));
  }

  /// Get daily XP cap for current mode
  static Future<int> getDailyCap() async {
    final mode = await getFaithMode();
    return _dailyCaps[mode] ?? 0;
  }

  /// Check if user can upgrade to next tier
  static Future<FaithTier?> getUpgradeableTier() async {
    final mode = await getFaithMode();
    final progress = await getFaithProgress();

    switch (mode) {
      case FaithTier.light:
        if (progress.xp >= _lightToDiscipleThreshold) {
          return FaithTier.disciple;
        }
        break;
      case FaithTier.disciple:
        if (progress.xp >= _discipleToKingdomThreshold) {
          return FaithTier.kingdom;
        }
        break;
      case FaithTier.off:
      case FaithTier.kingdom:
        return null; // No upgrades available
    }

    return null;
  }

  /// Get faith tier label (display name)
  static String getFaithModeLabel(FaithTier tier) {
    switch (tier) {
      case FaithTier.off:
        return 'Off';
      case FaithTier.light:
        return 'Light';
      case FaithTier.disciple:
        return 'Disciple';
      case FaithTier.kingdom:
        return 'Kingdom Builder';
    }
  }

  /// Get faith tier description
  static String getFaithModeDescription(FaithTier tier) {
    switch (tier) {
      case FaithTier.off:
        return 'Secular mode - no spiritual content';
      case FaithTier.light:
        return 'Minimal spiritual content with gentle encouragement';
      case FaithTier.disciple:
        return 'Active faith integration with daily devotions';
      case FaithTier.kingdom:
        return 'Complete spiritual journey with advanced features';
    }
  }

  /// Parse faith tier from string (with backward-compatibility migration support)
  /// Handles legacy capitalized strings and "Full" → disciple migration
  static FaithTier _parseFaithMode(String? modeString) {
    if (modeString == null) return FaithTier.off;
    
    // First try canonical lowercase strings
    final canonicalTier = parseFaithTier(modeString);
    if (canonicalTier != FaithTier.off || modeString.toLowerCase() == 'off') {
      return canonicalTier;
    }
    
    // Backward compatibility: handle legacy capitalized strings
    switch (modeString) {
      case 'Light':
        return FaithTier.light;
      case 'Full': // Migrate old 'Full' to 'Disciple'
        return FaithTier.disciple;
      case 'Disciple':
        return FaithTier.disciple;
      case 'Kingdom':
      case 'Kingdom Builder':
        return FaithTier.kingdom;
      case 'Off':
      default:
        return FaithTier.off;
    }
  }

  /// Convert faith tier to string (canonical lowercase)
  static String _faithModeToString(FaithTier tier) {
    return faithTierToString(tier);
  }

  /// Get urge threshold for micro-intervention based on faith tier
  static int urgeThresholdForMicro(FaithTier tier) {
    switch (tier) {
      case FaithTier.off:
        return 10; // Never show for Off mode
      case FaithTier.light:
        return 7;
      case FaithTier.disciple:
        return 6;
      case FaithTier.kingdom:
        return 5;
    }
  }

  /// Get ordered coping strategies based on faith tier
  static List<String> orderedCoping(FaithTier tier, List<String> baseStrategies, bool highUrge) {
    if (tier == FaithTier.off) {
      return baseStrategies;
    }

    final List<String> ordered = List.from(baseStrategies);
    
    // Pin faith-based strategies for Disciple and Kingdom modes
    if (tier == FaithTier.disciple || tier == FaithTier.kingdom) {
      final faithStrategies = ['read_scripture', 'pray'];
      for (final strategy in faithStrategies) {
        if (ordered.contains(strategy)) {
          ordered.remove(strategy);
          ordered.insert(0, strategy);
        }
      }
    }

    // For high urge situations, prioritize calming strategies
    if (highUrge) {
      final calmingStrategies = ['breathing', 'read_scripture', 'pray'];
      for (final strategy in calmingStrategies) {
        if (ordered.contains(strategy)) {
          ordered.remove(strategy);
          ordered.insert(0, strategy);
        }
      }
    }

    return ordered;
  }

  /// Get default journal prompt based on faith tier
  static String? defaultJournalPrompt(FaithTier tier) {
    switch (tier) {
      case FaithTier.off:
        return null;
      case FaithTier.light:
        return 'What brought you peace today?';
      case FaithTier.disciple:
        return 'How did you see God working in your life today?';
      case FaithTier.kingdom:
        return 'What spiritual growth did you experience today?';
    }
  }

  /// Get faith prompt chips for journal
  static List<String> getFaithPromptChips(FaithTier tier) {
    switch (tier) {
      case FaithTier.off:
        return [];
      case FaithTier.light:
        return ['What brought you peace today?'];
      case FaithTier.disciple:
        return [
          'How did you see God working in your life today?',
          'What scripture spoke to you today?',
          'How did you serve others today?',
        ];
      case FaithTier.kingdom:
        return [
          'What spiritual growth did you experience today?',
          'How did you advance God\'s kingdom today?',
          'What did you learn about God\'s character today?',
          'How did you share your faith today?',
        ];
    }
  }
}
