import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../../../theme/app_theme.dart';
import '../../../features/courses/models/course.dart';

class FeaturedCourseCard extends StatelessWidget {
  final Course course;
  final VoidCallback onTap;

  const FeaturedCourseCard({
    super.key,
    required this.course,
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
                AppTheme.secondaryLight.withOpacity(0.1),
                AppTheme.secondaryLight.withOpacity(0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.secondaryLight.withOpacity(0.3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Featured badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x1),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: AppSpace.x1),
                        Text(
                          'Featured',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x1),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      course.cost,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: course.cost.toLowerCase().contains('free')
                            ? AppTheme.secondaryLight
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpace.x3),
              
              // Course info
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: AppSpace.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: AppSpace.x1),
                        Text(
                          course.provider,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: AppSpace.x3),
              
              // Course summary
              Text(
                course.summary,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              
              SizedBox(height: AppSpace.x3),
              
              // Course details and action
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.duration,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          course.format.join(' • '),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: onTap,
                    icon: Icon(
                      course.isFirstParty() ? Icons.play_arrow : Icons.open_in_new,
                      size: 18,
                    ),
                    label: Text(course.isFirstParty() ? 'Start' : 'View'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryLight,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpace.x3,
                        vertical: AppSpace.x2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
}
