import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../../../common/widgets/collapsible_info_card.dart';
import '../services/faith_mode_navigator.dart';
import '../../courses/models/course_models.dart';

class FaithModeBanner extends StatelessWidget {
  const FaithModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FutureBuilder<FaithTier>(
      future: FaithModeNavigator.getCurrentFaithTier(),
      builder: (context, snapshot) {
        final faithTier = snapshot.data ?? FaithTier.off;
        
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => FaithModeNavigator.openFaithModeSelector(context),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpace.x4,
                  vertical: AppSpace.x3,
                ),
                child: Row(
                  children: [
                    // Left icon chip
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceTint.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        color: colorScheme.onSurface,
                        size: 18,
                      ),
                    ),
                    SizedBox(width: AppSpace.x3),
                    // Title and description
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Faith Mode: ${faithTier.displayName.toLowerCase()}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          SizedBox(height: AppSpace.x1),
                          Text(
                            _getFaithModeDescription(faithTier),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Trailing gear icon
                    IconButton(
                      onPressed: () => FaithModeNavigator.openFaithModeSelector(context),
                      icon: Icon(
                        Icons.settings,
                        color: colorScheme.onSurface,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 56,
                        minHeight: 56,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getFaithModeDescription(FaithTier tier) {
    switch (tier) {
      case FaithTier.off:
        return 'Secular mode - no spiritual content';
      case FaithTier.light:
        return 'Minimal spiritual content with gentle encouragement';
      case FaithTier.disciple:
        return 'Active faith integration with daily devotions';
      case FaithTier.kingdom:
        return 'Complete experience with service and leadership focus';
    }
  }
}
