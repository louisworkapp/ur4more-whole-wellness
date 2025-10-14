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
                SizedBox(width: 2.w), // Reduced from 3.w
                Expanded( // Added Expanded to prevent overflow
                  child: Text(
                    'Equipment Configuration',
                    style: theme.textTheme.titleMedium?.copyWith( // Changed from titleLarge to titleMedium
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    overflow: TextOverflow.ellipsis, // Added overflow handling
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Select your available equipment to customize workout plans',
              style: theme.textTheme.bodySmall?.copyWith( // Changed from bodyMedium to bodySmall
                color: colorScheme.onSurfaceVariant,
              ),
              overflow: TextOverflow.ellipsis, // Added overflow handling
              maxLines: 2, // Allow text to wrap to 2 lines
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
            SizedBox(height: 1.5.h), // Reduced from 2.h
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
            SizedBox(height: 1.5.h), // Reduced from 2.h
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
      padding: EdgeInsets.all(2.w), // Reduced from 3.w
      decoration: BoxDecoration(
        color: value
            ? colorScheme.primary.withOpacity( 0.1)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value
              ? colorScheme.primary.withOpacity( 0.3)
              : colorScheme.outline.withOpacity( 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(1.5.w), // Reduced from 2.w
            decoration: BoxDecoration(
              color: value
                  ? colorScheme.primary.withOpacity( 0.2)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: value ? colorScheme.primary : colorScheme.onSurfaceVariant,
              size: 20, // Reduced from 24
            ),
          ),
          SizedBox(width: 2.w), // Reduced from 3.w
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith( // Changed from titleMedium to titleSmall
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis, // Added overflow handling
                  maxLines: 2, // Allow title to wrap to 2 lines
                ),
                SizedBox(height: 0.3.h), // Reduced from 0.5.h
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis, // Added overflow handling
                  maxLines: 2, // Allow description to wrap to 2 lines
                ),
              ],
            ),
          ),
          SizedBox(width: 1.w), // Added spacing before switch
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
