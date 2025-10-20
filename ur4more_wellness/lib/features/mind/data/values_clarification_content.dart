/// Values Clarification Content Data
/// Contains prompts, examples, and faith-based connections for values exploration

class ValuesContent {
  final String prompt;
  final String? example;
  final String? faithConnection;
  final String category;
  final bool isFaithContent;

  const ValuesContent({
    required this.prompt,
    this.example,
    this.faithConnection,
    required this.category,
    required this.isFaithContent,
  });
}

class ValuesClarificationData {
  static const List<ValuesContent> content = [
    // CORE VALUES PROMPTS
    ValuesContent(
      prompt: "What matters most to you in life?",
      example: "Example: 'Family, honesty, creativity, helping others'",
      faithConnection: "How do these values align with God's heart for you?",
      category: "core_values",
      isFaithContent: false,
    ),
    ValuesContent(
      prompt: "What principles guide your decisions?",
      example: "Example: 'Integrity, compassion, growth, authenticity'",
      faithConnection: "The fruit of the Spirit includes love, joy, peace, patience, kindness, goodness, faithfulness, gentleness, and self-control (Galatians 5:22-23)",
      category: "core_values",
      isFaithContent: true,
    ),

    // VALUES IN ACTION PROMPTS
    ValuesContent(
      prompt: "When do you feel most like yourself?",
      example: "Example: 'When I'm helping someone, creating art, or spending time with family'",
      faithConnection: "God created you uniquely. What brings you joy reflects His design.",
      category: "values_in_action",
      isFaithContent: false,
    ),
    ValuesContent(
      prompt: "What activities make you feel fulfilled?",
      example: "Example: 'Teaching, volunteering, writing, mentoring'",
      faithConnection: "Each of you should use whatever gift you have received to serve others (1 Peter 4:10)",
      category: "values_in_action",
      isFaithContent: true,
    ),

    // DECISION MAKING PROMPTS
    ValuesContent(
      prompt: "How do your values influence your choices?",
      example: "Example: 'I choose jobs that allow me to help people, even if they pay less'",
      faithConnection: "Seek first his kingdom and his righteousness (Matthew 6:33)",
      category: "decision_making",
      isFaithContent: false,
    ),
    ValuesContent(
      prompt: "What would you do if no one was watching?",
      example: "Example: 'I'd still volunteer, be honest, and treat others with respect'",
      faithConnection: "The Lord does not look at the things people look at. People look at the outward appearance, but the Lord looks at the heart (1 Samuel 16:7)",
      category: "decision_making",
      isFaithContent: true,
    ),

    // CONFLICTING VALUES PROMPTS
    ValuesContent(
      prompt: "When have your values conflicted?",
      example: "Example: 'Wanting to help family vs. pursuing my career goals'",
      faithConnection: "God can help you find wisdom in difficult choices.",
      category: "conflicting_values",
      isFaithContent: false,
    ),
    ValuesContent(
      prompt: "How do you handle value conflicts?",
      example: "Example: 'I pray about it and seek wise counsel'",
      faithConnection: "If any of you lacks wisdom, you should ask God, who gives generously to all without finding fault (James 1:5)",
      category: "conflicting_values",
      isFaithContent: true,
    ),

    // GO DEEPER PROMPTS
    ValuesContent(
      prompt: "What legacy do you want to leave?",
      example: "Example: 'I want to be remembered as someone who made others feel valued'",
      faithConnection: "How does your faith shape the legacy you want to create?",
      category: "go_deeper",
      isFaithContent: false,
    ),
    ValuesContent(
      prompt: "How do your values connect to your faith?",
      example: "Example: 'My value of service comes from Jesus' example of serving others'",
      faithConnection: "Your values can be a reflection of God's character in your life.",
      category: "go_deeper",
      isFaithContent: true,
    ),
  ];

  // Common values list for selection
  static const List<String> commonValues = [
    'Family', 'Friendship', 'Love', 'Honesty', 'Integrity', 'Creativity',
    'Growth', 'Learning', 'Adventure', 'Security', 'Freedom', 'Justice',
    'Compassion', 'Service', 'Excellence', 'Authenticity', 'Peace',
    'Joy', 'Faith', 'Hope', 'Wisdom', 'Courage', 'Humility', 'Gratitude',
    'Forgiveness', 'Patience', 'Kindness', 'Generosity', 'Loyalty',
    'Independence', 'Achievement', 'Recognition', 'Health', 'Beauty',
    'Nature', 'Art', 'Music', 'Travel', 'Community', 'Tradition'
  ];

  /// Get content filtered by faith mode
  static List<ValuesContent> getContentForMode(bool isFaithMode) {
    if (isFaithMode) {
      return content; // Show all content for faith users
    } else {
      return content.where((item) => !item.isFaithContent).toList(); // Only secular content
    }
  }

  /// Get content by category
  static List<ValuesContent> getContentByCategory(String category, bool isFaithMode) {
    final allContent = getContentForMode(isFaithMode);
    return allContent.where((item) => item.category == category).toList();
  }

  /// Get all available categories
  static List<String> getCategories(bool isFaithMode) {
    final content = getContentForMode(isFaithMode);
    return content.map((item) => item.category).toSet().toList()..sort();
  }

  /// Get go deeper invitations
  static List<ValuesContent> getGoDeeperInvitations(bool isFaithMode) {
    return getContentByCategory("go_deeper", isFaithMode);
  }
}
