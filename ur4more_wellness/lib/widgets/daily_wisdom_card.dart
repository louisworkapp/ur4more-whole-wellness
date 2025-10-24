import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/tokens.dart';
import '../theme/tokens.dart';
import '../core/settings/settings_scope.dart';
import '../core/settings/settings_model.dart';
import '../services/gateway_service.dart';
import '../widgets/custom_icon_widget.dart';

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

class DailyWisdomCard extends StatefulWidget {
  const DailyWisdomCard({super.key});

  @override
  State<DailyWisdomCard> createState() => _DailyWisdomCardState();
}

class _DailyWisdomCardState extends State<DailyWisdomCard> with TickerProviderStateMixin {
  int _currentQuoteIndex = 0;
  bool _isExpanded = false;
  bool _isLoading = true;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  
  // Dynamic quotes from gateway
  List<Map<String, dynamic>> _quotes = [];
  Map<String, dynamic>? _currentQuote;
  FaithTier? _lastFaithTier; // Track faith mode changes

  // Fallback wisdom quotes for when gateway is unavailable
  final List<Map<String, dynamic>> _fallbackWisdomQuotes = [
    {
      'text': 'The fear of the Lord is the beginning of wisdom, and knowledge of the Holy One is understanding.',
      'author': 'Proverbs 9:10 (KJV)',
      'source': 'Gateway',
      'tags': ['wisdom', 'faith'],
    },
    {
      'text': 'Trust in the Lord with all thine heart; and lean not unto thine own understanding.',
      'author': 'Proverbs 3:5 (KJV)',
      'source': 'Gateway',
      'tags': ['trust', 'faith'],
    },
    {
      'text': 'For the Lord giveth wisdom: out of his mouth cometh knowledge and understanding.',
      'author': 'Proverbs 2:6 (KJV)',
      'source': 'Gateway',
      'tags': ['wisdom', 'faith'],
    },
    {
      'text': 'The wise in heart are called discerning, and gracious words promote instruction.',
      'author': 'Proverbs 16:21 (KJV)',
      'source': 'Gateway',
      'tags': ['wisdom', 'discernment'],
    },
    {
      'text': 'How much better to get wisdom than gold, to get insight rather than silver!',
      'author': 'Proverbs 16:16 (KJV)',
      'source': 'Gateway',
      'tags': ['wisdom', 'value'],
    },
    {
      'text': 'The beginning of wisdom is this: Get wisdom. Though it cost all you have, get understanding.',
      'author': 'Proverbs 4:7 (KJV)',
      'source': 'Gateway',
      'tags': ['wisdom', 'understanding'],
    },
    {
      'text': 'A wise man will hear, and will increase learning; and a man of understanding shall attain unto wise counsels.',
      'author': 'Proverbs 1:5 (KJV)',
      'source': 'Gateway',
      'tags': ['wisdom', 'learning'],
    },
    {
      'text': 'The wise store up knowledge, but the mouth of a fool invites ruin.',
      'author': 'Proverbs 10:14 (KJV)',
      'source': 'Gateway',
      'tags': ['wisdom', 'knowledge'],
    },
    {
      'text': 'Whoever walks with the wise becomes wise, but the companion of fools will suffer harm.',
      'author': 'Proverbs 13:20 (KJV)',
      'source': 'Gateway',
      'tags': ['wisdom', 'fellowship'],
    },
    {
      'text': 'The wise woman builds her house, but with her own hands the foolish one tears hers down.',
      'author': 'Proverbs 14:1 (KJV)',
      'source': 'Gateway',
      'tags': ['wisdom', 'building'],
    },
  ];

  @override
  void initState() {
    super.initState();
    _expandController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _expandController,
      curve: Curves.easeInOut,
    );
    _loadDailyWisdom();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentFaithTier = SettingsScope.of(context).value.faithTier;
    
    // Check if faith mode changed
    if (_lastFaithTier != currentFaithTier) {
      print('🔄 DailyWisdomCard: Faith mode changed from $_lastFaithTier to $currentFaithTier');
      _lastFaithTier = currentFaithTier;
      _clearCacheAndReload();
    }
  }

  void _clearCacheAndReload() async {
    // Clear gateway cache and reload quotes
    await GatewayService.clearQuoteCache();
    setState(() {
      _quotes = [];
      _currentQuoteIndex = 0;
      _currentQuote = null;
      _isLoading = true;
    });
    _loadDailyWisdom();
  }

  /// Get the daily quote index for 365-day rotation
  /// This ensures each day gets a different quote from the available pool
  int _getDailyQuoteIndex(int totalQuotes) {
    if (totalQuotes == 0) return 0;
    
    // Get the current date and calculate days since epoch
    final now = DateTime.now();
    final daysSinceEpoch = now.difference(DateTime(1970, 1, 1)).inDays;
    
    // Use modulo to cycle through quotes based on the day
    return daysSinceEpoch % totalQuotes;
  }

  Future<void> _loadDailyWisdom() async {
    try {
      final settings = SettingsScope.of(context).value;
      print('🔄 DailyWisdomCard: Current faithTier: ${settings.faithTier}');
      
      // Fetch wisdom quotes from gateway with unique topic for 365-day rotation
      final quotes = await GatewayService.fetchDailyQuotes(
        faithTier: settings.faithTier,
        topic: 'wisdom', // Use 'wisdom' topic to get wisdom quotes from gateway
        limit: 15,
      );
      
      if (mounted && quotes.isNotEmpty) {
        setState(() {
          _quotes = quotes;
          _currentQuoteIndex = _getDailyQuoteIndex(_quotes.length);
          _currentQuote = _quotes[_currentQuoteIndex];
          _isLoading = false;
        });
        print('✅ DailyWisdomCard: Loaded ${_quotes.length} wisdom quotes');
      } else {
        // Use fallback quotes
        setState(() {
          _quotes = _fallbackWisdomQuotes;
          _currentQuoteIndex = _getDailyQuoteIndex(_quotes.length);
          _currentQuote = _quotes[_currentQuoteIndex];
          _isLoading = false;
        });
        print('📦 DailyWisdomCard: Using fallback wisdom quotes');
      }
    } catch (e) {
      print('❌ DailyWisdomCard: Error loading wisdom quotes: $e');
      // Use fallback quotes
      setState(() {
        _quotes = _fallbackWisdomQuotes;
        _currentQuoteIndex = _getDailyQuoteIndex(_quotes.length);
        _currentQuote = _quotes[_currentQuoteIndex];
        _isLoading = false;
      });
    }
  }

  void _refreshQuote() {
    if (_quotes.isEmpty) return;
    
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
      _currentQuote = _quotes[_currentQuoteIndex];
    });
    
    // Provide haptic feedback
    HapticFeedback.lightImpact();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    
    if (_isExpanded) {
      _expandController.forward();
    } else {
      _expandController.reverse();
    }
    
    HapticFeedback.lightImpact();
  }

  bool get _isFaithQuote {
    if (_currentQuote == null) return false;
    final tags = (_currentQuote!['tags'] as List<dynamic>?)?.map((tag) => tag.toString()).toList() ?? [];
    return tags.contains('faith') || tags.contains('wisdom');
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_isLoading) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: AppSpace.x4),
        padding: Pad.card,
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
        child: Center(
          child: CircularProgressIndicator(
            color: T.gold,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_currentQuote == null) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: AppSpace.x4),
        padding: Pad.card,
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
        child: Text(
          'No wisdom available',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpace.x4),
      child: Column(
        children: [
          // Main wisdom card
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              padding: Pad.card,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _brandBlue.withOpacity(0.05),
                    _brandBlue.withOpacity(0.02),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _outlineColor,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and title
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
                          iconName: 'psychology',
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
                              'Daily Wisdom',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: _textColor,
                              ),
                            ),
                            Text(
                              '365 days of spiritual insight',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: _textSubColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Faith/Wisdom badge
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
                              iconName: 'auto_awesome',
                              color: _brandBlue200,
                              size: 12,
                            ),
                            SizedBox(width: AppSpace.x1),
                            Text(
                              'Wisdom',
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
                  
                  SizedBox(height: AppSpace.x3),
                  
                  // Quote text
                  Text(
                    _currentQuote!['text'] ?? '',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.onSurface,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  
                  SizedBox(height: AppSpace.x2),
                  
                  // Author and source
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _currentQuote!['author'] ?? '',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: T.gold,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        'Source: ${_currentQuote!['source'] ?? 'Gateway'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: AppSpace.x2),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _refreshQuote,
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: AppSpace.x2),
                            decoration: BoxDecoration(
                              color: T.gold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: T.gold.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'refresh',
                                  color: _brandBlue200,
                                  size: 16,
                                ),
                                SizedBox(width: AppSpace.x1),
                                Text(
                                  'New Wisdom',
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
                      GestureDetector(
                        onTap: _toggleExpanded,
                        child: Container(
                          padding: EdgeInsets.all(AppSpace.x2),
                          decoration: BoxDecoration(
                            color: T.gold.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: T.gold.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: AnimatedRotation(
                            turns: _isExpanded ? 0.5 : 0,
                            duration: const Duration(milliseconds: 300),
                            child: CustomIconWidget(
                              iconName: 'expand_more',
                              color: _brandBlue200,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: EdgeInsets.only(top: AppSpace.x2),
              padding: Pad.card,
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: T.gold.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wisdom Collection',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppSpace.x2),
                  Text(
                    'This wisdom rotates daily with a unique 365-day cycle, different from other daily content. Each day brings fresh spiritual insight to guide your journey.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: AppSpace.x3),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_quotes.length} wisdom quotes available',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _textSubColor,
                          ),
                        ),
                      ),
                      if (_quotes.length < 10)
                        GestureDetector(
                          onTap: _loadDailyWisdom,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: AppSpace.x2, vertical: AppSpace.x1),
                            decoration: BoxDecoration(
                              color: T.gold.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: 'add',
                                  color: _brandBlue200,
                                  size: 12,
                                ),
                                SizedBox(width: AppSpace.x1),
                                Text(
                                  'Load More',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: _brandBlue200,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
