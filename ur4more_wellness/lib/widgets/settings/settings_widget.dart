import 'package:flutter/material.dart';
import '../../design/tokens.dart';
import 'setting_card.dart';
import 'toggle_tile.dart';
import 'choice_tile.dart';

/// A reusable Settings widget for building settings sections
/// 
/// This widget provides a consistent way to display settings with:
/// - Section cards with titles and icons
/// - Toggle switches for boolean settings
/// - Choice tiles for selecting from options
/// - Custom content support
class SettingsWidget extends StatelessWidget {
  /// Title of the settings section
  final String title;
  
  /// Optional subtitle/description
  final String? subtitle;
  
  /// Optional icon for the section
  final Widget? icon;
  
  /// List of setting items to display
  final List<SettingItem> items;
  
  /// Optional margin around the entire widget
  final EdgeInsets? margin;
  
  /// Optional padding inside the card
  final EdgeInsets? padding;

  const SettingsWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.items,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return SettingCard(
      title: title,
      subtitle: subtitle,
      icon: icon,
      margin: margin,
      padding: padding,
      children: items.map((item) => _buildSettingItem(context, item)).toList(),
    );
  }

  Widget _buildSettingItem(BuildContext context, SettingItem item) {
    final widget = _buildItemWidget(context, item);
    
    // Wrap with key if provided for stable rebuilds
    if (item.key != null) {
      return KeyedSubtree(key: item.key, child: widget);
    }
    
    return widget;
  }

  Widget _buildItemWidget(BuildContext context, SettingItem item) {
    if (item is ToggleSettingItem) {
      return ToggleTile(
        key: item.key,
        title: item.title,
        subtitle: item.subtitle,
        icon: item.icon,
        value: item.value,
        onChanged: item.onChanged,
        enabled: item.enabled,
      );
    } else if (item is ChoiceSettingItem) {
      return ChoiceTile(
        key: item.key,
        value: item.value,
        groupValue: item.groupValue,
        title: item.title,
        subtitle: item.subtitle,
        icon: item.icon,
        onChanged: item.onChanged,
        enabled: item.enabled,
      );
    } else if (item is CustomSettingItem) {
      // Wrap custom item with semantics using SettingItem metadata
      return Semantics(
        label: '${item.title}${item.subtitle != null ? '. ${item.subtitle}' : ''}',
        child: item.child,
      );
    } else if (item is ActionSettingItem) {
      return _buildActionTile(context, item);
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildActionTile(BuildContext context, ActionSettingItem item) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final borderRadius = BorderRadius.circular(12);

    return MouseRegion(
      cursor: item.enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: Semantics(
        button: true,
        enabled: item.enabled,
        label: '${item.title}${item.subtitle != null ? '. ${item.subtitle}' : ''}',
        child: Material(
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: borderRadius,
            side: BorderSide(
              color: colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: InkWell(
            onTap: item.enabled ? item.onTap : null,
            borderRadius: borderRadius,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.all(AppSpace.x4),
                child: Row(
                  children: [
                    if (item.icon != null) ...[
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: item.icon!,
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
                            item.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: item.enabled
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurface.withOpacity(0.38),
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          if (item.subtitle != null) ...[
                            const SizedBox(height: AppSpace.x1),
                            Text(
                              item.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: item.enabled
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onSurfaceVariant.withOpacity(0.38),
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: AppSpace.x2),
                    item.trailing ??
                        Icon(
                          Icons.chevron_right,
                          color: item.enabled
                              ? colorScheme.onSurfaceVariant
                              : colorScheme.onSurfaceVariant.withOpacity(0.38),
                          size: 24,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Base class for setting items
abstract class SettingItem {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final bool enabled;
  final Key? key;

  const SettingItem({
    required this.title,
    this.subtitle,
    this.icon,
    this.enabled = true,
    this.key,
  });
}

/// Toggle setting item (boolean switch)
class ToggleSettingItem extends SettingItem {
  final bool value;
  final ValueChanged<bool>? onChanged;

  const ToggleSettingItem({
    required super.title,
    super.subtitle,
    super.icon,
    required this.value,
    this.onChanged,
    super.enabled = true,
    super.key,
  });
}

/// Choice setting item (radio-style selection)
class ChoiceSettingItem<T> extends SettingItem {
  final T value;
  final T? groupValue;
  final ValueChanged<T?>? onChanged;

  const ChoiceSettingItem({
    required super.title,
    super.subtitle,
    super.icon,
    required this.value,
    required this.groupValue,
    this.onChanged,
    super.enabled = true,
    super.key,
  });
}

/// Action setting item (tappable tile with navigation/action)
class ActionSettingItem extends SettingItem {
  final VoidCallback? onTap;
  final Widget? trailing;

  const ActionSettingItem({
    required super.title,
    super.subtitle,
    super.icon,
    this.onTap,
    this.trailing,
    super.enabled = true,
    super.key,
  });
}

/// Custom setting item (fully custom widget)
/// 
/// Uses title/subtitle/icon for semantics only - the child widget
/// is what actually renders.
class CustomSettingItem extends SettingItem {
  final Widget child;

  const CustomSettingItem({
    required super.title,
    super.subtitle,
    super.icon,
    required this.child,
    super.enabled = true,
    super.key,
  });
}

