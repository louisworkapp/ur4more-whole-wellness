import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../design/tokens.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../features/courses/data/course_repository.dart';
import '../../features/courses/models/course_models.dart';
import '../../routes/app_routes.dart';

class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final CourseRepository _repository = CourseRepository();
  
  Map<String, dynamic>? _lessonData;
  Course? _course;
  bool _isLoading = true;
  bool _isCompleted = false;
  int _currentWeek = 1;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadLessonData();
  }

  Future<void> _loadLessonData() async {
    final args = ModalRoute.of(context)?.settings.arguments as Map?;
    final week = (args?['week'] ?? 1) as int;
    final courseId = (args?['courseId'] ?? AppRoutes.ur4moreCoreId) as String;

    setState(() {
      _isLoading = true;
      _currentWeek = week;
    });

    try {
      // Load course data
      _course = await _repository.getCourseById(courseId);
      
      if (courseId == AppRoutes.ur4moreCoreId) {
        final courseData = await _repository.getUr4moreCoreData();
        if (courseData != null) {
          final lessons = courseData['lessons'] as List<dynamic>;
          _lessonData = lessons.firstWhere(
            (lesson) => lesson['week'] == week,
            orElse: () => lessons.first,
          );
        }
      }
      
      // Load progress
      final progress = await _repository.getCourseProgress(courseId);
      if (progress != null) {
        _progress = progress.progress;
        _isCompleted = week <= progress.currentWeek;
      }
    } catch (e) {
      print('Error loading lesson data: $e');
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
        appBar: CustomAppBar(
          title: "Loading...",
          backgroundColor: colorScheme.surface,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_lessonData == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: CustomAppBar(
          title: "Lesson Not Found",
          backgroundColor: colorScheme.surface,
        ),
        body: const Center(
          child: Text('Lesson not found'),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: "Week ${_lessonData!['week']}",
        backgroundColor: colorScheme.surface,
        actions: [
          if (_isCompleted)
            Container(
              margin: EdgeInsets.only(right: AppSpace.x2),
              padding: EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x1),
              decoration: BoxDecoration(
                color: AppTheme.primaryLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 16,
                  ),
                  SizedBox(width: AppSpace.x1),
                  Text(
                    "Completed",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(width: AppSpace.x2),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppSpace.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLessonHeader(theme, colorScheme),
            SizedBox(height: AppSpace.x4),
            _buildLessonContent(theme, colorScheme),
            SizedBox(height: AppSpace.x4),
            _buildPracticeSection(theme, colorScheme),
            SizedBox(height: AppSpace.x4),
            _buildActionButtons(theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryLight.withOpacity(0.1),
            AppTheme.primaryLight.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryLight.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primaryLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.auto_stories_rounded,
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
                      _lessonData!['title'],
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: AppSpace.x1),
                    Text(
                      _lessonData!['duration'] ?? '15 minutes',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpace.x3,
                  vertical: AppSpace.x2,
                ),
                decoration: BoxDecoration(
                  color: _lessonData!['type'] == 'foundation'
                      ? AppTheme.primaryLight.withOpacity(0.2)
                      : colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _lessonData!['type']?.toString().toUpperCase() ?? 'LESSON',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: _lessonData!['type'] == 'foundation'
                        ? AppTheme.primaryLight
                        : colorScheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x3),
          Text(
            _lessonData!['objective'],
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonContent(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpace.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Lesson Content',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpace.x3),
            _buildContentSection(
              theme,
              colorScheme,
              'This Week\'s Focus',
              _lessonData!['objective'] ?? 'Building foundational discipleship habits and understanding your identity in Christ.',
            ),
            SizedBox(height: AppSpace.x3),
            _buildContentSection(
              theme,
              colorScheme,
              'Key Learning Objectives',
              _getLearningObjectives(),
            ),
            SizedBox(height: AppSpace.x3),
            _buildContentSection(
              theme,
              colorScheme,
              'Scripture Focus',
              _getScriptureFocus(),
            ),
            if (_lessonData!['week'] <= 3) ...[
              SizedBox(height: AppSpace.x3),
              _buildContentSection(
                theme,
                colorScheme,
                'Foundation Phase',
                'This week is part of the foundation phase where we build core spiritual habits and understand what it means to follow Jesus.',
              ),
            ] else if (_lessonData!['week'] <= 6) ...[
              SizedBox(height: AppSpace.x3),
              _buildContentSection(
                theme,
                colorScheme,
                'Growth Phase',
                'You\'re now in the growth phase, developing emotional health and practical obedience in daily life.',
              ),
            ] else if (_lessonData!['week'] <= 9) ...[
              SizedBox(height: AppSpace.x3),
              _buildContentSection(
                theme,
                colorScheme,
                'Service Phase',
                'Welcome to the service phase! You\'ll learn to serve others and share your faith effectively.',
              ),
            ] else ...[
              SizedBox(height: AppSpace.x3),
              _buildContentSection(
                theme,
                colorScheme,
                'Multiplication Phase',
                'You\'ve reached the multiplication phase! Learn to become a disciple-maker and spiritual leader.',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContentSection(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryLight,
          ),
        ),
        SizedBox(height: AppSpace.x2),
        Text(
          content,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPracticeSection(ThemeData theme, ColorScheme colorScheme) {
    final practices = _lessonData!['practices'] as List<dynamic>? ?? [];

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpace.x4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.assignment_turned_in,
                  color: AppTheme.primaryLight,
                  size: 24,
                ),
                SizedBox(width: AppSpace.x2),
                Text(
                  'This Week\'s Practice',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpace.x3),
            ...practices.asMap().entries.map((entry) {
              final index = entry.key;
              final practice = entry.value;
              return Container(
                margin: EdgeInsets.only(bottom: AppSpace.x2),
                padding: EdgeInsets.all(AppSpace.x3),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpace.x3),
                    Expanded(
                      child: Text(
                        practice,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isCompleted ? null : _completeLesson,
            icon: Icon(_isCompleted ? Icons.check_circle : Icons.flag),
            label: Text(_isCompleted ? 'Completed' : 'Mark Complete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _isCompleted 
                  ? colorScheme.onSurfaceVariant 
                  : AppTheme.primaryLight,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: AppSpace.x6,
                vertical: AppSpace.x4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
        if (!_isCompleted) ...[
          SizedBox(height: AppSpace.x3),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _skipLesson,
              icon: Icon(Icons.skip_next),
              label: Text('Skip for Now'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colorScheme.onSurfaceVariant,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpace.x6,
                  vertical: AppSpace.x4,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _completeLesson() async {
    try {
      // Update progress
      final newProgress = (_currentWeek / 12).clamp(0.0, 1.0);
      await _repository.updateCourseProgress(
        AppRoutes.ur4moreCoreId,
        newProgress,
        _currentWeek,
      );

      // Award points (simulate)
      HapticFeedback.lightImpact();

      setState(() {
        _isCompleted = true;
        _progress = newProgress;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lesson completed! +50 points'),
          backgroundColor: AppTheme.primaryLight,
        ),
      );
    } catch (e) {
      print('Error completing lesson: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error completing lesson'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _skipLesson() {
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('You can return to this lesson anytime'),
      ),
    );
  }

  String _getLearningObjectives() {
    final week = _lessonData!['week'] as int;
    switch (week) {
      case 1:
        return '• Understand the gospel message and God\'s grace\n• Learn what it means to follow Jesus\n• Discover the importance of baptism and church community\n• Begin your discipleship journey';
      case 2:
        return '• Develop daily spiritual habits\n• Learn the ACTS prayer model\n• Understand the importance of Sabbath rest\n• Create a sustainable daily routine';
      case 3:
        return '• Discover your identity in Christ\n• Learn to "die to self" and become more like Jesus\n• Fight from victory, not for victory\n• Practice daily affirmations';
      case 4:
        return '• Create a personal rule of life\n• Learn habit stacking techniques\n• Make obedience practical and sustainable\n• Track spiritual growth habits';
      case 5:
        return '• Learn peacemaking and forgiveness\n• Understand healthy confession rhythms\n• Build authentic Christian community\n• Practice the 24-hour rule for conflicts';
      case 6:
        return '• Understand boundaries and emotional health\n• Learn to process grief and anxiety\n• Practice breath and Scripture interventions\n• Set healthy boundaries';
      case 7:
        return '• Understand vocation and calling\n• Learn to work with integrity and excellence\n• See your work as worship\n• Serve colleagues and customers';
      case 8:
        return '• Learn to share your story effectively\n• Practice Alpha-style conversations\n• Develop hospitality skills\n• Engage in spiritual conversations';
      case 9:
        return '• Discover your spiritual gifts\n• Learn about serving in ministry\n• Find your place in the church\n• Deploy your gifts for God\'s kingdom';
      case 10:
        return '• Understand biblical generosity\n• Learn about time, talent, and treasure\n• Engage in local mission work\n• Research justice issues';
      case 11:
        return '• Learn about spiritual warfare\n• Understand the armor of God\n• Practice freedom declarations\n• Break spiritual strongholds';
      case 12:
        return '• Learn to disciple others\n• Start a micro-group\n• Create a multiplication plan\n• Become a disciple-maker';
      default:
        return '• Build foundational discipleship habits\n• Understand your identity in Christ\n• Develop spiritual disciplines\n• Grow in your faith journey';
    }
  }

  String _getScriptureFocus() {
    final week = _lessonData!['week'] as int;
    switch (week) {
      case 1:
        return 'John 3:16-17 - "For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life. For God did not send his Son into the world to condemn the world, but to save the world through him."';
      case 2:
        return 'Matthew 6:6 - "But when you pray, go into your room, close the door and pray to your Father, who is unseen." and Mark 2:27 - "The Sabbath was made for man, not man for the Sabbath."';
      case 3:
        return 'Galatians 2:20 - "I have been crucified with Christ and I no longer live, but Christ lives in me. The life I now live in the body, I live by faith in the Son of God, who loved me and gave himself for me."';
      case 4:
        return 'Luke 9:23 - "Then he said to them all: \'Whoever wants to be my disciple must deny themselves and take up their cross daily and follow me.\'"';
      case 5:
        return 'Matthew 18:15 - "If your brother or sister sins, go and point out their fault, just between the two of you. If they listen to you, you have won them over."';
      case 6:
        return 'Philippians 4:6-7 - "Do not be anxious about anything, but in every situation, by prayer and petition, with thanksgiving, present your requests to God. And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus."';
      case 7:
        return 'Colossians 3:23 - "Whatever you do, work at it with all your heart, as working for the Lord, not for human masters."';
      case 8:
        return '1 Peter 3:15 - "But in your hearts revere Christ as Lord. Always be prepared to give an answer to everyone who asks you to give the reason for the hope that you have."';
      case 9:
        return '1 Corinthians 12:7 - "Now to each one the manifestation of the Spirit is given for the common good."';
      case 10:
        return '2 Corinthians 9:7 - "Each of you should give what you have decided in your heart to give, not reluctantly or under compulsion, for God loves a cheerful giver."';
      case 11:
        return 'Ephesians 6:10-11 - "Finally, be strong in the Lord and in his mighty power. Put on the full armor of God, so that you can take your stand against the devil\'s schemes."';
      case 12:
        return 'Matthew 28:19-20 - "Therefore go and make disciples of all nations, baptizing them in the name of the Father and of the Son and of the Holy Spirit, and teaching them to obey everything I have commanded you."';
      default:
        return 'John 15:5 - "I am the vine; you are the branches. If you remain in me and I in you, you will bear much fruit; apart from me you can do nothing."';
    }
  }
}
