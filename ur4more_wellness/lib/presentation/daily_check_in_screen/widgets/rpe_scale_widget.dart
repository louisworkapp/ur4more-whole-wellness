import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

class RpeScaleWidget extends StatefulWidget {
  final int currentValue;
  final ValueChanged<int> onChanged;

  const RpeScaleWidget({
    super.key,
    required this.currentValue,
    required this.onChanged,
  });

  @override
  State<RpeScaleWidget> createState() => _RpeScaleWidgetState();
}

class _RpeScaleWidgetState extends State<RpeScaleWidget> {
  String _getRpeDescription(int value) {
    switch (value) {
      case 1:
        return "Very Light - Minimal effort";
      case 2:
        return "Light - Easy activity";
      case 3:
        return "Moderate - Comfortable pace";
      case 4:
        return "Somewhat Hard - Noticeable effort";
      case 5:
        return "Hard - Challenging but sustainable";
      case 6:
        return "Very Hard - Difficult to maintain";
      case 7:
        return "Extremely Hard - Maximum effort";
      case 8:
        return "Near Maximal - Almost exhausted";
      case 9:
        return "Maximal - Cannot continue";
      case 10:
        return "Maximum - Complete exhaustion";
      default:
        return "Select your effort level";
    }
  }

  Color _getRpeColor(int value) {
    if (value <= 3) return Theme.of(context).colorScheme.tertiary;
    if (value <= 6) return Theme.of(context).colorScheme.secondary;
    return Theme.of(context).colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: Pad.card,
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
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x3),
            decoration: BoxDecoration(
              color: _getRpeColor(widget.currentValue).withOpacity( 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getRpeColor(widget.currentValue).withOpacity( 0.3),
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.currentValue.toString(),
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: _getRpeColor(widget.currentValue),
                    fontWeight: FontWeight.w700,
                    fontSize: 48, // Fixed font size instead of Sizer
                  ),
                ),
                SizedBox(height: AppSpace.x1),
                Text(
                  _getRpeDescription(widget.currentValue),
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
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getRpeColor(widget.currentValue),
              thumbColor: _getRpeColor(widget.currentValue),
              overlayColor:
                  _getRpeColor(widget.currentValue).withOpacity( 0.2),
              inactiveTrackColor:
                  theme.colorScheme.outline.withOpacity( 0.3),
              trackHeight: 8.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 24.0),
              tickMarkShape: SliderTickMarkShape.noTickMark,
            ),
            child: Slider(
              value: widget.currentValue.toDouble(),
              min: 1.0,
              max: 10.0,
              divisions: 9,
              onChanged: (value) {
                widget.onChanged(value.round());
              },
            ),
          ),
          SizedBox(height: AppSpace.x1),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '1',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '5',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '10',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x2),
          Container(
            padding: EdgeInsets.all(AppSpace.x3),
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
                SizedBox(width: AppSpace.x2),
                Expanded(
                  child: Text(
                    'RPE tracking helps monitor your recovery - no points awarded',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
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
