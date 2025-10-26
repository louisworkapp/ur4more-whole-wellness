enum CoachCategory { mind, body, spirit, work, admin, recovery, errand }

class ImplementationIntent {
  final String cue;       // If …
  final String location;  // Where
  final String firstStep; // Then …
  const ImplementationIntent({this.cue='', this.location='', this.firstStep=''});
  Map<String,dynamic> toJson()=>{'cue':cue,'location':location,'firstStep':firstStep};
  factory ImplementationIntent.fromJson(Map j)=>ImplementationIntent(
    cue:j['cue']??'', location:j['location']??'', firstStep:j['firstStep']??'');
}

class FaithOverlay {
  final String? verseRef;
  final String? prayerHint;
  final bool enabled;
  const FaithOverlay({this.verseRef, this.prayerHint, this.enabled=false});
  Map<String,dynamic> toJson()=>{'verseRef':verseRef,'prayerHint':prayerHint,'enabled':enabled};
  factory FaithOverlay.fromJson(Map j)=>FaithOverlay(
    verseRef:j['verseRef'], prayerHint:j['prayerHint'], enabled:j['enabled']??false);
}

class PlanBlock {
  final String id;
  final String title;
  final CoachCategory category;
  final DateTime start;
  final DateTime end;
  final bool fromCoach;
  final String? notes;
  final ImplementationIntent impl;
  final FaithOverlay faith;

  const PlanBlock({
    required this.id,
    required this.title,
    required this.category,
    required this.start,
    required this.end,
    this.fromCoach=false,
    this.notes,
    this.impl = const ImplementationIntent(),
    this.faith = const FaithOverlay(),
  });

  Duration get duration => end.difference(start);

  PlanBlock copyWith({
    String? title, CoachCategory? category, DateTime? start, DateTime? end,
    bool? fromCoach, String? notes, ImplementationIntent? impl, FaithOverlay? faith,
  }) => PlanBlock(
    id: id,
    title: title ?? this.title,
    category: category ?? this.category,
    start: start ?? this.start,
    end: end ?? this.end,
    fromCoach: fromCoach ?? this.fromCoach,
    notes: notes ?? this.notes,
    impl: impl ?? this.impl,
    faith: faith ?? this.faith,
  );

  Map<String,dynamic> toJson()=> {
    'id':id,'title':title,'category':category.name,
    'start':start.toIso8601String(),'end':end.toIso8601String(),
    'fromCoach':fromCoach,'notes':notes,
    'impl':impl.toJson(),'faith':faith.toJson(),
  };
  factory PlanBlock.fromJson(Map j)=> PlanBlock(
    id:j['id'], title:j['title'],
    category: CoachCategory.values.firstWhere((e)=>e.name==j['category']),
    start: DateTime.parse(j['start']), end: DateTime.parse(j['end']),
    fromCoach: j['fromCoach']??false, notes:j['notes'],
    impl: ImplementationIntent.fromJson(j['impl']??{}),
    faith: FaithOverlay.fromJson(j['faith']??{}),
  );
}