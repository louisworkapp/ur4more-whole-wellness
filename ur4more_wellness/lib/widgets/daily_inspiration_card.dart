import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../design/tokens.dart';
import '../core/settings/settings_scope.dart';
import '../core/settings/settings_model.dart';

class DailyInspirationCard extends StatefulWidget {
  const DailyInspirationCard({super.key});

  @override
  State<DailyInspirationCard> createState() => _DailyInspirationCardState();
}

class _DailyInspirationCardState extends State<DailyInspirationCard> with TickerProviderStateMixin {
  int _currentQuoteIndex = 0;
  bool _isExpanded = false;
  late AnimationController _expandController;
  late Animation<double> _expandAnimation;

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
    _setDailyQuote();
  }

  @override
  void dispose() {
    _expandController.dispose();
    super.dispose();
  }

  void _setDailyQuote() {
    // Use date-based seeding for consistent daily quotes
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    _currentQuoteIndex = dayOfYear % 14; // 14 total quotes (7 secular + 7 faith)
  }

  Map<String, dynamic> get _currentQuote {
    final settingsCtl = SettingsScope.of(context);
    final settings = settingsCtl.value;
    
    // Determine which quote to show based on faith mode
    if (settings.faithTier == FaithTier.off) {
      // Show secular quotes only
      return _secularQuotes[_currentQuoteIndex % _secularQuotes.length];
    } else {
      // Show faith quotes for any faith mode
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

  void _refreshQuote() {
    HapticFeedback.mediumImpact();
    setState(() {
      _currentQuoteIndex = (_currentQuoteIndex + 1) % 14;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final quote = _currentQuote;

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
                                Text(
                                  'Daily Inspiration',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
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
                              'Tap to ${_isExpanded ? 'collapse' : 'expand'}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
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
                      Icon(
                        _isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpace.x3),
                  
                  // Inspiration text
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
                      children: (quote['tags'] as List<String>).map((tag) {
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
                            '#$tag',
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
