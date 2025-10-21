import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/urge_theme_model.dart';

/// Repository for loading and managing urge theme data using the unified schema
class UrgeThemesRepository {
  static UrgeThemesData? _cachedData;

  /// Load all urge theme data (common, biblical, and actions)
  static Future<UrgeThemesData> load() async {
    if (_cachedData != null) return _cachedData!;

    try {
      // Load actions catalog
      final actionsJson = await rootBundle.loadString('assets/mind/urge/actions.catalog.json');
      final actionsData = json.decode(actionsJson) as Map<String, dynamic>;
      final actionsMap = <String, UrgeAction>{};
      
      final actions = actionsData['actions'] as Map<String, dynamic>;
      for (final entry in actions.entries) {
        actionsMap[entry.key] = UrgeAction.fromJson(entry.value as Map<String, dynamic>);
      }

      // Load common themes
      final commonJson = await rootBundle.loadString('assets/mind/urge/themes.common.json');
      final commonData = json.decode(commonJson) as Map<String, dynamic>;
      final commonThemes = <String, UrgeTheme>{};
      
      final themes = commonData['themes'] as Map<String, dynamic>;
      for (final entry in themes.entries) {
        commonThemes[entry.key] = UrgeTheme.fromJson(entry.value as Map<String, dynamic>);
      }

      // Load biblical themes
      final biblicalJson = await rootBundle.loadString('assets/mind/urge/themes.biblical.json');
      final biblicalData = json.decode(biblicalJson) as Map<String, dynamic>;
      final biblicalThemes = <String, UrgeTheme>{};
      
      final biblicalThemesData = biblicalData['themes'] as Map<String, dynamic>;
      for (final entry in biblicalThemesData.entries) {
        biblicalThemes[entry.key] = UrgeTheme.fromJson(entry.value as Map<String, dynamic>);
      }

      _cachedData = UrgeThemesData(
        commonThemes: commonThemes,
        biblicalThemes: biblicalThemes,
        actions: actionsMap,
      );

      return _cachedData!;
    } catch (e) {
      print('Error loading urge themes: $e');
      rethrow;
    }
  }

  /// Get a specific theme by ID
  static Future<UrgeTheme?> getTheme(String themeId) async {
    final data = await load();
    return data.getAllThemes()[themeId];
  }

  /// Get themes for a specific category
  static Future<Map<String, UrgeTheme>> getThemesByCategory(bool isBiblical) async {
    final data = await load();
    return data.getThemesByCategory(isBiblical);
  }

  /// Get an action by ID
  static Future<UrgeAction?> getAction(String actionId) async {
    final data = await load();
    return data.getAction(actionId);
  }

  /// Get actions for a theme and intensity level
  static Future<List<UrgeAction>> getActionsForThemeAndIntensity(
    String themeId, 
    double intensity,
  ) async {
    final data = await load();
    final theme = data.getAllThemes()[themeId];
    if (theme == null) return [];

    final actionIds = theme.actions.getActionsForIntensity(intensity);
    final actions = <UrgeAction>[];
    
    for (final actionId in actionIds) {
      final action = data.getAction(actionId);
      if (action != null) {
        actions.add(action);
      }
    }

    return actions;
  }

  /// Get prompts for a theme based on faith mode
  static Future<List<String>> getPromptsForTheme(
    String themeId, 
    bool isFaithActivated,
  ) async {
    final data = await load();
    final theme = data.getAllThemes()[themeId];
    if (theme == null) return [];

    return theme.prompts.getPromptsForFaithMode(isFaithActivated);
  }

  /// Get passages for a theme (only if faith is activated)
  static Future<List<BiblePassage>> getPassagesForTheme(
    String themeId,
    bool isFaithActivated,
  ) async {
    final data = await load();
    final theme = data.getAllThemes()[themeId];
    if (theme == null) return [];

    // Only return passages if faith is activated
    return isFaithActivated ? theme.passages : [];
  }

  /// Clear cached data (useful for testing or hot reload)
  static void clearCache() {
    _cachedData = null;
  }
}
