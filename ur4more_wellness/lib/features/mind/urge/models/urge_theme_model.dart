/// Data models for the unified urge theme schema
class UrgeTheme {
  final String label;
  final String icon;
  final List<BiblePassage> passages;
  final UrgeActions actions;
  final UrgePrompts prompts;

  const UrgeTheme({
    required this.label,
    required this.icon,
    required this.passages,
    required this.actions,
    required this.prompts,
  });

  factory UrgeTheme.fromJson(Map<String, dynamic> json) {
    return UrgeTheme(
      label: json['label'] as String,
      icon: json['icon'] as String,
      passages: (json['passages'] as List<dynamic>?)
          ?.map((p) => BiblePassage.fromJson(p as Map<String, dynamic>))
          .toList() ?? [],
      actions: UrgeActions.fromJson(json['actions'] as Map<String, dynamic>),
      prompts: UrgePrompts.fromJson(json['prompts'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'icon': icon,
      'passages': passages.map((p) => p.toJson()).toList(),
      'actions': actions.toJson(),
      'prompts': prompts.toJson(),
    };
  }
}

class BiblePassage {
  final String ref;
  final List<BibleVerse> verses;
  final String actNow;

  const BiblePassage({
    required this.ref,
    required this.verses,
    required this.actNow,
  });

  factory BiblePassage.fromJson(Map<String, dynamic> json) {
    return BiblePassage(
      ref: json['ref'] as String,
      verses: (json['verses'] as List<dynamic>?)
          ?.map((v) => BibleVerse.fromJson(v as Map<String, dynamic>))
          .toList() ?? [],
      actNow: json['actNow'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ref': ref,
      'verses': verses.map((v) => v.toJson()).toList(),
      'actNow': actNow,
    };
  }
}

class BibleVerse {
  final int v; // verse number
  final String t; // verse text

  const BibleVerse({
    required this.v,
    required this.t,
  });

  factory BibleVerse.fromJson(Map<String, dynamic> json) {
    return BibleVerse(
      v: json['v'] as int,
      t: json['t'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'v': v,
      't': t,
    };
  }
}

class UrgeActions {
  final List<String> low;
  final List<String> mid;
  final List<String> high;

  const UrgeActions({
    required this.low,
    required this.mid,
    required this.high,
  });

  factory UrgeActions.fromJson(Map<String, dynamic> json) {
    return UrgeActions(
      low: (json['low'] as List<dynamic>).cast<String>(),
      mid: (json['mid'] as List<dynamic>).cast<String>(),
      high: (json['high'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'low': low,
      'mid': mid,
      'high': high,
    };
  }

  /// Get actions for a given intensity level
  List<String> getActionsForIntensity(double intensity) {
    if (intensity >= 7) return high;
    if (intensity >= 4) return mid;
    return low;
  }
}

class UrgePrompts {
  final List<String> secular;
  final List<String> faith;

  const UrgePrompts({
    required this.secular,
    required this.faith,
  });

  factory UrgePrompts.fromJson(Map<String, dynamic> json) {
    return UrgePrompts(
      secular: (json['secular'] as List<dynamic>).cast<String>(),
      faith: (json['faith'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'secular': secular,
      'faith': faith,
    };
  }

  /// Get prompts based on faith mode
  List<String> getPromptsForFaithMode(bool isFaithActivated) {
    return isFaithActivated ? faith : secular;
  }
}

/// Action catalog entry
class UrgeAction {
  final String title;
  final String body;

  const UrgeAction({
    required this.title,
    required this.body,
  });

  factory UrgeAction.fromJson(Map<String, dynamic> json) {
    return UrgeAction(
      title: json['title'] as String,
      body: json['body'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'body': body,
    };
  }
}

/// Container for all urge themes
class UrgeThemesData {
  final Map<String, UrgeTheme> commonThemes;
  final Map<String, UrgeTheme> biblicalThemes;
  final Map<String, UrgeAction> actions;

  const UrgeThemesData({
    required this.commonThemes,
    required this.biblicalThemes,
    required this.actions,
  });

  /// Get all themes combined
  Map<String, UrgeTheme> getAllThemes() {
    return {...commonThemes, ...biblicalThemes};
  }

  /// Get themes by category
  Map<String, UrgeTheme> getThemesByCategory(bool isBiblical) {
    return isBiblical ? biblicalThemes : commonThemes;
  }

  /// Get action by ID
  UrgeAction? getAction(String actionId) {
    return actions[actionId];
  }
}
