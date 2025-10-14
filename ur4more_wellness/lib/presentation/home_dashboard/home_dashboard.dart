import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/level_badge.dart';
import './widgets/branded_header.dart';
import './widgets/daily_checkin_cta.dart';
import './widgets/points_progress_ring.dart';
import './widgets/wellness_navigation_card.dart';

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
      "route": "/body-fitness-screen",
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
      "route": "/mind-wellness-screen",
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
      "route": "/spiritual-growth-screen",
    },
  ];

  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Simulate loading user data
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() {
        // Data already loaded in mock format
      });
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    // Provide haptic feedback
    HapticFeedback.lightImpact();

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        // Update points slightly to show refresh worked
        userData["totalPoints"] = (userData["totalPoints"] as int) + 5;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: colorScheme.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: BrandedHeader(
                totalPoints: userData["totalPoints"] as int,
                onProfileTap:
                    () => Navigator.pushNamed(context, AppRoutes.settings),
                onNotificationTap: _handleNotificationTap,
              ),
            ),

            // Main content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  SizedBox(height: 2.h),

                  // Points progress ring
                  PointsProgressRing(
                    totalPoints: userData["totalPoints"] as int,
                    bodyProgress: userData["bodyProgress"] as double,
                    mindProgress: userData["mindProgress"] as double,
                    spiritualProgress: userData["spiritualProgress"] as double,
                    showSpiritualProgress: _shouldShowSpiritualContent(),
                  ),

                  SizedBox(height: 2.h),

                  // Level badge under the points ring
                  LevelBadge(points: userData["totalPoints"] as int),

                  SizedBox(height: 3.h),

                  // Daily check-in CTA with user ID for streak calculation
                  DailyCheckinCta(
                    isCompleted: userData["todayCompleted"] as bool,
                    onTap:
                        () => Navigator.pushNamed(context, AppRoutes.checkin),
                    lastCheckinDate: DateTime.parse(
                      userData["lastCheckinDate"] as String,
                    ),
                    userId: userData["userId"] as String,
                  ),

                  SizedBox(height: 2.h),

                  // Wellness navigation cards
                  ..._buildWellnessCards(context),

                  SizedBox(height: 10.h), // Bottom padding for navigation
                ],
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
          // Filter spiritual content based on faith mode
          if ((activity as Map<String, dynamic>)["id"] == "spiritual_growth") {
            return _shouldShowSpiritualContent();
          }
          return true;
        })
        .map((activity) {
          final activityMap = activity as Map<String, dynamic>;
          return WellnessNavigationCard(
            title: activityMap["title"] as String,
            subtitle: activityMap["subtitle"] as String,
            iconName: activityMap["iconName"] as String,
            primaryColor: Theme.of(context).colorScheme.primary,
            backgroundColor: Theme.of(context).colorScheme.primary,
            pointValue: activityMap["pointValue"] as int,
            completionPercentage: activityMap["completionPercentage"] as double,
            isCompleted: activityMap["isCompleted"] as bool,
            onTap:
                () => Navigator.pushNamed(
                  context,
                  activityMap["route"] as String,
                ),
            onLongPress: () => _showQuickActions(context, activityMap),
          );
        })
        .toList();
  }

  bool _shouldShowSpiritualContent() {
    final faithMode = userData["faithMode"] as String;
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

  void _showQuickActions(BuildContext context, Map<String, dynamic> activity) {
    HapticFeedback.mediumImpact();

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  activity["title"] as String,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 2.h),
                _buildQuickActionTile(
                  context,
                  'View Progress',
                  'track_changes',
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, activity["route"] as String);
                  },
                ),
                _buildQuickActionTile(context, 'Set Reminder', 'schedule', () {
                  Navigator.pop(context);
                  _showReminderDialog(context, activity);
                }),
                _buildQuickActionTile(context, 'Skip Today', 'skip_next', () {
                  Navigator.pop(context);
                  _handleSkipToday(activity);
                }),
                SizedBox(height: 2.h),
              ],
            ),
          ),
    );
  }

  Widget _buildQuickActionTile(
    BuildContext context,
    String title,
    String iconName,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: Theme.of(context).colorScheme.primary,
        size: 6.w,
      ),
      title: Text(title),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }

  void _showReminderDialog(
    BuildContext context,
    Map<String, dynamic> activity,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Set Reminder'),
            content: Text('Set a daily reminder for ${activity["title"]}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reminder set for ${activity["title"]}'),
                    ),
                  );
                },
                child: const Text('Set Reminder'),
              ),
            ],
          ),
    );
  }

  void _handleSkipToday(Map<String, dynamic> activity) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${activity["title"]} skipped for today'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            // Handle undo skip
          },
        ),
      ),
    );
  }
}
