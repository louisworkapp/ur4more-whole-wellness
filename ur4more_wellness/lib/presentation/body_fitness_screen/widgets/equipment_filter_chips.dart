import 'package:flutter/material.dart';
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
    final colorScheme = Theme.of(context).colorScheme;

    FilterChip chip(String label) {
      final selected = selectedEquipment.contains(label);

      return FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onEquipmentToggle(label),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: const VisualDensity(horizontal: -3, vertical: -3),
        padding: EdgeInsets.zero,
        labelPadding: const EdgeInsets.symmetric(horizontal: 10),
        backgroundColor: colorScheme.surface.withOpacity(.55),
        selectedColor: colorScheme.primary.withOpacity(.18),
        side: BorderSide(color: colorScheme.outline.withOpacity(.25)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: selected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
        ),
      );
    }

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: availableEquipment.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => chip(availableEquipment[i]),
      ),
    );
  }
}
