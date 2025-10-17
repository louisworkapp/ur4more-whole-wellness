
/// 4-tier Faith Mode system with XP progression
enum FaithTier { off, light, disciple, kingdomBuilder }

extension FaithTierExtension on FaithTier {
  static FaithTier fromString(String value) {
    switch (value.toLowerCase()) {
      case 'off':
        return FaithTier.off;
      case 'light':
        return FaithTier.light;
      case 'disciple':
        return FaithTier.disciple;
      case 'kingdombuilder':
      case 'kingdom_builder':
        return FaithTier.kingdomBuilder;
      default:
        return FaithTier.off;
    }
  }

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
}

/// Represents a single course lesson.
class Lesson {
  final int week;
  final String title;
  final String objective;
  final List<String> practice;

  Lesson({
    required this.week,
    required this.title,
    required this.objective,
    required this.practice,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      week: json['week'] as int,
      title: json['title'] as String,
      objective: json['objective'] as String,
      practice: List<String>.from(json['practice'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'week': week,
      'title': title,
      'objective': objective,
      'practice': practice,
    };
  }
}

/// Represents a course, either external or in-app.
class Course {
  final String id;
  final String title;
  final String provider;
  final String url;
  final List<String> format;
  final String duration;
  final String cost;
  final List<String> tiers;
  final List<String> tags;
  final String summary;
  final bool brandSafe;
  final String licenseNotes;

  const Course({
    required this.id,
    required this.title,
    required this.provider,
    required this.url,
    required this.format,
    required this.duration,
    required this.cost,
    required this.tiers,
    required this.tags,
    required this.summary,
    required this.brandSafe,
    required this.licenseNotes,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'] as String,
      title: json['title'] as String,
      provider: json['provider'] as String,
      url: json['url'] as String,
      format: List<String>.from(json['format'] as List),
      duration: json['duration'] as String,
      cost: json['cost'] as String,
      tiers: List<String>.from(json['tiers'] as List),
      tags: List<String>.from(json['tags'] as List),
      summary: json['summary'] as String,
      brandSafe: json['brandSafe'] as bool,
      licenseNotes: json['licenseNotes'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'provider': provider,
      'url': url,
      'format': format,
      'duration': duration,
      'cost': cost,
      'tiers': tiers,
      'tags': tags,
      'summary': summary,
      'brandSafe': brandSafe,
      'licenseNotes': licenseNotes,
    };
  }

  bool isVisibleForTier(FaithTier tier) {
    final tierString = tier.toString().split('.').last;
    return tiers.contains(tierString);
  }

  bool isExternal() => url.isNotEmpty;
  bool isFirstParty() => !isExternal();
}


class CourseProgress {
  final String courseId;
  final double progress; // 0.0 to 1.0
  final int currentWeek;
  final bool hasStarted;
  final DateTime lastAccessed;

  const CourseProgress({
    required this.courseId,
    required this.progress,
    required this.currentWeek,
    required this.hasStarted,
    required this.lastAccessed,
  });

  factory CourseProgress.fromJson(Map<String, dynamic> json) {
    return CourseProgress(
      courseId: json['courseId'] as String,
      progress: (json['progress'] as num).toDouble(),
      currentWeek: json['currentWeek'] as int,
      hasStarted: json['hasStarted'] as bool,
      lastAccessed: DateTime.parse(json['lastAccessed'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'progress': progress,
      'currentWeek': currentWeek,
      'hasStarted': hasStarted,
      'lastAccessed': lastAccessed.toIso8601String(),
    };
  }
}
