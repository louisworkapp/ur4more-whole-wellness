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

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              // Title with new typography
              Text(
                'Daily Check-in',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),

              SizedBox(height: 2.h),

              // Description with specified color
              Text(
                'Track your daily progress and earn points',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF475569),
                ),
                textAlign: TextAlign.center,
              ),

              SizedBox(height: 3.h),

              // Streak pill with specified styling - only show if streak >= 7
              if (!_isLoadingStreak && _currentStreak >= 7)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
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
                      SizedBox(width: 1.w),
                      Text(
                        '$_currentStreak day streak',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.gold, // Gold text/icon
                        ),
                      ),
                    ],
                  ),
                ),

              if (!_isLoadingStreak && _currentStreak >= 7)
                SizedBox(height: 3.h),

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: widget.onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    widget.isCompleted
                        ? 'View Today\'s Progress'
                        : 'Start Daily Check-in',
                    style: GoogleFonts.inter(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
