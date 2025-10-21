import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../services/faith_service.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'micro_intervention_card.dart';

class UrgeIntensityWidget extends StatefulWidget {
  final double urgeLevel; // Single urge level (0-10)
  final FaithMode faithMode;
  final List<String> selectedUrgeTypes; // Selected urge/craving types
  final ValueChanged<double> onChanged;
  final ValueChanged<List<String>>? onUrgeTypesChanged;

  const UrgeIntensityWidget({
    super.key,
    required this.urgeLevel,
    required this.faithMode,
    required this.onChanged,
    this.selectedUrgeTypes = const [],
    this.onUrgeTypesChanged,
  });

  @override
  State<UrgeIntensityWidget> createState() => _UrgeIntensityWidgetState();
}

class _UrgeIntensityWidgetState extends State<UrgeIntensityWidget> {
  List<String> _selectedItems = [];

  @override
  void initState() {
    super.initState();
    _selectedItems = List.from(widget.selectedUrgeTypes);
  }

  @override
  void didUpdateWidget(UrgeIntensityWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedUrgeTypes != widget.selectedUrgeTypes) {
      _selectedItems = List.from(widget.selectedUrgeTypes);
    }
  }

  void _updateSelectedItems(List<String> newItems) {
    setState(() {
      _selectedItems = newItems;
    });
    widget.onUrgeTypesChanged?.call(_selectedItems);
  }

  String _getUrgeDescription(double value) {
    if (value == 0) return "No urges or cravings";
    if (value <= 2) return "Mild urge - easily manageable";
    if (value <= 4) return "Moderate urge - noticeable but controlled";
    if (value <= 6) return "Strong urge - requires effort to resist";
    if (value <= 8) return "Very strong urge - difficult to resist";
    return "Overwhelming urge - seeking support";
  }

  Color _getUrgeColor(double value) {
    if (value == 0) return Theme.of(context).colorScheme.tertiary;
    if (value <= 3) return Theme.of(context).colorScheme.secondary;
    if (value <= 6) return Colors.orange;
    return Theme.of(context).colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(AppSpace.x4),
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
          // Privacy notice
          Container(
            padding: EdgeInsets.all(AppSpace.x3),
            decoration: BoxDecoration(
              color: theme.colorScheme.tertiary.withOpacity( 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.tertiary.withOpacity( 0.3),
              ),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'security',
                  color: theme.colorScheme.tertiary,
                  size: 20,
                ),
                SizedBox(width: AppSpace.x2),
                Expanded(
                  child: Text(
                    'Your responses are private and encrypted for your safety',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpace.x3),

          // Current urge level display
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x3),
            decoration: BoxDecoration(
              color: _getUrgeColor(widget.urgeLevel).withOpacity( 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getUrgeColor(widget.urgeLevel).withOpacity( 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'trending_up',
                      color: _getUrgeColor(widget.urgeLevel),
                      size: 32,
                    ),
                    SizedBox(width: AppSpace.x2),
                    Text(
                      widget.urgeLevel.round().toString(),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: _getUrgeColor(widget.urgeLevel),
                        fontWeight: FontWeight.w700,
                        fontSize: 36,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpace.x1),
                Text(
                  _getUrgeDescription(widget.urgeLevel),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpace.x3),

          // Urge/craving slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getUrgeColor(widget.urgeLevel),
              thumbColor: _getUrgeColor(widget.urgeLevel),
              overlayColor:
                  _getUrgeColor(widget.urgeLevel).withOpacity( 0.2),
              inactiveTrackColor:
                  theme.colorScheme.outline.withOpacity( 0.3),
              trackHeight: 6.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            ),
            child: Slider(
              value: widget.urgeLevel,
              min: 0.0,
              max: 10.0,
              divisions: 10,
              onChanged: widget.onChanged,
            ),
          ),
          SizedBox(height: AppSpace.x1),

          // Scale markers
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '5',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '10',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x2),

          // Detailed urge/craving types
          _buildUrgeDetailsSection(),

          SizedBox(height: AppSpace.x2),

          // Micro-intervention card (faith-based)
          MicroInterventionCard(
            urgeLevel: widget.urgeLevel,
            faithMode: widget.faithMode,
            onCompleted: () {
              // Optional callback for when intervention is completed
            },
          ),

          // High urge support message (for all modes)
          if (widget.urgeLevel >= 7) ...[
            Container(
              padding: EdgeInsets.all(AppSpace.x3),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.error.withOpacity( 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'favorite',
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  SizedBox(width: AppSpace.x2),
                  Expanded(
                    child: Text(
                      'Strong urges detected. Consider reaching out for support or using coping strategies.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                        fontWeight: FontWeight.w500,
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

  Widget _buildUrgeDetailsSection() {
    final theme = Theme.of(context);
    
    // Combined list of urge/craving types and biblical themes
    final List<Map<String, dynamic>> allUrgeTypes = [
      // Common urge/craving types
      {'key': 'substance', 'label': 'Substance Use', 'icon': 'local_drink', 'type': 'urge'},
      {'key': 'food', 'label': 'Food/Cravings', 'icon': 'restaurant', 'type': 'urge'},
      {'key': 'shopping', 'label': 'Shopping/Spending', 'icon': 'shopping_cart', 'type': 'urge'},
      {'key': 'social_media', 'label': 'Social Media', 'icon': 'share', 'type': 'urge'},
      {'key': 'gaming', 'label': 'Gaming/Entertainment', 'icon': 'sports_esports', 'type': 'urge'},
      {'key': 'work', 'label': 'Work/Productivity', 'icon': 'work', 'type': 'urge'},
      {'key': 'relationships', 'label': 'Relationships', 'icon': 'people', 'type': 'urge'},
      
      // Biblical themes (only show if faith mode is activated)
      if (widget.faithMode.isActivated) ...[
        {'key': 'pride', 'label': 'Pride', 'icon': 'trending_up', 'type': 'biblical', 'verse': 'Proverbs 16:18'},
        {'key': 'envy', 'label': 'Envy', 'icon': 'visibility', 'type': 'biblical', 'verse': 'Proverbs 14:30'},
        {'key': 'lust', 'label': 'Lust', 'icon': 'favorite', 'type': 'biblical', 'verse': 'Matthew 5:28'},
        {'key': 'greed', 'label': 'Greed', 'icon': 'attach_money', 'type': 'biblical', 'verse': 'Luke 12:15'},
        {'key': 'anger', 'label': 'Anger', 'icon': 'flash_on', 'type': 'biblical', 'verse': 'Ephesians 4:26'},
        {'key': 'sloth', 'label': 'Sloth/Laziness', 'icon': 'bedtime', 'type': 'biblical', 'verse': 'Proverbs 6:6'},
        {'key': 'gluttony', 'label': 'Gluttony', 'icon': 'restaurant', 'type': 'biblical', 'verse': 'Proverbs 23:2'},
        {'key': 'lost', 'label': 'Feeling Lost', 'icon': 'explore_off', 'type': 'biblical', 'verse': 'Psalm 23:3'},
      ],
      
      // Other at the bottom
      {'key': 'other', 'label': 'Other', 'icon': 'more_horiz', 'type': 'urge'},
    ];

    return Container(
      padding: EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section title
          Row(
            children: [
              CustomIconWidget(
                iconName: 'psychology',
                color: theme.colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: AppSpace.x2),
              Text(
                'Today\'s Top Urges & Cravings',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpace.x3),
          
          // Combined list
          Text(
            'What are you struggling with today?',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          
          SizedBox(height: AppSpace.x2),
          
          Wrap(
            spacing: AppSpace.x2,
            runSpacing: AppSpace.x1,
            children: allUrgeTypes.map((item) => _buildCombinedChip(item)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedChip(Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final isSelected = _selectedItems.contains(item['key']);
    final isBiblical = item['type'] == 'biblical';
    
    return GestureDetector(
      onTap: () {
        final newItems = List<String>.from(_selectedItems);
        if (isSelected) {
          newItems.remove(item['key']);
        } else {
          newItems.add(item['key']);
        }
        _updateSelectedItems(newItems);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: AppSpace.x3, vertical: AppSpace.x1),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isBiblical ? theme.colorScheme.secondaryContainer : theme.colorScheme.primaryContainer)
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? (isBiblical ? theme.colorScheme.secondary : theme.colorScheme.primary)
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: item['icon'],
              color: isSelected 
                  ? (isBiblical ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onPrimaryContainer)
                  : theme.colorScheme.onSurface,
              size: 16,
            ),
            SizedBox(width: AppSpace.x1),
            Text(
              item['label'],
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? (isBiblical ? theme.colorScheme.onSecondaryContainer : theme.colorScheme.onPrimaryContainer)
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
