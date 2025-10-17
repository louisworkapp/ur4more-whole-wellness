import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/course.dart';

class CourseRepository {
  static const String _coursesAssetPath = 'assets/data/courses_seed.json';
  static const String _ur4moreCoreAssetPath = 'assets/data/ur4more_core_12wk.json';
  static const String _progressPrefix = 'course:';

  List<Course>? _cachedCourses;
  Map<String, dynamic>? _ur4moreCoreData;

  Future<List<Course>> getAllCourses() async {
    if (_cachedCourses != null) {
      return _cachedCourses!;
    }

    try {
      final String jsonString = await rootBundle.loadString(_coursesAssetPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> coursesJson = jsonData['courses'] as List<dynamic>;

      _cachedCourses = coursesJson
          .map((json) => Course.fromJson(json as Map<String, dynamic>))
          .toList();

      return _cachedCourses!;
    } catch (e) {
      print('Error loading courses: $e');
      return [];
    }
  }

  Future<List<Course>> getCoursesForTier(FaithTier tier) async {
    final allCourses = await getAllCourses();
    
    return allCourses.where((course) {
      return course.isVisibleForTier(tier);
    }).toList();
  }

  Future<List<Course>> getFilteredCourses({
    required FaithTier tier,
    String? searchQuery,
    List<String>? formatFilters,
    bool? freeOnly,
  }) async {
    var courses = await getCoursesForTier(tier);

    // Apply search filter
    if (searchQuery != null && searchQuery.isNotEmpty) {
      courses = courses.where((course) {
        return course.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
               course.provider.toLowerCase().contains(searchQuery.toLowerCase()) ||
               course.tags.any((tag) => tag.toLowerCase().contains(searchQuery.toLowerCase()));
      }).toList();
    }

    // Apply format filters
    if (formatFilters != null && formatFilters.isNotEmpty) {
      courses = courses.where((course) {
        return formatFilters.any((filter) => course.format.contains(filter));
      }).toList();
    }

    // Apply free filter
    if (freeOnly == true) {
      courses = courses.where((course) {
        return course.cost.toLowerCase().contains('free');
      }).toList();
    }

    return courses;
  }

  Future<Course?> getCourseById(String id) async {
    final courses = await getAllCourses();
    try {
      return courses.firstWhere((course) => course.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUr4moreCoreData() async {
    if (_ur4moreCoreData != null) {
      return _ur4moreCoreData;
    }

    try {
      final String jsonString = await rootBundle.loadString(_ur4moreCoreAssetPath);
      _ur4moreCoreData = json.decode(jsonString) as Map<String, dynamic>;
      return _ur4moreCoreData!;
    } catch (e) {
      print('Error loading UR4MORE Core data: $e');
      return null;
    }
  }

  // Progress management
  Future<CourseProgress?> getCourseProgress(String courseId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressKey = '$_progressPrefix$courseId:progress';
      final weekKey = '$_progressPrefix$courseId:week';
      final lastAccessedKey = '$_progressPrefix$courseId:lastAccessed';

      final progress = prefs.getDouble(progressKey) ?? 0.0;
      final week = prefs.getInt(weekKey) ?? 0;
      final lastAccessedString = prefs.getString(lastAccessedKey);
      
      final lastAccessed = lastAccessedString != null 
          ? DateTime.parse(lastAccessedString)
          : DateTime.now();

      return CourseProgress(
        courseId: courseId,
        progress: progress.clamp(0.0, 1.0),
        currentWeek: week,
        hasStarted: progress > 0,
        lastAccessed: lastAccessed,
      );
    } catch (e) {
      print('Error loading course progress: $e');
      return null;
    }
  }

  Future<void> updateCourseProgress(String courseId, double progress, int week) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final progressKey = '$_progressPrefix$courseId:progress';
      final weekKey = '$_progressPrefix$courseId:week';
      final lastAccessedKey = '$_progressPrefix$courseId:lastAccessed';

      await prefs.setDouble(progressKey, progress.clamp(0.0, 1.0));
      await prefs.setInt(weekKey, week);
      await prefs.setString(lastAccessedKey, DateTime.now().toIso8601String());
    } catch (e) {
      print('Error updating course progress: $e');
    }
  }

  Future<void> markCourseStarted(String courseId) async {
    await updateCourseProgress(courseId, 0.01, 1); // Minimal progress to mark as started
  }

  // Helper methods for UI
  List<String> getAllFormats() {
    final formats = <String>{};
    _cachedCourses?.forEach((course) {
      formats.addAll(course.format);
    });
    return formats.toList()..sort();
  }

  List<String> getAllTags() {
    final tags = <String>{};
    _cachedCourses?.forEach((course) {
      tags.addAll(course.tags);
    });
    return tags.toList()..sort();
  }
}
