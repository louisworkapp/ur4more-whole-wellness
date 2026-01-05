import '../../../services/faith_service.dart';

/// Content templates for Mind Coach based on faith mode
class MindCoachCopy {
  final String greeting;
  final String nudgeSmallStep;
  final String reframeIntro;
  final String? faithOptional; // null in OFF mode

  const MindCoachCopy({
    required this.greeting,
    required this.nudgeSmallStep,
    required this.reframeIntro,
    this.faithOptional,
  });

  /// Get copy for specific faith mode
  static MindCoachCopy copyFor(FaithTier mode) {
    if (mode.isOff) {
      return const MindCoachCopy(
        greeting: "I'm your Mind Coach. We'll use evidence-based tools to steady your thoughts.",
        reframeIntro: "Let's catch the thought, test the evidence, and craft a balanced reframe.",
        nudgeSmallStep: "What's one tiny step you can take in the next 10 minutes?",
      );
    }
    
    // Activated modes
    return const MindCoachCopy(
      greeting: "I'm your Mind Coach. We'll steady your thoughts and, if you wish, invite God into the process.",
      reframeIntro: "Let's test the thought against truth and craft a faith-filled, balanced reframe.",
      nudgeSmallStep: "What's one faithful step you can take in the next 10 minutes?",
      faithOptional: "Would you like a short verse or prayer added?",
    );
  }
}

/// Exercise model for Mind Coach
class Exercise {
  final String id;
  final String title;
  final String descriptionOff;
  final String? descriptionFaith; // optional enrichment for faith modes
  final String icon;
  final int estimatedMinutes;
  final List<String> tags;

  const Exercise({
    required this.id,
    required this.title,
    required this.descriptionOff,
    this.descriptionFaith,
    required this.icon,
    required this.estimatedMinutes,
    required this.tags,
  });

  /// Get description based on faith mode
  String getDescription(FaithTier mode) {
    if (mode.isActivated && descriptionFaith != null) {
      return '$descriptionOff $descriptionFaith';
    }
    return descriptionOff;
  }
}

/// Course model for Mind Coach
class CourseTile {
  final String id;
  final String title;
  final String subtitle;
  final int xp;
  final Map<String, List<String>> gates;
  final String? deepLink;

  const CourseTile({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.xp,
    required this.gates,
    this.deepLink,
  });

  /// Check if course is available for given faith mode
  bool isAvailableFor(FaithTier mode) {
    if (gates.isEmpty) return true;
    
    final faithGates = gates['faith_mode'];
    if (faithGates == null) return true;
    
    final modeString = _faithModeToString(mode);
    return faithGates.contains(modeString);
  }

  String _faithModeToString(FaithTier mode) {
    switch (mode) {
      case FaithTier.off:
        return 'Off';
      case FaithTier.light:
        return 'Light';
      case FaithTier.disciple:
        return 'Disciple';
      case FaithTier.kingdom:
        return 'KingdomBuilder';
    }
  }
}
