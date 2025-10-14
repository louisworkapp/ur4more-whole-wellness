import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';

class FitnessHeader extends StatelessWidget {
  final int currentPoints;
  final int weeklyGoal;
  final double weeklyProgress;

  const FitnessHeader({
    super.key,
    required this.currentPoints,
    required this.weeklyGoal,
    required this.weeklyProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: Pad.card,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Body Fitness',
                      style: GoogleFonts.inter(
                        fontSize: 24, // Fixed font size instead of Sizer
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: AppSpace.x1),
                    Text(
                      'Strengthen your body',
                      style: GoogleFonts.inter(
                        fontSize: 14, // Fixed font size instead of Sizer
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity( 0.8),
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x1),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity( 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'stars',
                        color: AppTheme.secondaryLight,
                        size: 20,
                      ),
                      SizedBox(width: AppSpace.x2),
                      Text(
                        '$currentPoints',
                        style: GoogleFonts.inter(
                          fontSize: 16, // Fixed font size instead of Sizer
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpace.x3),
            Container(
              padding: Pad.card,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Weekly Progress',
                        style: GoogleFonts.inter(
                          fontSize: 14, // Fixed font size instead of Sizer
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${(weeklyProgress * 100).toInt()}%',
                        style: GoogleFonts.inter(
                          fontSize: 14, // Fixed font size instead of Sizer
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryLight,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpace.x1),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: weeklyProgress,
                      backgroundColor: Colors.white.withOpacity( 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.secondaryLight),
                      minHeight: 8,
                    ),
                  ),
                  SizedBox(height: AppSpace.x1),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(currentPoints * weeklyProgress).toInt()} / $weeklyGoal points',
                        style: GoogleFonts.inter(
                          fontSize: 12, // Fixed font size instead of Sizer
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity( 0.8),
                        ),
                      ),
                      Text(
                        '${weeklyGoal - (currentPoints * weeklyProgress).toInt()} to go',
                        style: GoogleFonts.inter(
                          fontSize: 12, // Fixed font size instead of Sizer
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity( 0.8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
