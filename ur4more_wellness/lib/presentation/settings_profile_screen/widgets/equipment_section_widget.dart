import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/settings/setting_card.dart';
import '../../../widgets/settings/toggle_tile.dart';
import '../../../design/tokens.dart';

class EquipmentSectionWidget extends StatelessWidget {
  final bool hasBodyweight;
  final bool hasResistanceBands;
  final bool hasPullupBar;
  final Function(bool) onBodyweightChanged;
  final Function(bool) onResistanceBandsChanged;
  final Function(bool) onPullupBarChanged;

  const EquipmentSectionWidget({
    super.key,
    required this.hasBodyweight,
    required this.hasResistanceBands,
    required this.hasPullupBar,
    required this.onBodyweightChanged,
    required this.onResistanceBandsChanged,
    required this.onPullupBarChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SettingCard(
      title: 'Equipment Configuration',
      subtitle: 'Select your available equipment to customize workout plans',
      icon: CustomIconWidget(
        iconName: 'fitness_center',
        color: colorScheme.primary,
        size: 24,
      ),
      children: [
        ToggleTile(
          title: 'Bodyweight Exercises',
          subtitle: 'Push-ups, squats, planks, and more',
          icon: CustomIconWidget(
            iconName: 'accessibility',
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          value: hasBodyweight,
          onChanged: onBodyweightChanged,
        ),
        const SizedBox(height: AppSpace.x3),
        ToggleTile(
          title: 'Resistance Bands',
          subtitle: 'Elastic bands for strength training',
          icon: CustomIconWidget(
            iconName: 'sports_gymnastics',
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          value: hasResistanceBands,
          onChanged: onResistanceBandsChanged,
        ),
        const SizedBox(height: AppSpace.x3),
        ToggleTile(
          title: 'Pullup Bar',
          subtitle: 'Doorway or wall-mounted bar',
          icon: CustomIconWidget(
            iconName: 'sports_martial_arts',
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          value: hasPullupBar,
          onChanged: onPullupBarChanged,
        ),
      ],
    );
  }

}
