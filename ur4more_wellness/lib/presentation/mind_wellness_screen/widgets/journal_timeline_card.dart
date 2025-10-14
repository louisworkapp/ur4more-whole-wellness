import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class JournalTimelineCard extends StatelessWidget {
  final Map<String, dynamic> entry;
  final Function() onTap;
  final Function() onEdit;
  final Function() onDelete;
  final Function() onShare;
  final Function() onFavorite;

  const JournalTimelineCard({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onShare,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isFavorite = entry["isFavorite"] as bool? ?? false;
    final mood = entry["mood"] as String? ?? "neutral";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildMoodIndicator(mood, colorScheme),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _formatDate(entry["date"] as DateTime),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (entry["tags"] != null &&
                              (entry["tags"] as List).isNotEmpty)
                            Wrap(
                              spacing: 1.w,
                              children:
                                  (entry["tags"] as List).take(3).map((tag) {
                                return Container(
                                  margin: EdgeInsets.only(top: 0.5.h),
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0FA97A)
                                        .withOpacity( 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    tag as String,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFF0FA97A),
                                      fontSize: 10.sp,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                        ],
                      ),
                    ),
                    if (isFavorite)
                      CustomIconWidget(
                        iconName: 'favorite',
                        color: Colors.red,
                        size: 16,
                      ),
                    SizedBox(width: 2.w),
                    CustomIconWidget(
                      iconName: 'more_vert',
                      color: colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  _truncateText(entry["content"] as String, 150),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                if ((entry["content"] as String).length > 150)
                  Padding(
                    padding: EdgeInsets.only(top: 1.h),
                    child: Text(
                      'Read more...',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF0FA97A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      _formatTime(entry["date"] as DateTime),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${(entry["content"] as String).split(' ').length} words',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoodIndicator(String mood, ColorScheme colorScheme) {
    Color moodColor;
    IconData moodIcon;

    switch (mood.toLowerCase()) {
      case 'happy':
        moodColor = Colors.green;
        moodIcon = Icons.sentiment_very_satisfied;
        break;
      case 'sad':
        moodColor = Colors.blue;
        moodIcon = Icons.sentiment_very_dissatisfied;
        break;
      case 'anxious':
        moodColor = Colors.orange;
        moodIcon = Icons.sentiment_dissatisfied;
        break;
      case 'peaceful':
        moodColor = const Color(0xFF0FA97A);
        moodIcon = Icons.self_improvement;
        break;
      case 'grateful':
        moodColor = Colors.purple;
        moodIcon = Icons.favorite;
        break;
      default:
        moodColor = colorScheme.onSurfaceVariant;
        moodIcon = Icons.sentiment_neutral;
    }

    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: moodColor.withOpacity( 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        moodIcon,
        color: moodColor,
        size: 16,
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(4.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurfaceVariant
                      .withOpacity( 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: 3.h),
              _buildContextMenuItem(
                context,
                icon: 'edit',
                title: 'Edit Entry',
                onTap: () {
                  Navigator.pop(context);
                  onEdit();
                },
              ),
              _buildContextMenuItem(
                context,
                icon: entry["isFavorite"] == true
                    ? 'favorite'
                    : 'favorite_border',
                title: entry["isFavorite"] == true
                    ? 'Remove from Favorites'
                    : 'Add to Favorites',
                onTap: () {
                  Navigator.pop(context);
                  onFavorite();
                },
              ),
              _buildContextMenuItem(
                context,
                icon: 'share',
                title: 'Share Anonymously',
                onTap: () {
                  Navigator.pop(context);
                  onShare();
                },
              ),
              _buildContextMenuItem(
                context,
                icon: 'delete',
                title: 'Delete Entry',
                isDestructive: true,
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
              SizedBox(height: 2.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContextMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: isDestructive ? colorScheme.error : colorScheme.onSurface,
        size: 20,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: isDestructive ? colorScheme.error : colorScheme.onSurface,
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}...';
  }
}
