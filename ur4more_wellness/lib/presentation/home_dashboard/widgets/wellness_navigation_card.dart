import 'dart:math';
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
      margin: EdgeInsets.symmetric(horizontal: min(4.w, 16.0), vertical: min(1.h, 8.0)),
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
            padding: EdgeInsets.all(min(4.w, 16.0)),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: min(12.w, 48.0),
                  height: min(12.w, 48.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(iconName),
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),

                SizedBox(width: min(4.w, 16.0)),

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

                      SizedBox(height: min(0.5.h, 4.0)),

                      // Subtitle with specified color
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF475569),
                        ),
                      ),

                      SizedBox(height: min(2.h, 16.0)),

                      // Progress indicator
                      LinearProgressIndicator(
                        value: completionPercentage,
                        backgroundColor:
                            theme.colorScheme.outline.withValues(alpha: 0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary),
                        minHeight: 4,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: min(2.w, 8.0)),

                // Points badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: min(2.w, 8.0), vertical: min(1.h, 8.0)),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
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
