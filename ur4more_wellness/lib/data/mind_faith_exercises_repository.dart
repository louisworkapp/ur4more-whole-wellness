import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class FaithExercise {
  final String id, title, summary;
  final List<String> categories, steps;
  final List<Map<String,String>> scriptureKJV;
  final String? prayer;
  final int xp;
  final int? timerSeconds, deadlineHours;
  FaithExercise({
    required this.id, required this.title, required this.summary,
    required this.categories, required this.steps,
    required this.scriptureKJV, this.prayer, required this.xp,
    this.timerSeconds, this.deadlineHours,
  });
}

class MindFaithExercisesRepository {
  static const _path = 'assets/mind/exercises_faith.json';
  List<FaithExercise>? _cache;

  Future<List<FaithExercise>> load() async {
    if (_cache != null) return _cache!;
    final raw = json.decode(await rootBundle.loadString(_path));
    // final gates = (raw['gates'] ?? {}) as Map<String, dynamic>;
    // You can check gates here if needed
    final list = (raw['exercises'] as List).cast<Map>();
    _cache = list.map((m) => FaithExercise(
      id: m['id'],
      title: m['title'],
      summary: m['summary'],
      categories: (m['categories'] as List).map((e) => e.toString()).toList(),
      steps: (m['steps'] as List).map((e) => e.toString()).toList(),
      scriptureKJV: ((m['scriptureKJV'] as List?) ?? []).cast<Map>().map((kv) =>
        kv.map((k, v) => MapEntry(k.toString(), v.toString()))).toList(),
      prayer: m['prayer'],
      xp: m['xp'] as int,
      timerSeconds: m['timerSeconds'],
      deadlineHours: m['deadlineHours'],
    )).toList();
    return _cache!;
  }
}
