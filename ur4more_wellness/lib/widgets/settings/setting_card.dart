import 'package:flutter/material.dart';

import '../../design/tokens.dart';

class SettingCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final List<Widget> children;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const SettingCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.children,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: margin ?? const EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(AppSpace.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  icon!,
                  const SizedBox(width: AppSpace.x3),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpace.x2),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            if (children.isNotEmpty) ...[
              const SizedBox(height: AppSpace.x4),
              ...children,
            ],
          ],
        ),
      ),
    );
  }
}
