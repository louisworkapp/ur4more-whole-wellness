import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../services/faith_service.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'micro_intervention_card.dart';

class UrgeIntensityWidget extends StatefulWidget {
  final double urgeLevel; // Single urge level (0-10)
  final FaithMode faithMode;
  final ValueChanged<double> onChanged;

  const UrgeIntensityWidget({
    super.key,
    required this.urgeLevel,
    required this.faithMode,
    required this.onChanged,
  });

  @override
  State<UrgeIntensityWidget> createState() => _UrgeIntensityWidgetState();
}

class _UrgeIntensityWidgetState extends State<UrgeIntensityWidget> {
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
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '5',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '10',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
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
}
