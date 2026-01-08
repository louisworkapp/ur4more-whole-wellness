// Example usage of PointsTestService for background testing
// 
// This file demonstrates how to test points programmatically without UI.
// You can call these methods from anywhere in your app during development.

import 'points_test_service.dart';

/// Example: Test points in the background
/// 
/// Usage examples:
/// 
/// 1. Quick test - Award 10 points to each category:
///    await PointsTestService.quickTest();
/// 
/// 2. Award specific points:
///    await PointsTestService.awardPoints(
///      category: 'body',
///      delta: 25,
///      action: 'workout_completed',
///      note: 'Test workout',
///    );
/// 
/// 3. Get current points:
///    final points = PointsTestService.getCurrentPoints();
///    print('Total: ${points['total']}, Body: ${points['body']}');
/// 
/// 4. Set specific point values:
///    await PointsTestService.setPoints(
///      body: 1000,
///      mind: 500,
///      spirit: 750,
///    );
/// 
/// 5. Reset all points:
///    await PointsTestService.resetPoints();
/// 
/// 6. Ensure points are loaded before testing:
///    await PointsTestService.ensureLoaded();
/// 
/// All operations are logged to debug console for monitoring.

class PointsTestExample {
  /// Example: Test awarding points after a workout
  static Future<void> testWorkoutCompletion() async {
    await PointsTestService.ensureLoaded();
    await PointsTestService.awardPoints(
      category: 'body',
      delta: 25,
      action: 'workout_completed',
      note: 'Test workout completion',
    );
  }

  /// Example: Test awarding points after a mind session
  static Future<void> testMindSession() async {
    await PointsTestService.ensureLoaded();
    await PointsTestService.awardPoints(
      category: 'mind',
      delta: 20,
      action: 'mind_session_completed',
      note: 'Test mind session',
    );
  }

  /// Example: Test awarding points after spiritual activity
  static Future<void> testSpiritualActivity() async {
    await PointsTestService.ensureLoaded();
    await PointsTestService.awardPoints(
      category: 'spirit',
      delta: 30,
      action: 'devotion_completed',
      note: 'Test devotion',
    );
  }

  /// Example: Test setting up a specific scenario
  static Future<void> testScenario() async {
    await PointsTestService.ensureLoaded();
    
    // Set up a scenario where user has:
    // - 1500 body points (75% progress)
    // - 1200 mind points (60% progress)
    // - 1700 spirit points (85% progress)
    await PointsTestService.setPoints(
      body: 1500,
      mind: 1200,
      spirit: 1700,
    );
  }

  /// Example: Test resetting and starting fresh
  static Future<void> testReset() async {
    await PointsTestService.resetPoints();
    // Now you can test from zero
    await PointsTestService.quickTest();
  }
}
