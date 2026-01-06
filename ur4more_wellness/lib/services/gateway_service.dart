import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/settings/settings_model.dart';
import 'gateway_error.dart';
import 'gateway_http_wrapper.dart';
import 'web_origin_stub.dart'
    if (dart.library.html) 'web_origin_web.dart' as web_origin;

class GatewayService {
  // Base URL from --dart-define=UR4MORE_API_BASE_URL=...
  // Defaults to http://127.0.0.1:8080 if not provided
  // Empty string means demo mode (no backend)
  static String get _baseUrl => String.fromEnvironment(
    'UR4MORE_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );
  
  // Track if we've done startup health probe
  static bool _startupProbeDone = false;
  static bool _autoDemoModeEnabled = false;
  
  // Check if we're in demo mode (no backend available)
  static bool get isDemoMode {
    final url = _baseUrl.trim();
    return url.isEmpty || url == 'demo' || url == 'offline' || _autoDemoModeEnabled;
  }
  
  // Last error for UI display
  static GatewayError? _lastError;
  static GatewayError? get lastError => _lastError;
  
  // Cache for health check result to avoid repeated checks
  static bool? _healthCheckCache;
  static DateTime? _healthCheckTime;
  
  /// Perform startup health probe and enable demo mode if needed
  static Future<void> performStartupHealthProbe() async {
    if (_startupProbeDone) return;
    _startupProbeDone = true;
    
    final url = _baseUrl.trim();
    if (url.isEmpty || url == 'demo' || url == 'offline') {
      if (kDebugMode) {
        print('📦 GatewayService: Startup - Demo mode explicitly enabled');
      }
      return;
    }
    
    // Check if we're on HTTPS origin (GitHub Pages)
    bool isHttpsOrigin = false;
    if (kIsWeb) {
      try {
        final origin = web_origin.getWebOrigin();
        isHttpsOrigin = origin != null && origin.startsWith('https://');
        if (kDebugMode) {
          print('🌐 GatewayService: Startup - Web origin: $origin (HTTPS: $isHttpsOrigin)');
        }
      } catch (e) {
        if (kDebugMode) {
          print('🌐 GatewayService: Startup - Could not detect web origin: $e');
        }
      }
    }
    
    // Perform health check with short timeout
    try {
      final healthUrl = '$_baseUrl/health';
      if (kDebugMode) {
        print('🔍 GatewayService: Startup - Performing health probe to $healthUrl');
      }
      
      final result = await GatewayHttpWrapper.executeWithErrorHandling(
        () => GatewayHttpWrapper.get(
          healthUrl,
          timeout: const Duration(seconds: 3),
        ),
        healthUrl,
      );
      
      if (result.error != null || result.response?.statusCode != 200) {
        // Health check failed
        _lastError = result.error ?? GatewayError(
          url: healthUrl,
          kind: GatewayErrorKind.unknown,
          rawException: 'Health check returned ${result.response?.statusCode ?? 'no response'}',
          statusCode: result.response?.statusCode,
        );
        
        // If on HTTPS origin, enable demo mode automatically
        if (isHttpsOrigin) {
          _autoDemoModeEnabled = true;
          if (kDebugMode) {
            print('📦 GatewayService: Startup - Health probe failed on HTTPS origin, enabling Demo Mode');
            print('📦 GatewayService: Demo Mode: gateway offline or not reachable from this origin');
          }
        } else {
          if (kDebugMode) {
            print('⚠️ GatewayService: Startup - Health probe failed, but not on HTTPS origin');
            print('⚠️ GatewayService: App will attempt to use gateway but may fall back to demo mode');
          }
        }
      } else {
        if (kDebugMode) {
          print('✅ GatewayService: Startup - Health probe successful');
        }
        _healthCheckCache = true;
        _healthCheckTime = DateTime.now();
      }
    } catch (e) {
      _lastError = GatewayError.fromException(e, '$_baseUrl/health');
      if (isHttpsOrigin) {
        _autoDemoModeEnabled = true;
        if (kDebugMode) {
          print('📦 GatewayService: Startup - Health probe exception on HTTPS origin, enabling Demo Mode');
          print('📦 GatewayService: Demo Mode: gateway offline or not reachable from this origin');
        }
      }
    }
  }
  
  // Check if gateway is available (with caching)
  static Future<bool> _isGatewayAvailable() async {
    if (isDemoMode) return false;
    
    // Cache health check for 30 seconds
    if (_healthCheckCache != null && _healthCheckTime != null) {
      final age = DateTime.now().difference(_healthCheckTime!);
      if (age.inSeconds < 30) {
        return _healthCheckCache!;
      }
    }
    
    final isHealthy = await checkHealth();
    _healthCheckCache = isHealthy;
    _healthCheckTime = DateTime.now();
    return isHealthy;
  }
  
  static const String _tokenKey = 'gateway_jwt_token';
  
  // Cache keys for daily content
  static const String _dailyQuoteKey = 'daily_quote_cache';
  static const String _dailyScriptureKey = 'daily_scripture_cache';
  static const String _lastFetchDateKey = 'last_fetch_date';

  // Dev token from --dart-define=UR4MORE_DEV_JWT=...
  // Only used in debug mode - release builds must use stored tokens
  static const String _devJwtToken = String.fromEnvironment('UR4MORE_DEV_JWT', defaultValue: '');

  static Future<Map<String, String>> _buildAuthHeaders() async {
    final token = await _getStoredToken() ?? _getDevToken();
    
    // Only store token if we have one (don't store empty strings)
    if (token.isNotEmpty) {
      await _storeToken(token);
    }
    
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Get dev token from dart-define, only in debug mode.
  /// Release builds will return empty string if no stored token exists.
  static String _getDevToken() {
    if (kReleaseMode) {
      // Release builds must not use dev tokens
      return '';
    }
    return _devJwtToken;
  }

  static Future<String?> _getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> _storeToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<bool> _isNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetch = prefs.getString(_lastFetchDateKey);
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    if (lastFetch != today) {
      await prefs.setString(_lastFetchDateKey, today);
      return true;
    }
    return false;
  }

  // Fetch daily quotes from gateway
  static Future<List<Map<String, dynamic>>> fetchDailyQuotes({
    required FaithTier faithTier,
    String topic = '',
    int limit = 15, // Increased from 5 to 15 for more rotation options
  }) async {
    // Demo mode: return fallback quotes immediately
    if (!await _isGatewayAvailable()) {
      if (kDebugMode) {
        print('📦 GatewayService: Demo mode - using fallback quotes');
      }
      return _getFallbackQuotes(faithTier);
    }
    
    if (kDebugMode) {
      print('🔄 GatewayService: Fetching daily quotes for faithTier: $faithTier, topic: $topic');
    }
    final headers = await _buildAuthHeaders();
    final isNewDay = await _isNewDay();
    
    if (kDebugMode) {
      print('🔄 GatewayService: isNewDay: $isNewDay');
    }
    
    // Check cache first (unless it's a new day)
    if (!isNewDay) {
      final cached = await _getCachedQuotes();
      if (cached.isNotEmpty) {
        if (kDebugMode) {
          print('📦 GatewayService: Using cached quotes (${cached.length} items)');
        }
        return cached;
      }
    }

    final faithMode = _convertFaithTierToMode(faithTier);
    final body = json.encode({
      'faithMode': faithMode,
      'lightConsentGiven': faithTier != FaithTier.off,
      'hideFaithOverlaysInMind': false,
      'topic': topic,
      'limit': limit,
    });

    final url = '$_baseUrl/content/quotes';
    final result = await GatewayHttpWrapper.executeWithErrorHandling(
      () => GatewayHttpWrapper.post(
        url,
        headers: headers,
        body: body,
        timeout: const Duration(seconds: 10),
      ),
      url,
    );

    if (result.error != null) {
      _lastError = result.error;
      if (kDebugMode) {
        print('❌ GatewayService: Quotes request failed: ${result.error!.displayMessage}');
      }
      return _getFallbackQuotes(faithTier);
    }

    // If error occurred, it's already set in result.error (including HTTP status codes >= 400)
    if (result.error != null) {
      _lastError = result.error;
      if (kDebugMode) {
        print('❌ GatewayService: Quotes request failed: ${result.error!.displayMessage}');
      }
      return _getFallbackQuotes(faithTier);
    }

    final response = result.response!;
    try {
      final List<dynamic> quotes = json.decode(response.body);
      final formattedQuotes = quotes.map((q) => {
        'text': q['text'] ?? '',
        'author': q['author'] ?? '',
        'source': q['source'] ?? 'Gateway',
        'tags': (q['tags'] as List<dynamic>?)?.map((tag) => tag.toString()).toList() ?? [],
        'license': q['license'] ?? 'public_domain',
      }).toList();
      
      if (kDebugMode) {
        print('✅ GatewayService: Successfully fetched ${formattedQuotes.length} quotes from gateway');
      }
      
      // Cache the results
      await _cacheQuotes(formattedQuotes);
      return formattedQuotes;
    } catch (e) {
      _lastError = GatewayError(
        url: url,
        kind: GatewayErrorKind.unknown,
        rawException: 'Failed to parse response: $e',
      );
      return _getFallbackQuotes(faithTier);
    }
  }

  // Fetch daily scripture from gateway
  static Future<Map<String, dynamic>?> fetchDailyScripture({
    required FaithTier faithTier,
    String theme = 'gluttony',
  }) async {
    // Demo mode: return fallback scripture immediately
    if (!await _isGatewayAvailable()) {
      if (kDebugMode) {
        print('📦 GatewayService: Demo mode - using fallback scripture');
      }
      return _getFallbackScripture();
    }
    
    final headers = await _buildAuthHeaders();
    final isNewDay = await _isNewDay();
    
    // Check cache first (unless it's a new day)
    if (!isNewDay) {
      final cached = await _getCachedScripture();
      if (cached != null) return cached;
    }

    final faithMode = _convertFaithTierToMode(faithTier);
    final body = json.encode({
      'faithMode': faithMode,
      'lightConsentGiven': faithTier != FaithTier.off,
      'hideFaithOverlaysInMind': false,
      'theme': theme,
      'limit': 1,
    });

    final url = '$_baseUrl/content/scripture';
    final result = await GatewayHttpWrapper.executeWithErrorHandling(
      () => GatewayHttpWrapper.post(
        url,
        headers: headers,
        body: body,
        timeout: const Duration(seconds: 10),
      ),
      url,
    );

    if (result.error != null) {
      _lastError = result.error;
      if (kDebugMode) {
        print('❌ GatewayService: Scripture request failed: ${result.error!.displayMessage}');
      }
      return _getFallbackScripture();
    }

    final response = result.response!;
    try {
      final scripture = json.decode(response.body);
      final formattedScripture = {
        'ref': scripture['ref'] ?? '',
        'verses': List<Map<String, dynamic>>.from(scripture['verses'] ?? []),
        'actNow': scripture['actNow'] ?? '',
        'source': scripture['source'] ?? 'kjv.local',
      };
      
      // Cache the result
      await _cacheScripture(formattedScripture);
      return formattedScripture;
    } catch (e) {
      _lastError = GatewayError(
        url: url,
        kind: GatewayErrorKind.unknown,
        rawException: 'Failed to parse response: $e',
      );
      return _getFallbackScripture();
    }
  }

  // Get manifest from gateway
  static Future<Map<String, dynamic>?> fetchManifest() async {
    final headers = await _buildAuthHeaders();
    final url = '$_baseUrl/content/manifest';
    
    final result = await GatewayHttpWrapper.executeWithErrorHandling(
      () => GatewayHttpWrapper.get(
        url,
        headers: headers,
        timeout: const Duration(seconds: 10),
      ),
      url,
    );

    if (result.error != null) {
      _lastError = result.error;
      if (kDebugMode) {
        print('❌ GatewayService: Manifest request failed: ${result.error!.displayMessage}');
      }
      return null;
    }

    final response = result.response!;
    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      _lastError = GatewayError(
        url: url,
        kind: GatewayErrorKind.unknown,
        rawException: 'Failed to parse response: $e',
      );
      return null;
    }
  }

  // Health check - returns full response data
  static Future<Map<String, dynamic>?> checkHealthResponse() async {
    if (isDemoMode) return null;
    
    final url = '$_baseUrl/health';
    final result = await GatewayHttpWrapper.executeWithErrorHandling(
      () => GatewayHttpWrapper.get(
        url,
        timeout: const Duration(seconds: 5),
      ),
      url,
    );
    
    if (result.error != null) {
      _lastError = result.error;
      return null;
    }

    final response = result.response!;
    try {
      return json.decode(response.body) as Map<String, dynamic>;
    } catch (e) {
      _lastError = GatewayError(
        url: url,
        kind: GatewayErrorKind.unknown,
        rawException: 'Failed to parse response: $e',
      );
      return null;
    }
  }

  // Health check - returns boolean (for backward compatibility)
  static Future<bool> checkHealth() async {
    final response = await checkHealthResponse();
    return response != null;
  }

  // Cache management
  static Future<void> _cacheQuotes(List<Map<String, dynamic>> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyQuoteKey, json.encode(quotes));
  }

  static Future<void> clearQuoteCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_dailyQuoteKey);
    await prefs.remove(_lastFetchDateKey);
    if (kDebugMode) {
      print('🗑️ GatewayService: Cleared quote cache');
    }
  }

  static Future<List<Map<String, dynamic>>> _getCachedQuotes() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_dailyQuoteKey);
    if (cached != null) {
      try {
        final List<dynamic> quotes = json.decode(cached);
        return quotes.cast<Map<String, dynamic>>();
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing cached quotes: $e');
        }
      }
    }
    return [];
  }

  static Future<void> _cacheScripture(Map<String, dynamic> scripture) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dailyScriptureKey, json.encode(scripture));
  }

  static Future<Map<String, dynamic>?> _getCachedScripture() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_dailyScriptureKey);
    if (cached != null) {
      try {
        return Map<String, dynamic>.from(json.decode(cached));
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing cached scripture: $e');
        }
      }
    }
    return null;
  }

  // Helper methods
  static String _convertFaithTierToMode(FaithTier tier) {
    switch (tier) {
      case FaithTier.off:
        return 'off';
      case FaithTier.light:
        return 'light';
      case FaithTier.disciple:
        return 'disciple';
      case FaithTier.kingdom:
        return 'kingdom';
    }
  }

  // Fallback content when gateway is unavailable
  static List<Map<String, dynamic>> _getFallbackQuotes(FaithTier faithTier) {
    if (faithTier == FaithTier.off) {
      return [
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
      ];
    } else {
      return [
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
      ];
    }
  }

  static Map<String, dynamic>? _getFallbackScripture() {
    return {
      'ref': '1 Corinthians 9:24–27 (KJV)',
      'verses': [
        {'v': 24, 't': 'Know ye not that they which run in a race run all, but one receiveth the prize? So run, that ye may obtain.'},
        {'v': 25, 't': 'And every man that striveth for the mastery is temperate in all things. Now they do it to obtain a corruptible crown; but we an incorruptible.'},
      ],
      'actNow': 'Plate plan → pray → eat with temperance; log one small victory.',
      'source': 'kjv.local',
    };
  }
}
