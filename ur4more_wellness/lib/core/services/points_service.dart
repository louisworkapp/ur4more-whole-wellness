import 'package:flutter/foundation.dart';

// Mock Supabase service
class Sb {
  static final Sb _instance = Sb._internal();
  factory Sb() => _instance;
  Sb._internal();

  static Sb get i => _instance;

  // Mock Supabase operations
  MockSupabaseTable from(String table) => MockSupabaseTable(table);
  Future<dynamic> rpc(
    String functionName, {
    Map<String, dynamic>? params,
  }) async {
    debugPrint('Mock RPC call: $functionName with params: $params');

    if (functionName == 'set_points_floor_zero') {
      final userId = params?['p_user'] as String?;
      final delta = params?['p_delta'] as int?;

      if (userId != null && delta != null) {
        // Mock implementation - in real app this would call Supabase RPC
        // For now, return mock updated points ensuring floor at 0
        final currentPoints = 2847; // Mock current points
        final newPoints =
            (currentPoints + delta).clamp(0, double.infinity).toInt();
        debugPrint(
          'Mock RPC set_points_floor_zero: user=$userId, delta=$delta, result=$newPoints',
        );
        return newPoints;
      }
    }

    return null;
  }
}

class MockSupabaseTable {
  final String tableName;
  MockSupabaseTable(this.tableName);

  Future<void> insert(Map<String, dynamic> data) async {
    debugPrint('Mock insert into $tableName: $data');
    // Mock insert operation
    await Future.delayed(const Duration(milliseconds: 100));
  }

  MockSupabaseQuery select(String columns) =>
      MockSupabaseQuery(tableName, columns);
  MockSupabaseQuery update(Map<String, dynamic> data) =>
      MockSupabaseQuery(tableName, '', data);
}

class MockSupabaseQuery {
  final String tableName;
  final String columns;
  final Map<String, dynamic>? updateData;

  MockSupabaseQuery(this.tableName, this.columns, [this.updateData]);

  MockSupabaseQuery eq(String column, dynamic value) {
    debugPrint('Mock query: $tableName.$column = $value');
    return this;
  }

  MockSupabaseQuery gte(String column, dynamic value) {
    debugPrint('Mock query: $tableName.$column >= $value');
    return this;
  }

  MockSupabaseQuery order(String column, {bool ascending = true}) {
    debugPrint('Mock query: ORDER BY $column ${ascending ? 'ASC' : 'DESC'}');
    return this;
  }

  MockSupabaseQuery limit(int count) {
    debugPrint('Mock query: LIMIT $count');
    return this;
  }

  Future<List<Map<String, dynamic>>> call() async {
    debugPrint('Mock query execution on $tableName');
    await Future.delayed(const Duration(milliseconds: 100));
    return []; // Return empty result for mock
  }
}

class PointsService {
  static Future<int> award({
    required String userId,
    required String action,
    required int value,
    String? note,
  }) async {
    final sb = Sb.i;

    try {
      // 1) Write to actions table
      await sb.from('actions').insert({
        'user_id': userId,
        'action': action,
        'value': value,
        'note': note,
        'created_at': DateTime.now().toIso8601String(),
      });

      // 2) Mirror to users.points with floor at 0
      final updated = await sb.rpc(
        'set_points_floor_zero',
        params: {'p_user': userId, 'p_delta': value},
      );

      if (updated != null) {
        return updated as int;
      } else {
        // Local fallback if RPC doesn't exist
        return await _localPointsUpdate(userId, value);
      }
    } catch (e) {
      debugPrint('Error in PointsService.award: $e');
      // Fallback to local update
      return await _localPointsUpdate(userId, value);
    }
  }

  static Future<int> _localPointsUpdate(String userId, int delta) async {
    try {
      // Mock current points fetch
      final currentPoints = 2847; // In real app, fetch from database
      final newPoints =
          (currentPoints + delta).clamp(0, double.infinity).toInt();

      // Mock update operation
      debugPrint(
        'Local fallback: updating user $userId points by $delta, new total: $newPoints',
      );

      return newPoints;
    } catch (e) {
      debugPrint('Error in local points update: $e');
      return 0;
    }
  }

  // Utility methods for common point awards
  static Future<int> awardWorkoutCompletion(String userId) async {
    return await award(
      userId: userId,
      action: 'workout_completed',
      value: 100,
      note: 'Body workout completed',
    );
  }

  static Future<int> awardReflectionCompletion(String userId) async {
    return await award(
      userId: userId,
      action: 'reflection_completed',
      value: 75,
      note: 'Mind reflection completed',
    );
  }

  static Future<int> awardDevotionCompletion(
    String userId,
    String reference,
  ) async {
    return await award(
      userId: userId,
      action: 'devotion_completed',
      value: 25,
      note: reference,
    );
  }

  static Future<int> awardCopingCompletion(String userId) async {
    return await award(
      userId: userId,
      action: 'coping_completed',
      value: 25,
      note: 'Daily check-in coping strategies',
    );
  }

  static Future<int> awardStreak7(String userId) async {
    return await award(
      userId: userId,
      action: 'streak_7',
      value: 50,
      note: '7-day check-in streak',
    );
  }

  static Future<int> redeemReward(
    String userId,
    int cost,
    String rewardTitle,
  ) async {
    return await award(
      userId: userId,
      action: 'redeem',
      value: -cost,
      note: rewardTitle,
    );
  }
}
