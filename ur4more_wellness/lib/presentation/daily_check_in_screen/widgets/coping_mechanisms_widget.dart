import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/brand_rules.dart';
import '../../../widgets/custom_icon_widget.dart';

class CopingMechanismsWidget extends StatefulWidget {
  final List<String> selectedMechanisms;
  final FaithMode faithMode;
  final ValueChanged<List<String>> onChanged;

  const CopingMechanismsWidget({
    super.key,
    required this.selectedMechanisms,
    required this.faithMode,
    required this.onChanged,
  });

  @override
  State<CopingMechanismsWidget> createState() => _CopingMechanismsWidgetState();
}

class _CopingMechanismsWidgetState extends State<CopingMechanismsWidget> {
  // Faith-safe coping strategies with updated naming
  final List<Map<String, dynamic>> _copingStrategies = [
    {
      'name':
          'Prayer & Breathing', // Updated from "Prayer/Meditation" 'icon': 'self_improvement',
      'points': 5,
      'key': 'breathing'
    },
    {
      'name': 'Read Scripture',
      'icon': 'menu_book',
      'points': 5,
      'key': 'scripture'
    },
    {
      'name': 'Physical Exercise',
      'icon': 'fitness_center',
      'points': 5,
      'key': 'exercise'
    },
    {
      'name': 'Journaling',
      'icon': 'edit_note',
      'points': 5,
      'key': 'journaling'
    },
    {
      'name': 'Listen to Music',
      'icon': 'music_note',
      'points': 5,
      'key': 'music'
    },
    {
      'name': 'Call a Friend',
      'icon': 'phone',
      'points': 5,
      'key': 'social_support'
    },
    {
      'name': 'Take a Walk',
      'icon': 'directions_walk',
      'points': 5,
      'key': 'walking'
    },
    {
      'name': 'Practice Gratitude',
      'icon': 'favorite',
      'points': 5,
      'key': 'gratitude'
    },
    {
      'name': 'Creative Activity',
      'icon': 'palette',
      'points': 5,
      'key': 'creative'
    },
    {
      'name': 'Mindful Eating',
      'icon': 'restaurant',
      'points': 5,
      'key': 'mindful_eating'
    },
    {
      'name': 'Cold Shower',
      'icon': 'shower',
      'points': 5,
      'key': 'cold_shower'
    },
    {
      'name': 'Deep Breathing',
      'icon': 'air',
      'points': 5,
      'key': 'deep_breathing'
    },
  ];

  void _toggleMechanism(String mechanism) {
    final updatedMechanisms = List<String>.from(widget.selectedMechanisms);
    if (updatedMechanisms.contains(mechanism)) {
      updatedMechanisms.remove(mechanism);
    } else {
      updatedMechanisms.add(mechanism);
    }
    widget.onChanged(updatedMechanisms);
  }

  // Calculate total points with cap at +25 per check-in
  int _calculateTotalPoints() {
    if (widget.selectedMechanisms.isEmpty) return 0;

    // Sum individual strategy points
    int totalPoints = 0;
    for (final mechanism in widget.selectedMechanisms) {
      final strategy = _copingStrategies.firstWhere(
        (s) => s['key'] == mechanism,
        orElse: () => {'points': 5}, // Default 5 points
      );
      totalPoints += (strategy['points'] as int);
    }

    // Cap at +25 max per check-in to avoid farming
    return totalPoints.clamp(0, 25);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final totalPoints = _calculateTotalPoints();

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity( 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Points indicator
          if (totalPoints > 0) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity( 0.1), // Gold accent
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.amber.withOpacity( 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'stars',
                    color: Colors.amber.shade700, // Gold color
                    size: 16,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '+$totalPoints points (max +25)',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 3.h),
          ],

          // Coping strategies grid with uniform height tiles
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 2.h,
              childAspectRatio: 2.2, // Uniform height
            ),
            itemCount: _copingStrategies.length,
            itemBuilder: (context, index) {
              final strategy = _copingStrategies[index];
              final isSelected =
                  widget.selectedMechanisms.contains(strategy['key']);

              return GestureDetector(
                onTap: () => _toggleMechanism(strategy['key']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity( 0.1)
                        : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline.withOpacity( 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon with check indicator
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: strategy['icon'],
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            size: 24,
                          ),
                          if (isSelected) ...[
                            SizedBox(width: 1.w),
                            CustomIconWidget(
                              iconName: 'check_circle',
                              color: theme.colorScheme.primary,
                              size: 16,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 1.h),

                      // Strategy name
                      Expanded(
                        child: Text(
                          strategy['name'],
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      // Points label
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade700, // Gold color for points
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '+${strategy['points']}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 8.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          if (widget.selectedMechanisms.isNotEmpty) ...[
            SizedBox(height: 3.h),

            // Points cap explanation
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withOpacity( 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Coping strategies are capped at +25 points per check-in to encourage genuine use.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
