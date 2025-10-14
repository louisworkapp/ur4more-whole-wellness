import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class EquipmentFilterChips extends StatelessWidget {
  final List<String> selectedEquipment;
  final Function(String) onEquipmentToggle;
  final List<String> availableEquipment;

  const EquipmentFilterChips({
    super.key,
    required this.selectedEquipment,
    required this.onEquipmentToggle,
    required this.availableEquipment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: availableEquipment.length,
        separatorBuilder: (context, index) => SizedBox(width: 2.w),
        itemBuilder: (context, index) {
          final equipment = availableEquipment[index];
          final isSelected = selectedEquipment.contains(equipment);

          return GestureDetector(
            onTap: () => onEquipmentToggle(equipment),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                // Selected chip: primary background + white text
                // Unselected chip: outline by default
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : colorScheme.outline.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: _getEquipmentIcon(equipment),
                    color: isSelected
                        ? Colors.white
                        : colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    equipment,
                    style: GoogleFonts.inter(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? Colors.white
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getEquipmentIcon(String equipment) {
    switch (equipment.toLowerCase()) {
      case 'bodyweight':
        return 'accessibility_new';
      case 'bands':
        return 'fitness_center';
      case 'pullup bar':
        return 'sports_gymnastics';
      default:
        return 'sports_handball';
    }
  }
}
