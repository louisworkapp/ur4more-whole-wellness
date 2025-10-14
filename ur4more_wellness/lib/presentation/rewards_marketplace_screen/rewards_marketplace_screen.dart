import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../core/app_export.dart';
import '../../design/tokens.dart';
import '../../core/brand_rules.dart';
import '../../core/services/points_service.dart';
import '../../core/services/telemetry.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/category_filter_widget.dart';
import './widgets/points_balance_card_widget.dart';
import './widgets/reward_card_widget.dart';
import './widgets/reward_detail_modal_widget.dart';
import './widgets/search_bar_widget.dart';

class RewardsMarketplaceScreen extends StatefulWidget {
  const RewardsMarketplaceScreen({super.key});

  @override
  State<RewardsMarketplaceScreen> createState() =>
      _RewardsMarketplaceScreenState();
}

class _RewardsMarketplaceScreenState extends State<RewardsMarketplaceScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  List<Map<String, dynamic>> _filteredRewards = [];
  bool _isLoading = false;

  // Mock user data
  int _currentPoints = 2450;
  final String _userId = "user_12345";

  // Mock recent transactions
  final List<Map<String, dynamic>> _recentTransactions = [
    {
      'type': 'earned',
      'description': 'Daily check-in completed',
      'points': 50,
      'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'type': 'spent',
      'description': 'UR4MORE Water Bottle',
      'points': 500,
      'timestamp': DateTime.now().subtract(const Duration(days: 1)),
    },
    {
      'type': 'earned',
      'description': 'Workout completed',
      'points': 100,
      'timestamp': DateTime.now().subtract(const Duration(days: 2)),
    },
  ];

  // Mock rewards data - filtered for UR4MORE-only + faith-safe content
  final List<Map<String, dynamic>> _allRewards = [
    {
      'id': 1,
      'name': 'UR4MORE Premium Water Bottle',
      'description':
          'Stainless steel water bottle with UR4MORE branding. Perfect for your fitness journey and staying hydrated throughout the day.',
      'pointsCost': 500,
      'category': 'Physical Products',
      'availability': true,
      'is_ur4more': true,
      'is_allowed': true,
      'image': 'https://images.unsplash.com/photo-1544003484-3cd181d17917',
      'semanticLabel':
          'Stainless steel water bottle with black cap on white background',
      'requirements': 'Must be redeemed within 30 days of earning points.',
      'terms':
          'Non-refundable. Shipping included within continental US. Allow 7-10 business days for delivery.',
    },
    {
      'id': 2,
      'name': 'UR4MORE Wellness Journal & Planner',
      'description':
          'Beautiful hardcover journal designed for daily reflections, goal setting, and spiritual growth tracking.',
      'pointsCost': 750,
      'category': 'Physical Products',
      'availability': true,
      'is_ur4more': true,
      'is_allowed': true,
      'image': 'https://images.unsplash.com/photo-1669139660221-19454e55751e',
      'semanticLabel':
          'Open hardcover journal with blank pages and a pen beside it on wooden desk',
      'requirements': 'Complete at least 7 daily check-ins to unlock.',
      'terms':
          'Personalization available for additional 100 points. Ships within 5-7 business days.',
    },
    {
      'id': 3,
      'name': 'UR4MORE Meditation Music Collection',
      'description':
          'Curated collection of 50+ instrumental tracks perfect for meditation, prayer, and mindfulness practices.',
      'pointsCost': 300,
      'category': 'Digital Content',
      'availability': true,
      'is_ur4more': true,
      'is_allowed': true,
      'image': 'https://images.unsplash.com/photo-1598357978527-210fc3eba49f',
      'semanticLabel':
          'Person wearing headphones with eyes closed in peaceful meditation pose',
      'requirements':
          'Digital download available immediately after redemption.',
      'terms':
          'MP3 format. Compatible with all devices. Lifetime access included.',
    },
    {
      'id': 4,
      'name': 'UR4MORE Virtual Wellness Workshop',
      'description':
          'Join our certified wellness coaches for a 2-hour interactive workshop on holistic health and spiritual wellness.',
      'pointsCost': 1200,
      'category': 'Experiences',
      'availability': true,
      'is_ur4more': true,
      'is_allowed': true,
      'image': 'https://images.unsplash.com/photo-1558131954-cb4124bdb894',
      'semanticLabel':
          'Group of diverse people in exercise poses during outdoor wellness class',
      'requirements': 'Must have completed at least 30 days of check-ins.',
      'terms':
          'Live session via Zoom. Recording provided for 30 days. Certificate of completion included.',
    },
    {
      'id': 5,
      'name': 'UR4MORE Fitness Resistance Bands',
      'description':
          'Set of 5 resistance bands with varying resistance levels. Includes door anchor and exercise guide.',
      'pointsCost': 800,
      'category': 'Physical Products',
      'availability': false,
      'is_ur4more': true,
      'is_allowed': true,
      'image': 'https://images.unsplash.com/photo-1584827386916-b5351d3ba34b',
      'semanticLabel':
          'Colorful resistance bands arranged on gym floor with handles visible',
      'requirements': 'Complete 10 body fitness workouts to unlock.',
      'terms':
          'Currently out of stock. Join waitlist for priority notification when available.',
    },
    {
      'id': 6,
      'name': 'UR4MORE Charity Donation - Local Food Bank',
      'description':
          'Make a meaningful impact by donating to your local food bank. \$10 donation made on your behalf.',
      'pointsCost': 400,
      'category': 'Donations',
      'availability': true,
      'is_ur4more': true,
      'is_allowed': true,
      'image': 'https://images.unsplash.com/photo-1527994317319-5a0fd6ca651f',
      'semanticLabel':
          'Volunteers sorting food donations in boxes at community food bank',
      'requirements': 'Available to all users.',
      'terms':
          'Donation receipt provided via email. Tax-deductible where applicable.',
    },
    {
      'id': 7,
      'name': 'UR4MORE Premium Devotional eBook',
      'description':
          '365 days of inspiring devotionals focused on wellness, faith, and personal growth. Digital format with offline reading.',
      'pointsCost': 600,
      'category': 'Digital Content',
      'availability': true,
      'is_ur4more': true,
      'is_allowed': true,
      'image': 'https://images.unsplash.com/photo-1629649586689-50f29c434627',
      'semanticLabel':
          'Open book with soft lighting and coffee cup on wooden table creating peaceful reading atmosphere',
      'requirements': 'Faith mode must be enabled to access.',
      'terms':
          'PDF and EPUB formats included. Compatible with all e-readers and devices.',
    },
    {
      'id': 8,
      'name': 'UR4MORE Mindfulness Bell App Premium',
      'description':
          'Unlock premium features in our mindfulness bell app including custom chimes, extended sessions, and progress tracking.',
      'pointsCost': 450,
      'category': 'Digital Content',
      'availability': true,
      'is_ur4more': true,
      'is_allowed': true,
      'image': 'https://images.unsplash.com/photo-1643064723677-e0c0ab9d9e54',
      'semanticLabel':
          'Smartphone displaying meditation app interface with timer and peaceful background',
      'requirements': 'Must have basic app installed.',
      'terms':
          '1-year premium subscription. Auto-renewal can be disabled in app settings.',
    },
  ];

  final List<String> _categories = [
    'All',
    'Physical Products',
    'Digital Content',
    'Experiences',
    'Donations',
  ];

  @override
  void initState() {
    super.initState();
    _applyRewardsFilter();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyRewardsFilter() {
    setState(() {
      _filteredRewards =
          _allRewards.where((reward) {
            // Apply UR4MORE-only + is_allowed + faith-safe filtering
            final isUR4MORE = reward['is_ur4more'] == true;
            final isAllowed = reward['is_allowed'] == true;
            final isFaithSafe = BrandRules.isRewardSafe(
              reward['name'] as String,
              reward['description'] as String,
            );

            if (!isUR4MORE || !isAllowed || !isFaithSafe) {
              return false;
            }

            // Apply category filter
            final matchesCategory =
                _selectedCategory == 'All' ||
                reward['category'] == _selectedCategory;

            // Apply search filter
            final matchesSearch =
                _searchController.text.isEmpty ||
                (reward['name'] as String).toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                ) ||
                (reward['description'] as String).toLowerCase().contains(
                  _searchController.text.toLowerCase(),
                );

            return matchesCategory && matchesSearch;
          }).toList();
    });
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _applyRewardsFilter();
  }

  void _onSearchChanged(String query) {
    _applyRewardsFilter();
  }

  void _onSearchClear() {
    _searchController.clear();
    _applyRewardsFilter();
  }

  Future<void> _refreshRewards() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
      // In real app, this would update from API
      _currentPoints = 2450;
    });

    Fluttertoast.showToast(
      msg: "Rewards updated successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showRewardDetail(Map<String, dynamic> reward) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => RewardDetailModalWidget(
            reward: reward,
            currentPoints: _currentPoints,
            onRedeem: () => _redeemReward(reward),
            onWishlist: () => _addToWishlist(reward),
            onShare: () => _shareReward(reward),
          ),
    );
  }

  Future<void> _redeemReward(Map<String, dynamic> reward) async {
    final pointsCost = reward['pointsCost'] as int;

    if (_currentPoints >= pointsCost) {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Confirm Redemption'),
              content: Text(
                'Are you sure you want to redeem "${reward['name']}" for $pointsCost points?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Close modal

                    try {
                      // Use PointsService to handle redemption with floor protection
                      final newPoints = await PointsService.redeemReward(
                        _userId,
                        pointsCost,
                        reward['name'] as String,
                      );

                      // Log analytics
                      Telemetry.redeem(
                        _userId,
                        reward['name'] as String,
                        pointsCost,
                      );

                      setState(() {
                        _currentPoints = newPoints;
                        _recentTransactions.insert(0, {
                          'type': 'spent',
                          'description': reward['name'],
                          'points': pointsCost,
                          'timestamp': DateTime.now(),
                        });
                      });

                      Fluttertoast.showToast(
                        msg:
                            "Reward redeemed successfully! Check your email for details.",
                        toastLength: Toast.LENGTH_LONG,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } catch (e) {
                      Fluttertoast.showToast(
                        msg: "Error redeeming reward: $e",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    }
                  },
                  child: Text('Redeem'),
                ),
              ],
            ),
      );
    } else {
      Fluttertoast.showToast(
        msg: "Insufficient points to redeem this reward",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  void _addToWishlist(Map<String, dynamic> reward) {
    Fluttertoast.showToast(
      msg: "${reward['name']} added to wishlist",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _shareReward(Map<String, dynamic> reward) {
    Fluttertoast.showToast(
      msg: "Sharing ${reward['name']}...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _showPointsHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: 500, // Fixed height instead of percentage
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: AppSpace.x1),
                  width: 48, // Fixed width instead of percentage
                  height: 2, // Fixed height instead of percentage
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurfaceVariant.withOpacity( 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: Pad.card,
                  child: Text(
                    'Points History',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(horizontal: AppSpace.x4),
                    itemCount: _recentTransactions.length,
                    separatorBuilder:
                        (context, index) => Divider(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity( 0.2),
                        ),
                    itemBuilder: (context, index) {
                      final transaction = _recentTransactions[index];
                      final isEarned = transaction['type'] == 'earned';

                      return ListTile(
                        leading: Container(
                          padding: EdgeInsets.all(AppSpace.x2),
                          decoration: BoxDecoration(
                            color:
                                isEarned
                                    ? Theme.of(context).colorScheme.tertiary
                                        .withOpacity( 0.2)
                                    : Theme.of(context).colorScheme.primary
                                        .withOpacity( 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomIconWidget(
                            iconName: isEarned ? 'add_circle' : 'remove_circle',
                            color:
                                isEarned
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(context).colorScheme.primary,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          transaction['description'] as String,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          _formatTimestamp(
                            transaction['timestamp'] as DateTime,
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        trailing: Text(
                          '${isEarned ? '+' : '-'}${transaction['points']}',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(
                            color:
                                isEarned
                                    ? Theme.of(context).colorScheme.tertiary
                                    : Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: 'Rewards',
        variant: CustomAppBarVariant.withActions,
        actions: [
          IconButton(
            onPressed: _showPointsHistory,
            icon: CustomIconWidget(
              iconName: 'history',
              color: colorScheme.onSurface,
              size: 24,
            ),
          ),
          IconButton(
            onPressed:
                () => Navigator.pushNamed(context, '/settings-profile-screen'),
            icon: CustomIconWidget(
              iconName: 'person_outline',
              color: colorScheme.onSurface,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpace.x2),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshRewards,
          color: colorScheme.primary,
          child: Column(
            children: [
              // Points balance card
              PointsBalanceCardWidget(
                currentPoints: _currentPoints,
                recentTransactions: _recentTransactions,
                onTap: _showPointsHistory,
              ),

              // Search bar
              SearchBarWidget(
                controller: _searchController,
                hintText: 'Search rewards...',
                onChanged: _onSearchChanged,
                onClear: _onSearchClear,
              ),

              // Category filters
              CategoryFilterWidget(
                categories: _categories,
                selectedCategory: _selectedCategory,
                onCategorySelected: _onCategorySelected,
              ),

              // Rewards grid
              Expanded(
                child:
                    _isLoading
                        ? Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        )
                        : _filteredRewards.isEmpty
                        ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomIconWidget(
                                iconName: 'search_off',
                                color: colorScheme.onSurfaceVariant,
                                size: 48,
                              ),
                              SizedBox(height: AppSpace.x2),
                              Text(
                                'No rewards found',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(height: AppSpace.x1),
                              Text(
                                'Try adjusting your search or category filter',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                        : GridView.builder(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpace.x2,
                            vertical: AppSpace.x1,
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: AppSpace.x2,
                                mainAxisSpacing: AppSpace.x1,
                              ),
                          itemCount: _filteredRewards.length,
                          itemBuilder: (context, index) {
                            final reward = _filteredRewards[index];
                            return RewardCardWidget(
                              reward: reward,
                              onTap: () => _showRewardDetail(reward),
                              onWishlist: () => _addToWishlist(reward),
                              onShare: () => _shareReward(reward),
                            );
                          },
                        ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 4,
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }
}
