import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../features/home/streaks.dart';
import '../../../design/tokens.dart';
import '../../../widgets/phone_card.dart';

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
    final t = Theme.of(context).textTheme;
    
    return PhoneCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Daily Check-in', style: t.titleLarge ?? AppText.title),
          const SizedBox(height: AppSpace.x3),
          Text('Track your daily progress and earn points',
              style: t.bodyMedium?.copyWith(color: Colors.white70) ?? AppText.body.merge(AppText.mutED)),
          const SizedBox(height: AppSpace.x2),
          
          // Alarm Clock & Morning Check-in button
          Container(
            width: double.infinity,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amber.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Navigator.of(context).pushNamed('/planner/morning-checkin'),
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.alarm,
                        color: Colors.amber,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Planner and Alarms',
                        style: t.bodyMedium?.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpace.x4),

          // Streak pill with specified styling - only show if streak >= 7
          if (!_isLoadingStreak && _currentStreak >= 7) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.x3, vertical: AppSpace.x1),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF6DB), // Pale gold background
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: AppColors.gold, // Gold text/icon
                    size: 16,
                  ),
                  const SizedBox(width: AppSpace.x1),
                  Text(
                    '$_currentStreak day streak',
                    style: t.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.gold, // Gold text/icon
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.x4),
          ],

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onTap,
              child: Text(
                widget.isCompleted
                    ? 'View Today\'s Progress'
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
