import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';

class RewardDetailModalWidget extends StatelessWidget {
  final Map<String, dynamic> reward;
  final int currentPoints;
  final VoidCallback? onRedeem;
  final VoidCallback? onWishlist;
  final VoidCallback? onShare;

  const RewardDetailModalWidget({
    super.key,
    required this.reward,
    required this.currentPoints,
    this.onRedeem,
    this.onWishlist,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final pointsCost = reward['pointsCost'] as int? ?? 0;
    final isAvailable = (reward['availability'] as bool?) ?? true;
    final canAfford = currentPoints >= pointsCost;

    return Container(
      height: 600, // Fixed height instead of percentage
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: AppSpace.x1),
            width: 48, // Fixed width instead of percentage
            height: 2, // Fixed height instead of percentage
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity( 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reward Details',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onWishlist,
                      icon: CustomIconWidget(
                        iconName: 'favorite_border',
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                    IconButton(
                      onPressed: onShare,
                      icon: CustomIconWidget(
                        iconName: 'share',
                        color: colorScheme.primary,
                        size: 24,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSpace.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CustomImageWidget(
                      imageUrl: reward['image'] as String? ?? '',
                      width: double.infinity,
                      height: 200, // Fixed height instead of percentage
                      fit: BoxFit.cover,
                      semanticLabel: reward['semanticLabel'] as String? ??
                          'Reward item detail image',
                    ),
                  ),
                  SizedBox(height: 3.h),
                  // Title and points
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          reward['name'] as String? ?? 'Reward Item',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: colorScheme.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'stars',
                              color: colorScheme.onPrimary,
                              size: 20,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              pointsCost.toString(),
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Category and availability
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          reward['category'] as String? ?? 'General',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 3.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? colorScheme.tertiary.withOpacity( 0.2)
                              : colorScheme.error.withOpacity( 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: isAvailable ? 'check_circle' : 'cancel',
                              color: isAvailable
                                  ? colorScheme.tertiary
                                  : colorScheme.error,
                              size: 16,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              isAvailable ? 'Available' : 'Out of Stock',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: isAvailable
                                    ? colorScheme.tertiary
                                    : colorScheme.error,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  // Description
                  Text(
                    'Description',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    reward['description'] as String? ??
                        'No description available.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.5,
                    ),
                  ),
                  if (reward['requirements'] != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      'Requirements',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      reward['requirements'] as String? ?? '',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        height: 1.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  if (reward['terms'] != null) ...[
                    SizedBox(height: 3.h),
                    Text(
                      'Terms & Conditions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      reward['terms'] as String? ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        height: 1.4,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          // Bottom action area
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: colorScheme.outline.withOpacity( 0.2),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                if (!canAfford && isAvailable)
                  Container(
                    padding: EdgeInsets.all(3.w),
                    margin: EdgeInsets.only(bottom: 2.h),
                    decoration: BoxDecoration(
                      color: colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'warning',
                          color: colorScheme.onErrorContainer,
                          size: 20,
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: Text(
                            'You need ${pointsCost - currentPoints} more points to redeem this reward.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onErrorContainer,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (isAvailable && canAfford) ? onRedeem : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (isAvailable && canAfford)
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant.withOpacity( 0.3),
                      foregroundColor: (isAvailable && canAfford)
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      !isAvailable
                          ? 'Out of Stock'
                          : !canAfford
                              ? 'Insufficient Points'
                              : 'Redeem Now',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
