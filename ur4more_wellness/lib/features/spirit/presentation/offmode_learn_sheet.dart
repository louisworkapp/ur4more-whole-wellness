import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../services/faith_mode_navigator.dart';

class OffModeLearnSheet extends StatelessWidget {
  const OffModeLearnSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(AppSpace.x5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              
              SizedBox(height: AppSpace.x4),
              
              // Title
              Text(
                'Understanding Soul vs Spirit',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              
              SizedBox(height: AppSpace.x2),
              
              Text(
                'A brief explanation of these concepts',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
              ),
              
              SizedBox(height: AppSpace.x5),
              
              // SOUL section
              _buildConceptSection(
                theme,
                colorScheme,
                'SOUL',
                'My thoughts, emotions, preferences (my will)',
                'The soul represents your natural self—your thoughts, feelings, and personal preferences. It\'s what drives your immediate desires and reactions.',
              ),
              
              SizedBox(height: AppSpace.x4),
              
              // SPIRIT section
              _buildConceptSection(
                theme,
                colorScheme,
                'SPIRIT',
                'God\'s will, God\'s life guiding ours',
                'In Christian faith, the Spirit represents God\'s guidance and will. When aligned with the Spirit, we follow a higher wisdom than our own impulses.',
              ),
              
              SizedBox(height: AppSpace.x5),
              
              // Why Off mode is shallow
              Container(
                padding: EdgeInsets.all(AppSpace.x4),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: colorScheme.outlineVariant,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        SizedBox(width: AppSpace.x2),
                        Text(
                          'Why Off mode is intentionally shallow',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpace.x2),
                    Text(
                      'We respect your privacy and choice. Off mode provides a neutral introduction without assuming your faith background.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSpace.x4),
              
              // What you unlock
              Text(
                'What you unlock with Faith Mode:',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              SizedBox(height: AppSpace.x2),
              
              _buildUnlockItem(
                theme,
                colorScheme,
                Icons.menu_book,
                'Scripture guidance',
                'Daily Bible verses and teachings',
              ),
              
              _buildUnlockItem(
                theme,
                colorScheme,
                Icons.favorite,
                'Prayer prompts',
                'Guided prayer and reflection',
              ),
              
              _buildUnlockItem(
                theme,
                colorScheme,
                Icons.auto_stories,
                'Discipleship courses',
                '12-week journey to follow Jesus',
              ),
              
              _buildUnlockItem(
                theme,
                colorScheme,
                Icons.favorite_border,
                'Peace verses',
                'Comforting Scripture for difficult times',
              ),
              
              SizedBox(height: AppSpace.x6),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        FaithModeNavigator.openFaithModeSelector(context);
                      },
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
                      onPressed: () => Navigator.pop(context),
                      style: TextButton.styleFrom(
                        minimumSize: Size(0, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'Close',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpace.x2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConceptSection(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String subtitle,
    String description,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppSpace.x1),
        Text(
          subtitle,
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSpace.x2),
        Text(
          description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.9),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockItem(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpace.x3),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(
              icon,
              color: colorScheme.onPrimaryContainer,
              size: 16,
            ),
          ),
          SizedBox(width: AppSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.7),
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
