import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../../../theme/tokens.dart';

class CourseProgressCard extends StatelessWidget {
  final int currentWeek;
  final double progress;
  final int discipleshipPoints;
  final VoidCallback onTap;

  const CourseProgressCard({
    super.key,
    required this.currentWeek,
    required this.progress,
    required this.discipleshipPoints,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(AppSpace.x4),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                T.blue.withOpacity(0.1),
                T.blue.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: T.blue.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  // Progress icon
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: T.blue,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: T.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  SizedBox(width: AppSpace.x4),
                  
                  // Progress info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UR4MORE Discipleship Core',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: T.blue,
                          ),
                        ),
                        SizedBox(height: AppSpace.x1),
                        Text(
                          currentWeek > 0 
                              ? 'Week $currentWeek of 12'
                              : 'Ready to start your journey',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (currentWeek > 0) ...[
                          SizedBox(height: AppSpace.x2),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: colorScheme.surfaceContainerHighest,
                                  valueColor: AlwaysStoppedAnimation<Color>(T.blue),
                                ),
                              ),
                              SizedBox(width: AppSpace.x2),
                              Text(
                                '${(progress * 100).round()}%',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: T.blue,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Points badge
                  Container(
                    padding: EdgeInsets.all(AppSpace.x3),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$discipleshipPoints',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: T.blue,
                          ),
                        ),
                        Text(
                          'Points',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: T.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              if (currentWeek > 0) ...[
                SizedBox(height: AppSpace.x3),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: AppSpace.x3, vertical: AppSpace.x2),
                  decoration: BoxDecoration(
                    color: T.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: T.blue,
                        size: 20,
                      ),
                      SizedBox(width: AppSpace.x2),
                      Expanded(
                        child: Text(
                          'Keep up the great work! You\'re building strong spiritual foundations.',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: T.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
