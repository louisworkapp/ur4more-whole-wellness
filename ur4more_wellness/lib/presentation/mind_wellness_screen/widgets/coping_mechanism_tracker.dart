import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class CopingMechanismTracker extends StatelessWidget {
  final List<Map<String, dynamic>> copingStrategies;
  final Function(String) onStrategyCompleted;

  const CopingMechanismTracker({
    super.key,
    required this.copingStrategies,
    required this.onStrategyCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'psychology',
                    color: const Color(0xFF0FA97A),
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Coping Strategies',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0FA97A).withOpacity( 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_getCompletedCount()}/${copingStrategies.length}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: const Color(0xFF0FA97A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              _buildProgressBar(theme, colorScheme),
              SizedBox(height: 2.h),
              ...copingStrategies.map((strategy) => _buildStrategyItem(
                    context,
                    strategy,
                    theme,
                    colorScheme,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(ThemeData theme, ColorScheme colorScheme) {
    final completedCount = _getCompletedCount();
    final progress = copingStrategies.isEmpty
        ? 0.0
        : completedCount / copingStrategies.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Progress',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF0FA97A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colorScheme.outline.withOpacity( 0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0FA97A)),
          minHeight: 0.8.h,
        ),
      ],
    );
  }

  Widget _buildStrategyItem(
    BuildContext context,
    Map<String, dynamic> strategy,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isCompleted = strategy["isCompleted"] as bool? ?? false;
    final pointsReward = strategy["pointsReward"] as int? ?? 0;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => onStrategyCompleted(strategy["id"] as String),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 6.w,
              height: 6.w,
              decoration: BoxDecoration(
                color:
                    isCompleted ? const Color(0xFF0FA97A) : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? const Color(0xFF0FA97A)
                      : colorScheme.outline,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isCompleted
                  ? CustomIconWidget(
                      iconName: 'check',
                      color: Colors.white,
                      size: 16,
                    )
                  : null,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strategy["title"] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isCompleted
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (strategy["description"] != null)
                  Padding(
                    padding: EdgeInsets.only(top: 0.5.h),
                    child: Text(
                      strategy["description"] as String,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                if (strategy["duration"] != null)
                  Padding(
                    padding: EdgeInsets.only(top: 0.5.h),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: colorScheme.onSurfaceVariant,
                          size: 12,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          '${strategy["duration"]} min',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (pointsReward > 0)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 2.w,
                vertical: 0.5.h,
              ),
              decoration: BoxDecoration(
                color: isCompleted
                    ? const Color(0xFF0FA97A).withOpacity( 0.1)
                    : const Color(0xFFC9A227).withOpacity( 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: isCompleted ? 'check_circle' : 'stars',
                    color: isCompleted
                        ? const Color(0xFF0FA97A)
                        : const Color(0xFFC9A227),
                    size: 12,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    isCompleted ? 'Earned' : '+$pointsReward',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isCompleted
                          ? const Color(0xFF0FA97A)
                          : const Color(0xFFC9A227),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  int _getCompletedCount() {
    return copingStrategies
        .where((strategy) => strategy["isCompleted"] as bool? ?? false)
        .length;
  }
}
