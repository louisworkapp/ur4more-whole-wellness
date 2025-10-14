import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

class CompletionSummaryWidget extends StatelessWidget {
  final int totalPointsEarned;
  final String? suggestionTitle;
  final String? suggestionAction;
  final VoidCallback onContinue;
  final Function(String)? onSuggestionTap;

  const CompletionSummaryWidget({
    super.key,
    required this.totalPointsEarned,
    this.suggestionTitle,
    this.suggestionAction,
    required this.onContinue,
    this.onSuggestionTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpace.x6),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Success indicator
          Container(
            width: 80, // Fixed width instead of percentage
            height: 80, // Fixed height instead of percentage
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity( 0.1),
              shape: BoxShape.circle,
            ),
            child: CustomIconWidget(
              iconName: 'check_circle',
              color: theme.colorScheme.primary,
              size: 40,
            ),
          ),
          SizedBox(height: AppSpace.x3),

          // Completion message
          Text(
            'Check-in Complete! ✓',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),

          // Points earned
          if (totalPointsEarned > 0) ...[
            Container(
              padding: EdgeInsets.symmetric(horizontal: AppSpace.x6, vertical: AppSpace.x2),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity( 0.1), // Gold accent
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.withOpacity( 0.3),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: 'stars',
                    color: Colors.amber.shade700, // Gold color
                    size: 24,
                  ),
                  SizedBox(width: AppSpace.x2),
                  Text(
                    'Saved • +$totalPointsEarned points',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpace.x3),
          ] else ...[
            // No points earned message
            Text(
              'Saved • Your progress has been recorded',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpace.x3),
          ],

          // Smart suggestion based on pain/urge levels
          if (suggestionTitle != null && suggestionAction != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity( 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity( 0.2),
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Suggested next step:',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  ElevatedButton.icon(
                    onPressed: () => onSuggestionTap?.call(suggestionAction!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 1.5.h),
                    ),
                    icon: CustomIconWidget(
                      iconName: suggestionAction == 'mobility_reset'
                          ? 'fitness_center'
                          : 'menu_book',
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                    label: Text(
                      suggestionTitle!,
                      style: TextStyle(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSpace.x3),
          ],

          // Continue button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary, // Navy primary CTA
                padding: EdgeInsets.symmetric(vertical: 2.h),
              ),
              child: Text(
                'Continue',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
