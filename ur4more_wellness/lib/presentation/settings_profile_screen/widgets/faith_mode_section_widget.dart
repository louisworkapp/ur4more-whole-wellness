import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../services/faith_service.dart';
import '../../../design/tokens.dart';

class FaithModeSectionWidget extends StatelessWidget {
  final FaithMode faithMode;
  final Function(FaithMode) onFaithModeChanged;

  const FaithModeSectionWidget({
    super.key,
    required this.faithMode,
    required this.onFaithModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'auto_awesome',
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: AppSpace.x3),
                Text(
                  'Faith Mode Control',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.x2),
            Text(
              'Control spiritual content visibility across the app',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpace.x4),
            _buildFaithModeSelector(theme, colorScheme),
            const SizedBox(height: AppSpace.x4),
            _buildFaithModeDescription(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildFaithModeSelector(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildModeOption(
          theme,
          colorScheme,
          FaithMode.off,
          'Off',
          'Secular mode - no spiritual content',
          Icons.visibility_off,
        ),
        const SizedBox(height: AppSpace.x3),
        _buildModeOption(
          theme,
          colorScheme,
          FaithMode.light,
          'Light',
          'Minimal spiritual content with gentle encouragement',
          Icons.wb_sunny_outlined,
        ),
        const SizedBox(height: AppSpace.x3),
        _buildModeOption(
          theme,
          colorScheme,
          FaithMode.disciple,
          'Disciple',
          'Active faith integration with daily devotions',
          Icons.auto_awesome,
        ),
        const SizedBox(height: AppSpace.x3),
        _buildModeOption(
          theme,
          colorScheme,
          FaithMode.kingdom,
          'Kingdom Builder',
          'Complete spiritual journey with advanced features',
          Icons.king_bed,
        ),
      ],
    );
  }

  Widget _buildModeOption(
    ThemeData theme,
    ColorScheme colorScheme,
    FaithMode mode,
    String title,
    String description,
    IconData icon,
  ) {
    final isSelected = faithMode == mode;
    
    return GestureDetector(
      onTap: () => onFaithModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(AppSpace.x3),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpace.x2),
              decoration: BoxDecoration(
                color: isSelected 
                    ? colorScheme.primary.withOpacity(0.1)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
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
                      fontWeight: FontWeight.w600,
                      color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: AppSpace.x1),
                  Text(
                    description,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isSelected ? colorScheme.onPrimaryContainer.withOpacity(0.8) : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: colorScheme.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFaithModeDescription(ThemeData theme, ColorScheme colorScheme) {
    // Get description from FaithService
    final description = FaithService.getFaithModeLabel(faithMode);
    final details = FaithService.getFaithModeDescription(faithMode);
    
    IconData iconData;
    Color iconColor;

    switch (faithMode) {
      case FaithMode.off:
        iconData = Icons.visibility_off;
        iconColor = colorScheme.onSurfaceVariant;
        break;
      case FaithMode.light:
        iconData = Icons.wb_sunny_outlined;
        iconColor = colorScheme.secondary;
        break;
      case FaithMode.disciple:
        iconData = Icons.auto_awesome;
        iconColor = colorScheme.primary;
        break;
      case FaithMode.kingdom:
        iconData = Icons.king_bed;
        iconColor = colorScheme.primary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity( 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpace.x2),
            decoration: BoxDecoration(
              color: iconColor.withOpacity( 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              iconData,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: AppSpace.x2),
                Text(
                  details,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
