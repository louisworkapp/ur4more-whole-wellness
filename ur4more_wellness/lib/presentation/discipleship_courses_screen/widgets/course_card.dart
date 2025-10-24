import 'package:flutter/material.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

class CourseCard extends StatelessWidget {
  final String title;
  final String description;
  final String duration;
  final String difficulty;
  final bool isRecommended;

  const CourseCard({
    super.key,
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.isRecommended,
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
          color: isRecommended ? T.gold.withOpacity(0.3) : T.gold.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and recommendation badge
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isRecommended)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: T.gold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Recommended',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: T.gold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Description
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.8),
              height: 1.4,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Course details
          Row(
            children: [
              _buildDetailItem('schedule', duration),
              const SizedBox(width: 16),
              _buildDetailItem('trending_up', difficulty),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String iconName, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: T.gold,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: T.gold,
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
