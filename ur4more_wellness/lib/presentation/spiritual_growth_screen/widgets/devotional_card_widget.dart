import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';

class DevotionalCardWidget extends StatelessWidget {
  final Map<String, dynamic> devotional;
  final VoidCallback? onTap;
  final VoidCallback? onShare;
  final VoidCallback? onBookmark;
  final VoidCallback? onAddToPrayer;
  final bool isBookmarked;

  const DevotionalCardWidget({
    super.key,
    required this.devotional,
    this.onTap,
    this.onShare,
    this.onBookmark,
    this.onAddToPrayer,
    this.isBookmarked = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      onLongPress: () => _showOptionsBottomSheet(context),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x1),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity( 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, colorScheme),
            _buildContent(context, colorScheme),
            _buildFooter(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Container(
      padding: Pad.card,
      decoration: BoxDecoration(
        color: AppTheme.secondaryLight.withOpacity( 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpace.x3, vertical: AppSpace.x1),
            decoration: BoxDecoration(
              color: AppTheme.secondaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              devotional["date"] as String? ?? "Today",
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: onBookmark,
            child: CustomIconWidget(
              iconName: isBookmarked ? 'bookmark' : 'bookmark_border',
              color: isBookmarked
                  ? AppTheme.secondaryLight
                  : colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Padding(
      padding: Pad.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            devotional["title"] as String? ?? "Daily Devotion",
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpace.x1),
          Container(
            padding: EdgeInsets.symmetric(horizontal: AppSpace.x3, vertical: AppSpace.x1),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withOpacity( 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              devotional["scripture"] as String? ?? "Philippians 4:13",
              style: theme.textTheme.labelLarge?.copyWith(
                color: AppTheme.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            devotional["verse"] as String? ??
                "I can do all things through Christ who strengthens me.",
            style: theme.textTheme.bodyLarge?.copyWith(
              fontStyle: FontStyle.italic,
              color: colorScheme.onSurface,
              height: 1.5,
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            devotional["reflection"] as String? ??
                "Today's reflection on spiritual growth...",
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    return Container(
      padding: Pad.card,
      child: Row(
        children: [
          if (devotional["isCompleted"] == true) ...[
            CustomIconWidget(
              iconName: 'check_circle',
              color: AppTheme.successLight,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              "Completed",
              style: theme.textTheme.labelMedium?.copyWith(
                color: AppTheme.successLight,
                fontWeight: FontWeight.w500,
              ),
            ),
          ] else ...[
            CustomIconWidget(
              iconName: 'schedule',
              color: colorScheme.onSurfaceVariant,
              size: 16,
            ),
            SizedBox(width: 2.w),
            Text(
              "${devotional["readTime"] ?? "5"} min read",
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: onShare,
            child: Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: 'share',
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: Pad.card,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withOpacity( 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            _buildOptionTile(
              context,
              icon: 'share',
              title: 'Share Verse',
              onTap: () {
                Navigator.pop(context);
                onShare?.call();
              },
            ),
            _buildOptionTile(
              context,
              icon: 'playlist_add',
              title: 'Add to Prayer List',
              onTap: () {
                Navigator.pop(context);
                onAddToPrayer?.call();
              },
            ),
            _buildOptionTile(
              context,
              icon: 'notifications',
              title: 'Set Reminder',
              onTap: () {
                Navigator.pop(context);
                // Handle reminder
              },
            ),
            _buildOptionTile(
              context,
              icon: isBookmarked ? 'bookmark' : 'bookmark_border',
              title: isBookmarked ? 'Remove Favorite' : 'Mark as Favorite',
              onTap: () {
                Navigator.pop(context);
                onBookmark?.call();
              },
            ),
            SizedBox(height: AppSpace.x2),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListTile(
      leading: CustomIconWidget(
        iconName: icon,
        color: colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}