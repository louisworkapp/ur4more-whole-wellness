import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

class MindWellnessHeader extends StatelessWidget {
  final int mentalWellnessPoints;
  final int reflectionStreak;
  final Function() onRefresh;

  const MindWellnessHeader({
    super.key,
    required this.mentalWellnessPoints,
    required this.reflectionStreak,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0FA97A),
            const Color(0xFF0FA97A).withOpacity( 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: Pad.card,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mind Wellness',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: AppSpace.x1),
                      Text(
                        'Nurture your mental health',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity( 0.9),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: onRefresh,
                    child: Container(
                      padding: EdgeInsets.all(AppSpace.x2),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity( 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: CustomIconWidget(
                        iconName: 'refresh',
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpace.x3),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: 'psychology',
                      title: 'Mind Points',
                      value: mentalWellnessPoints.toString(),
                      subtitle: 'Total earned',
                      theme: theme,
                    ),
                  ),
                  SizedBox(width: AppSpace.x4),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: 'local_fire_department',
                      title: 'Streak',
                      value: reflectionStreak.toString(),
                      subtitle: 'Days in a row',
                      theme: theme,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required String icon,
    required String title,
    required String value,
    required String subtitle,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity( 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withOpacity( 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: icon,
                color: Colors.white,
                size: 16,
              ),
              SizedBox(width: AppSpace.x2),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withOpacity( 0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x1),
          Text(
            value,
            style: theme.textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity( 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
