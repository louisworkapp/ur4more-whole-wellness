import 'package:flutter/foundation.dart';

// Import the new faith service
import '../services/faith_service.dart';

// Re-export FaithMode from faith service for backward compatibility
export '../services/faith_service.dart' show FaithMode;

// Brand Safety & Faith Rules
bool isFaithSafe(String s) {
  final t = s.toLowerCase();
  const banned = ['yoga', 'chakra', 'mantra', 'tarot', 'astrology', 'namaste'];
  return !banned.any(t.contains);
}

FaithMode parseFaith(String? v) => switch (v) {
  'Light' => FaithMode.light,
  'Full' => FaithMode.disciple, // Migrate old 'Full' to 'Disciple'
  'Disciple' => FaithMode.disciple,
  'Kingdom' => FaithMode.kingdom,
  _ => FaithMode.off,
};

String faithModeToString(FaithMode mode) => switch (mode) {
  FaithMode.light => 'Light',
  FaithMode.disciple => 'Disciple',
  FaithMode.kingdom => 'Kingdom',
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
