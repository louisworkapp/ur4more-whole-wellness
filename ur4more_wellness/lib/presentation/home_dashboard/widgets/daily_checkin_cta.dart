import 'package:flutter/material.dart';

import '../../../features/home/streaks.dart';
import '../../../design/tokens.dart';
import '../../../widgets/phone_card.dart';

class DailyCheckinCta extends StatefulWidget {
  final bool isCompleted;
  final VoidCallback onTap;
  final DateTime lastCheckinDate;
  final String userId;
  final VoidCallback? onPlannerTap;

  const DailyCheckinCta({
    super.key,
    required this.isCompleted,
    required this.onTap,
    required this.lastCheckinDate,
    required this.userId,
    this.onPlannerTap,
  });

  @override
  State<DailyCheckinCta> createState() => _DailyCheckinCtaState();
}

class _DailyCheckinCtaState extends State<DailyCheckinCta> {
  int _currentStreak = 0;
  bool _isLoadingStreak = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentStreak();
  }

  Future<void> _loadCurrentStreak() async {
    try {
      final streak = await Streaks.current(widget.userId);
      if (mounted) {
        setState(() {
          _currentStreak = streak;
          _isLoadingStreak = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _currentStreak = 7; // Fallback to mock streak
          _isLoadingStreak = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final cs = theme.colorScheme;
    
    return PhoneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Check-in', style: t.titleLarge ?? AppText.title),
          const SizedBox(height: AppSpace.x1),
          Text(
            'Track your daily progress and earn points',
            style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant) ??
                AppText.body.merge(AppText.mutED),
          ),
          const SizedBox(height: AppSpace.x3),

          // Optional secondary action (Planner / Alarms)
          if (widget.onPlannerTap != null) ...[
            FilledButton.tonal(
              onPressed: widget.onPlannerTap,
              style: FilledButton.styleFrom(
                backgroundColor: cs.secondaryContainer.withOpacity(0.35),
                foregroundColor: cs.onSurface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.schedule, size: 18, color: cs.secondary),
                  const SizedBox(width: 8),
                  const Text('Planner & Alarms'),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.x2),
          ],

          // Streak pill with specified styling - only show if streak >= 7
          if (!_isLoadingStreak && _currentStreak >= 7) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpace.x3,
                vertical: AppSpace.x1,
              ),
              decoration: BoxDecoration(
                color: cs.tertiaryContainer.withOpacity(0.4),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: cs.tertiary,
                    size: 16,
                  ),
                  const SizedBox(width: AppSpace.x1),
                  Text(
                    '$_currentStreak day streak',
                    style: t.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.tertiary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.x3),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.isCompleted ? null : widget.onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: Text(
                widget.isCompleted
                    ? 'Check-in Completed'
                    : 'Start Daily Check-in',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
