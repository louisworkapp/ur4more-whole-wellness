import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 4-tier Faith Mode system with XP progression
enum FaithMode { off, light, disciple, kingdom }

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
  static const Map<FaithMode, int> _dailyCaps = {
    FaithMode.off: 0,
    FaithMode.light: 10,
    FaithMode.disciple: 20,
    FaithMode.kingdom: 30,
  };

  // Tier upgrade thresholds
  static const int _lightToDiscipleThreshold = 200;
  static const int _discipleToKingdomThreshold = 600;

  /// Get current faith mode
  static Future<FaithMode> getFaithMode() async {
    final prefs = await SharedPreferences.getInstance();
    final modeString = prefs.getString(_faithModeKey);
    return _parseFaithMode(modeString);
  }

  /// Set faith mode
  static Future<void> setFaithMode(FaithMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_faithModeKey, _faithModeToString(mode));
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
    if (mode == FaithMode.off) {
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
  static Future<FaithMode?> getUpgradeableTier() async {
    final mode = await getFaithMode();
    final progress = await getFaithProgress();

    switch (mode) {
      case FaithMode.light:
        if (progress.xp >= _lightToDiscipleThreshold) {
          return FaithMode.disciple;
        }
        break;
      case FaithMode.disciple:
        if (progress.xp >= _discipleToKingdomThreshold) {
          return FaithMode.kingdom;
        }
        break;
      case FaithMode.off:
      case FaithMode.kingdom:
        return null; // No upgrades available
    }

    return null;
  }

  /// Get faith mode label
  static String getFaithModeLabel(FaithMode mode) {
    switch (mode) {
      case FaithMode.off:
        return 'Off';
      case FaithMode.light:
        return 'Light';
      case FaithMode.disciple:
        return 'Disciple';
      case FaithMode.kingdom:
        return 'Kingdom Builder';
    }
  }

  /// Get faith mode description
  static String getFaithModeDescription(FaithMode mode) {
    switch (mode) {
      case FaithMode.off:
        return 'Secular mode - no spiritual content';
      case FaithMode.light:
        return 'Minimal spiritual content with gentle encouragement';
      case FaithMode.disciple:
        return 'Active faith integration with daily devotions';
      case FaithMode.kingdom:
        return 'Complete spiritual journey with advanced features';
    }
  }

  /// Parse faith mode from string (with migration support)
  static FaithMode _parseFaithMode(String? modeString) {
    switch (modeString) {
      case 'Light':
        return FaithMode.light;
      case 'Full': // Migrate old 'Full' to 'Disciple'
        return FaithMode.disciple;
      case 'Disciple':
        return FaithMode.disciple;
      case 'Kingdom':
        return FaithMode.kingdom;
      case 'Off':
      default:
        return FaithMode.off;
    }
  }

  /// Convert faith mode to string
  static String _faithModeToString(FaithMode mode) {
    switch (mode) {
      case FaithMode.off:
        return 'Off';
      case FaithMode.light:
        return 'Light';
      case FaithMode.disciple:
        return 'Disciple';
      case FaithMode.kingdom:
        return 'Kingdom';
    }
  }

  /// Get urge threshold for micro-intervention based on faith mode
  static int urgeThresholdForMicro(FaithMode mode) {
    switch (mode) {
      case FaithMode.off:
        return 10; // Never show for Off mode
      case FaithMode.light:
        return 7;
      case FaithMode.disciple:
        return 6;
      case FaithMode.kingdom:
        return 5;
    }
  }

  /// Get ordered coping strategies based on faith mode
  static List<String> orderedCoping(FaithMode mode, List<String> baseStrategies, bool highUrge) {
    if (mode == FaithMode.off) {
      return baseStrategies;
    }

    final List<String> ordered = List.from(baseStrategies);
    
    // Pin faith-based strategies for Disciple and Kingdom modes
    if (mode == FaithMode.disciple || mode == FaithMode.kingdom) {
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

  /// Get default journal prompt based on faith mode
  static String? defaultJournalPrompt(FaithMode mode) {
    switch (mode) {
      case FaithMode.off:
        return null;
      case FaithMode.light:
        return 'What brought you peace today?';
      case FaithMode.disciple:
        return 'How did you see God working in your life today?';
      case FaithMode.kingdom:
        return 'What spiritual growth did you experience today?';
    }
  }

  /// Get faith prompt chips for journal
  static List<String> getFaithPromptChips(FaithMode mode) {
    switch (mode) {
      case FaithMode.off:
        return [];
      case FaithMode.light:
        return ['What brought you peace today?'];
      case FaithMode.disciple:
        return [
          'How did you see God working in your life today?',
          'What scripture spoke to you today?',
          'How did you serve others today?',
        ];
      case FaithMode.kingdom:
        return [
          'What spiritual growth did you experience today?',
          'How did you advance God\'s kingdom today?',
          'What did you learn about God\'s character today?',
          'How did you share your faith today?',
        ];
    }
  }
}
