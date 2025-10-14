import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum AppThemeMode { light, dark, system }

class ThemeSectionWidget extends StatelessWidget {
  final AppThemeMode themeMode;
  final Function(AppThemeMode) onThemeModeChanged;

  const ThemeSectionWidget({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
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
                  iconName: 'palette',
                  color: colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Theme Settings',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Choose your preferred app appearance',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            _buildThemeOptions(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOptions(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        _buildThemeOption(
          theme,
          colorScheme,
          'Light Theme',
          'Clean and bright interface',
          'light_mode',
          AppThemeMode.light,
          themeMode == AppThemeMode.light,
        ),
        SizedBox(height: 2.h),
        _buildThemeOption(
          theme,
          colorScheme,
          'Dark Theme',
          'Easy on the eyes in low light',
          'dark_mode',
          AppThemeMode.dark,
          themeMode == AppThemeMode.dark,
        ),
        SizedBox(height: 2.h),
        _buildThemeOption(
          theme,
          colorScheme,
          'System Default',
          'Follows your device settings',
          'settings_brightness',
          AppThemeMode.system,
          themeMode == AppThemeMode.system,
        ),
      ],
    );
  }

  Widget _buildThemeOption(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String description,
    String iconName,
    AppThemeMode mode,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => onThemeModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary.withOpacity( 0.1)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary.withOpacity( 0.3)
                : colorScheme.outline.withOpacity( 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: isSelected
                    ? colorScheme.primary.withOpacity( 0.2)
                    : colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: iconName,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
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
            if (isSelected)
              Container(
                padding: EdgeInsets.all(1.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: CustomIconWidget(
                  iconName: 'check',
                  color: colorScheme.onPrimary,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
