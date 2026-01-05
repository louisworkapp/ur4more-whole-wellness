import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course_models.dart';
import '../../../core/settings/settings_model.dart';

class CourseRepository {
  static const String _progressKeyPrefix = 'course:ur4more_core_12w:week:';
  static const String _progressPercentageKey = 'course:ur4more_core_12w:progress';
  static const String _lastWeekKey = 'course:ur4more_core_12w:lastWeek';
  static const String _courseProgressKey = 'course:ur4more_core_12w:progress_data';
  static const String _unlockKeyPrefix = 'course:ur4more_core_12w:week:';
  
  // Toggle for testing - set to false to unlock all weeks
  static const bool kLockSequential = true;

  /// Load the core discipleship course from assets
  Future<Course> loadCoreFromAssets(BuildContext context) async {
    try {
      final String jsonString = await rootBundle.loadString('assets/courses/discipleship_12w.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return Course.fromJson(jsonData);
    } catch (e) {
      print('Error loading course from assets: $e');
      rethrow;
    }
  }

  /// Get weeks visible for a given faith tier
  List<Week> visibleWeeksForTier(FaithTier tier, List<Week> allWeeks) {
    switch (tier) {
      case FaithTier.off:
        return [];
      case FaithTier.light:
        return allWeeks.where((week) => week.requiredTier == FaithTier.light).toList();
      case FaithTier.disciple:
      case FaithTier.kingdom:
        return allWeeks;
    }
  }

  /// Check if a specific week is unlocked for the user
  bool isWeekUnlocked(int week, FaithTier tier, CourseProgress progress) {
    // Check tier requirements first
    final weekData = _getWeekData(week);
    if (weekData != null && tier.index < weekData.requiredTier.index) {
      return false;
    }

    // If sequential locking is disabled, all weeks are unlocked (except tier restrictions)
    if (!kLockSequential) {
      return true;
    }

    // Sequential unlocking: Week 1 is always unlocked
    if (week == 1) return true;

    // Week N+1 is unlocked only if Week N is completed
    return progress.isWeekComplete(week - 1);
  }

  /// Get week data by week number (helper method)
  Week? _getWeekData(int week) {
    // This would typically come from the loaded course
    // For now, we'll use a simple mapping
    if (week <= 2) return null; // Weeks 1-2 are Light tier
    return null; // All other weeks are Disciple+ tier
  }

  /// Check if a week is gated for a specific faith tier
  bool isWeekGatedForTier(int week, FaithTier tier, Course course) {
    if (tier != FaithTier.off || course.gate?.offTierHardGateWeek == null) {
      return false;
    }
    
    return week >= course.gate!.offTierHardGateWeek!;
  }

  /// Mark a week as complete
  Future<void> persistWeekComplete(int week, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_progressKeyPrefix$week:done';
    
    if (value) {
      await prefs.setBool(key, true);
    } else {
      await prefs.remove(key);
    }
    
    // Update progress percentage
    await _updateProgressPercentage();
    
    // Update last week accessed
    if (value) {
      await prefs.setInt(_lastWeekKey, week);
    }
  }

  /// Check if a week is complete
  Future<bool> isWeekComplete(int week) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_progressKeyPrefix$week:done';
    return prefs.getBool(key) ?? false;
  }

  /// Get overall progress percentage (0.0 to 1.0)
  Future<double> percentComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_progressPercentageKey) ?? 0.0;
  }

  /// Get the current week (next incomplete week)
  Future<int> currentWeek() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lastWeekKey) ?? 1;
  }

  /// Update progress percentage based on completed weeks
  Future<void> _updateProgressPercentage() async {
    final prefs = await SharedPreferences.getInstance();
    int completedWeeks = 0;
    
    for (int week = 1; week <= 12; week++) {
      final key = '$_progressKeyPrefix$week:done';
      if (prefs.getBool(key) ?? false) {
        completedWeeks++;
      }
    }
    
    final percentage = completedWeeks / 12;
    await prefs.setDouble(_progressPercentageKey, percentage);
  }

  /// Get complete course progress
  Future<CourseProgress> getCourseProgress(String courseId) async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_courseProgressKey);
    
    if (progressJson != null) {
      try {
        final Map<String, dynamic> json = jsonDecode(progressJson);
        return CourseProgress.fromJson(json);
      } catch (e) {
        print('Error parsing course progress: $e');
      }
    }
    
    // Return empty progress if none exists
    return CourseProgress.empty(courseId);
  }

  /// Save complete course progress
  Future<void> saveCourseProgress(CourseProgress progress) async {
    final prefs = await SharedPreferences.getInstance();
    final progressJson = jsonEncode(progress.toJson());
    await prefs.setString(_courseProgressKey, progressJson);
  }

  /// Mark a week as complete and update progress
  Future<void> markWeekComplete(int week) async {
    await persistWeekComplete(week, true);
    
    // Update the complete course progress
    final progress = await getCourseProgress('ur4more_core_12w');
    final updatedWeekCompletion = Map<int, bool>.from(progress.weekCompletion);
    updatedWeekCompletion[week] = true;
    
    final updatedProgress = progress.copyWith(
      weekCompletion: updatedWeekCompletion,
      currentWeek: week + 1 > 12 ? 12 : week + 1,
      lastAccessed: DateTime.now(),
    );
    
    await saveCourseProgress(updatedProgress);
  }

  /// Get next incomplete week
  Future<int> getNextIncompleteWeek() async {
    for (int week = 1; week <= 12; week++) {
      if (!(await isWeekComplete(week))) {
        return week;
      }
    }
    return 12; // All weeks completed
  }

  /// Check if course is completed
  Future<bool> isCourseCompleted() async {
    for (int week = 1; week <= 12; week++) {
      if (!(await isWeekComplete(week))) {
        return false;
      }
    }
    return true;
  }

  /// Reset all progress (for testing)
  Future<void> resetProgress() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove all week completion keys
    for (int week = 1; week <= 12; week++) {
      final key = '$_progressKeyPrefix$week:done';
      await prefs.remove(key);
    }
    
    // Remove progress keys
    await prefs.remove(_progressPercentageKey);
    await prefs.remove(_lastWeekKey);
    await prefs.remove(_courseProgressKey);
  }

  /// Get week completion status for all weeks
  Future<Map<int, bool>> getAllWeekCompletion() async {
    final prefs = await SharedPreferences.getInstance();
    final Map<int, bool> completion = {};
    
    for (int week = 1; week <= 12; week++) {
      final key = '$_progressKeyPrefix$week:done';
      completion[week] = prefs.getBool(key) ?? false;
    }
    
    return completion;
  }

  /// Get formatted progress text
  Future<String> getProgressText() async {
    final completedWeeks = (await getAllWeekCompletion())
        .values
        .where((completed) => completed)
        .length;
    return '$completedWeeks of 12 weeks completed';
  }

  /// Get courses for a specific faith tier
  Future<List<Course>> getCoursesForTier(FaithTier tier) async {
    // For now, return the UR4MORE Core course if tier allows it
    if (tier == FaithTier.off) {
      return [];
    }
    
    final course = await getUr4moreCoreData();
    return [course];
  }

  /// Get course by ID
  Future<Course?> getCourseById(String courseId) async {
    if (courseId == 'ur4more_core_12w' || courseId == 'ur4more_core_12wk') {
      return await getUr4moreCoreData();
    }
    return null;
  }

  /// Get UR4MORE Core course data
  Future<Course> getUr4moreCoreData() async {
    // Create a mock BuildContext for loading assets
    // In a real app, you'd pass the context from the calling widget
    try {
      final String jsonString = await rootBundle.loadString('assets/courses/discipleship_12w.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return Course.fromJson(jsonData);
    } catch (e) {
      print('Error loading UR4MORE Core course: $e');
      // Return a default course if loading fails
      return Course(
        id: 'ur4more_core_12w',
        title: 'UR4MORE Discipleship Core (12 Weeks)',
        description: 'A comprehensive 12-week discipleship journey',
        summary: 'Transform your spiritual life through this foundational discipleship course',
        provider: 'UR4MORE',
        duration: '12 weeks',
        cost: 'Free',
        format: ['Self-paced'],
        tags: ['foundations', 'discipleship'],
        weeks: [],
      );
    }
  }

  /// Update course progress
  Future<void> updateCourseProgress(String courseId, int week, bool completed) async {
    if (completed) {
      await markWeekComplete(week);
    } else {
      await persistWeekComplete(week, false);
    }
  }

  /// Check if a week's unlock content is unlocked
  Future<bool> isWeekUnlock(int week) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_unlockKeyPrefix$week:unlock';
    return prefs.getBool(key) ?? false;
  }

  /// Set a week's unlock content as unlocked
  Future<void> setWeekUnlock(int week, bool unlocked) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_unlockKeyPrefix$week:unlock';
    
    if (unlocked) {
      await prefs.setBool(key, true);
    } else {
      await prefs.remove(key);
    }
  }

  /// Reset all unlock states (for testing)
  Future<void> resetUnlockStates() async {
    final prefs = await SharedPreferences.getInstance();
    
    for (int week = 1; week <= 12; week++) {
      final key = '$_unlockKeyPrefix$week:unlock';
      await prefs.remove(key);
    }
  }
}