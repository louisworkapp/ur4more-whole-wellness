class BoxLevel {
  final String id;
  final String title;
  final int inhale; // seconds
  final int hold1;
  final int exhale;
  final int hold2;
  final int defaultTotalSeconds;

  const BoxLevel({
    required this.id,
    required this.title,
    required this.inhale,
    required this.hold1,
    required this.exhale,
    required this.hold2,
    required this.defaultTotalSeconds,
  });
}

class BoxLevels {
  static const l1 = BoxLevel(
    id: 'l1', 
    title: 'L1 · 4-4-4-4',
    inhale: 4, 
    hold1: 4, 
    exhale: 4, 
    hold2: 4,
    defaultTotalSeconds: 60,
  );
  
  static const l2 = BoxLevel(
    id: 'l2', 
    title: 'L2 · 5-5-5-5',
    inhale: 5, 
    hold1: 5, 
    exhale: 5, 
    hold2: 5,
    defaultTotalSeconds: 120,
  );
  
  static const l3 = BoxLevel(
    id: 'l3', 
    title: 'L3 · 6-6-6-6',
    inhale: 6, 
    hold1: 6, 
    exhale: 6, 
    hold2: 6,
    defaultTotalSeconds: 180,
  );
  
  static const l4 = BoxLevel(
    id: 'l4', 
    title: 'L4 · 4-7-8-4',
    inhale: 4, 
    hold1: 7, 
    exhale: 8, 
    hold2: 4,
    defaultTotalSeconds: 180,
  );

  static const all = [l1, l2, l3, l4];

  static List<BoxLevel> available({
    required bool faithActivated,
    required bool hideFaithOverlaysInMind,
  }) {
    if (!faithActivated || hideFaithOverlaysInMind) return [l1];
    return all;
  }
}
