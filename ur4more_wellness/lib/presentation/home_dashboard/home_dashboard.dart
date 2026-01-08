import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../core/state/points_store.dart';
import '../../design/tokens.dart';
import '../../routes/app_routes.dart';
import './widgets/branded_header.dart';
import './widgets/daily_checkin_cta.dart';
import '../../widgets/media_card.dart';
import '../../widgets/daily_inspiration_card.dart';
import '../../theme/tokens.dart';
import '../../widgets/hero/hero_progress.dart';
import '../../widgets/debug/debug_points_bottom_sheet.dart';
import '../debug/debug_points_screen.dart';

class HomeDashboard extends StatefulWidget {
  const HomeDashboard({super.key});

  @override
  State<HomeDashboard> createState() => _HomeDashboardState();
}

class _HomeDashboardState extends State<HomeDashboard> {
  // Mock user data
  final Map<String, dynamic> userData = {
    "userId": "user_12345",
    "fullName": "Sarah Johnson",
    "email": "sarah.johnson@email.com",
    "totalPoints": 2847,
    "faithMode": "Full", // Off, Light, Full
    "timezone": "America/New_York",
    "equipment": ["bodyweight", "resistance_bands", "pullup_bar"],
    "currentStreak": 7,
    "lastCheckinDate": "2025-10-12T08:30:00Z",
    "todayCompleted": false,
    "bodyProgress": 0.75,
    "mindProgress": 0.60,
    "spiritualProgress": 0.85,
    "weeklyGoal": {
      "bodyWorkouts": 5,
      "mindSessions": 4,
      "spiritualDevotions": 7,
      "completed": {
        "bodyWorkouts": 3,
        "mindSessions": 2,
        "spiritualDevotions": 6,
      },
    },
    "notifications": {"hasUnread": true, "count": 3},
  };

  // Mock wellness activities data
  final List<Map<String, dynamic>> wellnessActivities = [
    {
      "id": "body_fitness",
      "title": "Body Fitness",
      "subtitle": "Strength & cardio workouts",
      "iconName": "fitness_center",
      "primaryColor": "#1E3A8A",
      "pointValue": 25,
      "completionPercentage": 0.75,
      "isCompleted": false,
      "route": "/",
      "routeIndex": 1,
    },
    {
      "id": "mind_wellness",
      "title": "Mind Wellness",
      "subtitle": "Reflection & mindfulness",
      "iconName": "psychology",
      "primaryColor": "#0FA97A",
      "pointValue": 20,
      "completionPercentage": 0.60,
      "isCompleted": false,
      "route": "/",
      "routeIndex": 2,
    },
    {
      "id": "spiritual_growth",
      "title": "Spiritual Growth",
      "subtitle": "Devotions & prayer",
      "iconName": "auto_awesome",
      "primaryColor": "#C9A227",
      "pointValue": 30,
      "completionPercentage": 0.85,
      "isCompleted": true,
      "route": "/",
      "routeIndex": 3,
    },
    {
      "id": "discipleship",
      "title": "Discipleship",
      "subtitle": "Courses & spiritual growth",
      "iconName": "auto_stories",
      "primaryColor": "#8B5CF6",
      "pointValue": 35,
      "completionPercentage": 0.25,
      "isCompleted": false,
      "route": "/courses",
      "routeIndex": -1,
    },
  ];

  bool _isRefreshing = false;
  final PointsStore _pointsStore = PointsStore.i;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _pointsStore.addListener(_onPointsChanged);
  }

  @override
  void dispose() {
    _pointsStore.removeListener(_onPointsChanged);
    super.dispose();
  }

  void _onPointsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadUserData() async {
    final userId = userData["userId"] as String;
    await _pointsStore.load(userId);
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);
    HapticFeedback.lightImpact();

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isRefreshing = false;
      userData["totalPoints"] = (userData["totalPoints"] as int) + 5;
    });
  }

  /// Navigate to debug points screen (debug mode only)
  void _navigateToDebugScreen() {
    if (!kDebugMode) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DebugPointsScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final points = _pointsStore.loaded ? _pointsStore.totalPoints : (userData["totalPoints"] as int);
    final showSpirit = _shouldShowSpiritualContent();

    return Scaffold(
      backgroundColor: cs.background, // calmer page background
      floatingActionButton: kDebugMode
          ? FloatingActionButton.small(
              onPressed: () => DebugPointsBottomSheet.show(context),
              backgroundColor: Colors.orange,
              child: const Icon(Icons.bug_report, size: 20),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: cs.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header with subtle points bump animation
            SliverToBoxAdapter(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                switchInCurve: Curves.easeOut,
                transitionBuilder: (child, anim) {
                  return ScaleTransition(
                    scale: Tween<double>(begin: 0.98, end: 1.0).animate(anim),
                    child: FadeTransition(opacity: anim, child: child),
                  );
                },
                child: GestureDetector(
                  onLongPress: kDebugMode ? _navigateToDebugScreen : null,
                  child: BrandedHeader(
                    key: ValueKey(points),
                    totalPoints: points,
                    onProfileTap: () => Navigator.pushNamed(context, AppRoutes.settings),
                    onNotificationTap: _handleNotificationTap,
                  ),
                ),
              ),
            ),

            // Main content
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: AppSpace.x2),

                    GestureDetector(
                      onLongPress: kDebugMode ? _navigateToDebugScreen : null,
                      child: AnimatedBuilder(
                        animation: _pointsStore,
                        builder: (context, child) {
                          final storePoints = _pointsStore.loaded ? _pointsStore.totalPoints : points;
                          final storeBody = _pointsStore.loaded ? _pointsStore.bodyProgress : (userData["bodyProgress"] as double);
                          final storeMind = _pointsStore.loaded ? _pointsStore.mindProgress : (userData["mindProgress"] as double);
                          final storeSpirit = _pointsStore.loaded ? _pointsStore.spiritProgress : (userData["spiritualProgress"] as double);
                          
                          return HeroProgress(
                            key: ValueKey('${storePoints}_${storeBody}_${storeMind}_${storeSpirit}'),
                            totalPoints: storePoints,
                            bodyProgress: storeBody,
                            mindProgress: storeMind,
                            spiritProgress: storeSpirit,
                            showSpirit: showSpirit,
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: AppSpace.x2),

                    // Daily Check-in: primary + optional secondary tonal
                    DailyCheckinCta(
                      isCompleted: userData["todayCompleted"] as bool,
                      onTap: () => Navigator.pushNamed(context, AppRoutes.checkin),
                      lastCheckinDate: DateTime.parse(userData["lastCheckinDate"] as String),
                      userId: userData["userId"] as String,
                      onPlannerTap: () => Navigator.pushNamed(context, AppRoutes.alarmClock),
                    ),

                    const SizedBox(height: AppSpace.x2),

                    const DailyInspirationCard(),

                    const SizedBox(height: AppSpace.x2),

                    ..._buildWellnessCards(context),

                    // breathing room for nav / scroll
                    const SizedBox(height: 96),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildWellnessCards(BuildContext context) {
    return (wellnessActivities as List)
        .where((activity) {
          final activityMap = activity as Map<String, dynamic>;
          // Filter spiritual content based on faith mode
          if (activityMap["id"] == "spiritual_growth") {
            return _shouldShowSpiritualContent();
          }
          // Filter discipleship content based on faith mode
          if (activityMap["id"] == "discipleship") {
            return _shouldShowDiscipleshipContent();
          }
          return true;
        })
        .map((activity) {
          final activityMap = activity as Map<String, dynamic>;
          final completionPercentage = activityMap["completionPercentage"] as double? ?? 0.0;
          
          // Get the appropriate color based on wellness category
          final activityId = activityMap["id"] as String? ?? '';
          final categoryColor = _getCategoryColor(activityId);
          
          return MediaCard(
            title: activityMap["title"] as String? ?? 'Activity',
            subtitle: activityMap["subtitle"] as String? ?? 'Description',
            accentColor: categoryColor,
            leading: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(activityMap["iconName"] as String? ?? 'help'),
                color: categoryColor,
                size: 24,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${(completionPercentage * 100).round()}%',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: categoryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: T.ink600,
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: completionPercentage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onTap: () {
              final routeIndex = activityMap["routeIndex"] as int? ?? 0;
              final route = activityMap["route"] as String? ?? "/";
              
              if (route == "/courses") {
                // Navigate directly to courses screen
                Navigator.pushNamed(context, AppRoutes.discipleshipCourses);
              } else {
                // Navigate to main scaffold with specific tab
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.main,
                  (route) => false,
                  arguments: routeIndex,
                );
              }
            },
          );
        })
        .toList();
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'fitness_center':
        return Icons.fitness_center;
      case 'psychology':
        return Icons.psychology;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'auto_stories':
        return Icons.auto_stories;
      default:
        return Icons.help;
    }
  }

  Color _getCategoryColor(String activityId) {
    switch (activityId) {
      case 'mind_wellness':
      case 'mind_coach':
        return T.mint; // Mind wellness: mint green
      case 'spiritual_growth':
      case 'discipleship':
        return T.gold; // Spiritual growth: golden
      case 'body_wellness':
      case 'fitness':
        return T.blue; // Body wellness: blue (existing)
      default:
        return T.blue; // Default: blue
    }
  }

  bool _shouldShowSpiritualContent() {
    final faithMode = userData["faithMode"] as String?;
    return faithMode == "Light" || faithMode == "Full";
  }

  bool _shouldShowDiscipleshipContent() {
    final faithMode = userData["faithMode"] as String?;
    // Show discipleship for Light, Disciple, and Kingdom Builder tiers
    return faithMode == "Light" || faithMode == "Full";
  }

  void _handleNotificationTap() {
    // Show notifications or navigate to notifications screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'You have ${userData["notifications"]["count"]} new notifications',
        ),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to notifications screen
          },
        ),
      ),
    );
  }

}
