import 'package:flutter/foundation.dart';

class Telemetry {
  static void logEvent(String name, Map<String, dynamic>? props) {
    if (kDebugMode) {
      debugPrint('📊 Analytics Event: $name');
      if (props != null && props.isNotEmpty) {
        debugPrint('   Props: $props');
      }
    }

    // In production, this would send to actual analytics service
    // Examples: Firebase Analytics, Mixpanel, Amplitude, etc.
  }

  // Predefined event methods for consistency
  static void workoutDone(String userId, String workoutType, int duration) {
    logEvent('workout_done', {
      'user_id': userId,
      'workout_type': workoutType,
      'duration_minutes': duration,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void reflectionSaved(String userId, int wordCount, String mood) {
    logEvent('reflection_saved', {
      'user_id': userId,
      'word_count': wordCount,
      'mood': mood,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void devotionDone(String userId, String reference) {
    logEvent('devotion_done', {
      'user_id': userId,
      'reference': reference,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void streak7Award(String userId, int currentStreak) {
    logEvent('streak_7_award', {
      'user_id': userId,
      'current_streak': currentStreak,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void redeem(String userId, String rewardName, int pointsCost) {
    logEvent('redeem', {
      'user_id': userId,
      'reward_name': rewardName,
      'points_cost': pointsCost,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  // User journey events
  static void appOpened(String userId) {
    logEvent('app_opened', {
      'user_id': userId,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void featureUsed(String userId, String feature) {
    logEvent('feature_used', {
      'user_id': userId,
      'feature': feature,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void checkInCompleted(String userId, int pointsEarned) {
    logEvent('checkin_completed', {
      'user_id': userId,
      'points_earned': pointsEarned,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  static void faithModeChanged(
    String userId,
    String newMode,
    String previousMode,
  ) {
    logEvent('faith_mode_changed', {
      'user_id': userId,
      'new_mode': newMode,
      'previous_mode': previousMode,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
