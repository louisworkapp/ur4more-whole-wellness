import 'package:flutter_test/flutter_test.dart';
import 'package:ur4more_wellness/features/breath/logic/presets.dart';

void main() {
  group('Breath Presets Tests', () {
    test('should have all 4 presets', () {
      expect(Presets.all.length, 4);
      expect(Presets.all.map((p) => p.id), containsAll([
        'quick_calm',
        'hrv',
        'focus',
        'sleep',
      ]));
    });

    test('should get preset by id', () {
      final focus = Presets.byId('focus');
      expect(focus.id, 'focus');
      expect(focus.name, 'Focus');
      
      final unknown = Presets.byId('unknown');
      expect(unknown.id, 'focus'); // fallback to focus
    });

    test('should have correct config for Quick Calm', () {
      final quickCalm = Presets.quickCalm;
      expect(quickCalm.config.inhale, 2);
      expect(quickCalm.config.hold1, 0);
      expect(quickCalm.config.exhale, 6);
      expect(quickCalm.config.hold2, 0);
      expect(quickCalm.config.exhaleWeighted, true);
      expect(quickCalm.config.totalSeconds, 120);
    });

    test('should have correct config for HRV', () {
      final hrv = Presets.hrv;
      expect(hrv.config.inhale, 5);
      expect(hrv.config.hold1, 0);
      expect(hrv.config.exhale, 5);
      expect(hrv.config.hold2, 0);
      expect(hrv.config.exhaleWeighted, false);
      expect(hrv.config.totalSeconds, 360);
    });

    test('should have correct config for Focus', () {
      final focus = Presets.focus;
      expect(focus.config.inhale, 4);
      expect(focus.config.hold1, 4);
      expect(focus.config.exhale, 4);
      expect(focus.config.hold2, 4);
      expect(focus.config.exhaleWeighted, false);
      expect(focus.config.totalSeconds, 180);
    });

    test('should have correct config for Sleep', () {
      final sleep = Presets.sleep;
      expect(sleep.config.inhale, 4);
      expect(sleep.config.hold1, 0);
      expect(sleep.config.exhale, 6);
      expect(sleep.config.hold2, 0);
      expect(sleep.config.exhaleWeighted, true);
      expect(sleep.dimUi, true);
      expect(sleep.config.totalSeconds, 360);
    });

    test('should calculate breaths per minute correctly', () {
      final focus = Presets.focus;
      expect(focus.config.cycleDuration, 16); // 4+4+4+4
      expect(focus.config.breathsPerMinute, 3.75); // 60/16
      
      final hrv = Presets.hrv;
      expect(hrv.config.cycleDuration, 10); // 5+0+5+0
      expect(hrv.config.breathsPerMinute, 6.0); // 60/10
    });

    test('should return all presets regardless of faith settings', () {
      final presets = Presets.available(
        faithActivated: false,
        hideFaithOverlaysInMind: true,
      );
      expect(presets.length, 4);
    });
  });
}
