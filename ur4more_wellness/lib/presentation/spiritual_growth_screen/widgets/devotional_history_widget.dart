import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DevotionalHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  final Function(Map<String, dynamic>)? onDevotionalTap;

  const DevotionalHistoryWidget({
    super.key,
    required this.history,
    this.onDevotionalTap,
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
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, colorScheme),
          _buildHistoryList(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    final completedCount =
        history.where((h) => h["isCompleted"] == true).length;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.primaryLight.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'history',
              color: Colors.white,
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Devotional History",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "$completedCount devotions completed",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
            decoration: BoxDecoration(
              color: AppTheme.successLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'local_fire_department',
                  color: Colors.white,
                  size: 14,
                ),
                SizedBox(width: 1.w),
                Text(
                  "${_calculateStreak()} day streak",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
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

  Widget _buildHistoryList(BuildContext context, ColorScheme colorScheme) {
    return Container(
      constraints: BoxConstraints(maxHeight: 40.h),
      child: ListView.separated(
        padding: EdgeInsets.all(4.w),
        itemCount: history.length,
        separatorBuilder: (context, index) => SizedBox(height: 1.h),
        itemBuilder: (context, index) {
          final devotional = history[index];
          return _buildHistoryItem(context, colorScheme, devotional);
        },
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    ColorScheme colorScheme,
    Map<String, dynamic> devotional,
  ) {
    final theme = Theme.of(context);
    final isCompleted = devotional["isCompleted"] == true;

    return GestureDetector(
      onTap: () => onDevotionalTap?.call(devotional),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCompleted
                ? AppTheme.successLight.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.successLight
                    : colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: isCompleted
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 16,
                      )
                    : CustomIconWidget(
                        iconName: 'menu_book',
                        color: colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    devotional["title"] as String? ?? "Daily Devotion",
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    devotional["scripture"] as String? ?? "Scripture Reference",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.primaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: colorScheme.onSurfaceVariant,
                        size: 12,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        devotional["date"] as String? ?? "Today",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (isCompleted) ...[
                        SizedBox(width: 3.w),
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: colorScheme.onSurfaceVariant,
                          size: 12,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          devotional["completedTime"] as String? ?? "Morning",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                if (devotional["points"] != null)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryLight.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "+${devotional["points"]}",
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppTheme.secondaryLight,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                SizedBox(height: 1.h),
                if (devotional["isBookmarked"] == true)
                  CustomIconWidget(
                    iconName: 'bookmark',
                    color: AppTheme.secondaryLight,
                    size: 16,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  int _calculateStreak() {
    int streak = 0;
    final sortedHistory = List<Map<String, dynamic>>.from(history)
      ..sort((a, b) {
        final dateA =
            DateTime.tryParse(a["date"] as String? ?? "") ?? DateTime.now();
        final dateB =
            DateTime.tryParse(b["date"] as String? ?? "") ?? DateTime.now();
        return dateB.compareTo(dateA);
      });

    for (final devotional in sortedHistory) {
      if (devotional["isCompleted"] == true) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
