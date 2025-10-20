/// Box Breathing Content Data
/// Contains verses and prayers specifically designed for 4-4-4-4 breathing pattern

class BoxBreathingContent {
  final String text;
  final String? reference;
  final String type; // 'verse' or 'prayer'
  final String category; // 'peace', 'strength', 'trust', 'rest', 'hope'
  final bool isFaithContent;

  const BoxBreathingContent({
    required this.text,
    this.reference,
    required this.type,
    required this.category,
    required this.isFaithContent,
  });
}

class BoxBreathingData {
  static const List<BoxBreathingContent> content = [
    // PEACE & CALM
    BoxBreathingContent(
      text: "Be still and know that I am God",
      reference: "Psalm 46:10",
      type: "verse",
      category: "peace",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Peace I leave with you; my peace I give you",
      reference: "John 14:27",
      type: "verse",
      category: "peace",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "The Lord is my shepherd; I shall not want",
      reference: "Psalm 23:1",
      type: "verse",
      category: "peace",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Inhale peace, exhale tension",
      reference: null,
      type: "prayer",
      category: "peace",
      isFaithContent: false,
    ),
    BoxBreathingContent(
      text: "Breathe in calm, breathe out chaos",
      reference: null,
      type: "prayer",
      category: "peace",
      isFaithContent: false,
    ),

    // STRENGTH & COURAGE
    BoxBreathingContent(
      text: "I can do all things through Christ who strengthens me",
      reference: "Philippians 4:13",
      type: "verse",
      category: "strength",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "The Lord is my strength and my shield",
      reference: "Psalm 28:7",
      type: "verse",
      category: "strength",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Fear not, for I am with you",
      reference: "Isaiah 41:10",
      type: "verse",
      category: "strength",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Inhale strength, exhale weakness",
      reference: null,
      type: "prayer",
      category: "strength",
      isFaithContent: false,
    ),
    BoxBreathingContent(
      text: "Breathe in courage, breathe out fear",
      reference: null,
      type: "prayer",
      category: "strength",
      isFaithContent: false,
    ),

    // TRUST & FAITH
    BoxBreathingContent(
      text: "Trust in the Lord with all your heart",
      reference: "Proverbs 3:5",
      type: "verse",
      category: "trust",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Now faith is confidence in what we hope for",
      reference: "Hebrews 11:1",
      type: "verse",
      category: "trust",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Cast all your anxiety on him because he cares for you",
      reference: "1 Peter 5:7",
      type: "verse",
      category: "trust",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Inhale trust, exhale doubt",
      reference: null,
      type: "prayer",
      category: "trust",
      isFaithContent: false,
    ),
    BoxBreathingContent(
      text: "Breathe in faith, breathe out worry",
      reference: null,
      type: "prayer",
      category: "trust",
      isFaithContent: false,
    ),

    // REST & RENEWAL
    BoxBreathingContent(
      text: "Come to me, all you who are weary and burdened",
      reference: "Matthew 11:28",
      type: "verse",
      category: "rest",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "He makes me lie down in green pastures",
      reference: "Psalm 23:2",
      type: "verse",
      category: "rest",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Those who hope in the Lord will renew their strength",
      reference: "Isaiah 40:31",
      type: "verse",
      category: "rest",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Inhale rest, exhale exhaustion",
      reference: null,
      type: "prayer",
      category: "rest",
      isFaithContent: false,
    ),
    BoxBreathingContent(
      text: "Breathe in renewal, breathe out fatigue",
      reference: null,
      type: "prayer",
      category: "rest",
      isFaithContent: false,
    ),

    // HOPE & JOY
    BoxBreathingContent(
      text: "The joy of the Lord is your strength",
      reference: "Nehemiah 8:10",
      type: "verse",
      category: "hope",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Weeping may stay for the night, but rejoicing comes in the morning",
      reference: "Psalm 30:5",
      type: "verse",
      category: "hope",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "And we know that in all things God works for the good",
      reference: "Romans 8:28",
      type: "verse",
      category: "hope",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Inhale hope, exhale despair",
      reference: null,
      type: "prayer",
      category: "hope",
      isFaithContent: false,
    ),
    BoxBreathingContent(
      text: "Breathe in joy, breathe out sorrow",
      reference: null,
      type: "prayer",
      category: "hope",
      isFaithContent: false,
    ),

    // LOVE & GRACE
    BoxBreathingContent(
      text: "For God so loved the world that he gave his one and only Son",
      reference: "John 3:16",
      type: "verse",
      category: "love",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Love is patient, love is kind",
      reference: "1 Corinthians 13:4",
      type: "verse",
      category: "love",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "My grace is sufficient for you",
      reference: "2 Corinthians 12:9",
      type: "verse",
      category: "love",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Inhale love, exhale hate",
      reference: null,
      type: "prayer",
      category: "love",
      isFaithContent: false,
    ),
    BoxBreathingContent(
      text: "Breathe in grace, breathe out judgment",
      reference: null,
      type: "prayer",
      category: "love",
      isFaithContent: false,
    ),

    // PROTECTION & SECURITY
    BoxBreathingContent(
      text: "The Lord will keep you from all harm",
      reference: "Psalm 121:7",
      type: "verse",
      category: "protection",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "No weapon forged against you will prevail",
      reference: "Isaiah 54:17",
      type: "verse",
      category: "protection",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "The Lord is my light and my salvation",
      reference: "Psalm 27:1",
      type: "verse",
      category: "protection",
      isFaithContent: true,
    ),
    BoxBreathingContent(
      text: "Inhale safety, exhale danger",
      reference: null,
      type: "prayer",
      category: "protection",
      isFaithContent: false,
    ),
    BoxBreathingContent(
      text: "Breathe in security, breathe out threat",
      reference: null,
      type: "prayer",
      category: "protection",
      isFaithContent: false,
    ),
  ];

  /// Get content filtered by faith mode
  static List<BoxBreathingContent> getContentForMode(bool isFaithMode) {
    if (isFaithMode) {
      return content; // Show all content for faith users
    } else {
      return content.where((item) => !item.isFaithContent).toList(); // Only secular content
    }
  }

  /// Get content by category
  static List<BoxBreathingContent> getContentByCategory(String category, bool isFaithMode) {
    final allContent = getContentForMode(isFaithMode);
    return allContent.where((item) => item.category == category).toList();
  }

  /// Get all available categories
  static List<String> getCategories(bool isFaithMode) {
    final content = getContentForMode(isFaithMode);
    return content.map((item) => item.category).toSet().toList()..sort();
  }
}
