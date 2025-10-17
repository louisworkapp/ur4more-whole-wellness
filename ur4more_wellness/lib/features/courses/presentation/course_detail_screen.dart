import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_app_bar.dart';
import '../data/course_repository.dart';
import '../models/course_models.dart';
import '../../../routes/app_routes.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  final CourseRepository _repository = CourseRepository();
  Course? _course;
  CourseProgress? _progress;
  FaithTier _currentTier = FaithTier.off;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final course = await _repository.loadCoreFromAssets(context);
      final progress = await _repository.getCourseProgress(course.id);
      final tier = FaithTier.light; // Default to light tier
      
      setState(() {
        _course = course;
        _progress = progress;
        _currentTier = tier;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading course data: $e');
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
        title: _course?.title ?? 'Course Details',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _course == null
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
              'Unable to load course',
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
                  _buildCourseHeader(theme, colorScheme),
                  const SizedBox(height: AppSpace.x6),
                  _buildWeeksList(theme, colorScheme),
                ],
              ),
            ),
          ),
        ),
        _buildBottomAction(theme, colorScheme),
      ],
    );
  }

  Widget _buildCourseHeader(ThemeData theme, ColorScheme colorScheme) {
    if (_course == null) return const SizedBox.shrink();

    final progressPercentage = _progress?.progressPercentage ?? 0.0;
    final completedWeeks = _progress?.weekCompletion.values
            .where((completed) => completed)
            .length ??
        0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                    child: Icon(
                      Icons.auto_stories_rounded,
                      color: colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpace.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _course!.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const SizedBox(height: AppSpace.x1),
                        Text(
                          _course!.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpace.x4),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Progress',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: AppSpace.x1),
                        LinearProgressIndicator(
                          value: progressPercentage,
                          backgroundColor: colorScheme.onPrimaryContainer.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.onPrimaryContainer,
                          ),
                          minHeight: 6,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.x4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.x3,
                      vertical: AppSpace.x2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimaryContainer.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Text(
                      '${(progressPercentage * 100).round()}%',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpace.x2),
              Text(
                '$completedWeeks of 12 weeks completed',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeksList(ThemeData theme, ColorScheme colorScheme) {
    if (_course == null || _progress == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Course Content',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpace.x4),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _course!.weeks.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpace.x3),
          itemBuilder: (context, index) {
            final week = _course!.weeks[index];
            return _buildWeekCard(theme, colorScheme, week);
          },
        ),
      ],
    );
  }

  Widget _buildWeekCard(ThemeData theme, ColorScheme colorScheme, Week week) {
    final isCompleted = _progress!.isWeekComplete(week.week);
    final isUnlocked = _repository.isWeekUnlocked(week.week, _currentTier, _progress!);
    final isCurrentWeek = week.week == _progress!.nextIncompleteWeek;

    return Card(
      elevation: isCurrentWeek ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        side: isCurrentWeek
            ? BorderSide(color: colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        onTap: isUnlocked ? () => _navigateToWeek(week) : null,
        child: Padding(
          padding: EdgeInsets.all(AppSpace.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? colorScheme.primary
                          : isUnlocked
                              ? colorScheme.primaryContainer
                              : colorScheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: isCompleted
                        ? Icon(
                            Icons.check,
                            color: colorScheme.onPrimary,
                            size: 20,
                          )
                        : isUnlocked
                            ? Text(
                                '${week.week}',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                                textAlign: TextAlign.center,
                              )
                            : Icon(
                                Icons.lock,
                                color: colorScheme.onSurfaceVariant,
                                size: 20,
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
                              'Week ${week.week}',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (isCurrentWeek) ...[
                              const SizedBox(width: AppSpace.x2),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpace.x2,
                                  vertical: AppSpace.x1,
                                ),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  borderRadius: BorderRadius.circular(AppRadius.sm),
                                ),
                                child: Text(
                                  'Current',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.onPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: AppSpace.x1),
                        Text(
                          week.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isUnlocked
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: AppSpace.x1),
                        Text(
                          week.theme,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isUnlocked
                                ? colorScheme.onSurfaceVariant
                                : colorScheme.onSurfaceVariant.withOpacity(0.6),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (!isUnlocked)
                    Icon(
                      Icons.lock_outline,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: AppSpace.x3),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.x2,
                      vertical: AppSpace.x1,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: colorScheme.onSecondaryContainer,
                        ),
                        const SizedBox(width: AppSpace.x1),
                        Text(
                          '${week.estLessonMinutes} min',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpace.x2),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.x2,
                      vertical: AppSpace.x1,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 14,
                          color: colorScheme.onTertiaryContainer,
                        ),
                        const SizedBox(width: AppSpace.x1),
                        Text(
                          '${week.estWeekPracticeMinutes} min/week',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onTertiaryContainer,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
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

  Widget _buildBottomAction(ThemeData theme, ColorScheme colorScheme) {
    final nextWeek = _progress?.nextIncompleteWeek ?? 1;
    final isCompleted = _progress?.weekCompletion.values.every((completed) => completed) ?? false;

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
                onPressed: isCompleted
                    ? () => _navigateToWeek(_course!.weeks[nextWeek - 1])
                    : () => _navigateToWeek(_course!.weeks[nextWeek - 1]),
                icon: Icon(
                  isCompleted ? Icons.refresh : Icons.play_arrow,
                ),
                label: Text(
                  isCompleted ? 'Review Course' : 'Continue',
                ),
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

  void _navigateToWeek(Week week) {
    if (_course != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.weekLesson,
        arguments: {
          'courseId': _course!.id,
          'week': week.week,
        },
      );
    }
  }
}
