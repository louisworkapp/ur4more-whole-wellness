import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../courses/models/course_models.dart';
import '../../../routes/app_routes.dart';
import '../../../design/tokens.dart';
import '../../../theme/app_colors.dart';

class DiscipleshipHeader extends StatefulWidget {
  final FaithTier? tier;
  
  const DiscipleshipHeader({
    super.key,
    this.tier,
  });

  @override
  State<DiscipleshipHeader> createState() => _DiscipleshipHeaderState();
}

class _DiscipleshipHeaderState extends State<DiscipleshipHeader> {
  double _progress = 0.0; // 0..1
  int _week = 0;
  bool _hasStarted = false;
  FaithTier _tier = FaithTier.off;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tier = widget.tier ?? FaithTier.light; // Default to light tier
      
      // Load progress data
      double progress = 0.0;
      int completedWeeks = 0;
      
      for (int week = 1; week <= 12; week++) {
        final key = 'course:ur4more_core_12w:week:$week:done';
        if (prefs.getBool(key) ?? false) {
          completedWeeks++;
        }
      }
      
      progress = completedWeeks / 12;
      final currentWeek = prefs.getInt('course:ur4more_core_12w:lastWeek') ?? 1;
      final hasStarted = completedWeeks > 0;
      
      setState(() {
        _progress = progress;
        _week = currentWeek;
        _hasStarted = hasStarted;
        _tier = tier;
      });
    } catch (e) {
      print('Error loading discipleship progress: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hide completely if tier is off
    if (_tier == FaithTier.off) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpace.x4,
        vertical: AppSpace.x3,
      ),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          onTap: _navigateToDiscipleship,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _hasStarted ? [
                  AppColors.gold,
                  AppColors.gold.withOpacity(0.8),
                ] : [
                  colorScheme.primaryContainer,
                  colorScheme.primaryContainer.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppRadius.lg),
            ),
            padding: const EdgeInsets.all(AppSpace.x5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: _hasStarted ? AppColors.gold : colorScheme.primary,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                      ),
                      child: Icon(
                        Icons.auto_stories_rounded,
                        color: _hasStarted ? Colors.white : colorScheme.onPrimary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppSpace.x4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasStarted ? 'Discipleship Progress' : 'Start your Discipleship',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: _hasStarted ? Colors.white : colorScheme.onPrimaryContainer,
                            ),
                          ),
                          const SizedBox(height: AppSpace.x1),
                          Text(
                            _getSubtitleText(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _hasStarted ? Colors.white.withOpacity(0.9) : colorScheme.onPrimaryContainer.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_hasStarted) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.x3,
                          vertical: AppSpace.x2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                        child: Text(
                          '${(_progress * 100).round()}%',
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (_hasStarted) ...[
                  const SizedBox(height: AppSpace.x4),
                  _buildProgressSection(theme, colorScheme),
                ],
                const SizedBox(height: AppSpace.x4),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _navigateToDiscipleship,
                        icon: Icon(
                          _hasStarted ? Icons.play_arrow : Icons.launch,
                          size: 20,
                        ),
                        label: Text(
                          _hasStarted ? 'Continue' : 'Start Course',
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 48),
                          backgroundColor: _hasStarted ? AppColors.gold : colorScheme.primary,
                          foregroundColor: _hasStarted ? Colors.white : colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.md),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpace.x3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpace.x3,
                        vertical: AppSpace.x2,
                      ),
                      decoration: BoxDecoration(
                        color: _hasStarted ? Colors.white.withOpacity(0.2) : colorScheme.onPrimaryContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.schedule,
                            size: 16,
                            color: _hasStarted ? Colors.white : colorScheme.onPrimaryContainer,
                          ),
                          const SizedBox(width: AppSpace.x1),
                          Text(
                            '12 weeks',
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: _hasStarted ? Colors.white : colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Widget _buildProgressSection(ThemeData theme, ColorScheme colorScheme) {
    final completedWeeks = (_progress * 12).round();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            Text(
              'Week $_week of 12',
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white.withOpacity(0.8),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.x2),
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.white.withOpacity(0.2),
          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          minHeight: 6,
        ),
      ],
    );
  }

  String _getSubtitleText() {
    if (!_hasStarted) {
      switch (_tier) {
        case FaithTier.light:
          return 'Begin your journey with foundational lessons';
        case FaithTier.disciple:
          return 'A practical 12-week journey to follow Jesus deeply';
        case FaithTier.kingdomBuilder:
          return 'Lead others as you grow in discipleship and service';
        default:
          return 'Start your discipleship journey';
      }
    } else {
      final completedWeeks = (_progress * 12).round();
      return 'You\'ve completed $completedWeeks of 12 weeks. Keep going!';
    }
  }

  void _navigateToDiscipleship() {
    Navigator.pushNamed(context, AppRoutes.courses);
  }
}