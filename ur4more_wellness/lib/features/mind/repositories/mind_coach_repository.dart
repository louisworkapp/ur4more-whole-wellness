import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import '../models/mind_coach_copy.dart';
import '../services/mind_exercises_service.dart';
import '../../../services/faith_service.dart';

/// Repository for managing Mind Coach content and data
class MindCoachRepository {
  static const String _coachPromptsAsset = 'assets/mind/coach_prompts.json';
  
  /// Load coach prompts from JSON asset
  static Future<Map<String, dynamic>> loadCoachPrompts() async {
    try {
      final String jsonString = await rootBundle.loadString(_coachPromptsAsset);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return jsonData;
    } catch (e) {
      debugPrint('Error loading coach prompts: $e');
      return _getDefaultPrompts();
    }
  }

  /// Get default prompts if asset loading fails
  static Map<String, dynamic> _getDefaultPrompts() {
    return {
      "version": 1,
      "coach": {
        "off": {
          "greeting": "I'm your Mind Coach. We'll use evidence-based tools to steady your thoughts.",
          "reframeIntro": "Let's catch the thought, test the evidence, and craft a balanced reframe.",
          "nudgeSmallStep": "What's one tiny step you can take in the next 10 minutes?",
          "quotes": [
            "Between stimulus and response there is a space. In that space is our power to choose our response. — Viktor Frankl",
            "We are what we repeatedly do. Excellence, then, is not an act, but a habit. — Will Durant"
          ]
        },
        "activated": {
          "greeting": "I'm your Mind Coach. We'll steady your thoughts and, if you wish, invite God into the process.",
          "reframeIntro": "Let's test the thought against truth and craft a faith-filled, balanced reframe.",
          "nudgeSmallStep": "What's one faithful step you can take in the next 10 minutes?",
          "faithOptional": "Would you like a short verse or prayer added?",
          "quotes": [
            "Between stimulus and response there is a space. In that space is our power to choose our response. — Viktor Frankl",
            "Be careful for nothing; but in every thing by prayer and supplication with thanksgiving let your requests be made known unto God. — Philippians 4:6"
          ],
          "scriptureKJV": [
            {
              "ref": "Philippians 4:6-7",
              "text": "Be careful for nothing; but in every thing by prayer and supplication with thanksgiving let your requests be made known unto God. And the peace of God, which passeth all understanding, shall keep your hearts and minds through Christ Jesus."
            }
          ]
        }
      }
    };
  }

  /// Get coach copy for specific faith mode
  static Future<MindCoachCopy> getCoachCopy(FaithTier mode) async {
    final prompts = await loadCoachPrompts();
    final coachData = prompts['coach'] as Map<String, dynamic>;
    final modeKey = mode.isOff ? 'off' : 'activated';
    final modeData = coachData[modeKey] as Map<String, dynamic>;

    return MindCoachCopy(
      greeting: modeData['greeting'] as String,
      reframeIntro: modeData['reframeIntro'] as String,
      nudgeSmallStep: modeData['nudgeSmallStep'] as String,
      faithOptional: modeData['faithOptional'] as String?,
    );
  }

  /// Get quotes for specific faith mode
  static Future<List<String>> getQuotes(FaithTier mode) async {
    final prompts = await loadCoachPrompts();
    final coachData = prompts['coach'] as Map<String, dynamic>;
    final modeKey = mode.isOff ? 'off' : 'activated';
    final modeData = coachData[modeKey] as Map<String, dynamic>;
    
    final quotes = modeData['quotes'] as List<dynamic>?;
    return quotes?.cast<String>() ?? [];
  }

  /// Get scripture verses for faith modes
  static Future<List<Map<String, String>>> getScriptureVerses(FaithTier mode) async {
    if (mode.isOff) return [];
    
    final prompts = await loadCoachPrompts();
    final coachData = prompts['coach'] as Map<String, dynamic>;
    final modeData = coachData['activated'] as Map<String, dynamic>;
    
    final scripture = modeData['scriptureKJV'] as List<dynamic>?;
    if (scripture == null) return [];
    
    return scripture.map((item) {
      final map = item as Map<String, dynamic>;
      return {
        'ref': map['ref'] as String,
        'text': map['text'] as String,
      };
    }).toList();
  }

  /// Get random quote for faith mode
  static Future<String> getRandomQuote(FaithTier mode) async {
    final quotes = await getQuotes(mode);
    if (quotes.isEmpty) return "Take one step at a time.";
    
    final random = DateTime.now().millisecondsSinceEpoch % quotes.length;
    return quotes[random];
  }

  /// Get random scripture verse for faith modes
  static Future<Map<String, String>?> getRandomScripture(FaithTier mode) async {
    if (mode.isOff) return null;
    
    final verses = await getScriptureVerses(mode);
    if (verses.isEmpty) return null;
    
    final random = DateTime.now().millisecondsSinceEpoch % verses.length;
    return verses[random];
  }

  /// Get exercises for faith mode
  static Future<List<Exercise>> getExercises(FaithTier mode) async {
    return await MindExercisesService.mindExercises(mode);
  }

  /// Get courses for faith mode
  static List<CourseTile> getCourses(FaithTier mode) {
    return MindCoursesService.getCourses(mode);
  }

  /// Get mode display text
  static String getModeDisplayText(FaithTier mode) {
    switch (mode) {
      case FaithTier.off:
        return "Mode: Secular-first";
      case FaithTier.light:
      case FaithTier.disciple:
      case FaithTier.kingdom:
        return "Mode: Faith-activated";
    }
  }

  /// Get mode pill color
  static int getModePillColor(FaithTier mode) {
    switch (mode) {
      case FaithTier.off:
        return 0xFF6B7280; // Gray
      case FaithTier.light:
        return 0xFFF59E0B; // Amber
      case FaithTier.disciple:
        return 0xFF3B82F6; // Blue
      case FaithTier.kingdom:
        return 0xFF8B5CF6; // Purple
    }
  }
}
