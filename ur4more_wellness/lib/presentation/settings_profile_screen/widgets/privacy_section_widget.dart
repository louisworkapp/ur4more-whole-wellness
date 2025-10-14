import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PrivacySectionWidget extends StatelessWidget {
  final bool dataCollectionEnabled;
  final bool analyticsEnabled;
  final bool crashReportingEnabled;
  final Function(bool) onDataCollectionChanged;
  final Function(bool) onAnalyticsChanged;
  final Function(bool) onCrashReportingChanged;
  final VoidCallback onViewPrivacyPolicy;
  final VoidCallback onViewTerms;

  const PrivacySectionWidget({
    super.key,
    required this.dataCollectionEnabled,
    required this.analyticsEnabled,
    required this.crashReportingEnabled,
    required this.onDataCollectionChanged,
    required this.onAnalyticsChanged,
    required this.onCrashReportingChanged,
    required this.onViewPrivacyPolicy,
    required this.onViewTerms,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'privacy_tip',
                  color: colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Privacy Controls',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Manage your data privacy and sharing preferences',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            _buildPrivacyToggle(
              theme,
              colorScheme,
              'Data Collection',
              'Allow collection of wellness data for personalized insights',
              'data_usage',
              dataCollectionEnabled,
              onDataCollectionChanged,
            ),
            SizedBox(height: 2.h),
            _buildPrivacyToggle(
              theme,
              colorScheme,
              'Usage Analytics',
              'Help improve the app by sharing anonymous usage data',
              'analytics',
              analyticsEnabled,
              onAnalyticsChanged,
            ),
            SizedBox(height: 2.h),
            _buildPrivacyToggle(
              theme,
              colorScheme,
              'Crash Reporting',
              'Automatically send crash reports to help fix issues',
              'bug_report',
              crashReportingEnabled,
              onCrashReportingChanged,
            ),
            SizedBox(height: 3.h),
            _buildPrivacyLinks(context, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacyToggle(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String description,
    String iconName,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: value
                  ? colorScheme.primary.withValues(alpha: 0.2)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: value ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 24,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: colorScheme.primary,
            inactiveThumbColor: colorScheme.outline,
            inactiveTrackColor: colorScheme.surfaceContainerHighest,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyLinks(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildLinkButton(
          context,
          theme,
          colorScheme,
          'Privacy Policy',
          'View our privacy policy and data handling practices',
          'policy',
          onViewPrivacyPolicy,
        ),
        SizedBox(height: 2.h),
        _buildLinkButton(
          context,
          theme,
          colorScheme,
          'Terms of Service',
          'Read the terms and conditions for using UR4MORE',
          'description',
          onViewTerms,
        ),
      ],
    );
  }

  Widget _buildLinkButton(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String description,
    String iconName,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'open_in_new',
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
