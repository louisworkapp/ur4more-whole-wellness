import '../models/mind_coach_copy.dart';
import '../../../services/faith_service.dart';

/// Service for managing Mind Coach exercises
class MindExercisesService {
  /// Get all available exercises for a given faith mode
  static List<Exercise> mindExercises(FaithMode mode) {
    return [
      Exercise(
        id: "thought_record",
        title: "Thought Record",
        descriptionOff: "Capture the situation, automatic thought, emotion, and evidence. Then reframe.",
        descriptionFaith: mode.isActivated ? "Optionally add a verse or identity statement as your anchor." : null,
        icon: "psychology",
        estimatedMinutes: 10,
        tags: ["CBT", "reframing", "evidence"],
      ),
      Exercise(
        id: "breathing",
        title: "Box Breathing",
        descriptionOff: "4-4-4-4 breathing pattern to calm your nervous system.",
        descriptionFaith: mode.isActivated ? "Combine with a calming verse or prayer." : null,
        icon: "air",
        estimatedMinutes: 5,
        tags: ["breathing", "calm", "grounding"],
      ),
      Exercise(
        id: "values_clarification",
        title: "Values Clarification",
        descriptionOff: "Identify your core values and how they guide your decisions.",
        descriptionFaith: mode.isActivated ? "Connect your values to your faith and purpose." : null,
        icon: "favorite",
        estimatedMinutes: 15,
        tags: ["values", "purpose", "decision-making"],
      ),
      Exercise(
        id: "implementation_intention",
        title: "Implementation Intention",
        descriptionOff: "Create specific if-then plans for challenging situations.",
        descriptionFaith: mode.isActivated ? "Include faith-based responses when appropriate." : null,
        icon: "event_note",
        estimatedMinutes: 8,
        tags: ["planning", "habits", "preparation"],
      ),
      Exercise(
        id: "mindful_observation",
        title: "Mindful Observation",
        descriptionOff: "Practice present-moment awareness without judgment.",
        descriptionFaith: mode.isActivated ? "Notice God's presence in the present moment." : null,
        icon: "visibility",
        estimatedMinutes: 7,
        tags: ["mindfulness", "present", "awareness"],
      ),
      Exercise(
        id: "gratitude_practice",
        title: "Gratitude Practice",
        descriptionOff: "Write down three things you're grateful for today.",
        descriptionFaith: mode.isActivated ? "Include gratitude for God's blessings and presence." : null,
        icon: "sentiment_satisfied",
        estimatedMinutes: 5,
        tags: ["gratitude", "positivity", "wellbeing"],
      ),
    ];
  }

  /// Get exercises filtered by tags
  static List<Exercise> getExercisesByTags(FaithMode mode, List<String> tags) {
    return mindExercises(mode).where((exercise) {
      return tags.any((tag) => exercise.tags.contains(tag));
    }).toList();
  }

  /// Get quick exercises (under 10 minutes)
  static List<Exercise> getQuickExercises(FaithMode mode) {
    return mindExercises(mode).where((exercise) {
      return exercise.estimatedMinutes < 10;
    }).toList();
  }

  /// Get exercises for high urge situations
  static List<Exercise> getUrgeExercises(FaithMode mode) {
    if (mode.isOff) {
      return getExercisesByTags(mode, ["breathing", "grounding", "calm"]);
    } else {
      return getExercisesByTags(mode, ["breathing", "grounding", "calm", "faith"]);
    }
  }
}

/// Service for managing Mind Coach courses
class MindCoursesService {
  /// Get available courses for a given faith mode
  static List<CourseTile> getCourses(FaithMode mode) {
    final courses = <CourseTile>[
      CourseTile(
        id: "cog_foundations_8w",
        title: "Cognitive Foundations (8 Weeks)",
        subtitle: "Restructure thinking, build resilience, act on values.",
        xp: 120, // per week, secular track
        gates: const {}, // always visible
      ),
    ];

    // Add Discipleship course if faith is activated
    if (mode.isActivated) {
      courses.add(
        CourseTile(
          id: "discipleship_12w",
          title: "Discipleship — 12 Weeks",
          subtitle: "Grace, renewal, union with Christ, mission.",
          xp: 150,
          gates: const {"faith_mode": ["Light", "Disciple", "KingdomBuilder"]},
          deepLink: "/spirit/discipleship_12w",
        ),
      );
    }

    return courses;
  }

  /// Get course by ID
  static CourseTile? getCourseById(String id, FaithMode mode) {
    return getCourses(mode).where((course) => course.id == id).firstOrNull;
  }
}
