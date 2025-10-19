import 'package:flutter/material.dart';
import '../repositories/mind_coach_repository.dart';
import '../../../services/faith_service.dart';
import '../../../../design/tokens.dart';
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
  FaithMode _faithMode = FaithMode.off;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadFaithMode();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFaithMode() async {
    try {
      final settings = SettingsScope.of(context).value;
      // Convert FaithTier to FaithMode
      switch (settings.faithTier) {
        case FaithTier.off:
          _faithMode = FaithMode.off;
          break;
        case FaithTier.light:
          _faithMode = FaithMode.light;
          break;
        case FaithTier.disciple:
          _faithMode = FaithMode.disciple;
          break;
        case FaithTier.kingdom:
          _faithMode = FaithMode.kingdom;
          break;
      }
      setState(() {});
    } catch (e) {
      // Default to off mode if there's an error
      _faithMode = FaithMode.off;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              backgroundColor: colorScheme.surface,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Mind Coach',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                titlePadding: EdgeInsets.only(
                  left: AppSpace.x4,
                  bottom: AppSpace.x2,
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colorScheme.primary.withOpacity(0.05),
                        colorScheme.surface,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: AppSpace.x4,
                        right: AppSpace.x4,
                        top: AppSpace.x6,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Mode Pill
                          _buildModePill(theme, colorScheme),
                          SizedBox(height: AppSpace.x2),
                          // Coach Status
                          _buildCoachStatus(theme, colorScheme),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            MindCoachTab(faithMode: _faithMode),
            MindExercisesTab(faithMode: _faithMode),
            MindCoursesTab(faithMode: _faithMode),
          ],
        ),
      ),
    );
  }

  Widget _buildModePill(ThemeData theme, ColorScheme colorScheme) {
    final modeText = MindCoachRepository.getModeDisplayText(_faithMode);
    final pillColor = MindCoachRepository.getModePillColor(_faithMode);

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

  Widget _buildCoachStatus(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        // Coach Avatar
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.psychology,
            color: Colors.white,
            size: 20,
          ),
        ),
        SizedBox(width: AppSpace.x3),
        // Status Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mind Coach Active',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              Text(
                _getStatusText(),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        // Status Indicator
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _getStatusText() {
    switch (_faithMode) {
      case FaithMode.off:
        return 'Evidence-based tools ready';
      case FaithMode.light:
        return 'Gentle faith integration available';
      case FaithMode.disciple:
        return 'Active faith coaching enabled';
      case FaithMode.kingdom:
        return 'Full spiritual journey active';
    }
  }
}
