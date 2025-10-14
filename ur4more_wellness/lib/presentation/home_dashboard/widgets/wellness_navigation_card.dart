import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WellnessNavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconName;
  final Color primaryColor;
  final Color backgroundColor;
  final int pointValue;
  final double completionPercentage;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;

  const WellnessNavigationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.primaryColor,
    required this.backgroundColor,
    required this.pointValue,
    required this.completionPercentage,
    required this.isCompleted,
    required this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        color: Colors.white,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity( 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(iconName),
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),

                SizedBox(width: 4.w),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with new typography
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),

                      SizedBox(height: 0.5.h),

                      // Subtitle with specified color
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF475569),
                        ),
                      ),

                      SizedBox(height: 2.h),

                      // Progress indicator
                      LinearProgressIndicator(
                        value: completionPercentage,
                        backgroundColor:
                            theme.colorScheme.outline.withOpacity( 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 2.w),

                // Points badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity( 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+$pointValue',
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.primary,
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

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'psychology':
        return Icons.psychology_alt;
      case 'auto_awesome':
        return Icons.auto_awesome;
      default:
        return Icons.circle;
    }
  }
}
