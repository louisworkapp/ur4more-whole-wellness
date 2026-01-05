import '../models/mind_coach_copy.dart';
import '../../../services/faith_service.dart';
import '../exercises/exercise_registry.dart';
import '../exercises/exercise_model.dart' as new_exercises;

/// Service for managing Mind Coach exercises
class MindExercisesService {
  /// Get all available exercises for a given faith mode
  static Future<List<Exercise>> mindExercises(FaithTier mode) async {
    final exercises = <Exercise>[
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
    
    // Add new evidence-based exercises
    exercises.addAll(await _getNewExercises(mode));
    
    return exercises;
  }

  /// Get new evidence-based exercises from registry
  static Future<List<Exercise>> _getNewExercises(FaithTier mode) async {
    try {
      print('DEBUG: Loading new exercises from registry...');
      final newExercises = await ExerciseRegistry.list();
      print('DEBUG: Loaded ${newExercises.length} new exercises: ${newExercises.map((e) => e.id).toList()}');
      final converted = newExercises.map((ne) => _convertNewExercise(ne, mode)).toList();
      print('DEBUG: Converted ${converted.length} exercises');
      return converted;
    } catch (e) {
      // If loading fails, return empty list
      print('DEBUG: Error loading new exercises: $e');
      return [];
    }
  }

  /// Convert new exercise model to existing exercise model
  static Exercise _convertNewExercise(new_exercises.Exercise ne, FaithTier mode) {
    String? descriptionFaith;
    if (mode.isActivated) {
      // Get appropriate overlay based on faith mode
      final overlay = mode == FaithTier.disciple 
          ? ne.overlays.disciple 
          : mode == FaithTier.kingdom 
              ? ne.overlays.kingdom 
              : ne.overlays.light;
      
      if (overlay.prompt != null || overlay.verseKJV.isNotEmpty) {
        final parts = <String>[];
        if (overlay.prompt != null) parts.add(overlay.prompt!);
        if (overlay.verseKJV.isNotEmpty) {
          final verse = overlay.verseKJV.first;
          parts.add('"${verse['text']}" — ${verse['ref']} (KJV)');
        }
        descriptionFaith = parts.join(' ');
      }
    }

    return Exercise(
      id: ne.id,
      title: ne.title,
      descriptionOff: ne.summary,
      descriptionFaith: descriptionFaith,
      icon: _getIconForExercise(ne.id),
      estimatedMinutes: ne.durationMinutes,
      tags: ne.tags,
    );
  }

  /// Get appropriate icon for exercise ID
  static String _getIconForExercise(String id) {
    switch (id) {
      case 'urge_surfing':
        return 'psychology';
      case 'worry_postpone':
        return 'event_note';
      case 'grounding_54321':
        return 'visibility';
      case 'pmr_short':
        return 'air';
      case 'defusion_label':
        return 'psychology';
      case 'tiny_wins':
        return 'sentiment_satisfied';
      default:
        return 'psychology';
    }
  }

  /// Get exercises filtered by tags
  static Future<List<Exercise>> getExercisesByTags(FaithTier mode, List<String> tags) async {
    final exercises = await mindExercises(mode);
    return exercises.where((exercise) {
      return tags.any((tag) => exercise.tags.contains(tag));
    }).toList();
  }

  /// Get quick exercises (under 10 minutes)
  static Future<List<Exercise>> getQuickExercises(FaithTier mode) async {
    final exercises = await mindExercises(mode);
    return exercises.where((exercise) {
      return exercise.estimatedMinutes < 10;
    }).toList();
  }

  /// Get exercises for high urge situations
  static Future<List<Exercise>> getUrgeExercises(FaithTier mode) async {
    if (mode.isOff) {
      return await getExercisesByTags(mode, ["breathing", "grounding", "calm"]);
    } else {
      return await getExercisesByTags(mode, ["breathing", "grounding", "calm", "faith"]);
    }
  }
}

/// Service for managing Mind Coach courses
class MindCoursesService {
  /// Get available courses for a given faith mode
  static List<CourseTile> getCourses(FaithTier mode) {
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
  static CourseTile? getCourseById(String id, FaithTier mode) {
    return getCourses(mode).where((course) => course.id == id).firstOrNull;
  }
}
