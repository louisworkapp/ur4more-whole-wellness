import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ExerciseProgressionService {
  static const String _completedExercisesKey = 'completed_exercises';
  
  /// Mark an exercise as completed
  static Future<void> markExerciseCompleted(String exerciseId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedJson = prefs.getString(_completedExercisesKey) ?? '[]';
    final completed = List<String>.from(json.decode(completedJson));
    
    if (!completed.contains(exerciseId)) {
      completed.add(exerciseId);
      await prefs.setString(_completedExercisesKey, json.encode(completed));
    }
  }
  
  /// Check if an exercise is completed
  static Future<bool> isExerciseCompleted(String exerciseId) async {
    final prefs = await SharedPreferences.getInstance();
    final completedJson = prefs.getString(_completedExercisesKey) ?? '[]';
    final completed = List<String>.from(json.decode(completedJson));
    return completed.contains(exerciseId);
  }
  
  /// Check if all prerequisites are met for an exercise
  static Future<bool> arePrerequisitesMet(List<String> prerequisites) async {
    if (prerequisites.isEmpty) return true;
    
    for (final prerequisite in prerequisites) {
      if (!await isExerciseCompleted(prerequisite)) {
        return false;
      }
    }
    return true;
  }
  
  /// Get all completed exercises
  static Future<List<String>> getCompletedExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final completedJson = prefs.getString(_completedExercisesKey) ?? '[]';
    return List<String>.from(json.decode(completedJson));
  }
  
  /// Clear all progress (for testing/reset)
  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_completedExercisesKey);
  }
}
