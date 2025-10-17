import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../services/faith_mode_navigator.dart';
import '../presentation/offmode_learn_sheet.dart';

class OffModeIntroCard extends StatelessWidget {
  const OffModeIntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.10),
            colorScheme.surfaceVariant.withOpacity(0.30),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpace.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row with badge
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.explore_outlined,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpace.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Soul vs Spirit (Intro)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppSpace.x2,
                              vertical: AppSpace.x1,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(AppRadius.sm),
                            ),
                            child: Text(
                              'Off mode',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: AppSpace.x1),
                      Text(
                        'A fast way to notice what\'s driving your choices.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpace.x4),
            
            // Section A: SOUL
            _buildSection(
              theme,
              colorScheme,
              'SOUL — "my will"',
              'The soul is the seat of my thoughts, feelings, and preferences. Left alone, I naturally choose what I want, now.',
            ),
            
            SizedBox(height: AppSpace.x3),
            
            // Section B: SPIRIT
            _buildSection(
              theme,
              colorScheme,
              'SPIRIT — "God\'s will"',
              'The Christian claim: life works best aligned with God\'s will. That guidance becomes clear when Faith Mode is on.',
            ),
            
            SizedBox(height: AppSpace.x3),
            
            // Section C: Today's experiment
            _buildSection(
              theme,
              colorScheme,
              'Today\'s 60-second experiment',
              '• Pause before a choice.\n• Ask: "What\'s the wisest next step?"\n• Note how \'my will\' differs from a better, higher way.',
              footer: 'Turn on Faith Mode to see Scripture, prayer prompts, and guided next steps.',
            ),
            
            SizedBox(height: AppSpace.x5),
            
            // CTA buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => FaithModeNavigator.openFaithModeSelector(context),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(0, 56),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      'Enable Faith Mode',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: AppSpace.x3),
                Expanded(
                  child: TextButton(
                    onPressed: () => _showLearnMoreSheet(context),
                    style: TextButton.styleFrom(
                      minimumSize: Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      'Learn more',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    String body, {
    String? footer,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x2),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.9),
            height: 1.4,
          ),
        ),
        if (footer != null) ...[
          SizedBox(height: AppSpace.x2),
          Text(
            footer,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.7),
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
        ],
      ],
    );
  }

  void _showLearnMoreSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const OffModeLearnSheet(),
    );
  }
}
