import 'package:flutter/material.dart';
import '../../models/mind_coach_copy.dart';
import '../../repositories/mind_coach_repository.dart';
import '../../../../services/faith_service.dart';
import '../../../../design/tokens.dart';
import '../../../../widgets/custom_icon_widget.dart';
import '../../services/conversion_funnel_service.dart';
import 'meaning_horizon_card.dart';

class MindCoursesTab extends StatefulWidget {
  final FaithMode faithMode;

  const MindCoursesTab({
    super.key,
    required this.faithMode,
  });

  @override
  State<MindCoursesTab> createState() => _MindCoursesTabState();
}

class _MindCoursesTabState extends State<MindCoursesTab> {
  List<CourseTile> _courses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  @override
  void didUpdateWidget(MindCoursesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.faithMode != widget.faithMode) {
      _loadCourses();
    }
  }

  void _loadCourses() {
    setState(() => _isLoading = true);
    
    final courses = MindCoachRepository.getCourses(widget.faithMode);
    
    setState(() {
      _courses = courses;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpace.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Mind Courses',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            'Structured learning paths for mental wellness',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          
          SizedBox(height: AppSpace.x6),
          
          // Courses List
          ..._courses.map((course) => Padding(
            padding: EdgeInsets.only(bottom: AppSpace.x4),
            child: _buildCourseCard(course, theme, colorScheme),
          )),
          
          // Coming Soon Section
          _buildComingSoonSection(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildCourseCard(
    CourseTile course,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return InkWell(
      onTap: () => _openCourse(course),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: EdgeInsets.all(AppSpace.x4),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Course Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCourseIcon(course.id),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                
                SizedBox(width: AppSpace.x4),
                
                // Course Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        course.title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: AppSpace.x1),
                      Text(
                        course.subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // XP Badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpace.x2,
                    vertical: AppSpace.x1,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: colorScheme.primary,
                        size: 16,
                      ),
                      SizedBox(width: AppSpace.x1),
                      Text(
                        '${course.xp} XP',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpace.x4),
            
            // Course Progress (placeholder)
            _buildCourseProgress(theme, colorScheme),
            
            SizedBox(height: AppSpace.x4),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openCourse(course),
                icon: CustomIconWidget(
                  iconName: 'play_arrow',
                  color: Colors.white,
                  size: 16,
                ),
                label: Text(
                  course.id == 'discipleship_12w' ? 'View in Spirit' : 'Start Course',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSpace.x3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseProgress(ThemeData theme, ColorScheme colorScheme) {
    // Placeholder progress - in real app, this would come from user data
    final progress = 0.0; // 0% progress
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpace.x2),
        LinearProgressIndicator(
          value: progress,
          backgroundColor: colorScheme.surfaceVariant,
          valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildComingSoonSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.construction,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              SizedBox(width: AppSpace.x2),
              Text(
                'Coming Soon',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            'More evidence-based courses are in development, including:\n• Stress Management\n• Sleep Optimization\n• Relationship Skills',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCourseIcon(String courseId) {
    switch (courseId) {
      case 'cog_foundations_8w':
        return Icons.psychology;
      case 'discipleship_12w':
        return Icons.auto_awesome;
      default:
        return Icons.school;
    }
  }

  void _openCourse(CourseTile course) {
    if (course.deepLink != null) {
      // Navigate to Spirit screen for Discipleship course
      Navigator.pushNamed(context, '/spiritual-growth-screen');
    } else {
      // Open course detail or start course
      showDialog(
        context: context,
        builder: (context) => _CourseDetailDialog(
          course: course,
          faithMode: widget.faithMode,
        ),
      );
    }
  }
}

class _CourseDetailDialog extends StatelessWidget {
  final CourseTile course;
  final FaithMode faithMode;

  const _CourseDetailDialog({
    required this.course,
    required this.faithMode,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 500),
        padding: EdgeInsets.all(AppSpace.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primary.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCourseIcon(course.id),
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
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${course.xp} XP per week',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: AppSpace.x3),
            Text(
              course.subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpace.x4),
            
            // Course content based on ID
            Expanded(
              child: _buildCourseContent(context),
            ),
            
            SizedBox(height: AppSpace.x4),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
                SizedBox(width: AppSpace.x3),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      
                      // Demo: Simulate week completion for OFF mode users
                      if (faithMode.isOff) {
                        _simulateWeekCompletion(context, course);
                      } else {
                        // Start course logic here
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('${course.title} started!'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    child: const Text('Start Course'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseContent(BuildContext context) {
    switch (course.id) {
      case 'cog_foundations_8w':
        return _buildCognitiveFoundationsContent(context);
      case 'discipleship_12w':
        return _buildDiscipleshipContent(context);
      default:
        return _buildGenericCourseContent(context);
    }
  }

  Widget _buildCognitiveFoundationsContent(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            'An 8-week evidence-based program combining Cognitive Behavioral Therapy (CBT), Motivational Interviewing, and Acceptance and Commitment Therapy (ACT) principles.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpace.x3),
          Text(
            'Weekly Topics:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpace.x2),
          ..._buildWeekTopics(context, [
            'Week 1: Understanding Thoughts & Emotions',
            'Week 2: Cognitive Distortions & Reframing',
            'Week 3: Behavioral Activation',
            'Week 4: Values Clarification',
            'Week 5: Mindfulness & Present Moment',
            'Week 6: Stress Management Techniques',
            'Week 7: Building Resilience',
            'Week 8: Maintaining Progress',
          ]),
        ],
      ),
    );
  }

  Widget _buildDiscipleshipContent(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Overview',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            'A 12-week spiritual growth journey that builds on cognitive foundations while integrating faith-based practices and biblical principles.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpace.x3),
          Text(
            'Weekly Topics:',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpace.x2),
          ..._buildWeekTopics(context, [
            'Week 1: Grace & Identity in Christ',
            'Week 2: Renewing the Mind',
            'Week 3: Prayer & Meditation',
            'Week 4: Scripture & Truth',
            'Week 5: Community & Fellowship',
            'Week 6: Service & Mission',
            'Week 7: Spiritual Disciplines',
            'Week 8: Overcoming Spiritual Battles',
            'Week 9: Fruit of the Spirit',
            'Week 10: Kingdom Living',
            'Week 11: Spiritual Gifts',
            'Week 12: Continuing the Journey',
          ]),
          SizedBox(height: AppSpace.x3),
          Container(
            padding: EdgeInsets.all(AppSpace.x3),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: AppSpace.x2),
                Expanded(
                  child: Text(
                    'This course is available in the Spirit section of the app.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
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

  Widget _buildGenericCourseContent(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Course details coming soon. This structured learning path will help you build essential mental wellness skills.',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }

  List<Widget> _buildWeekTopics(BuildContext context, List<String> topics) {
    final theme = Theme.of(context);
    return topics.map((topic) => Padding(
      padding: EdgeInsets.only(bottom: AppSpace.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: EdgeInsets.only(top: 6, right: AppSpace.x2),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              topic,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    )).toList();
  }

  IconData _getCourseIcon(String courseId) {
    switch (courseId) {
      case 'cog_foundations_8w':
        return Icons.psychology;
      case 'discipleship_12w':
        return Icons.auto_awesome;
      default:
        return Icons.school;
    }
  }

  /// Simulate week completion for demo purposes
  void _simulateWeekCompletion(BuildContext context, CourseTile course) {
    // Record completion for conversion tracking
    ConversionFunnelService.recordWeekCompletion();
    
    // Show completion message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Week 1 of ${course.title} completed!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    
    // Show Meaning Horizon card after a brief delay
    Future.delayed(const Duration(seconds: 3), () {
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => MeaningHorizonCard(
            headline: "Order is a beginning, not the end.",
            body: "Micro-order restores agency. We believe the deepest peace behind order is found in Jesus Christ.",
            onKeepSecular: () {
              // User chose to keep secular tools
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Continuing with secular tools. You can explore Faith Mode anytime in Settings.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        );
      }
    });
  }
}
