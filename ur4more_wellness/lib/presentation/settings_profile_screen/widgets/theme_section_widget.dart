import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/settings/setting_card.dart';
import '../../../widgets/settings/choice_tile.dart';

enum AppThemeMode { light, dark, system }

class ThemeSectionWidget extends StatelessWidget {
  final AppThemeMode themeMode;
  final ValueChanged<AppThemeMode?> onThemeModeChanged;

  const ThemeSectionWidget({
    super.key,
    required this.themeMode,
    required this.onThemeModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SettingCard(
      title: 'Theme Settings',
      subtitle: 'Choose your preferred app appearance',
      icon: CustomIconWidget(
        iconName: 'palette',
        color: colorScheme.primary,
        size: 24,
      ),
      children: [
        ChoiceTile<AppThemeMode>(
          value: AppThemeMode.light,
          groupValue: themeMode,
          title: 'Light Mode',
          subtitle: 'Clean and bright interface',
          icon: Icon(
            Icons.light_mode,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          onChanged: onThemeModeChanged,
        ),
        const SizedBox(height: AppSpace.x3),
        ChoiceTile<AppThemeMode>(
          value: AppThemeMode.dark,
          groupValue: themeMode,
          title: 'Dark Theme',
          subtitle: 'Easy on the eyes in low light',
          icon: Icon(
            Icons.dark_mode,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          onChanged: onThemeModeChanged,
        ),
        const SizedBox(height: AppSpace.x3),
        ChoiceTile<AppThemeMode>(
          value: AppThemeMode.system,
          groupValue: themeMode,
          title: 'System Default',
          subtitle: 'Follows your device settings',
          icon: Icon(
            Icons.settings_brightness,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          onChanged: onThemeModeChanged,
        ),
      ],
    );
  }

}
