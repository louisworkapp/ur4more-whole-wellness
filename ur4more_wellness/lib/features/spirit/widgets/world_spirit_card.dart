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
            colorScheme.surface,
            colorScheme.surfaceTint.withOpacity(0.06),
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
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceTint.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.public,
                    color: colorScheme.onSurface,
                    size: 18,
                  ),
                ),
                SizedBox(width: AppSpace.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Worldly Spirit',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: AppSpace.x1),
                      Text(
                        'Is there more to you than thoughts and feelings?',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
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
              SizedBox(height: AppSpace.x3),
              
              // Filter chips
              Wrap(
                spacing: AppSpace.x2,
                runSpacing: AppSpace.x1,
                children: [
                  _buildFilterChip(theme, colorScheme, 'Clarity'),
                  _buildFilterChip(theme, colorScheme, 'Perspective'),
                ],
              ),
              
              SizedBox(height: AppSpace.x4),
            ],
            
            // CTA buttons
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _isExpanded 
                        ? () => _showIntroSheet(context)
                        : () => setState(() => _isExpanded = true),
                    style: FilledButton.styleFrom(
                      minimumSize: Size(0, 56),
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
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.9),
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(ThemeData theme, ColorScheme colorScheme, String label) {
    return FilterChip(
      label: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: false,
      onSelected: (selected) {
        // Handle chip selection if needed
      },
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
      selectedColor: colorScheme.primaryContainer,
      checkmarkColor: colorScheme.onPrimaryContainer,
      side: BorderSide(
        color: colorScheme.outlineVariant,
        width: 1,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
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
