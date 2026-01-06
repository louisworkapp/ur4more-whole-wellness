import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'gateway_error.dart';

// Conditional import for web
import 'web_origin_stub.dart'
    if (dart.library.html) 'web_origin_web.dart' as web_origin;

/// HTTP wrapper with diagnostic logging and error handling
class GatewayHttpWrapper {
  static bool _hasLoggedStartup = false;

  /// Log base URL at startup (once)
  static void _logStartupUrl(String baseUrl) {
    if (!_hasLoggedStartup && kDebugMode) {
      _hasLoggedStartup = true;
      print('🌐 GatewayService: Startup - Base URL: $baseUrl');
      if (kIsWeb) {
        _logWebOrigin();
      }
    }
  }

  /// Log web origin information
  static void _logWebOrigin() {
    if (kIsWeb && kDebugMode) {
      try {
        final origin = web_origin.getWebOrigin();
        if (origin != null) {
          print('🌐 GatewayService: Web origin: $origin');
        } else {
          print('🌐 GatewayService: Running on web platform (origin unavailable)');
        }
      } catch (e) {
        print('🌐 GatewayService: Running on web platform (origin detection failed: $e)');
      }
    }
  }

  /// Get web origin (for web platform only)
  static String? _getWebOrigin() {
    if (!kIsWeb) return null;
    try {
      return web_origin.getWebOrigin();
    } catch (e) {
      return null;
    }
  }

  /// Log request details
  static void _logRequest(String method, String url, {Map<String, String>? headers}) {
    if (kDebugMode) {
      print('🌐 GatewayService: $method $url');
      if (headers != null && headers.isNotEmpty) {
        final authHeader = headers['Authorization'];
        if (authHeader != null) {
          print('🌐 GatewayService: Authorization: ${authHeader.substring(0, authHeader.length > 20 ? 20 : authHeader.length)}...');
        }
      }
    }
  }

  /// Log exception with full diagnostics
  static void _logException(Object exception, String url, {String? method}) {
    if (kDebugMode) {
      print('❌ GatewayService: Exception during ${method ?? 'request'}');
      print('❌ GatewayService: Exception type: ${exception.runtimeType}');
      print('❌ GatewayService: Exception message: $exception');
      print('❌ GatewayService: Target URL: $url');
      if (kIsWeb) {
        final origin = _getWebOrigin();
        if (origin != null) {
          print('❌ GatewayService: Web origin: $origin');
        }
      }
    }
  }

  /// Perform GET request with diagnostics
  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    _logStartupUrl(url.split('/').take(3).join('/'));
    _logRequest('GET', url, headers: headers);

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      ).timeout(
        timeout ?? const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout after ${timeout?.inSeconds ?? 10} seconds');
        },
      );

      if (kDebugMode) {
        print('📡 GatewayService: GET $url → ${response.statusCode}');
      }

      return response;
    } catch (e) {
      _logException(e, url, method: 'GET');
      rethrow;
    }
  }

  /// Perform POST request with diagnostics
  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
    Encoding? encoding,
    Duration? timeout,
  }) async {
    _logStartupUrl(url.split('/').take(3).join('/'));
    _logRequest('POST', url, headers: headers);

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
        encoding: encoding,
      ).timeout(
        timeout ?? const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout after ${timeout?.inSeconds ?? 10} seconds');
        },
      );

      if (kDebugMode) {
        print('📡 GatewayService: POST $url → ${response.statusCode}');
      }

      return response;
    } catch (e) {
      _logException(e, url, method: 'POST');
      rethrow;
    }
  }

  /// Execute request and return response or GatewayError
  static Future<({http.Response? response, GatewayError? error})> executeWithErrorHandling(
    Future<http.Response> Function() request,
    String url,
  ) async {
    try {
      final response = await request();
      
      // Check for HTTP error status codes
      if (response.statusCode >= 400) {
        final origin = _getWebOrigin();
        final error = GatewayError.fromException(
          Exception('HTTP ${response.statusCode}: ${response.body}'),
          url,
          statusCode: response.statusCode,
          origin: origin,
        );
        return (response: response, error: error);
      }
      
      return (response: response, error: null);
    } catch (e) {
      final origin = _getWebOrigin();
      final error = GatewayError.fromException(
        e,
        url,
        origin: origin,
      );
      return (response: null, error: error);
    }
  }
}

