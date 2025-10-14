import 'package:flutter/material.dart';

class LevelBadge extends StatelessWidget {
  final int points;

  const LevelBadge({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    String label =
        points < 1000 ? 'Explorer' : (points < 5000 ? 'Builder' : 'Disciple');

    Color badgeColor =
        points < 1000
            ? Theme.of(context).colorScheme.secondary
            : (points < 5000
                ? Theme.of(context).colorScheme.tertiary
                : Theme.of(context).colorScheme.primary);

    IconData badgeIcon =
        points < 1000
            ? Icons.explore_outlined
            : (points < 5000
                ? Icons.build_outlined
                : Icons.workspace_premium_outlined);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withAlpha(77), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, size: 16, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Utility methods
  static String getLevelName(int points) {
    return points < 1000
        ? 'Explorer'
        : (points < 5000 ? 'Builder' : 'Disciple');
  }

  static int getPointsToNextLevel(int points) {
    if (points < 1000) {
      return 1000 - points;
    } else if (points < 5000) {
      return 5000 - points;
    }
    return 0; // Already at max level
  }

  static double getLevelProgress(int points) {
    if (points < 1000) {
      return points / 1000.0;
    } else if (points < 5000) {
      return (points - 1000) / 4000.0;
    }
    return 1.0; // Max level reached
  }

  static String getLevelDescription(int points) {
    if (points < 1000) {
      return "Just starting your wellness journey";
    } else if (points < 5000) {
      return "Building healthy habits consistently";
    } else {
      return "Dedicated to spiritual and physical growth";
    }
  }
}
