import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/badge_chip.dart';
import '../data/course_repository.dart';
import '../models/course_models.dart';
import '../../../routes/app_routes.dart';
import '../../../core/settings/settings_model.dart';
import '../../spirit/services/faith_mode_navigator.dart';

// Design System Colors
const Color _bgColor = Color(0xFF0C1220);
const Color _surfaceColor = Color(0xFF121A2B);
const Color _surface2Color = Color(0xFF172238);
const Color _textColor = Color(0xFFEAF1FF);
const Color _textSubColor = Color(0xFFA8B7D6);
const Color _brandBlue = Color(0xFF3C79FF);
const Color _brandBlue200 = Color(0xFF7AA9FF);
const Color _brandGold = Color(0xFFFFC24D);
const Color _brandGold700 = Color(0xFFD59E27);
const Color _outlineColor = Color(0xFF243356);

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
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
        title: 'Discipleship Courses',
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
              'Unable to load courses',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpace.x2),
            Text(
              'Please check your connection and try again.',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, colorScheme),
            const SizedBox(height: 24),
            _buildCourseCard(theme, colorScheme),
            const SizedBox(height: 24),
            _buildUpcomingCourses(theme, colorScheme),
            const SizedBox(height: 24),
            _buildCourseCategories(theme, colorScheme),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), 
            blurRadius: 12, 
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _brandBlue200.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'auto_stories',
                  color: _brandBlue200,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Grow in Faith',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _textColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Structured discipleship for your journey',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _textSubColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Text(
              'Take your next step in following Jesus with carefully crafted courses designed to deepen your faith and understanding.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: _textSubColor,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (_currentTier != FaithTier.off)
            BadgeChip(
              icon: Icons.star,
              label: 'Faith Tier: ${_currentTier.displayName}',
              color: _brandBlue,
            ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(ThemeData theme, ColorScheme colorScheme) {
    if (_course == null || _progress == null) return const SizedBox.shrink();

    final progressPercentage = _progress!.progressPercentage;
    final completedWeeks = _progress!.weekCompletion.values
        .where((completed) => completed)
        .length;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), 
            blurRadius: 12, 
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToCourseDetail(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: _brandBlue200.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _brandBlue200.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'auto_stories',
                        color: _brandBlue200,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _course!.title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _textColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _course!.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _textSubColor,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Progress badge moved to its own row
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    BadgeChip(
                      icon: Icons.check_circle,
                      label: '${(progressPercentage * 100).round()}% Complete',
                      color: _brandGold,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildProgressSection(theme, colorScheme, progressPercentage, completedWeeks),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: _brandGold,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x26000000),
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _navigateToCourseDetail,
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CustomIconWidget(
                                    iconName: completedWeeks > 0 ? 'play_arrow' : 'launch',
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    completedWeeks > 0 ? 'Continue Course' : 'Start Course',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    BadgeChip(
                      icon: Icons.schedule,
                      label: '12 weeks',
                      color: _brandBlue200,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    ThemeData theme,
    ColorScheme colorScheme,
    double progressPercentage,
    int completedWeeks,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface2Color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _outlineColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CustomIconWidget(
                    iconName: 'trending_up',
                    color: _brandBlue,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Course Progress',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: _brandBlue,
                    ),
                  ),
                ],
              ),
              BadgeChip(
                label: '${(progressPercentage * 100).round()}%',
                color: _brandBlue200,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progressPercentage,
              minHeight: 8,
              backgroundColor: const Color(0xFF1A2643),
              valueColor: const AlwaysStoppedAnimation(_brandBlue),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$completedWeeks of 12 weeks completed',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: _textSubColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (completedWeeks > 0)
                BadgeChip(
                  icon: Icons.check_circle,
                  label: 'Active',
                  color: _brandGold,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingCourses(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'schedule',
              color: _brandBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Upcoming Courses',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: _brandBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _outlineColor, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000), 
                blurRadius: 12, 
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildUpcomingCourseItem(
                theme,
                colorScheme,
                'Prayer & Intercession',
                'Deepen your prayer life and learn to intercede for others',
                'Coming Soon',
                'favorite',
              ),
              const SizedBox(height: 12),
              _buildUpcomingCourseItem(
                theme,
                colorScheme,
                'Biblical Leadership',
                'Develop leadership skills grounded in biblical principles',
                'Q1 2025',
                'group',
              ),
              const SizedBox(height: 12),
              _buildUpcomingCourseItem(
                theme,
                colorScheme,
                'Spiritual Gifts Discovery',
                'Identify and develop your spiritual gifts for ministry',
                'Q2 2025',
                'auto_awesome',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingCourseItem(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String description,
    String status,
    String iconName,
  ) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: _brandBlue200.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _brandBlue200.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: CustomIconWidget(
            iconName: iconName,
            color: _brandBlue200,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: _textColor,
                ),
              ),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _textSubColor,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
        BadgeChip(
          label: status,
          color: _brandGold700,
        ),
      ],
    );
  }

  Widget _buildCourseCategories(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'category',
              color: _brandBlue,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Course Categories',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: _brandBlue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                theme,
                colorScheme,
                'Foundation',
                'Basic faith principles',
                'school',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCategoryCard(
                theme,
                colorScheme,
                'Growth',
                'Spiritual development',
                'trending_up',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildCategoryCard(
                theme,
                colorScheme,
                'Ministry',
                'Serving others',
                'volunteer_activism',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildCategoryCard(
                theme,
                colorScheme,
                'Leadership',
                'Leading with purpose',
                'group',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    String description,
    String iconName,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _outlineColor, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000), 
            blurRadius: 12, 
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _brandBlue200.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _brandBlue200.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: CustomIconWidget(
              iconName: iconName,
              color: _brandBlue200,
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: _brandBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: theme.textTheme.bodySmall?.copyWith(
              color: _textSubColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _navigateToCourseDetail() {
    if (_course != null) {
      Navigator.pushNamed(
        context,
        AppRoutes.courseDetail,
        arguments: {'courseId': _course!.id},
      );
    }
  }
}
