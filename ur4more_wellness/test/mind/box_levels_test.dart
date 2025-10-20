import 'package:flutter_test/flutter_test.dart';
import 'package:ur4more_wellness/features/mind/breath/logic/box_levels.dart';

void main() {
  group('BoxLevels.available', () {
    test('OFF → only L1', () {
      final list = BoxLevels.available(faithActivated: false, hideFaithOverlaysInMind: false);
      expect(list.length, 1);
      expect(list.first.id, 'l1');
    });

    test('Faith ON but overlays hidden → only L1', () {
      final list = BoxLevels.available(faithActivated: true, hideFaithOverlaysInMind: true);
      expect(list.length, 1);
      expect(list.first.id, 'l1');
    });

    test('Faith ON and overlays allowed → L1..L4', () {
      final list = BoxLevels.available(faithActivated: true, hideFaithOverlaysInMind: false);
      expect(list.length, 4);
      expect(list.map((e) => e.id), ['l1','l2','l3','l4']);
    });
  });
}
