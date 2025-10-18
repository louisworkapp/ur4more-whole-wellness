import 'package:flutter/material.dart';
import '../../design/tokens.dart';

class CollapsibleInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailingBadge;
  final bool collapsed;
  final VoidCallback onToggle;
  final Widget child;

  const CollapsibleInfoCard({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailingBadge,
    required this.collapsed,
    required this.onToggle,
    required this.child,
  });

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
            // Header row - acts as toggle
            Semantics(
              label: 'Toggle $title card',
              button: true,
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  constraints: const BoxConstraints(minHeight: 56),
                  child: Row(
                    children: [
                      // Icon chip
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceTint.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          icon,
                          color: colorScheme.onSurface,
                          size: 18,
                        ),
                      ),
                      SizedBox(width: AppSpace.x3),
                      // Title and subtitle column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (subtitle != null) ...[
                              SizedBox(height: AppSpace.x1),
                              Text(
                                subtitle!,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Spacer
                      const Spacer(),
                      // Optional trailing badge
                      if (trailingBadge != null) ...[
                        trailingBadge!,
                        SizedBox(width: AppSpace.x2),
                      ],
                      // Chevron button
                      Semantics(
                        label: collapsed ? 'Expand' : 'Collapse',
                        button: true,
                        child: InkWell(
                          onTap: onToggle,
                          borderRadius: BorderRadius.circular(16),
                          child: AnimatedRotation(
                            turns: collapsed ? 0.0 : 0.5,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            child: Icon(
                              Icons.keyboard_arrow_down,
                              color: colorScheme.onSurface,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Animated content
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              child: AnimatedCrossFade(
                duration: const Duration(milliseconds: 200),
                crossFadeState: collapsed 
                    ? CrossFadeState.showFirst 
                    : CrossFadeState.showSecond,
                firstChild: const SizedBox.shrink(),
                secondChild: Column(
                  children: [
                    SizedBox(height: AppSpace.x3),
                    child,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}