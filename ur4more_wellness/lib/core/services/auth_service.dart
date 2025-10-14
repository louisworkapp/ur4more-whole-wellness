import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  static const String _authTokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _isFirstLaunchKey = 'is_first_launch';

  static Future<bool> isAuthenticated() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Check if user has a valid token
      final token = prefs.getString(_authTokenKey);
      final userId = prefs.getString(_userIdKey);
      final tokenExpiry = prefs.getString(_tokenExpiryKey);
      
      if (token == null || userId == null || tokenExpiry == null) {
        return false;
      }
      
      // Check if token is expired
      final expiryDate = DateTime.tryParse(tokenExpiry);
      if (expiryDate == null || DateTime.now().isAfter(expiryDate)) {
        // Token expired, clear auth data
        await clearAuthData();
        return false;
      }
      
      return true;
    } catch (e) {
      debugPrint('Error checking authentication status: $e');
      return false;
    }
  }

  static Future<String?> getCurrentUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_userIdKey);
    } catch (e) {
      debugPrint('Error getting current user ID: $e');
      return null;
    }
  }

  static Future<void> saveAuthData({
    required String token,
    required String userId,
    required DateTime expiryDate,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_authTokenKey, token);
      await prefs.setString(_userIdKey, userId);
      await prefs.setString(_tokenExpiryKey, expiryDate.toIso8601String());
    } catch (e) {
      debugPrint('Error saving auth data: $e');
    }
  }

  static Future<void> clearAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_authTokenKey);
      await prefs.remove(_userIdKey);
      await prefs.remove(_tokenExpiryKey);
    } catch (e) {
      debugPrint('Error clearing auth data: $e');
    }
  }

  static Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isFirstLaunchKey) ?? true;
    } catch (e) {
      debugPrint('Error checking first launch: $e');
      return true;
    }
  }

  static Future<void> setFirstLaunchCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isFirstLaunchKey, false);
    } catch (e) {
      debugPrint('Error setting first launch completed: $e');
    }
  }

  // Mock authentication for development/testing
  static Future<bool> mockLogin({
    required String email,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock validation - in real app, this would call your backend
    if (email.isNotEmpty && password.isNotEmpty) {
      // Mock successful login
      final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
      final mockUserId = 'user_${DateTime.now().millisecondsSinceEpoch}';
      final mockExpiry = DateTime.now().add(const Duration(days: 30));
      
      await saveAuthData(
        token: mockToken,
        userId: mockUserId,
        expiryDate: mockExpiry,
      );
      
      return true;
    }
    
    return false;
  }

  // Mock logout
  static Future<void> logout() async {
    await clearAuthData();
  }
}