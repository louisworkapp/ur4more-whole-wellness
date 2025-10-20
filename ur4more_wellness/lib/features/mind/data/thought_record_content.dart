/// Thought Record Content Data
/// Contains prompts, examples, and faith-based anchors for CBT thought records

class ThoughtRecordContent {
  final String prompt;
  final String? example;
  final String? faithAnchor;
  final String category;
  final bool isFaithContent;

  const ThoughtRecordContent({
    required this.prompt,
    this.example,
    this.faithAnchor,
    required this.category,
    required this.isFaithContent,
  });
}

class ThoughtRecordData {
  static const List<ThoughtRecordContent> content = [
    // SITUATION PROMPTS
    ThoughtRecordContent(
      prompt: "What happened? Describe the situation objectively.",
      example: "Example: 'My boss gave me feedback on my presentation'",
      faithAnchor: "Remember: God sees the whole picture, even when we only see a part.",
      category: "situation",
      isFaithContent: false,
    ),
    ThoughtRecordContent(
      prompt: "Where were you? Who was there? What time was it?",
      example: "Example: 'In the conference room, 3 PM, with my team present'",
      faithAnchor: "God is present in every moment and every place.",
      category: "situation",
      isFaithContent: true,
    ),

    // AUTOMATIC THOUGHT PROMPTS
    ThoughtRecordContent(
      prompt: "What went through your mind? What did you think?",
      example: "Example: 'I'm terrible at presentations. Everyone thinks I'm incompetent.'",
      faithAnchor: "Challenge: What would God say about this thought?",
      category: "thought",
      isFaithContent: false,
    ),
    ThoughtRecordContent(
      prompt: "What automatic thoughts came up?",
      example: "Example: 'I always mess up. I'm not good enough.'",
      faithAnchor: "Truth: 'I am fearfully and wonderfully made' (Psalm 139:14)",
      category: "thought",
      isFaithContent: true,
    ),

    // EMOTION PROMPTS
    ThoughtRecordContent(
      prompt: "How did you feel? Rate the intensity (0-10).",
      example: "Example: 'Anxious (8/10), Embarrassed (6/10)'",
      faithAnchor: "God understands our emotions. Jesus felt them too.",
      category: "emotion",
      isFaithContent: false,
    ),
    ThoughtRecordContent(
      prompt: "What emotions did you experience?",
      example: "Example: 'Fear, shame, disappointment'",
      faithAnchor: "Cast all your anxiety on him because he cares for you (1 Peter 5:7)",
      category: "emotion",
      isFaithContent: true,
    ),

    // EVIDENCE FOR PROMPTS
    ThoughtRecordContent(
      prompt: "What evidence supports this thought?",
      example: "Example: 'I did stumble over my words twice'",
      faithAnchor: "Even in our weaknesses, God's strength is made perfect.",
      category: "evidence_for",
      isFaithContent: false,
    ),
    ThoughtRecordContent(
      prompt: "What facts support this automatic thought?",
      example: "Example: 'I've made similar mistakes before'",
      faithAnchor: "Our past doesn't define our future in Christ.",
      category: "evidence_for",
      isFaithContent: true,
    ),

    // EVIDENCE AGAINST PROMPTS
    ThoughtRecordContent(
      prompt: "What evidence contradicts this thought?",
      example: "Example: 'My boss said the content was excellent'",
      faithAnchor: "God's truth is greater than our fears.",
      category: "evidence_against",
      isFaithContent: false,
    ),
    ThoughtRecordContent(
      prompt: "What facts challenge this automatic thought?",
      example: "Example: 'I've given successful presentations before'",
      faithAnchor: "I can do all things through Christ who strengthens me (Philippians 4:13)",
      category: "evidence_against",
      isFaithContent: true,
    ),

    // BALANCED THOUGHT PROMPTS
    ThoughtRecordContent(
      prompt: "What's a more balanced way to think about this?",
      example: "Example: 'I made some mistakes, but the overall presentation was good'",
      faithAnchor: "Think about whatever is true, noble, right, pure, lovely (Philippians 4:8)",
      category: "balanced_thought",
      isFaithContent: false,
    ),
    ThoughtRecordContent(
      prompt: "How would you think about this with God's perspective?",
      example: "Example: 'I'm learning and growing. God is with me in this process.'",
      faithAnchor: "For I know the plans I have for you, declares the Lord (Jeremiah 29:11)",
      category: "balanced_thought",
      isFaithContent: true,
    ),

    // GO DEEPER PROMPTS
    ThoughtRecordContent(
      prompt: "What would you tell a friend in this situation?",
      example: "Example: 'You're being too hard on yourself. Everyone makes mistakes.'",
      faithAnchor: "God loves you unconditionally, even in your imperfections.",
      category: "go_deeper",
      isFaithContent: false,
    ),
    ThoughtRecordContent(
      prompt: "How does this connect to your deeper values?",
      example: "Example: 'This challenges my value of excellence, but also my value of growth.'",
      faithAnchor: "Your identity in Christ is secure, regardless of performance.",
      category: "go_deeper",
      isFaithContent: true,
    ),
  ];

  /// Get content filtered by faith mode
  static List<ThoughtRecordContent> getContentForMode(bool isFaithMode) {
    if (isFaithMode) {
      return content; // Show all content for faith users
    } else {
      return content.where((item) => !item.isFaithContent).toList(); // Only secular content
    }
  }

  /// Get content by category
  static List<ThoughtRecordContent> getContentByCategory(String category, bool isFaithMode) {
    final allContent = getContentForMode(isFaithMode);
    return allContent.where((item) => item.category == category).toList();
  }

  /// Get all available categories
  static List<String> getCategories(bool isFaithMode) {
    final content = getContentForMode(isFaithMode);
    return content.map((item) => item.category).toSet().toList()..sort();
  }

  /// Get go deeper invitations
  static List<ThoughtRecordContent> getGoDeeperInvitations(bool isFaithMode) {
    return getContentByCategory("go_deeper", isFaithMode);
  }
}
