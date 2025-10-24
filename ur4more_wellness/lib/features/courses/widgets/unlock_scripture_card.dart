import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../models/course_models.dart';

// Design System Colors
const Color _bgColor = Color(0xFF0C1220);
const Color _surfaceColor = Color(0xFF121A2B);
const Color _surface2Color = Color(0xFF172238);
const Color _textColor = Color(0xFFEAF1FF);
const Color _textSubColor = Color(0xFFA8B7D6);
const Color _brandBlue = Color(0xFF3C79FF);
const Color _brandBlue200 = Color(0xFF7AA9FF);
const Color _brandGold = Color(0xFFFFC24D);
const Color _brandGold700 = Color(0xFFD59E27);
const Color _outlineColor = Color(0xFF243356);

class UnlockScriptureCard extends StatelessWidget {
  final Unlock unlock;
  final bool unlocked;
  final VoidCallback onUnlock;

  const UnlockScriptureCard({
    super.key,
    required this.unlock,
    required this.unlocked,
    required this.onUnlock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), 
            blurRadius: 12, 
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title row
            Row(
              children: [
                Icon(
                  Icons.menu_book,
                  color: _brandBlue200,
                  size: 24,
                ),
                const SizedBox(width: AppSpace.x2),
                Expanded(
                  child: Text(
                    unlock.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _textColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppSpace.x3),
            
            // KJV Verses
            ...unlock.versesKJV.map((verse) => _buildVerseCard(theme, colorScheme, verse)),
            
            const SizedBox(height: AppSpace.x4),
            
            // Unlock button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: unlocked ? null : onUnlock,
                icon: Icon(
                  unlocked ? Icons.check_circle : Icons.lock_open,
                  size: 20,
                ),
                label: Text(
                  unlocked ? 'Deeper Truths Unlocked ✓' : 'Unlock Deeper Truths',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  backgroundColor: unlocked ? colorScheme.surfaceVariant : colorScheme.primary,
                  foregroundColor: unlocked ? colorScheme.onSurfaceVariant : colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
            
            // Deeper truths section (shown when unlocked)
            if (unlocked) ...[
              const SizedBox(height: AppSpace.x4),
              Container(
                width: double.infinity,
                height: 1,
                color: colorScheme.outline.withOpacity(0.2),
              ),
              const SizedBox(height: AppSpace.x4),
              
              // Insight
              Container(
                padding: const EdgeInsets.all(AppSpace.x3),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpace.x2),
                        Text(
                          'Insight:',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      unlock.insight,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _textColor,
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: AppSpace.x3),
              
              // Deeper truths
              Text(
                'Deeper Truths:',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpace.x2),
              ...unlock.deeperTruths.asMap().entries.map((entry) {
                final index = entry.key;
                final truth = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpace.x2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpace.x3),
                      Expanded(
                        child: Text(
                          truth,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: _textColor,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVerseCard(ThemeData theme, ColorScheme colorScheme, VerseKJV verse) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpace.x3),
      padding: const EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reference chip
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.x2,
              vertical: AppSpace.x1,
            ),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Text(
              verse.ref,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          const SizedBox(height: AppSpace.x2),
          
          // Verse text
          Text(
            verse.text,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSecondaryContainer,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
