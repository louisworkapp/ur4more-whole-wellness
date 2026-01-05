import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../services/faith_service.dart';
import '../../../design/tokens.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/settings/setting_card.dart';
import '../../../widgets/settings/choice_tile.dart';

class FaithModeSectionWidget extends StatelessWidget {
  final FaithTier faithMode;
  final ValueChanged<FaithTier?> onFaithModeChanged;
  final VoidCallback? onFaithModeEnabled;

  const FaithModeSectionWidget({
    super.key,
    required this.faithMode,
    required this.onFaithModeChanged,
    this.onFaithModeEnabled,
  });

  void _handleFaithModeChange(FaithTier? newMode) {
    // Check if faith mode is being enabled (from off to any faith mode)
    if (faithMode == FaithTier.off && newMode != null && newMode != FaithTier.off) {
      // Call the callback to show congratulations
      onFaithModeEnabled?.call();
    }
    
    // Always call the original callback
    onFaithModeChanged(newMode);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SettingCard(
      title: 'Faith Mode Control',
      subtitle: 'Control spiritual content visibility across the app',
      icon: CustomIconWidget(
        iconName: 'auto_awesome',
        color: T.gold, // Faith mode: golden icon
        size: 24,
      ),
      children: [
        ChoiceTile<FaithTier>(
          value: FaithTier.off,
          groupValue: faithMode,
          title: 'Off',
          subtitle: 'Secular mode - no spiritual content',
          icon: Icon(
            Icons.visibility_off,
            color: T.ink500, // Secular mode: neutral color
            size: 24,
          ),
          onChanged: _handleFaithModeChange,
        ),
        const SizedBox(height: AppSpace.x3),
        ChoiceTile<FaithTier>(
          value: FaithTier.light,
          groupValue: faithMode,
          title: 'Light',
          subtitle: 'Minimal spiritual content with gentle encouragement',
          icon: Icon(
            Icons.wb_sunny_outlined,
            color: T.gold, // Faith mode: golden color
            size: 24,
          ),
          onChanged: _handleFaithModeChange,
        ),
        const SizedBox(height: AppSpace.x3),
        ChoiceTile<FaithTier>(
          value: FaithTier.disciple,
          groupValue: faithMode,
          title: 'Disciple',
          subtitle: 'Active faith integration with daily devotions',
          icon: Icon(
            Icons.auto_awesome,
            color: T.gold, // Faith mode: golden color
            size: 24,
          ),
          onChanged: _handleFaithModeChange,
        ),
        const SizedBox(height: AppSpace.x3),
        ChoiceTile<FaithTier>(
          value: FaithTier.kingdom,
          groupValue: faithMode,
          title: 'Kingdom Builder',
          subtitle: 'Complete spiritual journey with advanced features',
          icon: Icon(
            Icons.king_bed,
            color: T.gold, // Faith mode: golden color
            size: 24,
          ),
          onChanged: _handleFaithModeChange,
        ),
      ],
    );
  }


}
