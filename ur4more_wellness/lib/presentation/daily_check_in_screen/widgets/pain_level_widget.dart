import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class PainLevelWidget extends StatefulWidget {
  final double painLevel; // Single pain level (0-10)
  final ValueChanged<double> onChanged;

  const PainLevelWidget({
    super.key,
    required this.painLevel,
    required this.onChanged,
  });

  @override
  State<PainLevelWidget> createState() => _PainLevelWidgetState();
}

class _PainLevelWidgetState extends State<PainLevelWidget> {
  bool _showDetailedView = false;

  String _getPainDescription(double value) {
    if (value == 0) return "No pain";
    if (value <= 2) return "Mild discomfort";
    if (value <= 4) return "Moderate pain";
    if (value <= 6) return "Significant pain";
    if (value <= 8) return "Severe pain";
    return "Extreme pain";
  }

  Color _getPainColor(double value) {
    if (value == 0) return Theme.of(context).colorScheme.tertiary;
    if (value <= 3) return Theme.of(context).colorScheme.secondary;
    if (value <= 6) return Colors.orange;
    return Theme.of(context).colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Simple mode - single slider
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: _getPainColor(widget.painLevel).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _getPainColor(widget.painLevel).withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'healing',
                      color: _getPainColor(widget.painLevel),
                      size: 32,
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      widget.painLevel.round().toString(),
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: _getPainColor(widget.painLevel),
                        fontWeight: FontWeight.w700,
                        fontSize: 36.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 1.h),
                Text(
                  _getPainDescription(widget.painLevel),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.h),

          // Pain slider
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getPainColor(widget.painLevel),
              thumbColor: _getPainColor(widget.painLevel),
              overlayColor:
                  _getPainColor(widget.painLevel).withValues(alpha: 0.2),
              inactiveTrackColor:
                  theme.colorScheme.outline.withValues(alpha: 0.3),
              trackHeight: 6.0,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
            ),
            child: Slider(
              value: widget.painLevel,
              min: 0.0,
              max: 10.0,
              divisions: 10,
              onChanged: widget.onChanged,
            ),
          ),
          SizedBox(height: 1.h),

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
          SizedBox(height: 2.h),

          // Optional "Add details" link for body map
          if (!_showDetailedView)
            Center(
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showDetailedView = true;
                  });
                },
                icon: CustomIconWidget(
                  iconName: 'add',
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                label: Text(
                  'Add details',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),

          // Detailed view - body regions (collapsed by default for MVP)
          if (_showDetailedView) ...[
            SizedBox(height: 3.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Pain Regions (Optional)',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showDetailedView = false;
                          });
                        },
                        child: Text(
                          'Hide',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Most common regions (limited to 3 + "More areas...")
                  _buildRegionChip('Head/Neck', 'psychology'),
                  SizedBox(height: 1.h),
                  _buildRegionChip('Back', 'airline_seat_recline_normal'),
                  SizedBox(height: 1.h),
                  _buildRegionChip('Legs', 'directions_walk'),
                  SizedBox(height: 1.h),

                  // "More areas..." collapsible
                  ExpansionTile(
                    title: Text(
                      'More areas...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    children: [
                      _buildRegionChip('Shoulders', 'accessibility'),
                      SizedBox(height: 1.h),
                      _buildRegionChip('Arms', 'pan_tool'),
                      SizedBox(height: 1.h),
                      _buildRegionChip('Chest', 'favorite'),
                      SizedBox(height: 1.h),
                      _buildRegionChip('Abdomen', 'circle'),
                      SizedBox(height: 1.h),
                      _buildRegionChip('Hips', 'accessibility_new'),
                      SizedBox(height: 1.h),
                      _buildRegionChip('Feet', 'directions_run'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRegionChip(String region, String iconName) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
          SizedBox(width: 2.w),
          Text(
            region,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
