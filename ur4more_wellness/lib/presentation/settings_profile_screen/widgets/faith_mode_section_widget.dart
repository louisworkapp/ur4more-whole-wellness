import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../services/faith_service.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/settings/setting_card.dart';
import '../../../widgets/settings/choice_tile.dart';

class FaithModeSectionWidget extends StatelessWidget {
  final FaithMode faithMode;
  final ValueChanged<FaithMode?> onFaithModeChanged;

  const FaithModeSectionWidget({
    super.key,
    required this.faithMode,
    required this.onFaithModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SettingCard(
      title: 'Faith Mode Control',
      subtitle: 'Control spiritual content visibility across the app',
      icon: CustomIconWidget(
        iconName: 'auto_awesome',
        color: colorScheme.primary,
        size: 24,
      ),
      children: [
        ChoiceTile<FaithMode>(
          value: FaithMode.off,
          groupValue: faithMode,
          title: 'Off',
          subtitle: 'Secular mode - no spiritual content',
          icon: Icon(
            Icons.visibility_off,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          onChanged: onFaithModeChanged,
        ),
        const SizedBox(height: AppSpace.x3),
        ChoiceTile<FaithMode>(
          value: FaithMode.light,
          groupValue: faithMode,
          title: 'Light',
          subtitle: 'Minimal spiritual content with gentle encouragement',
          icon: Icon(
            Icons.wb_sunny_outlined,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          onChanged: onFaithModeChanged,
        ),
        const SizedBox(height: AppSpace.x3),
        ChoiceTile<FaithMode>(
          value: FaithMode.disciple,
          groupValue: faithMode,
          title: 'Disciple',
          subtitle: 'Active faith integration with daily devotions',
          icon: Icon(
            Icons.auto_awesome,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          onChanged: onFaithModeChanged,
        ),
        const SizedBox(height: AppSpace.x3),
        ChoiceTile<FaithMode>(
          value: FaithMode.kingdom,
          groupValue: faithMode,
          title: 'Kingdom Builder',
          subtitle: 'Complete spiritual journey with advanced features',
          icon: Icon(
            Icons.king_bed,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          onChanged: onFaithModeChanged,
        ),
      ],
    );
  }


}
