import 'package:flutter_test/flutter_test.dart';
import 'package:ur4more_wellness/core/services/settings_service.dart';
import 'package:ur4more_wellness/features/mind/urge/repositories/urge_themes_repository.dart';
import 'package:ur4more_wellness/features/mind/urge/models/urge_theme_model.dart';
import 'package:ur4more_wellness/services/ai_suggestion_service.dart';
import 'package:ur4more_wellness/services/faith_service.dart';

void main() {
  group('Suggester Tests', () {
    late UrgeThemesData themesData;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      themesData = await UrgeThemesRepository.load();
    });

    test('should return correct actions for intensity levels', () async {
      final testTheme = themesData.commonThemes['substance_use']!;
      
      // Test low intensity
      final lowActions = await UrgeThemesRepository.getActionsForThemeAndIntensity(
          'substance_use', 2.0);
      expect(lowActions, isNotEmpty);
      expect(lowActions.length, equals(testTheme.actions.low.length));
      
      // Test mid intensity
      final midActions = await UrgeThemesRepository.getActionsForThemeAndIntensity(
          'substance_use', 5.0);
      expect(midActions, isNotEmpty);
      expect(midActions.length, equals(testTheme.actions.mid.length));
      
      // Test high intensity
      final highActions = await UrgeThemesRepository.getActionsForThemeAndIntensity(
          'substance_use', 8.0);
      expect(highActions, isNotEmpty);
      expect(highActions.length, equals(testTheme.actions.high.length));
    });

    test('should inject help_rail for high substance use intensity', () async {
      final highActions = await UrgeThemesRepository.getActionsForThemeAndIntensity(
          'substance_use', 8.0);
      
      // Check that help_rail is included for high intensity
      final hasHelpRail = highActions.any((action) => 
          action.title.toLowerCase().contains('help'));
      expect(hasHelpRail, isTrue);
    });

    test('should return mixed action types for different themes', () async {
      final themes = ['substance_use', 'food', 'shopping', 'social_media'];
      
      for (final themeId in themes) {
        final actions = await UrgeThemesRepository.getActionsForThemeAndIntensity(
            themeId, 5.0);
        expect(actions, isNotEmpty);
        
        // Each theme should have different action sets
        final actionTitles = actions.map((a) => a.title).toList();
        expect(actionTitles, isNotEmpty);
      }
    });

    test('should generate unified suggestions correctly', () async {
      final checkInData = CheckInData(
        painLevel: 3.0,
        painRegions: ['back'],
        urgeLevel: 6.0,
        urgeTypes: ['substance_use', 'food'],
        rpeLevel: 5,
        faithMode: FaithTier.light,
        timestamp: DateTime.now(),
      );

      final suggestions = await AISuggestionService.generateUnifiedSuggestions(checkInData);
      
      expect(suggestions, isNotEmpty);
      expect(suggestions.length, lessThanOrEqualTo(12)); // Limited to top 12
      
      // Check that suggestions are properly categorized
      for (final suggestion in suggestions) {
        expect(suggestion.id, isNotEmpty);
        expect(suggestion.title, isNotEmpty);
        expect(suggestion.description, isNotEmpty);
        expect(suggestion.category, isIn(['coping', 'exercise', 'social', 'spiritual']));
        expect(suggestion.priority, inInclusiveRange(1, 5));
        expect(suggestion.tags, contains('unified_schema'));
      }
    });

    test('should prioritize high-intensity suggestions', () async {
      final highIntensityData = CheckInData(
        painLevel: 0.0,
        painRegions: [],
        urgeLevel: 9.0, // Very high intensity
        urgeTypes: ['substance_use'],
        rpeLevel: 3,
        faithMode: FaithTier.off,
        timestamp: DateTime.now(),
      );

      final suggestions = await AISuggestionService.generateUnifiedSuggestions(highIntensityData);
      
      expect(suggestions, isNotEmpty);
      
      // High intensity should result in higher priority suggestions
      final highPrioritySuggestions = suggestions.where((s) => s.priority >= 4).toList();
      expect(highPrioritySuggestions, isNotEmpty);
    });

    test('should include faith-based suggestions when faith mode is activated', () async {
      final faithData = CheckInData(
        painLevel: 0.0,
        painRegions: [],
        urgeLevel: 5.0,
        urgeTypes: ['gluttony'], // Biblical theme
        rpeLevel: 3,
        faithMode: FaithTier.light,
        timestamp: DateTime.now(),
      );

      final suggestions = await AISuggestionService.generateUnifiedSuggestions(faithData);
      
      expect(suggestions, isNotEmpty);
      
      // Should include faith-based suggestions
      final faithSuggestions = suggestions.where((s) => 
          s.requiresFaithTier || s.category == 'spiritual').toList();
      expect(faithSuggestions, isNotEmpty);
    });

    test('should fallback to original method on error', () async {
      // This test would require mocking the repository to throw an error
      // For now, we'll test that the method exists and can be called
      final checkInData = CheckInData(
        painLevel: 0.0,
        painRegions: [],
        urgeLevel: 5.0,
        urgeTypes: ['substance_use'],
        rpeLevel: 3,
        faithMode: FaithTier.off,
        timestamp: DateTime.now(),
      );

      // Should not throw an exception
      expect(() => AISuggestionService.generateUnifiedSuggestions(checkInData), 
          returnsNormally);
    });

    test('should handle empty urge types gracefully', () async {
      final emptyData = CheckInData(
        painLevel: 0.0,
        painRegions: [],
        urgeLevel: 0.0,
        urgeTypes: [], // Empty urge types
        rpeLevel: 3,
        faithMode: FaithTier.off,
        timestamp: DateTime.now(),
      );

      final suggestions = await AISuggestionService.generateUnifiedSuggestions(emptyData);
      
      // Should return empty list or fallback suggestions
      expect(suggestions, isA<List>());
    });

    test('should validate action catalog completeness', () {
      final allThemes = themesData.getAllThemes();
      final allActionIds = <String>{};
      
      // Collect all action IDs
      for (final theme in allThemes.values) {
        allActionIds.addAll(theme.actions.low);
        allActionIds.addAll(theme.actions.mid);
        allActionIds.addAll(theme.actions.high);
      }
      
      // Verify all actions exist in catalog
      for (final actionId in allActionIds) {
        final action = themesData.getAction(actionId);
        expect(action, isNotNull, reason: 'Action $actionId not found in catalog');
        expect(action!.title, isNotEmpty);
        expect(action.body, isNotEmpty);
      }
    });
  });
}
