import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/badge_chip.dart';
import '../data/course_repository.dart';
import '../models/course_models.dart';
import '../../../services/scripture_service.dart';
import '../widgets/unlock_scripture_card.dart';
import '../../spirit/services/faith_mode_navigator.dart';
import '../../../core/settings/settings_model.dart';

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

class WeekLessonScreen extends StatefulWidget {
  const WeekLessonScreen({super.key});

  @override
  State<WeekLessonScreen> createState() => _WeekLessonScreenState();
}

class _WeekLessonScreenState extends State<WeekLessonScreen> {
  final CourseRepository _repository = CourseRepository();
  Week? _week;
  Course? _course;
  bool _isCompleted = false;
  bool _isLoading = true;
  bool _isUnlocked = false;
  bool _isGated = false;
  bool _isShowingPreview = false;
  FaithTier _currentTier = FaithTier.off;
  final Map<String, bool> _expandedScriptures = {};
  final Map<int, bool> _expandedReflections = {};
  final ScriptureService _scriptureService = ScriptureService();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _initializeAndLoadData();
    }
  }

  Future<void> _initializeAndLoadData() async {
    await _scriptureService.initialize();
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
      final isUnlocked = await _repository.isWeekUnlock(weekNumber);
      final currentTier = FaithModeNavigator.getCurrentFaithTier(context);
      final isGated = _repository.isWeekGatedForTier(weekNumber, currentTier, course);

      setState(() {
        _course = course;
        _week = week;
        _isCompleted = isCompleted;
        _isUnlocked = isUnlocked;
        _isGated = isGated;
        _currentTier = currentTier;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading week data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onUnlock() async {
    if (_week == null) return;
    
    try {
      await _repository.setWeekUnlock(_week!.week, true);
      setState(() {
        _isUnlocked = true;
      });
    } catch (e) {
      print('Error unlocking week: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to unlock deeper truths')),
      );
    }
  }

  Future<void> _enableFaithMode() async {
    await FaithModeNavigator.openFaithModeSelector(context);
    // Reload data to check if gating is still active
    _loadData();
  }

  void _showPreview() {
    setState(() {
      _isShowingPreview = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return WillPopScope(
      onWillPop: () async {
        // Return false to indicate no completion
        Navigator.of(context).pop(false);
        return false;
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: _week != null ? 'Week ${_week!.week}' : 'Lesson',
          showBackButton: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _week == null
                ? _buildErrorState(theme, colorScheme)
                : _buildContent(theme, colorScheme),
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpace.x6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            SizedBox(height: AppSpace.x4),
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
            SizedBox(height: AppSpace.x6),
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
                  SizedBox(height: AppSpace.x6),
                  
                  // Show soft lock if gated and not showing preview
                  if (_isGated && !_isShowingPreview) ...[
                    _buildSoftLockSection(theme, colorScheme),
                    SizedBox(height: AppSpace.x6),
                  ],
                  
                  // Show content based on gating and preview state
                  if (!_isGated || _isShowingPreview) ...[
                    _buildScriptureSection(theme, colorScheme),
                    SizedBox(height: AppSpace.x6),
                    _buildLessonSummary(theme, colorScheme),
                    SizedBox(height: AppSpace.x6),
                    _buildUnlockCard(theme, colorScheme),
                    SizedBox(height: AppSpace.x6),
                    _buildKeyIdeas(theme, colorScheme),
                    SizedBox(height: AppSpace.x6),
                    _buildReflectionQuestions(theme, colorScheme),
                    SizedBox(height: AppSpace.x6),
                    _buildPracticeSection(theme, colorScheme),
                    SizedBox(height: AppSpace.x6),
                    _buildPrayerSection(theme, colorScheme),
                    SizedBox(height: AppSpace.x6),
                    _buildResourcesSection(theme, colorScheme),
                    SizedBox(height: AppSpace.x8),
                  ] else if (_isGated && _isShowingPreview) ...[
                    // Show limited preview content
                    _buildPreviewContent(theme, colorScheme),
                    SizedBox(height: AppSpace.x8),
                  ],
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
    if (_week == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSpace.x5),
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
              SizedBox(width: AppSpace.x3),
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
                    SizedBox(height: AppSpace.x1),
                    Text(
                      _week!.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _textColor,
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
              color: _textSubColor,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScriptureSection(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null || _week!.scriptureRefs.isEmpty) return SizedBox.shrink();

    return _buildSection(
      theme,
      colorScheme,
      'Scripture Focus',
      Icons.menu_book,
      Column(
        children: _week!.scriptureRefs.map((ref) {
          final isExpanded = _expandedScriptures[ref] ?? false;
          final scriptureText = _scriptureService.getScriptureText(ref);
          
          return Container(
            margin: EdgeInsets.only(bottom: AppSpace.x3),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _expandedScriptures[ref] = !isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpace.x3),
                    child: Row(
                      children: [
                        Icon(
                          Icons.menu_book,
                          color: colorScheme.onSecondaryContainer,
                          size: 20,
                        ),
                        SizedBox(width: AppSpace.x2),
                        Expanded(
                          child: Text(
                            ref,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: colorScheme.onSecondaryContainer,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: colorScheme.onSecondaryContainer,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      AppSpace.x3,
                      0,
                      AppSpace.x3,
                      AppSpace.x3,
                    ),
                    child: scriptureText != null 
                      ? Text(
                          scriptureText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSecondaryContainer.withOpacity(0.9),
                            height: 1.5,
                            fontStyle: FontStyle.italic,
                          ),
                        )
                      : Text(
                          'Scripture text not found for: $ref',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.error,
                            height: 1.5,
                            fontStyle: FontStyle.italic,
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

  Widget _buildLessonSummary(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null) return SizedBox.shrink();

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

  Widget _buildUnlockCard(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null || _week!.unlock == null) return SizedBox.shrink();

    return UnlockScriptureCard(
      unlock: _week!.unlock!,
      unlocked: _isUnlocked,
      onUnlock: _onUnlock,
    );
  }

  Widget _buildSoftLockSection(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lock_outline,
                color: colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: AppSpace.x2),
              Expanded(
                child: Text(
                  'Faith content locked',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            'This week opens deeper guidance (Scripture, prayer, discernment). Enable Faith Mode to continue, or preview a tiny sample below.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpace.x4),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _enableFaithMode,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(0, 48),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    'Enable Faith Mode',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpace.x3),
              Expanded(
                child: TextButton(
                  onPressed: _showPreview,
                  style: TextButton.styleFrom(
                    minimumSize: Size(0, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    'Preview 60 seconds',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewContent(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Show only title and theme
        Container(
          padding: EdgeInsets.all(AppSpace.x4),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _week!.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSpace.x2),
              Text(
                _week!.theme,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpace.x4),
        
        // Show first 1-2 key ideas
        if (_week!.keyIdeas.isNotEmpty) ...[
          _buildSection(
            theme,
            colorScheme,
            'Key Ideas (Preview)',
            Icons.key,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _week!.keyIdeas.take(2).map((idea) => Padding(
                padding: EdgeInsets.only(bottom: AppSpace.x2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: EdgeInsets.only(top: 8, right: AppSpace.x3),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        idea,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
        
        SizedBox(height: AppSpace.x4),
        
        // Dimmed note at bottom
        Container(
          padding: EdgeInsets.all(AppSpace.x3),
          decoration: BoxDecoration(
            color: colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: colorScheme.onSurfaceVariant,
                size: 16,
              ),
              SizedBox(width: AppSpace.x2),
              Expanded(
                child: Text(
                  'Full content available with Faith Mode.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyIdeas(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null || _week!.keyIdeas.isEmpty) return SizedBox.shrink();

    return _buildSection(
      theme,
      colorScheme,
      'Key Ideas',
      Icons.key,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _week!.keyIdeas.map((idea) {
          return Padding(
            padding: EdgeInsets.only(bottom: AppSpace.x2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: EdgeInsets.only(
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
    if (_week == null || _week!.reflectionQs.isEmpty) return SizedBox.shrink();

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
          final isExpanded = _expandedReflections[index] ?? false;
          final answer = _getReflectionAnswer(index);
          
          return Container(
            margin: EdgeInsets.only(bottom: AppSpace.x3),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _expandedReflections[index] = !isExpanded;
                    });
                  },
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Padding(
                    padding: EdgeInsets.all(AppSpace.x4),
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
                        SizedBox(width: AppSpace.x3),
                        Expanded(
                          child: Text(
                            question,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ),
                        SizedBox(width: AppSpace.x2),
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: colorScheme.onSurface,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isExpanded && answer != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      AppSpace.x4 + 24 + AppSpace.x3, // Align with question text
                      AppSpace.x2,
                      AppSpace.x4,
                      AppSpace.x4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 16,
                              color: colorScheme.primary,
                            ),
                            SizedBox(width: AppSpace.x2),
                            Text(
                              'Reflection Guide:',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: AppSpace.x2),
                        Text(
                          answer,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.8),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  String? _getReflectionAnswer(int questionIndex) {
    // Provide thoughtful reflection guides for each question
    final answers = [
      "Consider how this truth applies to your daily life. What specific situations come to mind? How might this change your perspective or actions?",
      "Think about your personal experience with this concept. What challenges or victories have you faced? How has God shown Himself faithful?",
      "Reflect on the practical implications of this teaching. What steps can you take to apply this in your relationships, work, or daily routines?",
      "Consider the deeper meaning behind this principle. How does it connect to God's character and His plan for your life?",
      "Think about the community aspect of this teaching. How might this impact your relationships with family, friends, or church community?",
    ];
    
    return answers[questionIndex % answers.length];
  }

  Widget _buildPracticeSection(ThemeData theme, ColorScheme colorScheme) {
    if (_week == null || _week!.practice.isEmpty) return SizedBox.shrink();

    return _buildSection(
      theme,
      colorScheme,
      'Practice This Week',
      Icons.fitness_center,
      Column(
        children: _week!.practice.map((practice) {
          return Container(
            margin: EdgeInsets.only(bottom: AppSpace.x3),
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
    if (_week == null) return SizedBox.shrink();

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
    if (_week == null || _week!.resources.isEmpty) return SizedBox.shrink();

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
    if (_week == null) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(AppSpace.x4),
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
                onPressed: (_isCompleted || _isGated) ? null : _markWeekComplete,
                icon: Icon(_isCompleted ? Icons.check_circle : Icons.check),
                label: Text(_isCompleted ? 'Completed' : 'Mark Week Complete'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 56),
                  backgroundColor: _isGated ? colorScheme.surfaceVariant : null,
                  foregroundColor: _isGated ? colorScheme.onSurfaceVariant : null,
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
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(true); // Go back to course detail with completion status
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
