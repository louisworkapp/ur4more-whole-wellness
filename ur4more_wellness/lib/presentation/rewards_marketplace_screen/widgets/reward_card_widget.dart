import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';

class RewardCardWidget extends StatelessWidget {
  final Map<String, dynamic> reward;
  final VoidCallback? onTap;
  final VoidCallback? onWishlist;
  final VoidCallback? onShare;

  const RewardCardWidget({
    super.key,
    required this.reward,
    this.onTap,
    this.onWishlist,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAvailable = (reward['availability'] as bool?) ?? true;
    final pointsCost = reward['pointsCost'] as int? ?? 0;

    return Slidable(
      key: ValueKey(reward['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onWishlist?.call(),
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
            icon: Icons.favorite_border,
            label: 'Wishlist',
            borderRadius: BorderRadius.circular(12),
          ),
          SlidableAction(
            onPressed: (_) => onShare?.call(),
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            icon: Icons.share,
            label: 'Share',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x1),
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
              // Image section
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(16)),
                child: Stack(
                  children: [
                    CustomImageWidget(
                      imageUrl: reward['image'] as String? ?? '',
                      width: double.infinity,
                        height: 100, // Reduced from 120 to 100
                      fit: BoxFit.cover,
                      semanticLabel: reward['semanticLabel'] as String? ??
                          'Reward item image',
                    ),
                    if (!isAvailable)
                      Container(
                        width: double.infinity,
                        height: 100, // Reduced from 120 to 100 to match image height
                        color: Colors.black.withOpacity( 0.6),
                        child: Center(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppSpace.x4, vertical: AppSpace.x1),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Out of Stock',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onError,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    Positioned(
                      top: AppSpace.x1,
                      right: AppSpace.x2,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: AppSpace.x2, vertical: AppSpace.x1),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'stars',
                              color: colorScheme.onPrimary,
                              size: 12,
                            ),
                            SizedBox(width: AppSpace.x1),
                            Text(
                              pointsCost.toString(),
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Content section
              Padding(
                padding: EdgeInsets.all(AppSpace.x2), // Reduced from x3 to x2
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reward['name'] as String? ?? 'Reward Item',
                      style: theme.textTheme.titleSmall?.copyWith( // Changed from titleMedium to titleSmall
                        fontWeight: FontWeight.w600,
                        color: isAvailable
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpace.x1),
                    Text(
                      reward['description'] as String? ?? 'Reward description',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSpace.x2), // Reduced from x3 to x2
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppSpace.x2, vertical: AppSpace.x1),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            reward['category'] as String? ?? 'General',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (reward['requirements'] != null)
                          CustomIconWidget(
                            iconName: 'info_outline',
                            color: colorScheme.primary,
                            size: 16,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
