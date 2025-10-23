import 'package:flutter/material.dart';
import '../repositories/mind_coach_repository.dart';
import '../../../services/faith_service.dart';
import '../../../../design/tokens.dart';
import '../../../../theme/tokens.dart';
import '../../../../core/settings/settings_scope.dart';
import '../../../../core/settings/settings_model.dart';
import 'widgets/mind_coach_tab.dart';
import 'widgets/mind_exercises_tab.dart';
import 'widgets/mind_courses_tab.dart';

class MindCoachScreen extends StatefulWidget {
  const MindCoachScreen({super.key});

  @override
  State<MindCoachScreen> createState() => _MindCoachScreenState();
}

class _MindCoachScreenState extends State<MindCoachScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  FaithMode _getFaithModeFromTier(FaithTier faithTier) {
    // Convert FaithTier to FaithMode
    switch (faithTier) {
      case FaithTier.off:
        return FaithMode.off;
      case FaithTier.light:
        return FaithMode.light;
      case FaithTier.disciple:
        return FaithMode.disciple;
      case FaithTier.kingdom:
        return FaithMode.kingdom;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get current settings from SettingsScope (reactive to changes)
    final settings = SettingsScope.of(context).value;
    final faithMode = _getFaithModeFromTier(settings.faithTier);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Mind Coach',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: colorScheme.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: colorScheme.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(
              icon: Icon(Icons.psychology),
              text: 'Coach',
            ),
            Tab(
              icon: Icon(Icons.fitness_center),
              text: 'Exercises',
            ),
            Tab(
              icon: Icon(Icons.school),
              text: 'Courses',
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Mode Pill Section
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: AppSpace.x4,
              vertical: AppSpace.x2,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  T.mint.withOpacity(0.05), // Mind wellness: mint green gradient
                  colorScheme.surface,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: _buildModePill(theme, colorScheme, faithMode),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                MindCoachTab(faithMode: faithMode),
                MindExercisesTab(faithMode: faithMode),
                MindCoursesTab(faithMode: faithMode),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModePill(ThemeData theme, ColorScheme colorScheme, FaithMode faithMode) {
    final modeText = MindCoachRepository.getModeDisplayText(faithMode);
    final pillColor = MindCoachRepository.getModePillColor(faithMode);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpace.x3,
        vertical: AppSpace.x1,
      ),
      decoration: BoxDecoration(
        color: Color(pillColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Color(pillColor).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: Color(pillColor),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppSpace.x2),
          Text(
            modeText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Color(pillColor),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

}

