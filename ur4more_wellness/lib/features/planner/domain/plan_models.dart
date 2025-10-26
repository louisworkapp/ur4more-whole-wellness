enum CoachCategory { mind, body, spirit, work, errand }

class PlanBlock {
  final String id;
  final String title;
  final CoachCategory category;
  final DateTime start;
  final DateTime end;
  final bool fromCoach;
  final String? notes;
  final String? verseRef;   // faith overlay
  final bool verseEnabled;

  PlanBlock({
    required this.id,
    required this.title,
    required this.category,
    required this.start,
    required this.end,
    this.fromCoach = false,
    this.notes,
    this.verseRef,
    this.verseEnabled = false,
  });

  Duration get duration => end.difference(start);

  PlanBlock copyWith({
    String? title,
    CoachCategory? category,
    DateTime? start,
    DateTime? end,
    bool? fromCoach,
    String? notes,
    String? verseRef,
    bool? verseEnabled,
  }) => PlanBlock(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    start: start ?? this.start,
    end: end ?? this.end,
    fromCoach: fromCoach ?? this.fromCoach,
    notes: notes ?? this.notes,
    verseRef: verseRef ?? this.verseRef,
    verseEnabled: verseEnabled ?? this.verseEnabled,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category.name,
    'start': start.toIso8601String(),
    'end': end.toIso8601String(),
    'fromCoach': fromCoach,
    'notes': notes,
    'verseRef': verseRef,
    'verseEnabled': verseEnabled,
  };

  static PlanBlock fromJson(Map<String, dynamic> j) => PlanBlock(
    id: j['id'],
    title: j['title'],
    category: CoachCategory.values.firstWhere((e)=>e.name==j['category']),
    start: DateTime.parse(j['start']),
    end: DateTime.parse(j['end']),
    fromCoach: j['fromCoach'] ?? false,
    notes: j['notes'],
    verseRef: j['verseRef'],
    verseEnabled: j['verseEnabled'] ?? false,
  );
}
