import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/settings/settings_model.dart';
import 'gateway_service.dart';

class DevotionalService {
  static const String _dailyDevotionalKey = 'daily_devotional_cache';
  static const String _devotionalHistoryKey = 'devotional_history';
  static const String _lastDevotionalDateKey = 'last_devotional_date';

  // Generate daily devotional from gateway scripture with 365-day rotation
  static Future<Map<String, dynamic>?> getDailyDevotional({
    required FaithTier faithTier,
    String theme = 'gluttony',
  }) async {
    try {
      print('📖 DevotionalService: Getting daily devotional for faithTier: $faithTier, theme: $theme');
      final isNewDay = await _isNewDay();
      
      // Check cache first (unless it's a new day)
      if (!isNewDay) {
        final cached = await _getCachedDevotional();
        if (cached != null) {
          print('📦 DevotionalService: Using cached devotional');
          return cached;
        }
      }

      // Fetch fresh scripture from gateway
      print('🌐 DevotionalService: Fetching fresh scripture from gateway');
      final scripture = await GatewayService.fetchDailyScripture(
        faithTier: faithTier,
        theme: theme,
      );

      if (scripture != null) {
        final devotional = _createDevotionalFromScripture(scripture);
        
        // Cache the devotional
        await _cacheDevotional(devotional);
        
        // Add to history
        await _addToHistory(devotional);
        
        return devotional;
      } else {
        return _getFallbackDevotional();
      }
    } catch (e) {
      print('Error loading daily devotional: $e');
      return _getFallbackDevotional();
    }
  }

  // Get devotional history
  static Future<List<Map<String, dynamic>>> getDevotionalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString(_devotionalHistoryKey);
      
      if (historyJson != null) {
        final List<dynamic> history = json.decode(historyJson);
        return history.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      print('Error loading devotional history: $e');
      return [];
    }
  }

  // Mark devotional as completed
  static Future<void> markDevotionalCompleted(String devotionalId) async {
    try {
      final history = await getDevotionalHistory();
      final updatedHistory = history.map((item) {
        if (item['id'] == devotionalId) {
          return {...item, 'isCompleted': true, 'completedTime': _getTimeOfDay()};
        }
        return item;
      }).toList();
      
      await _saveHistory(updatedHistory);
    } catch (e) {
      print('Error marking devotional as completed: $e');
    }
  }

  // Toggle bookmark
  static Future<void> toggleBookmark(String devotionalId) async {
    try {
      final history = await getDevotionalHistory();
      final updatedHistory = history.map((item) {
        if (item['id'] == devotionalId) {
          return {...item, 'isBookmarked': !(item['isBookmarked'] ?? false)};
        }
        return item;
      }).toList();
      
      await _saveHistory(updatedHistory);
    } catch (e) {
      print('Error toggling bookmark: $e');
    }
  }

  // Helper methods
  static Future<bool> _isNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetch = prefs.getString(_lastDevotionalDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (lastFetch != today) {
      await prefs.setString(_lastDevotionalDateKey, today);
      return true;
    }
    return false;
  }

  static Map<String, dynamic> _createDevotionalFromScripture(Map<String, dynamic> scripture) {
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year, 1, 1)).inDays;
    
    // Create a unique ID based on date
    final id = 'devotional_${now.year}_${dayOfYear}';
    
    // Extract verse text
    final verses = List<Map<String, dynamic>>.from(scripture['verses'] ?? []);
    final verseText = verses.map((v) => v['t'] ?? '').join(' ');
    
    // Create reflection based on scripture
    final reflection = _generateReflection(scripture['ref'] ?? '', verseText, scripture['actNow'] ?? '');
    
    return {
      'id': id,
      'title': _generateTitle(scripture['ref'] ?? ''),
      'date': now.toIso8601String().split('T')[0],
      'scripture': scripture['ref'] ?? '',
      'verse': verseText,
      'reflection': reflection,
      'readTime': _estimateReadTime(verseText, reflection),
      'isCompleted': false,
      'isBookmarked': false,
      'points': 25,
      'actNow': scripture['actNow'] ?? '',
      'source': scripture['source'] ?? 'kjv.local',
    };
  }

  static String _generateTitle(String reference) {
    // Just return "Daily Wisdom" since the scripture reference is shown below
    return 'Daily Wisdom';
  }

  // Get daily wisdom quote with 365-day rotation
  static Future<Map<String, dynamic>?> getDailyWisdom({
    required FaithTier faithTier,
  }) async {
    try {
      print('🔄 DevotionalService: Getting daily wisdom for faithTier: $faithTier');
      
      // Fetch wisdom quotes from gateway
      final quotes = await GatewayService.fetchDailyQuotes(
        faithTier: faithTier,
        topic: 'wisdom',
        limit: 15,
      );
      
      if (quotes.isNotEmpty) {
        // Use 365-day rotation to select quote
        final quoteIndex = _getDailyQuoteIndex(quotes.length);
        final selectedQuote = quotes[quoteIndex];
        
        // Create wisdom devotional from quote
        final wisdom = {
          'title': 'Daily Wisdom',
          'subtitle': '365 days of spiritual insight',
          'quote': selectedQuote['text'] ?? 'Wisdom comes from experience.',
          'author': selectedQuote['author'] ?? 'Unknown',
          'date': _formatDate(DateTime.now()),
          'isCompleted': false,
          'readTime': '3',
          'isBookmarked': false,
          'type': 'wisdom',
          'dayOfYear': _getDayOfYear(),
        };
        
        print('✅ DevotionalService: Loaded wisdom quote for day ${_getDayOfYear()}');
        return wisdom;
      } else {
        return _getFallbackWisdom();
      }
    } catch (e) {
      print('❌ DevotionalService: Error loading daily wisdom: $e');
      return _getFallbackWisdom();
    }
  }

  /// Get the daily quote index for 365-day rotation
  /// This ensures each day gets a different quote from the available pool
  static int _getDailyQuoteIndex(int totalQuotes) {
    if (totalQuotes == 0) return 0;
    
    // Get the current date and calculate days since epoch
    final now = DateTime.now();
    final daysSinceEpoch = now.difference(DateTime(1970, 1, 1)).inDays;
    
    // Use modulo to cycle through quotes based on the day
    return daysSinceEpoch % totalQuotes;
  }

  /// Get the day of the year (1-365)
  static int _getDayOfYear() {
    final now = DateTime.now();
    final startOfYear = DateTime(now.year, 1, 1);
    return now.difference(startOfYear).inDays + 1;
  }

  /// Format date for display
  static String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  /// Fallback wisdom when gateway fails
  static Map<String, dynamic> _getFallbackWisdom() {
    final fallbackQuotes = [
      {
        'quote': 'The fear of the Lord is the beginning of wisdom.',
        'author': 'Proverbs 9:10',
      },
      {
        'quote': 'Trust in the Lord with all your heart and lean not on your own understanding.',
        'author': 'Proverbs 3:5',
      },
      {
        'quote': 'For I know the plans I have for you, declares the Lord.',
        'author': 'Jeremiah 29:11',
      },
    ];
    
    final quoteIndex = _getDailyQuoteIndex(fallbackQuotes.length);
    final selectedQuote = fallbackQuotes[quoteIndex];
    
    return {
      'title': 'Daily Wisdom',
      'subtitle': '365 days of spiritual insight',
      'quote': selectedQuote['quote'],
      'author': selectedQuote['author'],
      'date': _formatDate(DateTime.now()),
      'isCompleted': false,
      'readTime': '3',
      'isBookmarked': false,
      'type': 'wisdom',
      'dayOfYear': _getDayOfYear(),
    };
  }

  static String _generateReflection(String reference, String verseText, String actNow) {
    // Create a reflection based on the scripture content
    final book = reference.split(' ')[0];
    
    return 'Today\'s passage from $book reminds us of God\'s faithfulness and wisdom. As we meditate on these words, let us consider how they apply to our daily walk. $actNow';
  }

  static int _estimateReadTime(String verseText, String reflection) {
    // Rough estimate: 200 words per minute
    final totalWords = verseText.split(' ').length + reflection.split(' ').length;
    return (totalWords / 200 * 60).ceil().clamp(2, 10);
  }

  static String _getTimeOfDay() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  // Cache management
  static Future<void> _cacheDevotional(Map<String, dynamic> devotional) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyDevotionalKey, json.encode(devotional));
  }

  static Future<Map<String, dynamic>?> _getCachedDevotional() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_dailyDevotionalKey);
    if (cached != null) {
      try {
        return Map<String, dynamic>.from(json.decode(cached));
      } catch (e) {
        print('Error parsing cached devotional: $e');
      }
    }
    return null;
  }

  static Future<void> _addToHistory(Map<String, dynamic> devotional) async {
    final history = await getDevotionalHistory();
    
    // Check if this devotional already exists in history
    final exists = history.any((item) => item['id'] == devotional['id']);
    if (!exists) {
      history.insert(0, devotional);
      
      // Keep only last 30 days
      if (history.length > 30) {
        history.removeRange(30, history.length);
      }
      
      await _saveHistory(history);
    }
  }

  static Future<void> _saveHistory(List<Map<String, dynamic>> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_devotionalHistoryKey, json.encode(history));
  }

  // Fallback devotional
  static Map<String, dynamic> _getFallbackDevotional() {
    return {
      'id': 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      'title': 'Walking in Faith',
      'date': DateTime.now().toIso8601String().split('T')[0],
      'scripture': 'Hebrews 11:1',
      'verse': 'Now faith is confidence in what we hope for and assurance about what we do not see.',
      'reflection': 'Faith is not about having all the answers, but about trusting God\'s plan even when we cannot see the full picture. Today, let us walk boldly in faith, knowing that God is guiding our steps and preparing good things for those who love Him.',
      'readTime': 5,
      'isCompleted': false,
      'isBookmarked': false,
      'points': 25,
      'actNow': 'Take a moment to reflect on God\'s faithfulness in your life.',
      'source': 'fallback',
    };
  }
}
