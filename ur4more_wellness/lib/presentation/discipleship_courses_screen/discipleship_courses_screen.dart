import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../design/tokens.dart';
import '../../widgets/custom_app_bar.dart';
import '../../features/courses/presentation/courses_screen.dart';
import '../../features/courses/data/course_repository.dart';
import '../../features/courses/models/course_models.dart';
import '../../services/faith_service.dart';
import './widgets/discipleship_header.dart';
import './widgets/course_progress_card.dart';
import './widgets/featured_course_card.dart';

class DiscipleshipCoursesScreen extends StatefulWidget {
  const DiscipleshipCoursesScreen({super.key});

  @override
  State<DiscipleshipCoursesScreen> createState() => _DiscipleshipCoursesScreenState();
}

class _DiscipleshipCoursesScreenState extends State<DiscipleshipCoursesScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final CourseRepository _repository = CourseRepository();
  
  List<Course> _courses = [];
  List<Course> _featuredCourses = [];
  bool _isLoading = true;
  int _discipleshipPoints = 850;
  int _currentWeek = 3;
  double _progress = 0.25;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get current faith tier
      final faithMode = await FaithService.getFaithMode();
      final tier = _getFaithTierFromMode(faithMode.toString().split('.').last);
      
      _courses = await _repository.getCoursesForTier(tier);
      
      // Get featured courses (UR4MORE Core and other prominent ones)
      _featuredCourses = _courses.where((course) => 
        course.id == 'ur4more_core_12wk' || 
        course.tags.contains('foundations') ||
        course.provider == 'UR4MORE'
      ).toList();
      
      // Get progress for UR4MORE Core
      if (_courses.any((c) => c.id == 'ur4more_core_12wk')) {
        final progress = await _repository.getCourseProgress('ur4more_core_12wk');
        if (progress != null) {
          _currentWeek = progress.currentWeek;
          _progress = progress.progress;
        }
      }
    } catch (e) {
      print('Error loading discipleship data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  FaithTier _getFaithTierFromMode(String faithMode) {
    switch (faithMode.toLowerCase()) {
      case 'off':
        return FaithTier.off;
      case 'light':
        return FaithTier.light;
      case 'disciple':
        return FaithTier.disciple;
      case 'kingdom':
        return FaithTier.kingdomBuilder;
      default:
        return FaithTier.off;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: "Discipleship",
        variant: CustomAppBarVariant.withActions,
        backgroundColor: colorScheme.surface,
        actions: [
          Container(
            margin: EdgeInsets.only(right: AppSpace.x2),
            padding: EdgeInsets.symmetric(horizontal: AppSpace.x3, vertical: AppSpace.x1),
            decoration: BoxDecoration(
              color: AppTheme.secondaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomIconWidget(
                  iconName: 'auto_awesome',
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: AppSpace.x1),
                Text(
                  "$_discipleshipPoints",
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: CustomIconWidget(
              iconName: 'search',
              color: colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () => _navigateToAllCourses(),
          ),
          SizedBox(width: AppSpace.x2),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildActiveContent(context, colorScheme),
    );
  }

  Widget _buildActiveContent(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Discipleship header
        const DiscipleshipHeader(),

        // Progress card
        CourseProgressCard(
          currentWeek: _currentWeek,
          progress: _progress,
          discipleshipPoints: _discipleshipPoints,
          onTap: () => _navigateToUr4moreCore(),
        ),

        // Featured course
        if (_featuredCourses.isNotEmpty)
          FeaturedCourseCard(
            course: _featuredCourses.first,
            onTap: () => _navigateToCourse(_featuredCourses.first),
          ),

        // Tab bar
        Container(
          margin: EdgeInsets.symmetric(horizontal: AppSpace.x4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: "Featured"),
              Tab(text: "All Courses"),
              Tab(text: "Progress"),
            ],
            labelColor: AppTheme.primaryLight,
            unselectedLabelColor: colorScheme.onSurfaceVariant,
            indicatorColor: AppTheme.primaryLight,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w400,
            ),
            dividerColor: Colors.transparent,
          ),
        ),

        // Tab content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildFeaturedTab(context, colorScheme),
              _buildAllCoursesTab(context, colorScheme),
              _buildProgressTab(context, colorScheme),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedTab(BuildContext context, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryLight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: AppSpace.x2),
            
            // Featured courses grid
            ..._featuredCourses.map((course) => Container(
              margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x1),
              child: _buildCourseCard(course, colorScheme, isFeatured: true),
            )),
            
            SizedBox(height: AppSpace.x4),
          ],
        ),
      ),
    );
  }

  Widget _buildAllCoursesTab(BuildContext context, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryLight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: AppSpace.x2),
            
            // All courses list
            ..._courses.map((course) => Container(
              margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x1),
              child: _buildCourseCard(course, colorScheme, isFeatured: false),
            )),
            
            SizedBox(height: AppSpace.x4),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressTab(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppTheme.primaryLight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: AppSpace.x2),
            
            // Progress overview
            Container(
              margin: EdgeInsets.symmetric(horizontal: AppSpace.x4),
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
                  Text(
                    "Learning Journey",
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryLight,
                    ),
                  ),
                  SizedBox(height: AppSpace.x2),
                  Text(
                    "You're making great progress in your discipleship journey! Keep up the momentum and continue growing in your faith.",
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: AppSpace.x3),
                  Row(
                    children: [
                      Expanded(
                        child: _buildProgressStat(
                          "Weeks Completed",
                          "$_currentWeek of 12",
                          Icons.check_circle_outline,
                          colorScheme,
                        ),
                      ),
                      SizedBox(width: AppSpace.x3),
                      Expanded(
                        child: _buildProgressStat(
                          "Progress",
                          "${(_progress * 100).round()}%",
                          Icons.trending_up,
                          colorScheme,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpace.x4),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressStat(String label, String value, IconData icon, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    
    return Container(
      padding: EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppTheme.primaryLight,
            size: 24,
          ),
          SizedBox(height: AppSpace.x1),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryLight,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCourseCard(Course course, ColorScheme colorScheme, {required bool isFeatured}) {
    final theme = Theme.of(context);
    final isUr4moreCore = course.id == 'ur4more_core_12wk';

    return Container(
      decoration: BoxDecoration(
        gradient: isUr4moreCore
            ? LinearGradient(
                colors: [
                  AppTheme.primaryLight.withOpacity(0.1),
                  AppTheme.primaryLight.withOpacity(0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        borderRadius: BorderRadius.circular(16),
        border: isUr4moreCore
            ? Border.all(
                color: AppTheme.primaryLight.withOpacity(0.3),
                width: 2,
              )
            : Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
      ),
      child: Card(
        elevation: isFeatured ? 2 : 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToCourse(course),
          child: Padding(
            padding: EdgeInsets.all(AppSpace.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Course icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isUr4moreCore
                            ? AppTheme.primaryLight
                            : colorScheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isUr4moreCore
                            ? Icons.auto_stories_rounded
                            : Icons.play_circle_outline,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: AppSpace.x3),
                    
                    // Course info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  course.title,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: isUr4moreCore
                                        ? AppTheme.primaryLight
                                        : colorScheme.onSurface,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (course.isFirstParty())
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: AppSpace.x2,
                                    vertical: AppSpace.x1,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUr4moreCore
                                        ? AppTheme.primaryLight.withOpacity(0.2)
                                        : colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'In-App',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: isUr4moreCore
                                          ? AppTheme.primaryLight
                                          : colorScheme.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
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
                            course.cost,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: course.cost.toLowerCase().contains('free')
                                  ? AppTheme.primaryLight
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _navigateToCourse(course),
                      icon: Icon(
                        course.isFirstParty() ? Icons.play_arrow : Icons.open_in_new,
                        size: 18,
                      ),
                      label: Text(course.isFirstParty() ? 'Start' : 'View'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isUr4moreCore
                            ? AppTheme.primaryLight
                            : colorScheme.primary,
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
      ),
    );
  }

  void _navigateToAllCourses() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CoursesScreen(),
      ),
    );
  }

  void _navigateToCourse(Course course) {
    if (course.isFirstParty()) {
      Navigator.pushNamed(
        context,
        AppRoutes.courseDetail,
        arguments: {'courseId': course.id},
      );
    } else {
      // For external courses, navigate to the full courses screen
      _navigateToAllCourses();
    }
  }

  void _navigateToUr4moreCore() {
    final ur4moreCore = _courses.firstWhere(
      (course) => course.id == 'ur4more_core_12wk',
      orElse: () => _courses.first,
    );
    _navigateToCourse(ur4moreCore);
  }

  Future<void> _refreshContent() async {
    await _loadData();
  }
}
