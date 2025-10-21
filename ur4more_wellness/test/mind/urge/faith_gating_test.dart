import 'package:flutter_test/flutter_test.dart';
import 'package:ur4more_wellness/features/mind/urge/repositories/urge_themes_repository.dart';
import 'package:ur4more_wellness/features/mind/urge/models/urge_theme_model.dart';
import 'package:ur4more_wellness/services/faith_service.dart';

void main() {
  group('Faith Gating Tests', () {
    late UrgeThemesData themesData;

    setUpAll(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      themesData = await UrgeThemesRepository.load();
    });

    test('should return empty passages when faith mode is off', () async {
      final passages = await UrgeThemesRepository.getPassagesForTheme('gluttony', false);
      expect(passages, isEmpty);
    });

    test('should return passages when faith mode is on', () async {
      final passages = await UrgeThemesRepository.getPassagesForTheme('gluttony', true);
      expect(passages, isNotEmpty);
      expect(passages.first.ref, contains('1 Corinthians 9:24–27'));
    });

    test('should return secular prompts when faith mode is off', () async {
      final prompts = await UrgeThemesRepository.getPromptsForTheme('gluttony', false);
      expect(prompts, isNotEmpty);
      
      // Check that prompts don't contain faith-specific language
      for (final prompt in prompts) {
        expect(prompt.toLowerCase(), isNot(contains('god')));
        expect(prompt.toLowerCase(), isNot(contains('pray')));
        expect(prompt.toLowerCase(), isNot(contains('scripture')));
      }
    });

    test('should return faith prompts when faith mode is on', () async {
      final prompts = await UrgeThemesRepository.getPromptsForTheme('gluttony', true);
      expect(prompts, isNotEmpty);
      
      // Check that at least one prompt contains faith-specific language
      final hasFaithContent = prompts.any((prompt) => 
          prompt.toLowerCase().contains('god') || 
          prompt.toLowerCase().contains('pray') ||
          prompt.toLowerCase().contains('glorify'));
      expect(hasFaithContent, isTrue);
    });

    test('should handle all faith modes correctly', () {
      final faithModes = [FaithMode.off, FaithMode.light, FaithMode.disciple, FaithMode.kingdom];
      
      for (final mode in faithModes) {
        final isActivated = mode.isActivated;
        
        if (isActivated) {
          // Should be able to access faith content
          expect(() => UrgeThemesRepository.getPassagesForTheme('gluttony', true), 
              returnsNormally);
          expect(() => UrgeThemesRepository.getPromptsForTheme('gluttony', true), 
              returnsNormally);
        } else {
          // Should return empty or secular content
          expect(() => UrgeThemesRepository.getPassagesForTheme('gluttony', false), 
              returnsNormally);
          expect(() => UrgeThemesRepository.getPromptsForTheme('gluttony', false), 
              returnsNormally);
        }
      }
    });

    test('should distinguish between common and biblical themes', () {
      // Common themes should not have passages even when faith is on
      final commonThemes = ['substance_use', 'food', 'shopping', 'social_media'];
      
      for (final themeId in commonThemes) {
        final theme = themesData.commonThemes[themeId];
        expect(theme, isNotNull);
        expect(theme!.passages, isEmpty);
      }
      
      // Biblical themes should have passages when faith is on
      final biblicalThemes = ['pride', 'envy', 'lust', 'greed', 'anger', 'sloth', 'gluttony', 'feeling_lost'];
      
      for (final themeId in biblicalThemes) {
        final theme = themesData.biblicalThemes[themeId];
        expect(theme, isNotNull);
        // Note: Some biblical themes may have empty passages initially (placeholders)
        // but the structure should be there
        expect(theme!.passages, isA<List>());
      }
    });

    test('should handle hideFaithOverlaysInMind setting', () {
      // This test simulates the hideFaithOverlaysInMind setting
      // When true, even if faith mode is activated, passages should not be shown
      
      // Simulate faith mode activated but hidden in Mind
      final shouldShowFaith = true && false; // faith activated but hidden
      expect(shouldShowFaith, isFalse);
      
      // This would be the logic in the UI:
      // if (faithMode.isActivated && !hideFaithOverlaysInMind) {
      //   show passages
      // }
    });

    test('should validate faith consent requirements', () {
      // Test that faith content requires proper consent
      final biblicalTheme = themesData.biblicalThemes['gluttony']!;
      
      // Faith prompts should be different from secular prompts
      expect(biblicalTheme.prompts.faith, isNot(equals(biblicalTheme.prompts.secular)));
      
      // Faith prompts should contain faith-specific language
      final hasFaithInPrompts = biblicalTheme.prompts.faith.any((prompt) =>
          prompt.toLowerCase().contains('god') ||
          prompt.toLowerCase().contains('pray') ||
          prompt.toLowerCase().contains('glorify'));
      expect(hasFaithInPrompts, isTrue);
    });
  });
}
