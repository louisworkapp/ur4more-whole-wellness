import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class WorkoutCard extends StatelessWidget {
  final Map<String, dynamic> workout;
  final VoidCallback onTap;
  final VoidCallback? onFavorite;
  final VoidCallback? onSchedule;
  final VoidCallback? onShare;

  const WorkoutCard({
    super.key,
    required this.workout,
    required this.onTap,
    this.onFavorite,
    this.onSchedule,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity( 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            workout['name'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            workout['description'] as String,
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w400,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Container(
                      width: 20.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: colorScheme.surfaceContainerHighest,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CustomImageWidget(
                          imageUrl: workout['thumbnail'] as String,
                          width: 20.w,
                          height: 12.h,
                          fit: BoxFit.cover,
                          semanticLabel:
                              workout['thumbnailSemanticLabel'] as String,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    _buildInfoChip(
                      context,
                      icon: 'schedule',
                      label: '${workout['duration']} min',
                      colorScheme: colorScheme,
                    ),
                    SizedBox(width: 2.w),
                    _buildInfoChip(
                      context,
                      icon: 'local_fire_department',
                      label: '${workout['calories']} cal',
                      colorScheme: colorScheme,
                    ),
                    SizedBox(width: 2.w),
                    _buildDifficultyChip(
                      context,
                      difficulty: workout['difficulty'] as String,
                      colorScheme: colorScheme,
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      child: _buildEquipmentRow(
                        context,
                        equipment:
                            (workout['equipment'] as List).cast<String>(),
                        colorScheme: colorScheme,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: AppTheme.secondaryLight.withOpacity( 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'stars',
                            color: AppTheme.secondaryLight,
                            size: 16,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            '${workout['points']} pts',
                            style: GoogleFonts.inter(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.secondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context, {
    required String icon,
    required String label,
    required ColorScheme colorScheme,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: icon,
            color: colorScheme.onSurfaceVariant,
            size: 14,
          ),
          SizedBox(width: 1.w),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyChip(
    BuildContext context, {
    required String difficulty,
    required ColorScheme colorScheme,
  }) {
    Color difficultyColor;
    switch (difficulty.toLowerCase()) {
      case 'beginner':
        difficultyColor = AppTheme.successLight;
        break;
      case 'intermediate':
        difficultyColor = AppTheme.secondaryLight;
        break;
      case 'advanced':
        difficultyColor = AppTheme.errorLight;
        break;
      default:
        difficultyColor = colorScheme.onSurfaceVariant;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: difficultyColor.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        difficulty,
        style: GoogleFonts.inter(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: difficultyColor,
        ),
      ),
    );
  }

  Widget _buildEquipmentRow(
    BuildContext context, {
    required List<String> equipment,
    required ColorScheme colorScheme,
  }) {
    return Row(
      children: equipment.take(3).map((eq) {
        return Padding(
          padding: EdgeInsets.only(right: 1.w),
          child: CustomIconWidget(
            iconName: _getEquipmentIcon(eq),
            color: colorScheme.onSurfaceVariant,
            size: 16,
          ),
        );
      }).toList(),
    );
  }

  String _getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'bodyweight':
        return 'accessibility_new';
      case 'bands':
        return 'fitness_center';
      case 'pullup bar':
        return 'sports_gymnastics';
      default:
        return 'sports_handball';
    }
  }
}
