import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_app_bar.dart';
import '../data/course_repository.dart';
import '../models/course_models.dart';

class WeekLessonScreen extends StatefulWidget {
  const WeekLessonScreen({super.key});

  @override
  State<WeekLessonScreen> createState() => _WeekLessonScreenState();
}

class _WeekLessonScreenState extends State<WeekLessonScreen> {
  final CourseRepository _repository = CourseRepository();
  Course? _course;
  Week? _week;
  bool _isCompleted = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final courseId = args?['courseId'] as String?;
      final weekNumber = args?['week'] as int?;

      if (courseId == null || weekNumber == null) {
        throw Exception('Missing course ID or week number');
      }

      final course = await _repository.loadCoreFromAssets(context);
      final week = course.weeks.firstWhere(
        (w) => w.week == weekNumber,
        orElse: () => throw Exception('Week not found'),
      );
      final isCompleted = await _repository.isWeekComplete(weekNumber);

      setState(() {
        _course = course;
        _week = week;
        _isCompleted = isCompleted;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading week data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: CustomAppBar(
        title: _week != null ? 'Week ${_week!.week}' : 'Lesson',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _week == null
              ? _buildErrorState(theme, colorScheme)
              : _buildContent(theme, colorScheme),
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.x6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: AppSpace.x4),
            Text(
              'Unable to load lesson',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpace.x2),
            Text(
              'Please try again later.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpace.x6),
            ElevatedButton(
              onPressed: _loadData,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppSpace.x4),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWeekHeader(theme, colorScheme),
                  const SizedBox(height: AppSpace.x6),
                  _buildScriptureSection(theme, colorScheme),
                  const SizedBox(height: AppSpace.x6),
                  _buildLessonSummary(theme, colorScheme),
                  const SizedBox(height: AppSpace.x6),
                  _buildKeyIdeas(theme, colorScheme),
                  const SizedBox(height: AppSpace.x6),
                  _buildReflectionQuestions(theme, colorScheme),
                  const SizedBox(height: AppSpace.x6),
                  _buildPracticeSection(theme, colorScheme),
                  const SizedBox(height: AppSpace.x6),
                  _buildPrayerSection(theme, colorScheme),
                  const SizedBox(height: AppSpace.x6),
                  _buildResourcesSection(theme, colorScheme),
                  const SizedBox(height: AppSpace.x8),
                ],
              ),
            ),
          ),
        ),
        _buildBottomAction(theme, colorScheme),
      ],
    );
  }

  Widget _buildWeekHeader(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpace.x5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
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
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: _isCompleted
                    ? Icon(
                        Icons.check,
                        color: colorScheme.onPrimary,
                        size: 24,
                      )
                    : Text(
                        '${_week!.week}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
              ),
              const SizedBox(width: AppSpace.x3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Week ${_week!.week}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppSpace.x1),
                    Text(
                      _week!.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x3),
          Text(
            _week!.theme,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onPrimaryContainer.withOpacity(0.9),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScriptureSection(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null || _week!.scriptureRefs.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      theme,
      colorScheme,
      'Scripture Focus',
      Icons.menu_book,
      Wrap(
        spacing: AppSpace.x2,
        runSpacing: AppSpace.x2,
        children: _week!.scriptureRefs.map((ref) {
          return Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpace.x3,
              vertical: AppSpace.x2,
            ),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Text(
              ref,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLessonSummary(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null) return const SizedBox.shrink();

    return _buildSection(
      theme,
      colorScheme,
      'This Week\'s Focus',
      Icons.lightbulb_outline,
      Text(
        _week!.lessonSummary,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: colorScheme.onSurface,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildKeyIdeas(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null || _week!.keyIdeas.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      theme,
      colorScheme,
      'Key Ideas',
      Icons.key,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _week!.keyIdeas.map((idea) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpace.x2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(
                    top: AppSpace.x2,
                    right: AppSpace.x3,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    idea,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReflectionQuestions(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null || _week!.reflectionQs.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      theme,
      colorScheme,
      'Reflection Questions',
      Icons.psychology,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _week!.reflectionQs.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpace.x3),
            padding: EdgeInsets.all(AppSpace.x4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpace.x3),
                Expanded(
                  child: Text(
                    question,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPracticeSection(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null || _week!.practice.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      theme,
      colorScheme,
      'Practice This Week',
      Icons.fitness_center,
      Column(
        children: _week!.practice.map((practice) {
          return Container(
            margin: const EdgeInsets.only(bottom: AppSpace.x3),
            padding: EdgeInsets.all(AppSpace.x4),
            decoration: BoxDecoration(
              color: colorScheme.tertiaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        practice.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                    Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpace.x2,
              vertical: AppSpace.x1,
            ),
                      decoration: BoxDecoration(
                        color: colorScheme.tertiary,
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                      child: Text(
                        '${practice.estMinutes} min',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpace.x2),
                Text(
                  practice.desc,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onTertiaryContainer,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPrayerSection(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null) return const SizedBox.shrink();

    return _buildSection(
      theme,
      colorScheme,
      'Prayer',
      Icons.favorite,
      Container(
        padding: EdgeInsets.all(AppSpace.x4),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer.withOpacity(0.3),
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
        child: Text(
          _week!.prayer,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSecondaryContainer,
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildResourcesSection(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null || _week!.resources.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      theme,
      colorScheme,
      'Additional Resources',
      Icons.link,
      Column(
        children: _week!.resources.map((resource) {
          return Container(
            margin: EdgeInsets.only(bottom: AppSpace.x2),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                _getResourceIcon(resource.kind),
                color: colorScheme.primary,
                size: 20,
              ),
              title: Text(
                resource.title,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: Text(
                resource.kind,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: Icon(
                Icons.open_in_new,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
              onTap: () {
                // TODO: Open resource URL
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Opening ${resource.title}'),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSection(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    IconData icon,
    Widget content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: colorScheme.primary,
            ),
            SizedBox(width: AppSpace.x2),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpace.x3),
        content,
      ],
    );
  }

  Widget _buildBottomAction(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isCompleted ? null : _markWeekComplete,
                icon: Icon(_isCompleted ? Icons.check_circle : Icons.check),
                label: Text(_isCompleted ? 'Completed' : 'Mark Week Complete'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getResourceIcon(String kind) {
    switch (kind.toLowerCase()) {
      case 'article':
        return Icons.article;
      case 'video':
        return Icons.play_circle;
      case 'audio':
        return Icons.headphones;
      default:
        return Icons.link;
    }
  }

  Future<void> _markWeekComplete() async {
    if (_week == null) return;

    try {
      await _repository.markWeekComplete(_week!.week);
      
      setState(() {
        _isCompleted = true;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Week ${_week!.week} marked as complete!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );

        // Show completion dialog
        _showCompletionDialog();
      }
    } catch (e) {
      print('Error marking week complete: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Error marking week complete. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Week Complete!'),
        content: Text('Congratulations on completing Week ${_week!.week}: ${_week!.title}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to course detail
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
