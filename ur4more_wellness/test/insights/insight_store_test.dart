import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ur4more_wellness/insights/insight_store.dart';

void main() {
  group('InsightStore', () {
    late InsightStore store;

    setUp(() {
      TestWidgetsFlutterBinding.ensureInitialized();
      // Use in-memory SharedPreferences for testing
      SharedPreferences.setMockInitialValues({});
      store = InsightStore();
    });

    test('should add and retrieve exercise samples', () async {
      final sample = ExerciseSample(
        id: 'test_exercise',
        ts: DateTime(2024, 1, 1, 12, 0, 0),
        preMood: 5.0,
        postMood: 7.0,
        preUrge: 8.0,
        postUrge: 4.0,
        postConfidence: 8.5,
      );

      await store.add(sample);
      final byId = await store.byId();

      expect(byId['test_exercise'], isNotNull);
      expect(byId['test_exercise']!.length, equals(1));
      expect(byId['test_exercise']!.first.id, equals('test_exercise'));
      expect(byId['test_exercise']!.first.preMood, equals(5.0));
      expect(byId['test_exercise']!.first.postMood, equals(7.0));
    });

    test('should preserve max 1000 samples', () async {
      // Add 1001 samples
      for (int i = 0; i < 1001; i++) {
        await store.add(ExerciseSample(
          id: 'test_exercise',
          ts: DateTime(2024, 1, 1, 12, 0, i),
        ));
      }

      final byId = await store.byId();
      expect(byId['test_exercise']!.length, equals(1000));
    });

    test('should handle JSON round-trip correctly', () async {
      final original = ExerciseSample(
        id: 'json_test',
        ts: DateTime(2024, 1, 1, 12, 0, 0),
        preMood: 3.5,
        preUrge: 7.2,
        postMood: 6.8,
        postUrge: 2.1,
        postConfidence: 9.0,
      );

      await store.add(original);
      final retrieved = await store.byId();

      final sample = retrieved['json_test']!.first;
      expect(sample.id, equals(original.id));
      expect(sample.ts, equals(original.ts));
      expect(sample.preMood, equals(original.preMood));
      expect(sample.preUrge, equals(original.preUrge));
      expect(sample.postMood, equals(original.postMood));
      expect(sample.postUrge, equals(original.postUrge));
      expect(sample.postConfidence, equals(original.postConfidence));
    });

    test('should handle null values correctly', () async {
      final sample = ExerciseSample(
        id: 'null_test',
        ts: DateTime(2024, 1, 1, 12, 0, 0),
        // All other values are null
      );

      await store.add(sample);
      final byId = await store.byId();

      final retrieved = byId['null_test']!.first;
      expect(retrieved.id, equals('null_test'));
      expect(retrieved.preMood, isNull);
      expect(retrieved.preUrge, isNull);
      expect(retrieved.postMood, isNull);
      expect(retrieved.postUrge, isNull);
      expect(retrieved.postConfidence, isNull);
    });

    test('should group samples by exercise ID', () async {
      await store.add(ExerciseSample(
        id: 'exercise_a',
        ts: DateTime(2024, 1, 1, 12, 0, 0),
      ));
      await store.add(ExerciseSample(
        id: 'exercise_b',
        ts: DateTime(2024, 1, 1, 12, 1, 0),
      ));
      await store.add(ExerciseSample(
        id: 'exercise_a',
        ts: DateTime(2024, 1, 1, 12, 2, 0),
      ));

      final byId = await store.byId();

      expect(byId['exercise_a']!.length, equals(2));
      expect(byId['exercise_b']!.length, equals(1));
      expect(byId.keys.length, equals(2));
    });
  });
}
