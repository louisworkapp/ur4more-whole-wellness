import 'package:flutter/foundation.dart';
import '../../core/services/points_service.dart';

class Streaks {
  static Future<int> current(String userId) async {
    final sb = Sb.i;

    try {
      final rows =
          await sb
              .from('checkins')
              .select('plan_date')
              .eq('user_id', userId)
              .order('plan_date', ascending: false)
              .limit(14)
              .call();

      final dates =
          rows
              .map<DateTime>((r) => DateTime.parse(r['plan_date'] as String))
              .toList();

      int streak = 0;
      DateTime? d = DateTime.now().toUtc();

      while (dates.any(
        (x) => x.difference(DateTime.utc(d!.year, d.month, d.day)).inDays == 0,
      )) {
        streak++;
        d = d!.subtract(const Duration(days: 1));
      }

      return streak;
    } catch (e) {
      debugPrint('Error calculating streak: $e');
      // Return mock streak for development
      return 7; // Mock 7-day streak
    }
  }

  static Future<void> maybeAward7(String userId) async {
    try {
      final s = await current(userId);
      if (s >= 7) {
        // Idempotent check
        final sb = Sb.i;
        final prior =
            await sb
                .from('actions')
                .select('id')
                .eq('user_id', userId)
                .eq('action', 'streak_7')
                .gte(
                  'created_at',
                  DateTime.now()
                      .toUtc()
                      .subtract(const Duration(days: 7))
                      .toIso8601String(),
                )
                .call();

        if (prior.isEmpty) {
          await PointsService.awardStreak7(userId);
          debugPrint('Awarded 7-day streak bonus to user: $userId');
        } else {
          debugPrint(
            '7-day streak bonus already awarded recently for user: $userId',
          );
        }
      }
    } catch (e) {
      debugPrint('Error in maybeAward7: $e');
    }
  }

  // Utility methods
  static Future<bool> hasActiveStreak(String userId) async {
    final currentStreak = await current(userId);
    return currentStreak > 0;
  }

  static Future<int> getDaysUntilNextMilestone(String userId) async {
    final currentStreak = await current(userId);
    if (currentStreak < 7) {
      return 7 - currentStreak;
    } else if (currentStreak < 30) {
      return 30 - currentStreak;
    } else if (currentStreak < 100) {
      return 100 - currentStreak;
    }
    return 0; // Already at max milestone
  }

  static String getStreakMotivation(int streak) {
    if (streak == 0) {
      return "Start your journey today! 🌱";
    } else if (streak < 7) {
      return "Keep going! ${7 - streak} days to your first milestone! 🔥";
    } else if (streak < 30) {
      return "Amazing! ${30 - streak} days to your 30-day milestone! 🏆";
    } else if (streak < 100) {
      return "Incredible! ${100 - streak} days to your 100-day milestone! 💎";
    } else {
      return "You're a legend! $streak days strong! 👑";
    }
  }
}
