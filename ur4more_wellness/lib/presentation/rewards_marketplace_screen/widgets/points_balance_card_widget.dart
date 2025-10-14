import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

class PointsBalanceCardWidget extends StatelessWidget {
  final int currentPoints;
  final List<Map<String, dynamic>> recentTransactions;
  final VoidCallback? onTap;

  const PointsBalanceCardWidget({
    super.key,
    required this.currentPoints,
    required this.recentTransactions,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
        padding: Pad.card,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withOpacity( 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Available Points',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimary.withOpacity( 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: AppSpace.x1),
                    Text(
                      currentPoints.toString(),
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 32, // Fixed font size instead of Sizer
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.all(AppSpace.x3),
                  decoration: BoxDecoration(
                    color: colorScheme.onPrimary.withOpacity( 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: CustomIconWidget(
                    iconName: 'stars',
                    color: colorScheme.onPrimary,
                    size: 32,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpace.x3),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Activity',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.onPrimary.withOpacity( 0.8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: AppSpace.x1),
                      if (recentTransactions.isNotEmpty)
                        ...recentTransactions
                            .take(2)
                            .map((transaction) => Padding(
                                  padding: EdgeInsets.only(bottom: AppSpace.x1),
                                  child: Row(
                                    children: [
                                      CustomIconWidget(
                                        iconName:
                                            (transaction['type'] as String?) ==
                                                    'earned'
                                                ? 'add_circle_outline'
                                                : 'remove_circle_outline',
                                        color:
                                            (transaction['type'] as String?) ==
                                                    'earned'
                                                ? colorScheme.tertiary
                                                : colorScheme.onPrimary
                                                    .withOpacity( 0.7),
                                        size: 14,
                                      ),
                                      SizedBox(width: AppSpace.x2),
                                      Expanded(
                                        child: Text(
                                          transaction['description']
                                                  as String? ??
                                              'Transaction',
                                          style: theme.textTheme.bodySmall
                                              ?.copyWith(
                                            color: colorScheme.onPrimary
                                                .withOpacity( 0.9),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Text(
                                        '${(transaction['type'] as String?) == 'earned' ? '+' : '-'}${transaction['points']}',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: colorScheme.onPrimary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList()
                      else
                        Text(
                          'No recent activity',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onPrimary.withOpacity( 0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                CustomIconWidget(
                  iconName: 'chevron_right',
                  color: colorScheme.onPrimary.withOpacity( 0.7),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
