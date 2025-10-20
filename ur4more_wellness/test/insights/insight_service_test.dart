import 'package:flutter_test/flutter_test.dart';
import 'package:ur4more_wellness/insights/insight_store.dart';
import 'package:ur4more_wellness/insights/insight_service.dart';

// Mock InsightStore for testing
class MockInsightStore extends InsightStore {
  final Map<String, List<ExerciseSample>> _samples = {};

  @override
  Future<void> add(ExerciseSample sample) async {
    (_samples[sample.id] ??= []).add(sample);
  }

  @override
  Future<Map<String, List<ExerciseSample>>> byId() async {
    return Map.from(_samples);
  }
}

void main() {
  group('InsightService', () {
    late MockInsightStore store;
    late InsightService service;

    setUp(() {
      store = MockInsightStore();
      service = InsightService(store);
    });

    test('should return null for empty exercise data', () async {
      final insight = await service.forExercise('nonexistent_exercise');
      expect(insight, isNull);
    });

    test('should compute correct deltas for single sample', () async {
      await store.add(ExerciseSample(
        id: 'test_exercise',
        ts: DateTime(2024, 1, 1, 12, 0, 0),
        preMood: 5.0,
        postMood: 7.0,
        preUrge: 8.0,
        postUrge: 4.0,
        postConfidence: 8.5,
      ));

      final insight = await service.forExercise('test_exercise');
      
      expect(insight, isNotNull);
      expect(insight!.id, equals('test_exercise'));
      expect(insight.avgDeltaMood, equals(2.0)); // 7.0 - 5.0
      expect(insight.avgDeltaUrge, equals(-4.0)); // 4.0 - 8.0
      expect(insight.avgPostConfidence, equals(8.5));
      expect(insight.count, equals(1));
    });

    test('should use last 7 samples for rolling average', () async {
      // Add 10 samples
      for (int i = 0; i < 10; i++) {
        await store.add(ExerciseSample(
          id: 'test_exercise',
          ts: DateTime(2024, 1, 1, 12, 0, i),
          preMood: i.toDouble(),
          postMood: (i + 2).toDouble(), // Always +2 improvement
          preUrge: (10 - i).toDouble(),
          postUrge: (8 - i).toDouble(), // Always -2 improvement
          postConfidence: 5.0 + i,
        ));
      }

      final insight = await service.forExercise('test_exercise');
      
      expect(insight, isNotNull);
      expect(insight!.count, equals(7)); // Should use last 7
      expect(insight.avgDeltaMood, equals(2.0)); // All samples have +2 mood delta
      expect(insight.avgDeltaUrge, equals(-2.0)); // All samples have -2 urge delta
      expect(insight.avgPostConfidence, equals(11.0)); // Average of last 7: 5+3, 5+4, ..., 5+9 = (5+3+5+4+5+5+5+6+5+7+5+8+5+9)/7 = 77/7 = 11
    });

    test('should handle partial data correctly', () async {
      await store.add(ExerciseSample(
        id: 'partial_exercise',
        ts: DateTime(2024, 1, 1, 12, 0, 0),
        preMood: 5.0,
        // postMood is null
        preUrge: 8.0,
        postUrge: 4.0,
        // postConfidence is null
      ));

      final insight = await service.forExercise('partial_exercise');
      
      expect(insight, isNotNull);
      expect(insight!.avgDeltaMood, isNull); // Can't compute without postMood
      expect(insight.avgDeltaUrge, equals(-4.0)); // 4.0 - 8.0
      expect(insight.avgPostConfidence, isNull); // Can't compute without postConfidence
      expect(insight.count, equals(1));
    });

    test('should compute averages correctly for multiple samples', () async {
      // Add 3 samples with different deltas
      await store.add(ExerciseSample(
        id: 'multi_exercise',
        ts: DateTime(2024, 1, 1, 12, 0, 0),
        preMood: 3.0,
        postMood: 6.0, // +3
        preUrge: 9.0,
        postUrge: 6.0, // -3
        postConfidence: 7.0,
      ));
      
      await store.add(ExerciseSample(
        id: 'multi_exercise',
        ts: DateTime(2024, 1, 1, 12, 1, 0),
        preMood: 4.0,
        postMood: 5.0, // +1
        preUrge: 8.0,
        postUrge: 7.0, // -1
        postConfidence: 8.0,
      ));
      
      await store.add(ExerciseSample(
        id: 'multi_exercise',
        ts: DateTime(2024, 1, 1, 12, 2, 0),
        preMood: 2.0,
        postMood: 4.0, // +2
        preUrge: 7.0,
        postUrge: 5.0, // -2
        postConfidence: 9.0,
      ));

      final insight = await service.forExercise('multi_exercise');
      
      expect(insight, isNotNull);
      expect(insight!.count, equals(3));
      expect(insight.avgDeltaMood, equals(2.0)); // (3+1+2)/3 = 2
      expect(insight.avgDeltaUrge, equals(-2.0)); // (-3-1-2)/3 = -2
      expect(insight.avgPostConfidence, equals(8.0)); // (7+8+9)/3 = 8
    });

    test('should handle samples with no pre/post data', () async {
      await store.add(ExerciseSample(
        id: 'no_data_exercise',
        ts: DateTime(2024, 1, 1, 12, 0, 0),
        // All mood/urge/confidence values are null
      ));

      final insight = await service.forExercise('no_data_exercise');
      
      expect(insight, isNotNull);
      expect(insight!.count, equals(1));
      expect(insight.avgDeltaMood, isNull);
      expect(insight.avgDeltaUrge, isNull);
      expect(insight.avgPostConfidence, isNull);
    });
  });
}
