import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

enum FaithMode { off, light, full }

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
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
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
                SizedBox(width: 3.w),
                Text(
                  'Faith Mode Control',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 1.h),
            Text(
              'Control spiritual content visibility across the app',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 3.h),
            _buildFaithModeSelector(theme, colorScheme),
            SizedBox(height: 3.h),
            _buildFaithModeDescription(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildFaithModeSelector(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildFaithModeOption(
            theme,
            colorScheme,
            'Off',
            FaithMode.off,
            faithMode == FaithMode.off,
          ),
          _buildFaithModeOption(
            theme,
            colorScheme,
            'Light',
            FaithMode.light,
            faithMode == FaithMode.light,
          ),
          _buildFaithModeOption(
            theme,
            colorScheme,
            'Full',
            FaithMode.full,
            faithMode == FaithMode.full,
          ),
        ],
      ),
    );
  }

  Widget _buildFaithModeOption(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    FaithMode mode,
    bool isSelected,
  ) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onFaithModeChanged(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withOpacity( 0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFaithModeDescription(ThemeData theme, ColorScheme colorScheme) {
    String description;
    String details;
    IconData iconData;
    Color iconColor;

    switch (faithMode) {
      case FaithMode.off:
        description = 'Secular Mode';
        details =
            'No spiritual content will be shown. Focus on physical and mental wellness only.';
        iconData = Icons.visibility_off;
        iconColor = colorScheme.onSurfaceVariant;
        break;
      case FaithMode.light:
        description = 'Light Faith Mode';
        details =
            'Minimal spiritual content with optional devotions and gentle faith-based encouragement.';
        iconData = Icons.wb_sunny_outlined;
        iconColor = colorScheme.secondary;
        break;
      case FaithMode.full:
        description = 'Full Faith Mode';
        details =
            'Complete spiritual integration with daily devotions, scripture references, and faith-based wellness content.';
        iconData = Icons.auto_awesome;
        iconColor = colorScheme.primary;
        break;
    }

    return Container(
      padding: EdgeInsets.all(3.w),
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
            padding: EdgeInsets.all(2.w),
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
          SizedBox(width: 3.w),
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
                SizedBox(height: 1.h),
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
