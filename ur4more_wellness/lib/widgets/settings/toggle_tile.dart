import 'package:flutter/material.dart';

import '../../design/tokens.dart';

class ToggleTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;

  const ToggleTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Semantics(
      button: true,
      enabled: enabled,
      label: '$title${subtitle != null ? '. $subtitle' : ''}',
      toggled: value,
      child: AbsorbPointer(
        absorbing: !enabled,
        child: InkWell(
          onTap: enabled ? () => onChanged?.call(!value) : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.all(AppSpace.x4),
          decoration: BoxDecoration(
            color: value
                ? colorScheme.primary.withOpacity(0.15)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: value
                  ? colorScheme.primary.withOpacity(0.4)
                  : colorScheme.outline.withOpacity(0.2),
              width: value ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: value
                        ? colorScheme.primary.withOpacity(0.3)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: icon!,
                  ),
                ),
                const SizedBox(width: AppSpace.x3),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpace.x1),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.x2),
              Switch.adaptive(
                value: value,
                onChanged: enabled ? onChanged : null,
                activeThumbColor: colorScheme.primary,
                activeTrackColor: colorScheme.primary.withOpacity(0.3),
                inactiveThumbColor: colorScheme.outline,
                inactiveTrackColor: colorScheme.surfaceContainerHighest,
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
