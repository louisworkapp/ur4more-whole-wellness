import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';

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
      margin: const EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
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
            padding: const EdgeInsets.all(AppSpace.x4),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 48,
                  height: 48,
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

                const SizedBox(width: AppSpace.x4),

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

                      const SizedBox(height: AppSpace.x1),

                      // Subtitle with specified color
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF475569),
                        ),
                      ),

                      const SizedBox(height: AppSpace.x4),

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

                const SizedBox(width: AppSpace.x2),

                // Points badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity( 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+$pointValue',
                    style: GoogleFonts.inter(
                      fontSize: min(12.0, (theme.textTheme.bodySmall?.fontSize ?? 12)),
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
