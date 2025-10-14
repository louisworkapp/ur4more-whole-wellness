import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/devotional_card_widget.dart';
import './widgets/devotional_history_widget.dart';
import './widgets/faith_mode_banner_widget.dart';
import './widgets/prayer_request_widget.dart';
import './widgets/spiritual_milestone_widget.dart';

class SpiritualGrowthScreen extends StatefulWidget {
  const SpiritualGrowthScreen({super.key});

  @override
  State<SpiritualGrowthScreen> createState() => _SpiritualGrowthScreenState();
}

class _SpiritualGrowthScreenState extends State<SpiritualGrowthScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomIndex = 3;
  String _faithMode = "Full"; // Off, Light, Full
  int _spiritualPoints = 1250;
  int _devotionStreak = 7;

  // Mock data for devotionals
  final List<Map<String, dynamic>> _todayDevotionals = [
    {
      "id": 1,
      "title": "Walking in Faith",
      "date": "October 13, 2024",
      "scripture": "Hebrews 11:1",
      "verse":
          "Now faith is confidence in what we hope for and assurance about what we do not see.",
      "reflection":
          "Faith is not about having all the answers, but about trusting God's plan even when we cannot see the full picture. Today, let us walk boldly in faith, knowing that God is guiding our steps and preparing good things for those who love Him.",
      "readTime": 5,
      "isCompleted": false,
      "isBookmarked": false,
      "points": 25,
    },
    {
      "id": 2,
      "title": "God's Unfailing Love",
      "date": "October 12, 2024",
      "scripture": "Psalm 136:1",
      "verse":
          "Give thanks to the Lord, for he is good. His love endures forever.",
      "reflection":
          "In every season of life, God's love remains constant. His mercy is new every morning, and His faithfulness extends to all generations. Take time today to reflect on the many ways God has shown His love in your life.",
      "readTime": 4,
      "isCompleted": true,
      "isBookmarked": true,
      "points": 25,
    },
  ];

  final List<Map<String, dynamic>> _devotionalHistory = [
    {
      "id": 1,
      "title": "Walking in Faith",
      "date": "2024-10-13",
      "scripture": "Hebrews 11:1",
      "isCompleted": true,
      "isBookmarked": false,
      "points": 25,
      "completedTime": "Morning",
    },
    {
      "id": 2,
      "title": "God's Unfailing Love",
      "date": "2024-10-12",
      "scripture": "Psalm 136:1",
      "isCompleted": true,
      "isBookmarked": true,
      "points": 25,
      "completedTime": "Evening",
    },
    {
      "id": 3,
      "title": "Strength in Weakness",
      "date": "2024-10-11",
      "scripture": "2 Corinthians 12:9",
      "isCompleted": true,
      "isBookmarked": false,
      "points": 25,
      "completedTime": "Morning",
    },
    {
      "id": 4,
      "title": "Peace That Surpasses",
      "date": "2024-10-10",
      "scripture": "Philippians 4:7",
      "isCompleted": false,
      "isBookmarked": false,
      "points": 25,
    },
  ];

  final List<Map<String, dynamic>> _spiritualMilestones = [
    {
      "id": 1,
      "title": "First Week Faithful",
      "description": "Complete devotions for 7 consecutive days",
      "progress": 7,
      "target": 7,
      "isCompleted": true,
      "points": 100,
      "completedDate": "Oct 13, 2024",
    },
    {
      "id": 2,
      "title": "Prayer Warrior",
      "description": "Submit 10 prayer requests",
      "progress": 6,
      "target": 10,
      "isCompleted": false,
      "points": 150,
    },
    {
      "id": 3,
      "title": "Scripture Scholar",
      "description": "Read devotions from 5 different books of the Bible",
      "progress": 3,
      "target": 5,
      "isCompleted": false,
      "points": 200,
    },
    {
      "id": 4,
      "title": "Faithful Friend",
      "description": "Share 3 verses with others",
      "progress": 0,
      "target": 3,
      "isCompleted": false,
      "points": 75,
    },
  ];

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: "Spiritual Growth",
        variant: CustomAppBarVariant.withActions,
        backgroundColor: colorScheme.surface,
        actions: [
          Container(
            margin: EdgeInsets.only(right: 2.w),
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
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
                SizedBox(width: 1.w),
                Text(
                  "$_spiritualPoints",
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
              iconName: 'settings',
              color: colorScheme.onSurface,
              size: 24,
            ),
            onPressed: () =>
                Navigator.pushNamed(context, '/settings-profile-screen'),
          ),
          SizedBox(width: 2.w),
        ],
      ),
      body: _faithMode == "Off"
          ? _buildOffModeContent(context, colorScheme)
          : _buildActiveContent(context, colorScheme),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  Widget _buildOffModeContent(BuildContext context, ColorScheme colorScheme) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 2.h),
            FaithModeBannerWidget(
              faithMode: _faithMode,
              onSettingsTap: () =>
                  Navigator.pushNamed(context, '/settings-profile-screen'),
            ),
            SizedBox(height: 4.h),
            _buildWelcomeBackMessage(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveContent(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          // Faith mode banner
          FaithModeBannerWidget(
            faithMode: _faithMode,
            onSettingsTap: () =>
                Navigator.pushNamed(context, '/settings-profile-screen'),
          ),

          // Streak and points header
          _buildStreakHeader(context, colorScheme),

          // Tab bar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: "Today"),
                Tab(text: "History"),
                Tab(text: "Milestones"),
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
                _buildTodayTab(context, colorScheme),
                _buildHistoryTab(context, colorScheme),
                _buildMilestonesTab(context, colorScheme),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakHeader(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryLight,
            AppTheme.primaryLight.withOpacity( 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity( 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: CustomIconWidget(
              iconName: 'local_fire_department',
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$_devotionStreak Day Streak",
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  "Keep up your daily devotion habit!",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity( 0.9),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppTheme.secondaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  "$_spiritualPoints",
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Points",
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTab(BuildContext context, ColorScheme colorScheme) {
    return RefreshIndicator(
      onRefresh: _refreshContent,
      color: AppTheme.primaryLight,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 2.h),

            // Today's devotionals
            ..._todayDevotionals.map((devotional) => DevotionalCardWidget(
                  devotional: devotional,
                  isBookmarked: devotional["isBookmarked"] == true,
                  onTap: () => _openDevotional(devotional),
                  onShare: () => _shareDevotional(devotional),
                  onBookmark: () => _toggleBookmark(devotional),
                  onAddToPrayer: () => _addToPrayerList(devotional),
                )),

            SizedBox(height: 2.h),

            // Prayer requests section
            PrayerRequestWidget(
              onSubmit: _submitPrayerRequest,
            ),

            SizedBox(height: 4.h),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          DevotionalHistoryWidget(
            history: _devotionalHistory,
            onDevotionalTap: _openDevotional,
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildMilestonesTab(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 2.h),
          SpiritualMilestoneWidget(
            milestones: _spiritualMilestones,
          ),
          SizedBox(height: 4.h),
        ],
      ),
    );
  }

  Widget _buildWelcomeBackMessage(
      BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity( 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'auto_awesome',
            color: colorScheme.onSurfaceVariant,
            size: 48,
          ),
          SizedBox(height: 2.h),
          Text(
            "Welcome Back!",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            "Your spiritual growth journey is waiting for you. Enable faith mode in settings to access devotions, prayer requests, and spiritual milestones.",
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _refreshContent() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh content
    });
  }

  void _openDevotional(Map<String, dynamic> devotional) {
    // Mark as completed and award points
    setState(() {
      if (devotional["isCompleted"] != true) {
        devotional["isCompleted"] = true;
        _spiritualPoints += (devotional["points"] as int? ?? 25);

        // Show celebration animation
        _showCompletionCelebration();
      }
    });
  }

  void _shareDevotional(Map<String, dynamic> devotional) {
    // Implement sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Sharing: ${devotional["title"]}"),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _toggleBookmark(Map<String, dynamic> devotional) {
    setState(() {
      devotional["isBookmarked"] = !(devotional["isBookmarked"] == true);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(devotional["isBookmarked"] == true
            ? "Added to favorites"
            : "Removed from favorites"),
        backgroundColor: AppTheme.primaryLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _addToPrayerList(Map<String, dynamic> devotional) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added ${devotional["scripture"]} to prayer list"),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _submitPrayerRequest(String request) {
    setState(() {
      _spiritualPoints += 10; // Award points for prayer submission
    });
  }

  void _showCompletionCelebration() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'celebration',
              color: AppTheme.secondaryLight,
              size: 48,
            ),
            SizedBox(height: 2.h),
            Text(
              "Devotion Completed!",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: 1.h),
            Text(
              "You earned 25 spiritual points!",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Continue"),
            ),
          ],
        ),
      ),
    );
  }
}
