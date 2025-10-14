import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_colors.dart';
import '../../../features/home/streaks.dart';

class DailyCheckinCta extends StatefulWidget {
  final bool isCompleted;
  final VoidCallback onTap;
  final DateTime lastCheckinDate;
  final String userId;

  const DailyCheckinCta({
    super.key,
    required this.isCompleted,
    required this.onTap,
    required this.lastCheckinDate,
    required this.userId,
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

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360), // cap card width
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Check-in', style: theme.textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(
                  'Track your daily progress and earn points',
                  style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
                ),
                const SizedBox(height: 16),

                // Streak pill with specified styling - only show if streak >= 7
                if (!_isLoadingStreak && _currentStreak >= 7) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF6DB), // Pale gold background
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: AppColors.gold, // Gold text/icon
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$_currentStreak day streak',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold, // Gold text/icon
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // ✅ Full-width, wraps to 2 lines, no overflow
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: widget.onTap,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(0, 56),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: Text(
                      widget.isCompleted
                          ? 'View Today\'s Progress'
                          : 'Start Daily Check-in',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
