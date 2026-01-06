import 'package:flutter/material.dart';

import '../../design/tokens.dart';

class ChoiceTile<T> extends StatelessWidget {
  final T value;
  final T? groupValue;
  final String title;
  final String? subtitle;
  final Widget? icon;
  final ValueChanged<T?>? onChanged;
  final bool enabled;

  const ChoiceTile({
    super.key,
    required this.value,
    required this.groupValue,
    required this.title,
    this.subtitle,
    this.icon,
    this.onChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = value == groupValue;

    return Semantics(
      button: true,
      enabled: enabled,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      label: '$title${subtitle != null ? '. $subtitle' : ''}',
      child: AbsorbPointer(
        absorbing: !enabled,
        child: InkWell(
          onTap: enabled ? () => onChanged?.call(value) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
          constraints: const BoxConstraints(minHeight: 56),
          padding: const EdgeInsets.all(AppSpace.x4),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary.withOpacity(0.15) : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              if (icon != null) ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? colorScheme.primary.withOpacity(0.2)
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
                        fontWeight: FontWeight.w600,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppSpace.x1),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isSelected ? colorScheme.primary.withOpacity(0.8) : colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colorScheme.primary,
                  size: 24,
                ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
