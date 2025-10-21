import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ExerciseStep {
  final String label;
  final String body;
  const ExerciseStep({required this.label, required this.body});
  factory ExerciseStep.fromJson(Map<String, dynamic> j) =>
      ExerciseStep(label: j['label'] ?? '', body: j['body'] ?? '');
}

class OverlayBlock {
  final List<Map<String, String>> verseKJV;
  final String? prompt;
  final String? identity;
  final String? commission;
  const OverlayBlock({this.verseKJV = const [], this.prompt, this.identity, this.commission});
  factory OverlayBlock.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const OverlayBlock();
    final v = (j['verseKJV'] as List?)?.cast<Map<String, dynamic>>() ?? const [];
    return OverlayBlock(
      verseKJV: v.map((e) => <String, String>{'ref': e['ref']?.toString() ?? '', 'text': e['text']?.toString() ?? ''}).toList(),
      prompt: j['prompt']?.toString(),
      identity: j['identity']?.toString(),
      commission: j['commission']?.toString(),
    );
  }
}

class Overlays {
  final OverlayBlock light;
  final OverlayBlock disciple;
  final OverlayBlock kingdom;
  const Overlays({required this.light, required this.disciple, required this.kingdom});
  factory Overlays.fromJson(Map<String, dynamic>? j) => Overlays(
    light: OverlayBlock.fromJson(j?['light']),
    disciple: OverlayBlock.fromJson(j?['disciple']),
    kingdom: OverlayBlock.fromJson(j?['kingdom']),
  );
}

class ExerciseCopy {
  final String intro;
  final List<ExerciseStep> steps;
  final String completion;
  const ExerciseCopy({required this.intro, required this.steps, required this.completion});
  factory ExerciseCopy.fromJson(Map<String, dynamic> j) => ExerciseCopy(
    intro: j['intro'] ?? '',
    steps: ((j['steps'] as List?) ?? const []).map((e) => ExerciseStep.fromJson(e)).toList(),
    completion: j['completion'] ?? '',
  );
}

class Exercise {
  final String id, title, summary;
  final int durationMinutes, xp;
  final List<String> tags, safetyNotes;
  final ExerciseCopy offCopy;
  final Overlays overlays;

  const Exercise({
    required this.id,
    required this.title,
    required this.summary,
    required this.durationMinutes,
    required this.tags,
    required this.safetyNotes,
    required this.offCopy,
    required this.overlays,
    required this.xp,
  });

  factory Exercise.fromJson(Map<String, dynamic> j) => Exercise(
    id: j['id'],
    title: j['title'],
    summary: j['summary'],
    durationMinutes: j['duration_minutes'],
    tags: (j['tags'] as List).cast<String>(),
    safetyNotes: (j['safety_notes'] as List).cast<String>(),
    offCopy: ExerciseCopy.fromJson(j['offCopy']),
    overlays: Overlays.fromJson(j['activatedOverlays']),
    xp: j['xp'] ?? 20,
  );

  static Future<Exercise> loadAsset(String path) async {
    final raw = await rootBundle.loadString(path);
    return Exercise.fromJson(json.decode(raw));
  }
}
