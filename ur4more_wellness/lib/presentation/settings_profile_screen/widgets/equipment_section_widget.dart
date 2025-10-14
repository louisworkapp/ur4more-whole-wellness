import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

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
                  iconName: 'fitness_center',
                  color: colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Equipment Configuration',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Select your available equipment to customize workout plans',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            _buildEquipmentToggle(
              context,
              theme,
              colorScheme,
              'Bodyweight Exercises',
              'Push-ups, squats, planks, and more',
              'accessibility',
              hasBodyweight,
              onBodyweightChanged,
            ),
            SizedBox(height: 2.h),
            _buildEquipmentToggle(
              context,
              theme,
              colorScheme,
              'Resistance Bands',
              'Elastic bands for strength training',
              'sports_gymnastics',
              hasResistanceBands,
              onResistanceBandsChanged,
            ),
            SizedBox(height: 2.h),
            _buildEquipmentToggle(
              context,
              theme,
              colorScheme,
              'Pullup Bar',
              'Doorway or wall-mounted bar',
              'sports_martial_arts',
              hasPullupBar,
              onPullupBarChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentToggle(
    BuildContext context,
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
        color: value
            ? colorScheme.primary.withValues(alpha: 0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outline.withValues(alpha: 0.2),
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
}
