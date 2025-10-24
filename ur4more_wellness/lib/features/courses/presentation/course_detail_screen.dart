import 'package:flutter/material.dart';
import 'dart:math';
import '../../../theme/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';
import '../../../widgets/discipleship_background.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/badge_chip.dart';
import '../data/course_repository.dart';
import '../models/course_models.dart';
import '../../../routes/app_routes.dart';

class CourseDetailScreen extends StatefulWidget {
  const CourseDetailScreen({super.key});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with TickerProviderStateMixin {
  final CourseRepository _repository = CourseRepository();
  Course? _course;
  CourseProgress? _progress;
  FaithTier _currentTier = FaithTier.off;
  bool _isLoading = true;

  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _sparkleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.linear,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
    _sparkleController.repeat();

    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _sparkleController.dispose();
    super.dispose();
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
    
    return Scaffold(
      body: Stack(
        children: [
          // Custom background gradient
          const DiscipleshipBackground(),
          
          // Content overlay
          SafeArea(
            child: Column(
              children: [
                // Custom app bar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Expanded(
                        child: Text(
                          _course?.title ?? 'Course Details',
                          style: theme.textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          // Profile action
                        },
                        icon: const Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                
                // Main content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: T.gold))
                      : _course == null
                          ? _buildErrorState(theme)
                          : _buildContent(theme),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.white,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load course',
              style: theme.textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again later.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadData,
              style: ElevatedButton.styleFrom(
                backgroundColor: T.gold,
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Top section with fish logo in center
          Container(
            height: 200,
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: T.gold.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: T.gold.withOpacity(0.3),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: T.gold.withOpacity(0.2),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Image.asset(
                        'assets/images/fish_logo.png',
                        color: T.gold,
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          // Content section with proper spacing
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Course header message
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      Text(
                        _course?.title ?? 'Discipleship Course',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 12),
                      
                      Text(
                        _course?.description ?? 'A comprehensive journey through the foundations of Christian faith.',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: T.gold,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              color: Colors.black.withOpacity(0.5),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Progress card with enhanced styling
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: T.gold.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CustomIconWidget(
                                  iconName: 'trending_up',
                                  color: T.gold,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Progress',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                BadgeChip(
                                  label: '${((_progress?.progressPercentage ?? 0.0) * 100).round()}%',
                                  color: T.gold,
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 12),
                            
                            LinearProgressIndicator(
                              value: _progress?.progressPercentage ?? 0.0,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(T.gold),
                              minHeight: 8,
                            ),
                            
                            const SizedBox(height: 8),
                            
                            Text(
                              '${(_progress?.weekCompletion.values.where((completed) => completed).length ?? 0)} of 12 weeks completed',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Course content section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: T.gold.withOpacity(0.4),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const CustomIconWidget(
                                  iconName: 'library_books',
                                  color: T.gold,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Course Content',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            
                            const SizedBox(height: 16),
                            
                            // Course weeks list - show all weeks
                            ...(_course?.weeks.map((week) => _buildWeekCard(theme, week)) ?? []),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Continue button with enhanced styling
                      Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: T.gold,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: T.gold.withOpacity(0.4),
                              blurRadius: 15,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              final nextWeek = _progress?.nextIncompleteWeek ?? 1;
                              if (_course != null && _course!.weeks.isNotEmpty) {
                                _navigateToWeek(_course!.weeks[nextWeek - 1]);
                              }
                            },
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CustomIconWidget(
                                    iconName: 'play_arrow',
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    (_progress?.weekCompletion.values.every((completed) => completed) ?? false)
                                        ? 'Review Course'
                                        : 'Continue',
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Waves footer at bottom of scroll
          Container(
            height: 120,
            width: double.infinity,
            child: Center(
              child: Image.asset(
                'assets/images/waves_logo.png',
                width: 300,
                height: 80,
                color: T.gold.withOpacity(0.3),
                colorBlendMode: BlendMode.modulate,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekCard(ThemeData theme, Week week) {
    final isCompleted = _progress?.isWeekComplete(week.week) ?? false;
    final isUnlocked = _repository.isWeekUnlocked(week.week, _currentTier, _progress!);
    final isCurrentWeek = week.week == (_progress?.nextIncompleteWeek ?? 1);

    return GestureDetector(
      onTap: isUnlocked ? () => _navigateToWeek(week) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isCurrentWeek 
                ? T.gold.withOpacity(0.5)
                : isUnlocked 
                    ? T.gold.withOpacity(0.2)
                    : Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
        children: [
          // Week number/status icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isCompleted
                  ? T.gold.withOpacity(0.2)
                  : isUnlocked
                      ? T.gold.withOpacity(0.15)
                      : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: T.gold, size: 20)
                : isUnlocked
                    ? Center(
                        child: Text(
                          '${week.week}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: T.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      )
                    : const Icon(Icons.lock, color: Colors.white54, size: 20),
          ),
          
          const SizedBox(width: 12),
          
          // Week content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Week ${week.week}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: T.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrentWeek) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: T.gold.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Current',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: T.gold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  week.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  week.theme,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
          
          // Duration badges
          Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: T.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${week.estLessonMinutes} min',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: T.gold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: T.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${week.estWeekPracticeMinutes} min/week',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: T.gold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
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