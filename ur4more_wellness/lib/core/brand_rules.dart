import 'package:flutter/foundation.dart';

// Brand Safety & Faith Rules
bool isFaithSafe(String s) {
  final t = s.toLowerCase();
  const banned = ['yoga', 'chakra', 'mantra', 'tarot', 'astrology', 'namaste'];
  return !banned.any(t.contains);
}

enum FaithMode { off, light, full }

FaithMode parseFaith(String? v) => switch (v) {
  'Light' => FaithMode.light,
  'Full' => FaithMode.full,
  _ => FaithMode.off,
};

String faithModeToString(FaithMode mode) => switch (mode) {
  FaithMode.light => 'Light',
  FaithMode.full => 'Full',
  FaithMode.off => 'Off',
};

// Brand validation utilities
class BrandRules {
  static const List<String> bannedWords = [
    'yoga',
    'chakra',
    'mantra',
    'tarot',
    'astrology',
    'namaste',
  ];

  static bool isContentSafe(String content) {
    return isFaithSafe(content);
  }

  static bool isRewardSafe(String title, String payload) {
    return isFaithSafe(title) && isFaithSafe(payload);
  }

  static String sanitizeContent(String content) {
    if (!isContentSafe(content)) {
      debugPrint('Content filtered for brand safety: $content');
      return '';
    }
    return content;
  }
}
