import 'exercise_model.dart';

class ExerciseRegistry {
  static const paths = <String, String>{
    'urge_surfing': 'assets/mind/exercises/urge_surfing.json',
    'worry_postpone': 'assets/mind/exercises/worry_postpone.json',
    'grounding_54321': 'assets/mind/exercises/grounding_54321.json',
    'pmr_short': 'assets/mind/exercises/pmr_short.json',
    'defusion_label': 'assets/mind/exercises/defusion_label.json',
    'tiny_wins': 'assets/mind/exercises/tiny_wins.json',
  };

  static Future<List<Exercise>> list() async {
    final items = <Exercise>[];
    for (final p in paths.values) {
      items.add(await Exercise.loadAsset(p));
    }
    return items;
  }

  static Future<Exercise> byId(String id) => Exercise.loadAsset(paths[id]!);
}
