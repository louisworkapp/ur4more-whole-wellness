import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class SpiritualMilestoneWidget extends StatelessWidget {
  final List<Map<String, dynamic>> milestones;

  const SpiritualMilestoneWidget({
    super.key,
    required this.milestones,
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
          _buildMilestonesList(context, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.successLight.withValues(alpha: 0.1),
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
              color: AppTheme.successLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'emoji_events',
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
                  "Spiritual Milestones",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "Your faith journey achievements",
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
              color: AppTheme.secondaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "${milestones.where((m) => m["isCompleted"] == true).length}/${milestones.length}",
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMilestonesList(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: milestones.asMap().entries.map((entry) {
          final index = entry.key;
          final milestone = entry.value;
          final isLast = index == milestones.length - 1;

          return _buildMilestoneItem(
            context,
            colorScheme,
            milestone,
            isLast,
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMilestoneItem(
    BuildContext context,
    ColorScheme colorScheme,
    Map<String, dynamic> milestone,
    bool isLast,
  ) {
    final theme = Theme.of(context);
    final isCompleted = milestone["isCompleted"] == true;
    final isInProgress =
        milestone["progress"] != null && milestone["progress"] > 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 8.w,
              height: 8.w,
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppTheme.successLight
                    : isInProgress
                        ? AppTheme.secondaryLight
                        : colorScheme.outline.withValues(alpha: 0.3),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isCompleted
                      ? AppTheme.successLight
                      : isInProgress
                          ? AppTheme.secondaryLight
                          : colorScheme.outline,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? CustomIconWidget(
                        iconName: 'check',
                        color: Colors.white,
                        size: 16,
                      )
                    : isInProgress
                        ? Container(
                            width: 3.w,
                            height: 3.w,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 6.h,
                color: colorScheme.outline.withValues(alpha: 0.2),
                margin: EdgeInsets.symmetric(vertical: 1.h),
              ),
          ],
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Container(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 2.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        milestone["title"] as String? ?? "Milestone",
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isCompleted
                              ? colorScheme.onSurface
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    if (milestone["points"] != null)
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryLight.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          "+${milestone["points"]} pts",
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppTheme.secondaryLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 0.5.h),
                Text(
                  milestone["description"] as String? ??
                      "Complete this milestone to grow spiritually",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
                if (milestone["progress"] != null && !isCompleted) ...[
                  SizedBox(height: 1.h),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Progress",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            "${milestone["progress"]}/${milestone["target"] ?? 100}",
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 0.5.h),
                      LinearProgressIndicator(
                        value: (milestone["progress"] as num? ?? 0) /
                            (milestone["target"] as num? ?? 100),
                        backgroundColor:
                            colorScheme.outline.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.secondaryLight),
                        minHeight: 1.h,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  ),
                ],
                if (isCompleted && milestone["completedDate"] != null) ...[
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'calendar_today',
                        color: AppTheme.successLight,
                        size: 14,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        "Completed ${milestone["completedDate"]}",
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppTheme.successLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
