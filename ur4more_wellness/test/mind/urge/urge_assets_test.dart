import 'package:flutter_test/flutter_test.dart';
import 'package:ur4more_wellness/features/mind/urge/repositories/urge_themes_repository.dart';
import 'package:ur4more_wellness/features/mind/urge/models/urge_theme_model.dart';

void main() {
  group('Urge Assets Tests', () {
    late UrgeThemesData themesData;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      themesData = await UrgeThemesRepository.load();
    });

    test('should load all required assets', () {
      expect(themesData.commonThemes, isNotEmpty);
      expect(themesData.biblicalThemes, isNotEmpty);
      expect(themesData.actions, isNotEmpty);
    });

    test('should have correct number of themes', () {
      expect(themesData.commonThemes.length, equals(8));
      expect(themesData.biblicalThemes.length, equals(8));
    });

    test('should have all required common themes', () {
      final expectedCommonThemes = [
        'substance_use',
        'food',
        'shopping',
        'social_media',
        'gaming',
        'work',
        'relationships',
        'other',
      ];

      for (final themeId in expectedCommonThemes) {
        expect(themesData.commonThemes.containsKey(themeId), isTrue,
            reason: 'Missing common theme: $themeId');
      }
    });

    test('should have all required biblical themes', () {
      final expectedBiblicalThemes = [
        'pride',
        'envy',
        'lust',
        'greed',
        'anger',
        'sloth',
        'gluttony',
        'feeling_lost',
      ];

      for (final themeId in expectedBiblicalThemes) {
        expect(themesData.biblicalThemes.containsKey(themeId), isTrue,
            reason: 'Missing biblical theme: $themeId');
      }
    });

    test('should have unified schema structure for all themes', () {
      final allThemes = themesData.getAllThemes();
      
      for (final entry in allThemes.entries) {
        final theme = entry.value;
        
        // Check required fields
        expect(theme.label, isNotEmpty, reason: '${entry.key} missing label');
        expect(theme.icon, isNotEmpty, reason: '${entry.key} missing icon');
        expect(theme.actions, isNotNull, reason: '${entry.key} missing actions');
        expect(theme.prompts, isNotNull, reason: '${entry.key} missing prompts');
        
        // Check actions structure
        expect(theme.actions.low, isNotEmpty, reason: '${entry.key} missing low actions');
        expect(theme.actions.mid, isNotEmpty, reason: '${entry.key} missing mid actions');
        expect(theme.actions.high, isNotEmpty, reason: '${entry.key} missing high actions');
        
        // Check prompts structure
        expect(theme.prompts.secular, isNotEmpty, reason: '${entry.key} missing secular prompts');
        expect(theme.prompts.faith, isNotEmpty, reason: '${entry.key} missing faith prompts');
      }
    });

    test('should have all referenced actions in catalog', () {
      final allThemes = themesData.getAllThemes();
      final allActionIds = <String>{};
      
      // Collect all action IDs from themes
      for (final theme in allThemes.values) {
        allActionIds.addAll(theme.actions.low);
        allActionIds.addAll(theme.actions.mid);
        allActionIds.addAll(theme.actions.high);
      }
      
      // Check that all action IDs exist in catalog
      for (final actionId in allActionIds) {
        expect(themesData.actions.containsKey(actionId), isTrue,
            reason: 'Action $actionId referenced but not found in catalog');
      }
    });

    test('should have valid action catalog entries', () {
      for (final entry in themesData.actions.entries) {
        final action = entry.value;
        expect(action.title, isNotEmpty, reason: 'Action ${entry.key} missing title');
        expect(action.body, isNotEmpty, reason: 'Action ${entry.key} missing body');
      }
    });

    test('should have gluttony passage with full KJV text', () {
      final gluttonyTheme = themesData.biblicalThemes['gluttony'];
      expect(gluttonyTheme, isNotNull);
      expect(gluttonyTheme!.passages, isNotEmpty);
      
      final passage = gluttonyTheme.passages.first;
      expect(passage.ref, contains('1 Corinthians 9:24–27'));
      expect(passage.verses, hasLength(4));
      expect(passage.actNow, isNotEmpty);
      
      // Check that verses have full text (no ellipses)
      for (final verse in passage.verses) {
        expect(verse.t, isNotEmpty);
        expect(verse.t, isNot(contains('...')));
      }
    });

    test('should have empty passages for common themes', () {
      for (final theme in themesData.commonThemes.values) {
        expect(theme.passages, isEmpty, 
            reason: 'Common theme ${theme.label} should have empty passages');
      }
    });

    test('should have intensity-based action selection', () {
      final testTheme = themesData.commonThemes['substance_use']!;
      
      // Test low intensity (0-3)
      final lowActions = testTheme.actions.getActionsForIntensity(2.0);
      expect(lowActions, equals(testTheme.actions.low));
      
      // Test mid intensity (4-6)
      final midActions = testTheme.actions.getActionsForIntensity(5.0);
      expect(midActions, equals(testTheme.actions.mid));
      
      // Test high intensity (7-10)
      final highActions = testTheme.actions.getActionsForIntensity(8.0);
      expect(highActions, equals(testTheme.actions.high));
    });

    test('should have faith-based prompt selection', () {
      final testTheme = themesData.biblicalThemes['gluttony']!;
      
      // Test secular prompts
      final secularPrompts = testTheme.prompts.getPromptsForFaithMode(false);
      expect(secularPrompts, equals(testTheme.prompts.secular));
      
      // Test faith prompts
      final faithPrompts = testTheme.prompts.getPromptsForFaithMode(true);
      expect(faithPrompts, equals(testTheme.prompts.faith));
    });
  });
}
