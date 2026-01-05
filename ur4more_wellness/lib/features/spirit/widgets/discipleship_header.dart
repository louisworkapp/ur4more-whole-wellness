import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../courses/models/course_models.dart';
import '../../../routes/app_routes.dart';
import '../../../design/tokens.dart';
import '../../../theme/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

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
      child: GestureDetector(
        onTap: _navigateToDiscipleship,
        child: Container(
          decoration: BoxDecoration(
            color: _surfaceColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _outlineColor,
              width: 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000), 
                blurRadius: 12, 
                offset: Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppSpace.x4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(AppSpace.x2),
                      decoration: BoxDecoration(
                        color: _brandBlue200.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _brandBlue200.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: CustomIconWidget(
                        iconName: 'auto_stories',
                        color: _brandBlue200,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpace.x3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _hasStarted ? 'Discipleship Progress' : 'Start your Discipleship',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: _textColor,
                            ),
                          ),
                          Text(
                            _getSubtitleText(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _textSubColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Progress badge
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x1),
                      decoration: BoxDecoration(
                        color: _brandBlue200.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: _hasStarted ? 'trending_up' : 'play_arrow',
                            color: _brandBlue200,
                            size: 12,
                          ),
                          SizedBox(width: AppSpace.x1),
                          Text(
                            _hasStarted ? '${(_progress * 100).round()}%' : 'Start',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _brandBlue200,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (_hasStarted) ...[
                  SizedBox(height: AppSpace.x3),
                  _buildProgressSection(theme, colorScheme),
                ],
                SizedBox(height: AppSpace.x3),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _navigateToDiscipleship,
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: AppSpace.x2),
                          decoration: BoxDecoration(
                            color: _brandBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _brandBlue.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: _hasStarted ? 'play_arrow' : 'launch',
                                color: _brandBlue200,
                                size: 16,
                              ),
                              SizedBox(width: AppSpace.x1),
                              Text(
                                _hasStarted ? 'Continue Course' : 'Start Course',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: _brandBlue200,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpace.x2),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x1),
                      decoration: BoxDecoration(
                        color: T.gold.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomIconWidget(
                            iconName: 'schedule',
                            color: _brandBlue200,
                            size: 12,
                          ),
                          SizedBox(width: AppSpace.x1),
                          Text(
                            '12 weeks',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _brandBlue200,
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
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              'Week $_week of 12',
              style: theme.textTheme.labelMedium?.copyWith(
                color: T.gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpace.x2),
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: T.gold.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(T.gold),
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
        case FaithTier.kingdom:
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