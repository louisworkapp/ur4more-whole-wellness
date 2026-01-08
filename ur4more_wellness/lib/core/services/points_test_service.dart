import 'package:flutter/foundation.dart';
import '../state/points_store.dart';
import 'auth_service.dart';

/// Service for testing points in the background without UI
/// Useful for automated testing, debugging, and development
class PointsTestService {
  /// Ensure a test user ID exists, creating one if needed
  static Future<String> _ensureTestUserId() async {
    String? userId = await AuthService.getCurrentUserId();
    
    if (userId == null) {
      // Create a test user ID for debugging
      userId = 'test_user_${DateTime.now().millisecondsSinceEpoch}';
      await AuthService.saveAuthData(
        token: 'test_token',
        userId: userId,
        expiryDate: DateTime.now().add(const Duration(days: 365)),
      );
      debugPrint('PointsTestService: Created test user ID: $userId');
    }
    
    return userId;
  }

  /// Load points for the current user (or create test user if none exists)
  static Future<void> ensureLoaded() async {
    final userId = await _ensureTestUserId();
    final store = PointsStore.i;
    
    if (!store.loaded || store.totalPoints == 0) {
      await store.load(userId);
      debugPrint('PointsTestService: Loaded points - Total: ${store.totalPoints}, Body: ${store.bodyPoints}, Mind: ${store.mindPoints}, Spirit: ${store.spiritPoints}');
    }
  }

  /// Award points to a category (background operation)
  static Future<void> awardPoints({
    required String category,
    required int delta,
    String action = 'test_award',
    String? note,
  }) async {
    final userId = await _ensureTestUserId();
    final store = PointsStore.i;
    
    // Ensure store is loaded
    if (!store.loaded) {
      await store.load(userId);
    }
    
    await store.awardCategory(
      userId: userId,
      category: category,
      delta: delta,
      action: action,
      note: note ?? 'Background test',
    );
    
    debugPrint('PointsTestService: Awarded $delta points to $category. New total: ${store.totalPoints}');
  }

  /// Get current points summary
  static Map<String, dynamic> getCurrentPoints() {
    final store = PointsStore.i;
    return {
      'total': store.totalPoints,
      'body': store.bodyPoints,
      'mind': store.mindPoints,
      'spirit': store.spiritPoints,
      'bodyProgress': store.bodyProgress,
      'mindProgress': store.mindProgress,
      'spiritProgress': store.spiritProgress,
      'loaded': store.loaded,
    };
  }

  /// Reset all points to zero
  static Future<void> resetPoints() async {
    final userId = await _ensureTestUserId();
    final store = PointsStore.i;
    await store.reset(userId);
    debugPrint('PointsTestService: Reset all points to zero');
  }

  /// Set points directly (for testing specific scenarios)
  static Future<void> setPoints({
    int? total,
    int? body,
    int? mind,
    int? spirit,
  }) async {
    final userId = await _ensureTestUserId();
    final store = PointsStore.i;
    
    // Ensure store is loaded first
    if (!store.loaded) {
      await store.load(userId);
    }
    
    // Calculate deltas needed
    if (body != null && body != store.bodyPoints) {
      final delta = body - store.bodyPoints;
      await store.awardCategory(
        userId: userId,
        category: 'body',
        delta: delta,
        action: 'test_set',
        note: 'Set body points to $body',
      );
    }
    
    if (mind != null && mind != store.mindPoints) {
      final delta = mind - store.mindPoints;
      await store.awardCategory(
        userId: userId,
        category: 'mind',
        delta: delta,
        action: 'test_set',
        note: 'Set mind points to $mind',
      );
    }
    
    if (spirit != null && spirit != store.spiritPoints) {
      final delta = spirit - store.spiritPoints;
      await store.awardCategory(
        userId: userId,
        category: 'spirit',
        delta: delta,
        action: 'test_set',
        note: 'Set spirit points to $spirit',
      );
    }
    
    debugPrint('PointsTestService: Set points - Total: ${store.totalPoints}, Body: ${store.bodyPoints}, Mind: ${store.mindPoints}, Spirit: ${store.spiritPoints}');
  }

  /// Quick test: Award 10 points to each category
  static Future<void> quickTest() async {
    await ensureLoaded();
    await awardPoints(category: 'body', delta: 10, action: 'quick_test');
    await awardPoints(category: 'mind', delta: 10, action: 'quick_test');
    await awardPoints(category: 'spirit', delta: 10, action: 'quick_test');
    debugPrint('PointsTestService: Quick test completed');
  }
}
