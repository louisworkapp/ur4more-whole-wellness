import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

class CourseProgressCard extends StatelessWidget {
  final String courseTitle;
  final double progress;
  final bool isActive;

  const CourseProgressCard({
    super.key,
    required this.courseTitle,
    required this.progress,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? T.gold.withOpacity(0.3) : T.gold.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Course icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isActive ? T.gold.withOpacity(0.2) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: CustomIconWidget(
              iconName: 'school',
              color: isActive ? T.gold : Colors.white.withOpacity(0.6),
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Course info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isActive ? 'Ready to start' : 'Coming soon',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isActive ? T.gold : Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          
          // Status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? T.gold.withOpacity(0.2) : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isActive ? 'Active' : 'Locked',
              style: theme.textTheme.labelSmall?.copyWith(
                color: isActive ? T.gold : Colors.white.withOpacity(0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}