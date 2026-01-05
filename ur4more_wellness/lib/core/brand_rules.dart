import 'package:flutter/foundation.dart';

// Import FaithTier from canonical location
import 'settings/settings_model.dart' show FaithTier, parseFaithTier, faithTierToString;

// Brand Safety & Faith Rules
bool isFaithSafe(String s) {
  final t = s.toLowerCase();
  const banned = ['yoga', 'chakra', 'mantra', 'tarot', 'astrology', 'namaste'];
  return !banned.any(t.contains);
}

/// Parse faith tier from string (supports legacy capitalized strings)
FaithTier parseFaith(String? v) {
  if (v == null) return FaithTier.off;
  final lower = v.toLowerCase().trim();
  switch (lower) {
    case 'light':
      return FaithTier.light;
    case 'full': // Migrate old 'Full' to 'Disciple'
    case 'disciple':
      return FaithTier.disciple;
    case 'kingdom':
      return FaithTier.kingdom;
    default:
      return FaithTier.off;
  }
}

/// Convert FaithTier to display string (capitalized)
String faithModeToString(FaithTier mode) => switch (mode) {
  FaithTier.light => 'Light',
  FaithTier.disciple => 'Disciple',
  FaithTier.kingdom => 'Kingdom',
  FaithTier.off => 'Off',
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
