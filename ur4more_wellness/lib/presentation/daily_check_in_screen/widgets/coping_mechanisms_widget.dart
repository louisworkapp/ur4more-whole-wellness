import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../core/app_export.dart';
import '../../../core/brand_rules.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

class CopingMechanismsWidget extends StatefulWidget {
  final List<String> selectedMechanisms;
  final FaithMode faithMode;
  final Function(List<String>) onChanged;

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
  final List<Map<String, dynamic>> _copingStrategies = [
    {
      'key': 'read_scripture',
      'name': 'Read Scripture',
      'icon': 'menu_book',
      'points': 5,
    },
    {
      'key': 'physical_exercise',
      'name': 'Physical Exercise',
      'icon': 'fitness_center',
      'points': 5,
    },
    {
      'key': 'journaling',
      'name': 'Journaling',
      'icon': 'auto_stories',
      'points': 5,
    },
    {
      'key': 'listen_music',
      'name': 'Listen to Music',
      'icon': 'headphones',
      'points': 5,
    },
    {
      'key': 'call_friend',
      'name': 'Call a Friend',
      'icon': 'call',
      'points': 5,
    },
    {
      'key': 'take_walk',
      'name': 'Take a Walk',
      'icon': 'directions_walk',
      'points': 5,
    },
    {
      'key': 'practice_gratitude',
      'name': 'Practice Gratitude',
      'icon': 'favorite_border',
      'points': 5,
    },
    {
      'key': 'creative_activity',
      'name': 'Creative Activity',
      'icon': 'brush',
      'points': 5,
    },
    {
      'key': 'mindful_eating',
      'name': 'Mindful Eating',
      'icon': 'restaurant',
      'points': 5,
    },
    {
      'key': 'cold_shower',
      'name': 'Cold Shower',
      'icon': 'ac_unit',
      'points': 5,
    },
    {
      'key': 'deep_breathing',
      'name': 'Deep Breathing',
      'icon': 'self_improvement',
      'points': 5,
    },
  ];

  void _toggleMechanism(String key) {
    setState(() {
      if (widget.selectedMechanisms.contains(key)) {
        widget.selectedMechanisms.remove(key);
      } else {
        widget.selectedMechanisms.add(key);
      }
      widget.onChanged(widget.selectedMechanisms);
    });
  }

  int _calculateTotalPoints() {
    return widget.selectedMechanisms.fold(0, (total, key) {
      final strategy = _copingStrategies.firstWhere(
        (s) => s['key'] == key,
        orElse: () => {'points': 0},
      );
      return total + (strategy['points'] as int);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final cols = width >= 520 ? 3 : 2;
    final childAspect = cols == 3 ? 2.4 : 2.0;
    final totalPoints = _calculateTotalPoints();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Points indicator
        if (totalPoints > 0) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.amber.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'stars',
                  color: Colors.amber.shade700,
                  size: 16,
                ),
                const SizedBox(width: 8),
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
          const SizedBox(height: 16),
        ],

        // Responsive grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: childAspect,
          ),
          itemCount: _copingStrategies.length,
          itemBuilder: (context, index) {
            final strategy = _copingStrategies[index];
            final isSelected = widget.selectedMechanisms.contains(strategy['key']);
            return _CopingCard(
              strategy: strategy,
              isSelected: isSelected,
              onTap: () => _toggleMechanism(strategy['key']),
            );
          },
        ),
      ],
    );
  }
}

class _CopingCard extends StatelessWidget {
  const _CopingCard({
    required this.strategy,
    required this.isSelected,
    required this.onTap,
  });

  final Map<String, dynamic> strategy;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: isSelected
          ? colorScheme.primary.withOpacity(0.1)
          : colorScheme.surface,
      elevation: 0,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: isSelected
                      ? colorScheme.primary.withOpacity(0.2)
                      : colorScheme.primary.withOpacity(0.08),
                  child: CustomIconWidget(
                    iconName: strategy['icon'],
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    strategy['name'],
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _PointsChip(value: strategy['points']),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PointsChip extends StatelessWidget {
  const _PointsChip({required this.value});
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.orange.shade500,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '+$value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'radio_button_checked',
            size: 14,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                subtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}