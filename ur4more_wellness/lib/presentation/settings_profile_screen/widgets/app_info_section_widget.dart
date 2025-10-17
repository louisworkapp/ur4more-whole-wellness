import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/settings/setting_card.dart';
import '../../../design/tokens.dart';

class AppInfoSectionWidget extends StatelessWidget {
  final String appVersion;
  final VoidCallback onContactSupport;
  final VoidCallback onViewHelp;
  final VoidCallback onRateApp;

  const AppInfoSectionWidget({
    super.key,
    required this.appVersion,
    required this.onContactSupport,
    required this.onViewHelp,
    required this.onRateApp,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SettingCard(
      title: 'App Information',
      subtitle: 'Version information and support options',
      icon: CustomIconWidget(
        iconName: 'info',
        color: colorScheme.primary,
        size: 24,
      ),
      children: [
        _buildAppVersionInfo(theme, colorScheme),
        const SizedBox(height: AppSpace.x4),
        _buildSupportActions(context, theme, colorScheme),
      ],
    );
  }

  Widget _buildAppVersionInfo(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.x3),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'auto_awesome',
              color: colorScheme.primary,
              size: 32,
            ),
          ),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UR4MORE Wellness',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpace.x1),
                Text(
                  'Version $appVersion',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpace.x1),
                Text(
                  'Faith-based holistic wellness platform',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportActions(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildSupportButton(
          context,
          theme,
          colorScheme,
          'Help & FAQ',
          'Get answers to common questions',
          'help_outline',
          onViewHelp,
        ),
        const SizedBox(height: AppSpace.x3),
        _buildSupportButton(
          context,
          theme,
          colorScheme,
          'Contact Support',
          'Get help from our support team',
          'support_agent',
          onContactSupport,
        ),
        const SizedBox(height: AppSpace.x3),
        _buildSupportButton(
          context,
          theme,
          colorScheme,
          'Rate This App',
          'Share your experience with others',
          'star_rate',
          onRateApp,
        ),
      ],
    );
  }

  Widget _buildSupportButton(
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
              iconName: 'chevron_right',
              color: colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
