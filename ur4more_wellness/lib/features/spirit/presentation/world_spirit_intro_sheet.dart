import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../services/faith_mode_navigator.dart';

class WorldSpiritIntroSheet extends StatelessWidget {
  const WorldSpiritIntroSheet({super.key});

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
                'Explore Soul and Spirit',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              
              SizedBox(height: AppSpace.x5),
              
              // Content paragraphs
              _buildParagraph(
                theme,
                colorScheme,
                'Soul often describes my inner life—thoughts, feelings, preferences. Left alone, I act from what I want now.',
              ),
              
              SizedBox(height: AppSpace.x4),
              
              _buildParagraph(
                theme,
                colorScheme,
                'Spirit points to a higher will. In the Christian view, God\'s Spirit leads us into wisdom, love, and truth.',
              ),
              
              SizedBox(height: AppSpace.x4),
              
              _buildParagraph(
                theme,
                colorScheme,
                'You can keep browsing quietly, or enable Faith Mode anytime to see fuller guidance.',
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
                        'Browse first',
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

  Widget _buildParagraph(ThemeData theme, ColorScheme colorScheme, String text) {
    return Text(
      text,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.9),
        height: 1.5,
      ),
    );
  }
}
