import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../../../common/widgets/collapsible_info_card.dart';
import 'micro_reflection_modal.dart';

class SoulVsSpiritCard extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;

  const SoulVsSpiritCard({
    super.key,
    required this.collapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CollapsibleInfoCard(
      icon: Icons.psychology_outlined,
      title: 'Soul vs Spirit (Intro)',
      subtitle: 'A fast way to notice what\'s driving your choices.',
      trailingBadge: Container(
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
      collapsed: collapsed,
      onToggle: onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SOUL callout
          _buildCallout(
            theme,
            colorScheme,
            Icons.psychology_outlined,
            'SOUL — "my will"',
            'The seat of my thoughts, feelings, and preferences. Left alone, I naturally choose what I want, now.',
            false,
          ),
          
          SizedBox(height: AppSpace.x3),
          
          // SPIRIT callout
          _buildCallout(
            theme,
            colorScheme,
            Icons.auto_awesome,
            'SPIRIT — "God\'s will"',
            'A wiser will that aims at truth, love, and lasting good. Following Spirit often feels higher than impulse.',
            true,
          ),
          
          SizedBox(height: AppSpace.x3),
          
          // Today's experiment section
          _buildExperimentSection(theme, colorScheme),
          
          SizedBox(height: AppSpace.x4),
          
          // Reflection button
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: () => _showReflectionModal(context),
              icon: Icon(Icons.timer, size: 18),
              label: Text('1-min reflection'),
              style: TextButton.styleFrom(
                minimumSize: Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallout(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String title,
    String description,
    bool isPrimary,
  ) {
    return Container(
      padding: EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: isPrimary 
            ? colorScheme.primaryContainer.withOpacity(0.3)
            : colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isPrimary 
              ? colorScheme.primary.withOpacity(0.3)
              : colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isPrimary 
                  ? colorScheme.primary.withOpacity(0.1)
                  : colorScheme.surfaceTint.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isPrimary 
                  ? colorScheme.primary
                  : colorScheme.onSurface,
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
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: isPrimary 
                        ? colorScheme.primary
                        : colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpace.x1),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperimentSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.2),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s 60-second experiment',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            '• Pause before a choice.\n• Ask: "What\'s the wisest next step?"\n• Note how \'my will\' differs from a better, higher way.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            'Turn on Faith Mode to see Scripture, prayer prompts, and guided next steps.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontStyle: FontStyle.italic,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  void _showReflectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MicroReflectionModal(),
    );
  }
}
