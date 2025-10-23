import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_export.dart';
import '../../design/tokens.dart';
import '../../theme/tokens.dart';
import '../../widgets/custom_app_bar.dart';
import '../../features/spirit/widgets/discipleship_header.dart';
import '../../features/spirit/widgets/offmode_intro_card.dart';
import '../../features/spirit/widgets/world_spirit_card.dart';
import '../../features/spirit/widgets/soul_vs_spirit_card.dart';
import '../../features/spirit/widgets/alignment_preview_card.dart';
import '../../features/spirit/widgets/faith_mode_banner.dart';
import '../../core/settings/settings_scope.dart';
import '../../core/settings/settings_model.dart';
import '../../services/devotional_service.dart';
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
  
  // Collapsible card states
  bool _soulCollapsed = true;
  bool _alignCollapsed = true;
  int _currentBottomIndex = 3;
  int _spiritualPoints = 1250;
  int _devotionStreak = 7;

  // Dynamic devotionals from gateway
  List<Map<String, dynamic>> _todayDevotionals = [];
  bool _isLoadingDevotionals = true;

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
    _loadCollapsedStates();
    // Don't load devotionals in initState - wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load devotionals after dependencies are available
    if (_todayDevotionals.isEmpty) {
      _loadDailyDevotionals();
    }
  }

  Future<void> _loadCollapsedStates() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _soulCollapsed = prefs.getBool('spirit.soulCollapsed') ?? true;
      _alignCollapsed = prefs.getBool('spirit.alignCollapsed') ?? true;
    });
  }

  Future<void> _loadDailyDevotionals() async {
    try {
      final settingsCtl = SettingsScope.of(context);
      final settings = settingsCtl.value;
      
      // Only load devotionals if faith mode is enabled
      if (settings.faithTier != FaithTier.off) {
        final devotional = await DevotionalService.getDailyDevotional(
          faithTier: settings.faithTier,
          theme: 'gluttony', // You can make this dynamic based on user preferences
        );
        
        if (mounted && devotional != null) {
          setState(() {
            _todayDevotionals = [devotional];
            _isLoadingDevotionals = false;
          });
        }
      } else {
        setState(() {
          _isLoadingDevotionals = false;
        });
      }
    } catch (e) {
      print('Error loading daily devotionals: $e');
      if (mounted) {
        setState(() {
          _isLoadingDevotionals = false;
        });
      }
    }
  }

  void _toggleSoulCollapsed() async {
    setState(() {
      _soulCollapsed = !_soulCollapsed;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('spirit.soulCollapsed', _soulCollapsed);
  }

  void _toggleAlignCollapsed() async {
    setState(() {
      _alignCollapsed = !_alignCollapsed;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('spirit.alignCollapsed', _alignCollapsed);
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
    
    // Get current settings from SettingsController
    final settings = SettingsScope.of(context).value;
    final faithTier = settings.faithTier;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: "Spiritual Growth",
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
                Navigator.pushNamed(context, AppRoutes.settings),
          ),
          SizedBox(width: AppSpace.x2),
        ],
      ),
      body: faithTier == FaithTier.off
          ? _buildOffModeContent(context, colorScheme)
          : _buildActiveContent(context, colorScheme),
    );
  }

  Widget _buildOffModeContent(BuildContext context, ColorScheme colorScheme) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSpace.x2),
            // New faith mode banner
            const FaithModeBanner(),
            SizedBox(height: AppSpace.x3),
            // World Spirit card
            const WorldSpiritCard(),
            SizedBox(height: AppSpace.x3),
            // Soul vs Spirit card (collapsible)
            SoulVsSpiritCard(
              collapsed: _soulCollapsed,
              onToggle: _toggleSoulCollapsed,
            ),
            SizedBox(height: AppSpace.x3),
            // Keep existing Off mode intro as final card
            const OffModeIntroCard(),
            SizedBox(height: AppSpace.x6),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveContent(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);
    
    // Get current settings from SettingsController
    final settings = SettingsScope.of(context).value;
    final faithTier = settings.faithTier;

    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: [
            // Faith mode banner
            FaithModeBannerWidget(
              faithMode: faithTier.name,
              onSettingsTap: () =>
                  Navigator.pushNamed(context, AppRoutes.settings),
            ),

            // Discipleship header
            const DiscipleshipHeader(),

            // Streak and points header
            _buildStreakHeader(context, colorScheme),

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
                  Tab(text: "Today"),
                  Tab(text: "History"),
                  Tab(text: "Milestones"),
                ],
                labelColor: T.gold, // Spiritual growth: golden
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: T.gold, // Spiritual growth: golden
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

            // Tab content - now using a fixed height container instead of Expanded
            Container(
              height: MediaQuery.of(context).size.height * 0.6, // Give it a reasonable height
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTodayTab(context, colorScheme),
                  _buildHistoryTab(context, colorScheme),
                  _buildMilestonesTab(context, colorScheme),
                ],
              ),
            ),
            
            // Add some bottom padding to ensure content is fully visible
            SizedBox(height: AppSpace.x6),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakHeader(BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x1),
      padding: Pad.card,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            T.gold, // Spiritual growth: golden
            T.gold.withOpacity(0.8), // Spiritual growth: golden
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpace.x3),
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
          SizedBox(width: AppSpace.x4),
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
                SizedBox(height: AppSpace.x1),
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
            padding: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
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
      color: T.gold, // Spiritual growth: golden
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: AppSpace.x2),

            // Today's devotionals
            if (_isLoadingDevotionals)
              Container(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(
                    color: T.gold, // Spiritual growth: golden
                  ),
                ),
              )
            else if (_todayDevotionals.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpace.x4),
                child: Column(
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: AppSpace.x3),
                    Text(
                      'No devotionals available',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpace.x2),
                    Text(
                      'Enable Faith Mode in settings to access daily devotionals',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ..._todayDevotionals.map((devotional) => DevotionalCardWidget(
                    devotional: devotional,
                    isBookmarked: devotional["isBookmarked"] == true,
                    onTap: () => _openDevotional(devotional),
                    onShare: () => _shareDevotional(devotional),
                    onBookmark: () => _toggleBookmark(devotional),
                    onAddToPrayer: () => _addToPrayerList(devotional),
                  )),

            SizedBox(height: AppSpace.x2),

            // Prayer requests section
            PrayerRequestWidget(
              onSubmit: _submitPrayerRequest,
            ),

            SizedBox(height: AppSpace.x4),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSpace.x2),
          DevotionalHistoryWidget(
            history: _devotionalHistory,
            onDevotionalTap: _openDevotional,
          ),
          SizedBox(height: AppSpace.x4),
        ],
      ),
    );
  }

  Widget _buildMilestonesTab(BuildContext context, ColorScheme colorScheme) {
    return SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: AppSpace.x2),
          SpiritualMilestoneWidget(
            milestones: _spiritualMilestones,
          ),
          SizedBox(height: AppSpace.x4),
        ],
      ),
    );
  }

  Widget _buildWelcomeBackMessage(
      BuildContext context, ColorScheme colorScheme) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpace.x4),
      padding: EdgeInsets.all(AppSpace.x6),
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
          SizedBox(height: AppSpace.x2),
          Text(
            "Welcome Back!",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpace.x1),
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
    // Reload daily devotionals
    await _loadDailyDevotionals();
  }

  void _openDevotional(Map<String, dynamic> devotional) async {
    // Mark as completed and award points
    if (devotional["isCompleted"] != true) {
      await DevotionalService.markDevotionalCompleted(devotional["id"]);
      setState(() {
        devotional["isCompleted"] = true;
        _spiritualPoints += (devotional["points"] as int? ?? 25);
      });
      
      // Show celebration animation
      _showCompletionCelebration();
    }
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

  void _toggleBookmark(Map<String, dynamic> devotional) async {
    await DevotionalService.toggleBookmark(devotional["id"]);
    setState(() {
      devotional["isBookmarked"] = !(devotional["isBookmarked"] == true);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(devotional["isBookmarked"] == true
            ? "Added to favorites"
            : "Removed from favorites"),
        backgroundColor: T.gold, // Spiritual growth: golden
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
            SizedBox(height: AppSpace.x2),
            Text(
              "Devotion Completed!",
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            SizedBox(height: AppSpace.x1),
            Text(
              "You earned 25 spiritual points!",
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: AppSpace.x2),
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

