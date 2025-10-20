import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExerciseSample {
  final String id;
  final DateTime ts;
  final double? preMood, preUrge, postMood, postUrge, postConfidence;
  
  ExerciseSample({
    required this.id,
    required this.ts,
    this.preMood, 
    this.preUrge, 
    this.postMood, 
    this.postUrge, 
    this.postConfidence,
  });

  Map<String, dynamic> toJson() => {
    "id": id, 
    "ts": ts.toIso8601String(),
    "preMood": preMood, 
    "preUrge": preUrge, 
    "postMood": postMood, 
    "postUrge": postUrge, 
    "postConfidence": postConfidence
  };

  static ExerciseSample fromJson(Map<String, dynamic> m) => ExerciseSample(
    id: m["id"], 
    ts: DateTime.parse(m["ts"]),
    preMood: (m["preMood"] as num?)?.toDouble(),
    preUrge: (m["preUrge"] as num?)?.toDouble(),
    postMood: (m["postMood"] as num?)?.toDouble(),
    postUrge: (m["postUrge"] as num?)?.toDouble(),
    postConfidence: (m["postConfidence"] as num?)?.toDouble(),
  );
}

class InsightStore {
  static const _k = "exercise_samples_v1";
  
  Future<List<ExerciseSample>> _getAll() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getStringList(_k) ?? const [];
    return raw.map((s) => ExerciseSample.fromJson(json.decode(s))).toList();
  }
  
  Future<void> add(ExerciseSample s) async {
    final p = await SharedPreferences.getInstance();
    final list = p.getStringList(_k) ?? [];
    list.add(json.encode(s.toJson()));
    // keep cap to last 1000 samples
    final capped = list.length > 1000 ? list.sublist(list.length-1000) : list;
    await p.setStringList(_k, capped);
  }
  
  Future<Map<String, List<ExerciseSample>>> byId() async {
    final all = await _getAll();
    final map = <String, List<ExerciseSample>>{};
    for (final s in all) { 
      (map[s.id] ??= []).add(s); 
    }
    return map;
  }
}
