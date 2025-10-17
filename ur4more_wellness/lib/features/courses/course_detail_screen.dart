import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../design/tokens.dart';
import 'data/course_repository.dart';
import 'models/course.dart';
import '../../routes/app_routes.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final CourseRepository _repository = CourseRepository();
  
  Course? _course;
  CourseProgress? _progress;
  Map<String, dynamic>? _ur4moreCoreData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCourseData();
  }

  Future<void> _loadCourseData() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final courseId = (args?['courseId'] ?? '') as String;

    if (courseId.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _course = await _repository.getCourseById(courseId);
      
      if (courseId == AppRoutes.ur4moreCoreId) {
        _ur4moreCoreData = await _repository.getUr4moreCoreData();
      }
      
      _progress = await _repository.getCourseProgress(courseId);
    } catch (e) {
      print('Error loading course data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Loading...'),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_course == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(
          title: const Text('Course Not Found'),
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
        ),
        body: const Center(
          child: Text('Course not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(_course!.title),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        foregroundColor: colorScheme.onSurface,
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(1.0),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpace.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCourseHeader(theme, colorScheme),
                const SizedBox(height: AppSpace.x4),
                _buildCourseInfo(theme, colorScheme),
                const SizedBox(height: AppSpace.x4),
                if (_course!.id == AppRoutes.ur4moreCoreId)
                  _buildUr4moreJourney(theme, colorScheme),
                if (_course!.id == AppRoutes.ur4moreCoreId)
                  const SizedBox(height: AppSpace.x4),
                _buildProgressSection(theme, colorScheme),
                const SizedBox(height: AppSpace.x4),
                _buildActionButton(theme, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseHeader(ThemeData theme, ColorScheme colorScheme) {
    final isUr4moreCore = _course!.id == AppRoutes.ur4moreCoreId;
    
    return Container(
      padding: const EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUr4moreCore
              ? [
                  const Color(0xFF0FA97A).withOpacity(0.1),
                  const Color(0xFF0FA97A).withOpacity(0.05),
                ]
              : [
                  colorScheme.primary.withOpacity(0.1),
                  colorScheme.primary.withOpacity(0.05),
                ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUr4moreCore
              ? const Color(0xFF0FA97A).withOpacity(0.3)
              : colorScheme.primary.withOpacity(0.2),
          width: isUr4moreCore ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpace.x3),
                decoration: BoxDecoration(
                  color: isUr4moreCore
                      ? const Color(0xFF0FA97A)
                      : colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isUr4moreCore
                      ? Icons.auto_stories_rounded
                      : Icons.auto_stories_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: AppSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _course!.title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isUr4moreCore
                            ? const Color(0xFF0FA97A)
                            : colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpace.x1),
                    Text(
                      _course!.provider,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (_course!.isFirstParty())
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.x3,
                    vertical: AppSpace.x2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'In-App',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpace.x3),
          Text(
            _course!.summary,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseInfo(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Course Details',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpace.x3),
            
            // Duration and Cost
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    theme,
                    colorScheme,
                    Icons.schedule,
                    'Duration',
                    _course!.duration,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    theme,
                    colorScheme,
                    Icons.attach_money,
                    'Cost',
                    _course!.cost,
                    valueColor: _course!.cost.toLowerCase().contains('free')
                        ? colorScheme.primary
                        : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.x3),
            
            // Format
            _buildInfoItem(
              theme,
              colorScheme,
              Icons.play_circle_outline,
              'Format',
              _course!.format.join(', '),
            ),
            const SizedBox(height: AppSpace.x3),
            
            // Tags
            Text(
              'Topics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpace.x2),
            Wrap(
              spacing: AppSpace.x2,
              runSpacing: AppSpace.x2,
              children: _course!.tags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpace.x3,
                    vertical: AppSpace.x2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.labelMedium,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    ThemeData theme,
    ColorScheme colorScheme,
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpace.x2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(ThemeData theme, ColorScheme colorScheme) {
    if (_course!.isFirstParty() && _progress != null) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Progress',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpace.x3),
              
              if (_progress!.hasStarted) ...[
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Week ${_progress!.currentWeek} of 12',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${(_progress!.progress * 100).round()}% Complete',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.x3,
                        vertical: AppSpace.x2,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${(_progress!.progress * 100).round()}%',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.x3),
                LinearProgressIndicator(
                  value: _progress!.progress,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                ),
              ] else ...[
                Text(
                  'Ready to start your discipleship journey!',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildUr4moreJourney(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: const Color(0xFF0FA97A).withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.route,
                  color: const Color(0xFF0FA97A),
                  size: 24,
                ),
                const SizedBox(width: AppSpace.x2),
                Text(
                  'Your Discipleship Journey',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0FA97A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.x3),
            Text(
              'This 12-week journey will transform your spiritual life through structured learning, practical application, and community engagement.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppSpace.x3),
            _buildJourneyPhase(
              theme,
              colorScheme,
              'Weeks 1-3',
              'Foundation',
              'Building core spiritual habits and understanding your identity in Christ',
              const Color(0xFF0FA97A),
            ),
            const SizedBox(height: AppSpace.x2),
            _buildJourneyPhase(
              theme,
              colorScheme,
              'Weeks 4-6',
              'Growth',
              'Developing emotional health and practical obedience in daily life',
              const Color(0xFF0FA97A).withOpacity(0.7),
            ),
            const SizedBox(height: AppSpace.x2),
            _buildJourneyPhase(
              theme,
              colorScheme,
              'Weeks 7-9',
              'Service',
              'Learning to serve others and share your faith effectively',
              const Color(0xFF0FA97A).withOpacity(0.5),
            ),
            const SizedBox(height: AppSpace.x2),
            _buildJourneyPhase(
              theme,
              colorScheme,
              'Weeks 10-12',
              'Multiplication',
              'Becoming a disciple-maker and spiritual leader in your community',
              const Color(0xFF0FA97A).withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJourneyPhase(
    ThemeData theme,
    ColorScheme colorScheme,
    String weeks,
    String title,
    String description,
    Color accentColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: accentColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppSpace.x3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      weeks,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: AppSpace.x2),
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpace.x1),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(ThemeData theme, ColorScheme colorScheme) {
    final isFirstParty = _course!.isFirstParty();
    final hasStarted = _progress?.hasStarted ?? false;
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _handleAction(),
        icon: Icon(
          isFirstParty 
              ? (hasStarted ? Icons.play_arrow : Icons.flag)
              : Icons.open_in_new,
        ),
        label: Text(
          isFirstParty 
              ? (hasStarted ? 'Continue Course' : 'Start Course')
              : 'Open Provider',
        ),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.x6,
            vertical: AppSpace.x4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _handleAction() {
    if (_course!.isFirstParty()) {
      // Navigate to in-app course content
      _showCourseContent();
    } else if (_course!.url.isNotEmpty) {
      _launchUrl(_course!.url);
    }
  }

  void _showCourseContent() {
    if (_ur4moreCoreData != null) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => _Ur4moreCoreContent(
          courseData: _ur4moreCoreData!,
          progress: _progress,
          onLessonTap: (week) {
            Navigator.pop(context);
            _startOrContinueLesson(week);
          },
        ),
      );
    }
  }

  void _startOrContinueLesson(int week) {
    Navigator.pushNamed(
      context,
      AppRoutes.lesson,
      arguments: {
        'week': week,
        'courseId': _course!.id,
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL: $e');
    }
  }
}

class _Ur4moreCoreContent extends StatelessWidget {
  final Map<String, dynamic> courseData;
  final CourseProgress? progress;
  final Function(int) onLessonTap;

  const _Ur4moreCoreContent({
    required this.courseData,
    required this.progress,
    required this.onLessonTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final lessons = courseData['lessons'] as List<dynamic>;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: AppSpace.x2),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onSurfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpace.x4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Course Lessons',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
          ),
          
          // Lessons list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final week = lesson['week'] as int;
                final isCompleted = progress != null && week <= progress!.currentWeek;
                final isCurrent = progress != null && week == progress!.currentWeek;
                
                return Container(
                  margin: const EdgeInsets.only(bottom: AppSpace.x3),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isCompleted 
                            ? colorScheme.primary
                            : isCurrent
                                ? colorScheme.primary.withOpacity(0.2)
                                : colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: isCompleted
                            ? Icon(
                                Icons.check,
                                color: colorScheme.onPrimary,
                                size: 24,
                              )
                            : Text(
                                '$week',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: isCurrent 
                                      ? colorScheme.primary
                                      : colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    title: Text(
                      lesson['title'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCompleted 
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      lesson['objective'],
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: Icon(
                      Icons.play_arrow,
                      color: isCompleted 
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.primary,
                    ),
                    onTap: () => onLessonTap(week),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isCurrent 
                            ? colorScheme.primary.withOpacity(0.3)
                            : colorScheme.outline.withOpacity(0.2),
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
