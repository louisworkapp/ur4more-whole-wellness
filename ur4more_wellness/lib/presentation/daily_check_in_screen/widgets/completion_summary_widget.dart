import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../services/faith_service.dart';
import '../../../widgets/custom_icon_widget.dart';

class CompletionSummaryWidget extends StatelessWidget {
  final int totalPointsEarned;
  final String? suggestionTitle;
  final String? suggestionAction;
  final FaithTier faithMode;
  final double painLevel;
  final double urgeLevel;
  final VoidCallback onContinue;
  final Function(String)? onSuggestionTap;

  const CompletionSummaryWidget({
    super.key,
    required this.totalPointsEarned,
    this.suggestionTitle,
    this.suggestionAction,
    required this.faithMode,
    required this.painLevel,
    required this.urgeLevel,
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
          SizedBox(height: AppSpace.x2),

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

          // Faith XP and Streak (for non-Off modes)
          if (faithMode != FaithTier.off) ...[
            FutureBuilder<FaithProgress>(
              future: FaithService.getFaithProgress(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final progress = snapshot.data!;
                  return Container(
                    padding: EdgeInsets.all(AppSpace.x4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'auto_awesome',
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            SizedBox(width: AppSpace.x2),
                            Text(
                              'Faith Progress',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpace.x2),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              children: [
                                Text(
                                  '${progress.xp}',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Faith XP',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  '${progress.streakDays}',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  'Day Streak',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            SizedBox(height: AppSpace.x3),
          ],

          // Peace Verse card (for Light with high pain/urge, or Disciple/Kingdom)
          if (faithMode != FaithTier.off && 
              ((faithMode == FaithTier.light && (painLevel > 0 || urgeLevel >= 7)) ||
               faithMode == FaithTier.disciple || 
               faithMode == FaithTier.kingdom)) ...[
            _buildPeaceVerseCard(theme),
            SizedBox(height: AppSpace.x3),
          ],

          // Smart suggestion based on pain/urge levels
          if (suggestionTitle != null && suggestionAction != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpace.x4),
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
                  SizedBox(height: AppSpace.x2),
                  ElevatedButton.icon(
                    onPressed: () => onSuggestionTap?.call(suggestionAction!),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(
                          horizontal: AppSpace.x6, vertical: AppSpace.x3),
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
                padding: EdgeInsets.symmetric(vertical: AppSpace.x2),
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

  Widget _buildPeaceVerseCard(ThemeData theme) {
    final isExpanded = faithMode == FaithTier.disciple || faithMode == FaithTier.kingdom;
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.secondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'menu_book',
                color: theme.colorScheme.secondary,
                size: 20,
              ),
              SizedBox(width: AppSpace.x2),
              Text(
                'Peace Verse',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.colorScheme.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            '"Peace I leave with you; my peace I give you. I do not give to you as the world gives. Do not let your hearts be troubled and do not be afraid."',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpace.x1),
          Text(
            '— John 14:27',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (!isExpanded) ...[
            SizedBox(height: AppSpace.x2),
            Text(
              'Many people find comfort in scripture during difficult times.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
