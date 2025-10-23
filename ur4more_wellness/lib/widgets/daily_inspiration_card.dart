import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/tokens.dart';
import '../core/settings/settings_scope.dart';
import '../core/settings/settings_model.dart';
import '../services/gateway_service.dart';

class DailyInspirationCard extends StatefulWidget {
  const DailyInspirationCard({super.key});

  @override
  State<DailyInspirationCard> createState() => _DailyInspirationCardState();
}

class _DailyInspirationCardState extends State<DailyInspirationCard> with TickerProviderStateMixin {
  int _currentQuoteIndex = 0;
  bool _isExpanded = false;
  bool _isLoading = true;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;
  
  // Dynamic quotes from gateway
  List<Map<String, dynamic>> _quotes = [];
  Map<String, dynamic>? _currentQuote;
  FaithTier? _lastFaithTier; // Track faith mode changes

  // Simple quotes array - 7 secular and 7 faith-based
  final List<Map<String, dynamic>> _secularQuotes = [
    {
      'text': 'The only way to do great work is to love what you do.',
      'author': 'Steve Jobs',
      'source': 'Stanford Commencement Speech',
      'tags': ['motivation', 'passion'],
    },
    {
      'text': 'Success is not final, failure is not fatal: it is the courage to continue that counts.',
      'author': 'Winston Churchill',
      'source': 'Historical Quote',
      'tags': ['perseverance', 'courage'],
    },
    {
      'text': 'The future belongs to those who believe in the beauty of their dreams.',
      'author': 'Eleanor Roosevelt',
      'source': 'Historical Quote',
      'tags': ['dreams', 'hope'],
    },
    {
      'text': 'In the middle of difficulty lies opportunity.',
      'author': 'Albert Einstein',
      'source': 'Historical Quote',
      'tags': ['opportunity', 'growth'],
    },
    {
      'text': 'Be yourself; everyone else is already taken.',
      'author': 'Oscar Wilde',
      'source': 'Historical Quote',
      'tags': ['authenticity', 'self'],
    },
    {
      'text': 'The way to get started is to quit talking and begin doing.',
      'author': 'Walt Disney',
      'source': 'Historical Quote',
      'tags': ['action', 'productivity'],
    },
    {
      'text': 'Life is what happens to you while you\'re busy making other plans.',
      'author': 'John Lennon',
      'source': 'Historical Quote',
      'tags': ['life', 'mindfulness'],
    },
  ];

  final List<Map<String, dynamic>> _faithQuotes = [
    {
      'text': 'For I know the plans I have for you, declares the Lord, plans to prosper you and not to harm you, to give you hope and a future.',
      'author': 'Jeremiah 29:11',
      'source': 'Holy Bible',
      'tags': ['hope', 'purpose'],
    },
    {
      'text': 'I can do all things through Christ who strengthens me.',
      'author': 'Philippians 4:13',
      'source': 'Holy Bible',
      'tags': ['strength', 'faith'],
    },
    {
      'text': 'And we know that in all things God works for the good of those who love him.',
      'author': 'Romans 8:28',
      'source': 'Holy Bible',
      'tags': ['trust', 'goodness'],
    },
    {
      'text': 'The Lord is my shepherd; I shall not want.',
      'author': 'Psalm 23:1',
      'source': 'Holy Bible',
      'tags': ['peace', 'provision'],
    },
    {
      'text': 'Be still, and know that I am God.',
      'author': 'Psalm 46:10',
      'source': 'Holy Bible',
      'tags': ['peace', 'trust'],
    },
    {
      'text': 'Trust in the Lord with all your heart and lean not on your own understanding.',
      'author': 'Proverbs 3:5',
      'source': 'Holy Bible',
      'tags': ['trust', 'wisdom'],
    },
    {
      'text': 'And the peace of God, which transcends all understanding, will guard your hearts and your minds in Christ Jesus.',
      'author': 'Philippians 4:7',
      'source': 'Holy Bible',
      'tags': ['peace', 'protection'],
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
    // Don't load quotes in initState - wait for didChangeDependencies
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Check if faith mode has changed
    final settingsCtl = SettingsScope.of(context);
    final currentFaithTier = settingsCtl.value.faithTier;
    
    if (_lastFaithTier != null && _lastFaithTier != currentFaithTier) {
      print('🔄 DailyInspirationCard: Faith mode changed from $_lastFaithTier to $currentFaithTier');
      // Clear cache and reload quotes when faith mode changes
      _clearCacheAndReload();
    } else if (_quotes.isEmpty) {
      // Load quotes after dependencies are available (first time)
      _loadDailyQuotes();
    }
    
    _lastFaithTier = currentFaithTier;
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  Future<void> _clearCacheAndReload() async {
    // Clear the quote cache
    await GatewayService.clearQuoteCache();
    
    // Reset state
    setState(() {
      _quotes = [];
      _currentQuoteIndex = 0;
      _isLoading = true;
    });
    
    // Reload quotes with new faith mode
    await _loadDailyQuotes();
  }

  Future<void> _loadDailyQuotes() async {
    try {
      final settingsCtl = SettingsScope.of(context);
      final settings = settingsCtl.value;
      
      print('🎯 DailyInspirationCard: Current faithTier: ${settings.faithTier}');
      print('🎯 DailyInspirationCard: _isFaithQuote: ${settings.faithTier != FaithTier.off}');
      
      // Fetch fresh quotes from gateway
      final quotes = await GatewayService.fetchDailyQuotes(
        faithTier: settings.faithTier,
        topic: 'daily_inspiration',
        limit: 15, // Increased for more rotation options
      );
      
      if (mounted) {
        setState(() {
          _quotes = quotes;
          _isLoading = false;
          _currentQuoteIndex = 0;
          _currentQuote = quotes.isNotEmpty ? quotes[0] : _getFallbackQuote(settings.faithTier);
        });
      }
    } catch (e) {
      print('Error loading daily quotes: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _currentQuote = _getFallbackQuote(SettingsScope.of(context).value.faithTier);
        });
      }
    }
  }

  Map<String, dynamic> _getFallbackQuote(FaithTier faithTier) {
    if (faithTier == FaithTier.off) {
      return _secularQuotes[_currentQuoteIndex % _secularQuotes.length];
    } else {
      return _faithQuotes[_currentQuoteIndex % _faithQuotes.length];
    }
  }

  bool get _isFaithQuote {
    final settingsCtl = SettingsScope.of(context);
    final settings = settingsCtl.value;
    return settings.faithTier != FaithTier.off;
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

  void _refreshQuote() async {
    HapticFeedback.mediumImpact();
    
    if (_quotes.isNotEmpty) {
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % _quotes.length;
        _currentQuote = _quotes[_currentQuoteIndex];
      });
      
      // If we're near the end of available quotes, fetch more
      if (_currentQuoteIndex >= _quotes.length - 3) {
        await _fetchMoreQuotes();
      }
    } else {
      // Fallback to static quotes
      final settingsCtl = SettingsScope.of(context);
      final settings = settingsCtl.value;
      setState(() {
        _currentQuoteIndex = (_currentQuoteIndex + 1) % 14;
        _currentQuote = _getFallbackQuote(settings.faithTier);
      });
    }
  }

  Future<void> _fetchMoreQuotes() async {
    try {
      final settingsCtl = SettingsScope.of(context);
      final settings = settingsCtl.value;
      
      // Fetch additional quotes with different topics for variety
      final topics = ['motivation', 'wisdom', 'growth', 'peace', 'strength'];
      final randomTopic = topics[_currentQuoteIndex % topics.length];
      
      final moreQuotes = await GatewayService.fetchDailyQuotes(
        faithTier: settings.faithTier,
        topic: randomTopic,
        limit: 10, // Fetch 10 more quotes
      );
      
      if (mounted && moreQuotes.isNotEmpty) {
        setState(() {
          // Add new quotes to existing ones, avoiding duplicates
          final existingTexts = _quotes.map((q) => q['text'].toLowerCase()).toSet();
          final newQuotes = moreQuotes.where((q) => 
            !existingTexts.contains(q['text'].toLowerCase())
          ).toList();
          
          _quotes.addAll(newQuotes);
          print('🔄 Added ${newQuotes.length} new quotes. Total: ${_quotes.length}');
        });
      }
    } catch (e) {
      print('Error fetching more quotes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final quote = _currentQuote ?? _getFallbackQuote(SettingsScope.of(context).value.faithTier);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
      child: Column(
        children: [
          // Main inspiration card
          GestureDetector(
            onTap: _toggleExpanded,
            child: Container(
              padding: const EdgeInsets.all(AppSpace.x4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _isFaithQuote 
                        ? const Color(0xFFC9A227).withOpacity(0.1)
                        : const Color(0xFF0FA97A).withOpacity(0.1),
                    _isFaithQuote 
                        ? const Color(0xFFC9A227).withOpacity(0.05)
                        : const Color(0xFF0FA97A).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isFaithQuote 
                      ? const Color(0xFFC9A227).withOpacity(0.2)
                      : const Color(0xFF0FA97A).withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and type indicator
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _isFaithQuote 
                              ? const Color(0xFFC9A227).withOpacity(0.1)
                              : const Color(0xFF0FA97A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _isFaithQuote ? Icons.auto_awesome : Icons.lightbulb,
                          color: _isFaithQuote 
                              ? const Color(0xFFC9A227)
                              : const Color(0xFF0FA97A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: AppSpace.x3),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    'Daily Inspiration',
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: AppSpace.x2),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _isFaithQuote 
                                        ? const Color(0xFFC9A227).withOpacity(0.1)
                                        : const Color(0xFF0FA97A).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _isFaithQuote ? 'Faith' : 'Secular',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: _isFaithQuote 
                                          ? const Color(0xFFC9A227)
                                          : const Color(0xFF0FA97A),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                                    Text(
                                      'Tap to ${_isExpanded ? 'collapse' : 'expand'} • ${_quotes.length} quotes available',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                          ],
                        ),
                      ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: _refreshQuote,
                                    icon: Icon(
                                      Icons.refresh,
                                      color: _isFaithQuote 
                                          ? const Color(0xFFC9A227)
                                          : const Color(0xFF0FA97A),
                                      size: 20,
                                    ),
                                    tooltip: 'New inspiration',
                                  ),
                                  if (_quotes.length < 10) // Show load more button if we have few quotes
                                    IconButton(
                                      onPressed: _fetchMoreQuotes,
                                      icon: Icon(
                                        Icons.add_circle_outline,
                                        color: _isFaithQuote 
                                            ? const Color(0xFFC9A227)
                                            : const Color(0xFF0FA97A),
                                        size: 20,
                                      ),
                                      tooltip: 'Load more quotes',
                                    ),
                                ],
                              ),
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpace.x3),
                  
                  // Inspiration text
                  if (_isLoading)
                    Container(
                      height: 60,
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _isFaithQuote 
                                ? const Color(0xFFC9A227)
                                : const Color(0xFF0FA97A),
                          ),
                        ),
                      ),
                    )
                  else
                    Text(
                      quote['text'],
                      style: theme.textTheme.bodyLarge?.copyWith(
                        height: 1.4,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: _isExpanded ? null : 3,
                      overflow: _isExpanded ? null : TextOverflow.ellipsis,
                    ),
                  
                  // Author (always visible)
                  const SizedBox(height: AppSpace.x2),
                  Text(
                    '— ${quote['author']}',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Expanded content
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Container(
              margin: const EdgeInsets.only(top: AppSpace.x2),
              padding: const EdgeInsets.all(AppSpace.x4),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (quote['source'].isNotEmpty) ...[
                    Text(
                      'Source: ${quote['source']}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: AppSpace.x2),
                  ],
                  if (quote['tags'].isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: (quote['tags'] as List<dynamic>).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _isFaithQuote 
                                ? const Color(0xFFC9A227).withOpacity(0.1)
                                : const Color(0xFF0FA97A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '#${tag.toString()}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: _isFaithQuote 
                                  ? const Color(0xFFC9A227)
                                  : const Color(0xFF0FA97A),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  // Faith invitation for secular mode users
                  if (!_isFaithQuote) ...[
                    const SizedBox(height: AppSpace.x3),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        // Navigate to settings faith section
                        Navigator.of(context).pushNamed('/settings', arguments: {'section': 'faith'});
                      },
                      child: Container(
                        padding: const EdgeInsets.all(AppSpace.x3),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFC9A227).withOpacity(0.1),
                              const Color(0xFFC9A227).withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFC9A227).withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: const Color(0xFFC9A227).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.auto_stories_rounded,
                                color: Color(0xFFC9A227),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpace.x3),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Deeper Truths in Faith',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: const Color(0xFFC9A227),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Explore spiritual wisdom and biblical insights',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              color: const Color(0xFFC9A227),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
