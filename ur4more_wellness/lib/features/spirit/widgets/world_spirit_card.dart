import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../presentation/world_spirit_intro_sheet.dart';

class WorldSpiritCard extends StatefulWidget {
  const WorldSpiritCard({super.key});

  @override
  State<WorldSpiritCard> createState() => _WorldSpiritCardState();
}

class _WorldSpiritCardState extends State<WorldSpiritCard> {
  bool _isExpanded = false;

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
            // Title row with icon
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
                    Icons.public,
                    color: colorScheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpace.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'World Spirit',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: AppSpace.x1),
                      Text(
                        'Is there more to you than thoughts and feelings?',
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
            
            // Body content
            if (_isExpanded) ...[
              _buildBulletPoint(
                theme,
                colorScheme,
                'Many cultures believe there\'s more than what we see.',
              ),
              SizedBox(height: AppSpace.x2),
              _buildBulletPoint(
                theme,
                colorScheme,
                'People report moments of guidance that feel \'higher\' than impulse.',
              ),
              SizedBox(height: AppSpace.x2),
              _buildBulletPoint(
                theme,
                colorScheme,
                'What if your life could align with a will wiser than your own?',
              ),
              SizedBox(height: AppSpace.x4),
            ],
            
            // CTA buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isExpanded 
                        ? () => _showIntroSheet(context)
                        : () => setState(() => _isExpanded = true),
                    style: ElevatedButton.styleFrom(
                      minimumSize: Size(0, 56),
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      _isExpanded ? 'I\'m open to explore' : 'Learn more',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (_isExpanded) ...[
                  SizedBox(width: AppSpace.x3),
                  Expanded(
                    child: TextButton(
                      onPressed: () => setState(() => _isExpanded = false),
                      style: TextButton.styleFrom(
                        minimumSize: Size(0, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: Text(
                        'Not now',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(ThemeData theme, ColorScheme colorScheme, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.only(top: 8, right: AppSpace.x3),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _showIntroSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const WorldSpiritIntroSheet(),
    );
  }
}
