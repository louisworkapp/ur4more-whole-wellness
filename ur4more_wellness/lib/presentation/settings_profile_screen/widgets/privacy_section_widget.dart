import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/settings/setting_card.dart';
import '../../../widgets/settings/toggle_tile.dart';
import '../../../design/tokens.dart';

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

    return SettingCard(
      title: 'Privacy Controls',
      subtitle: 'Manage your data privacy and sharing preferences',
      icon: CustomIconWidget(
        iconName: 'privacy_tip',
        color: colorScheme.primary,
        size: 24,
      ),
      children: [
        ToggleTile(
          title: 'Data Collection',
          subtitle: 'Allow collection of wellness data for personalized insights',
          icon: CustomIconWidget(
            iconName: 'data_usage',
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          value: dataCollectionEnabled,
          onChanged: onDataCollectionChanged,
        ),
        const SizedBox(height: AppSpace.x3),
        ToggleTile(
          title: 'Usage Analytics',
          subtitle: 'Help improve the app by sharing anonymous usage data',
          icon: CustomIconWidget(
            iconName: 'analytics',
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          value: analyticsEnabled,
          onChanged: onAnalyticsChanged,
        ),
        const SizedBox(height: AppSpace.x3),
        ToggleTile(
          title: 'Crash Reporting',
          subtitle: 'Automatically send crash reports to help fix issues',
          icon: CustomIconWidget(
            iconName: 'bug_report',
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          value: crashReportingEnabled,
          onChanged: onCrashReportingChanged,
        ),
        const SizedBox(height: AppSpace.x4),
        _buildPrivacyLinks(context, theme, colorScheme),
      ],
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
        const SizedBox(height: AppSpace.x3),
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
        padding: const EdgeInsets.all(AppSpace.x3),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity( 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpace.x3),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpace.x3),
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
                  const SizedBox(height: AppSpace.x1),
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
