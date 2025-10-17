
enum FaithTier {
  off,
  light,
  disciple,
  kingdomBuilder;

  String get displayName {
    switch (this) {
      case FaithTier.off:
        return 'Off';
      case FaithTier.light:
        return 'Light';
      case FaithTier.disciple:
        return 'Disciple';
      case FaithTier.kingdomBuilder:
        return 'Kingdom Builder';
    }
  }

  static FaithTier fromString(String value) {
    switch (value.toLowerCase()) {
      case 'off':
        return FaithTier.off;
      case 'light':
        return FaithTier.light;
      case 'disciple':
        return FaithTier.disciple;
      case 'kingdom builder':
        return FaithTier.kingdomBuilder;
      default:
        return FaithTier.off;
    }
  }
}

class CourseGate {
  final int? offTierHardGateWeek;

  CourseGate({
    this.offTierHardGateWeek,
  });

  factory CourseGate.fromJson(Map<String, dynamic> json) {
    return CourseGate(
      offTierHardGateWeek: json['offTierHardGateWeek'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'offTierHardGateWeek': offTierHardGateWeek,
    };
  }
}

class Course {
  final String id;
  final String title;
  final String description;
  final String summary;
  final String provider;
  final String duration;
  final String cost;
  final List<String> format;
  final List<String> tags;
  final List<Week> weeks;
  final CourseGate? gate;

  Course({
    required this.id,
    required this.title,
    required this.description,
    required this.summary,
    required this.provider,
    required this.duration,
    required this.cost,
    required this.format,
    required this.tags,
    required this.weeks,
    this.gate,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      summary: json['summary'] as String? ?? json['description'] as String,
      provider: json['provider'] as String? ?? 'UR4MORE',
      duration: json['duration'] as String? ?? '12 weeks',
      cost: json['cost'] as String? ?? 'Free',
      format: List<String>.from(json['format'] as List? ?? ['Self-paced']),
      tags: List<String>.from(json['tags'] as List? ?? ['foundations']),
      weeks: (json['weeks'] as List)
          .map((weekJson) => Week.fromJson(weekJson as Map<String, dynamic>))
          .toList(),
      gate: json['gate'] != null 
          ? CourseGate.fromJson(json['gate'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'summary': summary,
      'provider': provider,
      'duration': duration,
      'cost': cost,
      'format': format,
      'tags': tags,
      'weeks': weeks.map((week) => week.toJson()).toList(),
      'gate': gate?.toJson(),
    };
  }

  bool isFirstParty() {
    return provider == 'UR4MORE';
  }
}

class Week {
  final int week;
  final String title;
  final String theme;
  final List<String> scriptureRefs;
  final String lessonSummary;
  final List<String> keyIdeas;
  final List<String> reflectionQs;
  final List<Practice> practice;
  final String prayer;
  final List<Resource> resources;
  final String tierMin;
  final int estLessonMinutes;
  final int estWeekPracticeMinutes;
  final Unlock? unlock;

  Week({
    required this.week,
    required this.title,
    required this.theme,
    required this.scriptureRefs,
    required this.lessonSummary,
    required this.keyIdeas,
    required this.reflectionQs,
    required this.practice,
    required this.prayer,
    required this.resources,
    required this.tierMin,
    required this.estLessonMinutes,
    required this.estWeekPracticeMinutes,
    this.unlock,
  });

  factory Week.fromJson(Map<String, dynamic> json) {
    return Week(
      week: json['week'] as int,
      title: json['title'] as String,
      theme: json['theme'] as String,
      scriptureRefs: List<String>.from(json['scriptureRefs'] as List),
      lessonSummary: json['lessonSummary'] as String,
      keyIdeas: List<String>.from(json['keyIdeas'] as List),
      reflectionQs: List<String>.from(json['reflectionQs'] as List),
      practice: (json['practice'] as List)
          .map((practiceJson) => Practice.fromJson(practiceJson as Map<String, dynamic>))
          .toList(),
      prayer: json['prayer'] as String,
      resources: (json['resources'] as List)
          .map((resourceJson) => Resource.fromJson(resourceJson as Map<String, dynamic>))
          .toList(),
      tierMin: json['tierMin'] as String,
      estLessonMinutes: json['estLessonMinutes'] as int,
      estWeekPracticeMinutes: json['estWeekPracticeMinutes'] as int,
      unlock: json['unlock'] != null ? Unlock.fromJson(json['unlock'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'title': title,
      'theme': theme,
      'scriptureRefs': scriptureRefs,
      'lessonSummary': lessonSummary,
      'keyIdeas': keyIdeas,
      'reflectionQs': reflectionQs,
      'practice': practice.map((p) => p.toJson()).toList(),
      'prayer': prayer,
      'resources': resources.map((r) => r.toJson()).toList(),
      'tierMin': tierMin,
      'estLessonMinutes': estLessonMinutes,
      'estWeekPracticeMinutes': estWeekPracticeMinutes,
      'unlock': unlock?.toJson(),
    };
  }

  FaithTier get requiredTier => FaithTier.fromString(tierMin);
}

class Practice {
  final String title;
  final String desc;
  final int estMinutes;

  Practice({
    required this.title,
    required this.desc,
    required this.estMinutes,
  });

  factory Practice.fromJson(Map<String, dynamic> json) {
    return Practice(
      title: json['title'] as String,
      desc: json['desc'] as String,
      estMinutes: json['estMinutes'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'desc': desc,
      'estMinutes': estMinutes,
    };
  }
}

class Resource {
  final String title;
  final String kind;
  final String url;

  Resource({
    required this.title,
    required this.kind,
    required this.url,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      title: json['title'] as String,
      kind: json['kind'] as String,
      url: json['url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'kind': kind,
      'url': url,
    };
  }
}

class CourseProgress {
  final String courseId;
  final Map<int, bool> weekCompletion;
  final DateTime lastAccessed;
  final int currentWeek;

  CourseProgress({
    required this.courseId,
    required this.weekCompletion,
    required this.lastAccessed,
    required this.currentWeek,
  });

  factory CourseProgress.empty(String courseId) {
    return CourseProgress(
      courseId: courseId,
      weekCompletion: {},
      lastAccessed: DateTime.now(),
      currentWeek: 1,
    );
  }

  double get progressPercentage {
    if (weekCompletion.isEmpty) return 0.0;
    final completedWeeks = weekCompletion.values.where((completed) => completed).length;
    return completedWeeks / weekCompletion.length;
  }

  double get progress => progressPercentage;

  int get nextIncompleteWeek {
    for (int week = 1; week <= 12; week++) {
      if (!(weekCompletion[week] ?? false)) {
        return week;
      }
    }
    return 12; // All weeks completed
  }

  bool isWeekComplete(int week) {
    return weekCompletion[week] == true;
  }

  CourseProgress copyWith({
    String? courseId,
    Map<int, bool>? weekCompletion,
    DateTime? lastAccessed,
    int? currentWeek,
  }) {
    return CourseProgress(
      courseId: courseId ?? this.courseId,
      weekCompletion: weekCompletion ?? this.weekCompletion,
      lastAccessed: lastAccessed ?? this.lastAccessed,
      currentWeek: currentWeek ?? this.currentWeek,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'weekCompletion': weekCompletion.map((key, value) => MapEntry(key.toString(), value)),
      'lastAccessed': lastAccessed.toIso8601String(),
      'currentWeek': currentWeek,
    };
  }

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      courseId: json['courseId'] as String,
      weekCompletion: (json['weekCompletion'] as Map<String, dynamic>)
          .map((key, value) => MapEntry(int.parse(key), value as bool)),
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
      currentWeek: json['currentWeek'] as int,
    );
  }
}

class VerseKJV {
  final String ref;
  final String text;

  VerseKJV({
    required this.ref,
    required this.text,
  });

  factory VerseKJV.fromJson(Map<String, dynamic> json) {
    return VerseKJV(
      ref: json['ref'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ref': ref,
      'text': text,
    };
  }
}

class Unlock {
  final String title;
  final List<VerseKJV> versesKJV;
  final String insight;
  final List<String> deeperTruths;

  Unlock({
    required this.title,
    required this.versesKJV,
    required this.insight,
    required this.deeperTruths,
  });

  factory Unlock.fromJson(Map<String, dynamic> json) {
    return Unlock(
      title: json['title'] as String,
      versesKJV: (json['versesKJV'] as List)
          .map((verseJson) => VerseKJV.fromJson(verseJson as Map<String, dynamic>))
          .toList(),
      insight: json['insight'] as String,
      deeperTruths: List<String>.from(json['deeperTruths'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'versesKJV': versesKJV.map((verse) => verse.toJson()).toList(),
      'insight': insight,
      'deeperTruths': deeperTruths,
    };
  }
}
