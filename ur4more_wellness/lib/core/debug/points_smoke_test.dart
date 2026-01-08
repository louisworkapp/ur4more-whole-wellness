import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';
import '../state/points_store.dart';

class PointsSmokeTestResult {
  final bool ok;
  final List<String> steps;
  final String? error;

  const PointsSmokeTestResult({
    required this.ok,
    required this.steps,
    this.error,
  });
}

class PointsSmokeTest {
  static Future<PointsSmokeTestResult> run() async {
    final steps = <String>[];
    try {
      String? userId = await AuthService.getCurrentUserId();
      steps.add('Fetched current user id: ${userId ?? "null"}');

      if (userId == null && kDebugMode) {
        userId = 'debug_user';
        await AuthService.saveAuthData(
          token: 'debug_token',
          userId: userId,
          expiryDate: DateTime.now().add(const Duration(days: 365)),
        );
        steps.add('Created debug user id');
      }

      if (userId == null) {
        return PointsSmokeTestResult(
          ok: false,
          steps: steps,
          error: 'No user id available',
        );
      }

      final store = PointsStore.i;
      await store.load(userId);
      steps.add('Loaded points for $userId');

      final baselineTotal = store.totalPoints;
      final baselineBody = store.bodyPoints;
      final baselineMind = store.mindPoints;
      final baselineSpirit = store.spiritPoints;

      await store.awardCategory(
        userId: userId,
        category: 'body',
        delta: 10,
        action: 'debug_smoke',
        note: 'smoke',
      );
      await store.awardCategory(
        userId: userId,
        category: 'mind',
        delta: 10,
        action: 'debug_smoke',
        note: 'smoke',
      );
      await store.awardCategory(
        userId: userId,
        category: 'spirit',
        delta: 10,
        action: 'debug_smoke',
        note: 'smoke',
      );
      steps.add('Awarded +10 to each category');

      final afterTotal = store.totalPoints;
      final afterBody = store.bodyPoints;
      final afterMind = store.mindPoints;
      final afterSpirit = store.spiritPoints;

      if (afterBody < baselineBody + 10 ||
          afterMind < baselineMind + 10 ||
          afterSpirit < baselineSpirit + 10) {
        return PointsSmokeTestResult(
          ok: false,
          steps: steps,
          error: 'Category points did not increase by expected amounts',
        );
      }

      if (afterTotal < baselineTotal + 30) {
        return PointsSmokeTestResult(
          ok: false,
          steps: steps,
          error: 'Total points did not increase as expected',
        );
      }

      // Reload to validate persistence
      await store.load(userId);
      if (store.bodyPoints != afterBody ||
          store.mindPoints != afterMind ||
          store.spiritPoints != afterSpirit ||
          store.totalPoints != afterTotal) {
        return PointsSmokeTestResult(
          ok: false,
          steps: steps,
          error: 'Persisted values do not match after reload',
        );
      }

      steps.add('Persistence verified');
      return PointsSmokeTestResult(ok: true, steps: steps);
    } catch (e) {
      return PointsSmokeTestResult(
        ok: false,
        steps: steps,
        error: 'Exception: $e',
      );
    }
  }
}
