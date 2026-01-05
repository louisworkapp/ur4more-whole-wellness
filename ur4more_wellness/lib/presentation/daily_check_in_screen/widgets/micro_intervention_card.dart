import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../services/faith_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class MicroInterventionCard extends StatefulWidget {
  final double urgeLevel;
  final FaithTier faithMode;
  final VoidCallback? onCompleted;

  const MicroInterventionCard({
    super.key,
    required this.urgeLevel,
    required this.faithMode,
    this.onCompleted,
  });

  @override
  State<MicroInterventionCard> createState() => _MicroInterventionCardState();
}

class _MicroInterventionCardState extends State<MicroInterventionCard> {
  bool _isExpanded = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    // Auto-expand for Disciple and Kingdom modes
    _isExpanded = widget.faithMode == FaithTier.disciple || 
                  widget.faithMode == FaithTier.kingdom;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  void _completeIntervention() async {
    if (_isCompleted) return;

    setState(() {
      _isCompleted = true;
    });

    // Award faith XP
    final xpAwarded = await FaithService.awardFaithXp(5, DateTime.now());
    
    if (xpAwarded > 0) {
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Faith XP +$xpAwarded earned!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }

    widget.onCompleted?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Don't show for Off mode
    if (widget.faithMode == FaithTier.off) {
      return const SizedBox.shrink();
    }

    final threshold = FaithService.urgeThresholdForMicro(widget.faithMode);
    final shouldShow = widget.urgeLevel >= threshold;

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(top: AppSpace.x3),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Header - always visible
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              padding: EdgeInsets.all(AppSpace.x3),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(AppSpace.x2),
                    decoration: BoxDecoration(
                      color: colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: 'psychology',
                      color: colorScheme.error,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: AppSpace.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Micro-Intervention Available',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: AppSpace.x1),
                        Text(
                          'Would you like to try a quick calming technique?',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),

          // Expandable content
          if (_isExpanded) ...[
            Divider(
              height: 1,
              color: colorScheme.outline.withOpacity(0.3),
            ),
            Padding(
              padding: EdgeInsets.all(AppSpace.x3),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Calming Technique',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppSpace.x2),
                  
                  // Breathing exercise
                  Container(
                    padding: EdgeInsets.all(AppSpace.x3),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CustomIconWidget(
                              iconName: 'air',
                              color: colorScheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: AppSpace.x2),
                            Text(
                              '4-7-8 Breathing',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpace.x2),
                        Text(
                          '1. Breathe in for 4 counts\n2. Hold for 7 counts\n3. Breathe out for 8 counts\n4. Repeat 3-4 times',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppSpace.x3),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _completeIntervention,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                            padding: EdgeInsets.symmetric(vertical: AppSpace.x2),
                          ),
                          child: Text(
                            _isCompleted ? 'Completed ✓' : 'I\'ll try this',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpace.x2),
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            setState(() {
                              _isExpanded = false;
                            });
                          },
                          child: Text(
                            'Maybe later',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Faith XP indicator
                  if (_isCompleted) ...[
                    SizedBox(height: AppSpace.x2),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpace.x3,
                        vertical: AppSpace.x2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          CustomIconWidget(
                            iconName: 'stars',
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(width: AppSpace.x2),
                          Text(
                            'Faith XP +5 earned!',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
