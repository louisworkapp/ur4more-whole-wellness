import 'package:flutter/material.dart';
import '../services/faith_service.dart';
import 'pain_relief_guide.dart';
import '../features/mind/urge/repositories/urge_themes_repository.dart';
import '../features/mind/urge/models/urge_theme_model.dart';

/// Data model for AI-generated suggestions
class AISuggestion {
  final String id;
  final String title;
  final String description;
  final String category; // 'exercise', 'coping', 'spiritual', 'social'
  final String iconName;
  final int priority; // 1-5, higher is more important
  final String reasoning; // Why this suggestion was made
  final List<String> tags;
  final bool requiresFaithMode;
  final String? faithVerse;
  final String? faithPrompt;

  const AISuggestion({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconName,
    required this.priority,
    required this.reasoning,
    required this.tags,
    this.requiresFaithMode = false,
    this.faithVerse,
    this.faithPrompt,
  });

  factory AISuggestion.fromJson(Map<String, dynamic> json) {
    return AISuggestion(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      iconName: json['iconName'] as String,
      priority: json['priority'] as int,
      reasoning: json['reasoning'] as String,
      tags: List<String>.from(json['tags'] as List),
      requiresFaithMode: json['requiresFaithMode'] as bool? ?? false,
      faithVerse: json['faithVerse'] as String?,
      faithPrompt: json['faithPrompt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'iconName': iconName,
      'priority': priority,
      'reasoning': reasoning,
      'tags': tags,
      'requiresFaithMode': requiresFaithMode,
      'faithVerse': faithVerse,
      'faithPrompt': faithPrompt,
    };
  }
}

/// Input data for AI analysis
class CheckInData {
  final double painLevel;
  final List<String> painRegions;
  final double urgeLevel;
  final List<String> urgeTypes;
  final int rpeLevel;
  final FaithMode faithMode;
  final DateTime timestamp;
  final String? mood;

  const CheckInData({
    required this.painLevel,
    required this.painRegions,
    required this.urgeLevel,
    required this.urgeTypes,
    required this.rpeLevel,
    required this.faithMode,
    required this.timestamp,
    this.mood,
  });
}

/// AI Suggestion Service - Rule-based intelligent suggestions
class AISuggestionService {
  static const List<AISuggestion> _allSuggestions = [
    // Pain-focused suggestions
    AISuggestion(
      id: 'gentle_stretching',
      title: 'Gentle Stretching',
      description: 'Light stretches to ease muscle tension and improve circulation.',
      category: 'exercise',
      iconName: 'accessibility_new',
      priority: 4,
      reasoning: 'Recommended for mild to moderate pain to improve mobility.',
      tags: ['pain', 'mobility', 'gentle'],
    ),
    AISuggestion(
      id: 'heat_therapy',
      title: 'Heat Therapy',
      description: 'Apply warmth to tense areas for 15-20 minutes to relax muscles.',
      category: 'coping',
      iconName: 'local_fire_department',
      priority: 3,
      reasoning: 'Heat helps relax tense muscles and reduce pain.',
      tags: ['pain', 'relaxation', 'physical'],
    ),
    AISuggestion(
      id: 'deep_breathing_pain',
      title: 'Pain-Focused Breathing',
      description: 'Use breathing techniques to manage pain and reduce tension.',
      category: 'coping',
      iconName: 'air',
      priority: 4,
      reasoning: 'Breathing exercises help manage pain perception and stress.',
      tags: ['pain', 'breathing', 'mindfulness'],
    ),
    AISuggestion(
      id: 'prayer_healing',
      title: 'Prayer for Healing',
      description: 'Seek God\'s comfort and healing through prayer.',
      category: 'spiritual',
      iconName: 'volunteer_activism',
      priority: 5,
      reasoning: 'Spiritual comfort can provide strength during physical pain.',
      tags: ['pain', 'prayer', 'healing'],
      requiresFaithMode: true,
      faithVerse: 'James 5:16',
      faithPrompt: 'Pray for healing and ask God to give you strength.',
    ),

    // Urge/Craving-focused suggestions
    AISuggestion(
      id: 'urge_surfing',
      title: 'Urge Surfing',
      description: 'Ride the wave of craving without acting on it.',
      category: 'coping',
      iconName: 'waves',
      priority: 5,
      reasoning: 'High urge levels benefit from mindful acceptance techniques.',
      tags: ['urge', 'craving', 'mindfulness'],
    ),
    AISuggestion(
      id: 'scripture_reading',
      title: 'Scripture Reading',
      description: 'Read God\'s word to find strength and guidance.',
      category: 'spiritual',
      iconName: 'menu_book',
      priority: 4,
      reasoning: 'Scripture provides spiritual strength during temptation.',
      tags: ['urge', 'scripture', 'strength'],
      requiresFaithMode: true,
      faithVerse: '1 Corinthians 10:13',
      faithPrompt: 'God provides a way out of every temptation.',
    ),
    AISuggestion(
      id: 'call_friend',
      title: 'Call a Friend',
      description: 'Reach out to someone you trust for support.',
      category: 'social',
      iconName: 'call',
      priority: 4,
      reasoning: 'Social support helps manage urges and cravings.',
      tags: ['urge', 'social', 'support'],
    ),
    AISuggestion(
      id: 'physical_activity',
      title: 'Physical Activity',
      description: 'Engage in exercise to redirect energy and boost mood.',
      category: 'exercise',
      iconName: 'fitness_center',
      priority: 3,
      reasoning: 'Physical activity helps manage urges and improves mood.',
      tags: ['urge', 'exercise', 'mood'],
    ),

    // High exertion recovery suggestions
    AISuggestion(
      id: 'recovery_breathing',
      title: 'Recovery Breathing',
      description: 'Slow, deep breathing to help your body recover.',
      category: 'coping',
      iconName: 'air',
      priority: 4,
      reasoning: 'High exertion requires focused recovery techniques.',
      tags: ['recovery', 'breathing', 'exertion'],
    ),
    AISuggestion(
      id: 'gratitude_practice',
      title: 'Gratitude Practice',
      description: 'Reflect on what you\'re thankful for today.',
      category: 'spiritual',
      iconName: 'favorite',
      priority: 3,
      reasoning: 'Gratitude helps shift focus from fatigue to appreciation.',
      tags: ['recovery', 'gratitude', 'mindfulness'],
    ),
    AISuggestion(
      id: 'rest_meditation',
      title: 'Restful Meditation',
      description: 'Guided meditation to help your body and mind recover.',
      category: 'coping',
      iconName: 'self_improvement',
      priority: 4,
      reasoning: 'Meditation aids in physical and mental recovery.',
      tags: ['recovery', 'meditation', 'rest'],
    ),

    // Biblical theme-specific suggestions
    AISuggestion(
      id: 'humility_prayer',
      title: 'Humility Prayer',
      description: 'Pray for God to help you see yourself clearly.',
      category: 'spiritual',
      iconName: 'volunteer_activism',
      priority: 4,
      reasoning: 'Addressing pride through prayer and humility.',
      tags: ['pride', 'humility', 'prayer'],
      requiresFaithMode: true,
      faithVerse: 'Proverbs 16:18',
      faithPrompt: 'Ask God to help you walk in humility.',
    ),
    AISuggestion(
      id: 'service_others',
      title: 'Serve Others',
      description: 'Focus on helping someone else today.',
      category: 'spiritual',
      iconName: 'volunteer_activism',
      priority: 4,
      reasoning: 'Service helps combat envy and selfishness.',
      tags: ['envy', 'service', 'others'],
      requiresFaithMode: true,
      faithVerse: 'Philippians 2:3-4',
      faithPrompt: 'Consider others better than yourself.',
    ),
    AISuggestion(
      id: 'contentment_practice',
      title: 'Contentment Practice',
      description: 'Practice being satisfied with what you have.',
      category: 'spiritual',
      iconName: 'favorite',
      priority: 3,
      reasoning: 'Contentment helps overcome envy and greed.',
      tags: ['envy', 'greed', 'contentment'],
      requiresFaithMode: true,
      faithVerse: 'Philippians 4:11-12',
      faithPrompt: 'Learn to be content in all circumstances.',
    ),

    // General wellness suggestions
    AISuggestion(
      id: 'mindful_walking',
      title: 'Mindful Walking',
      description: 'Take a slow, intentional walk to clear your mind.',
      category: 'exercise',
      iconName: 'directions_walk',
      priority: 2,
      reasoning: 'Gentle movement helps with overall wellness.',
      tags: ['wellness', 'walking', 'mindfulness'],
    ),
    AISuggestion(
      id: 'journaling',
      title: 'Journaling',
      description: 'Write down your thoughts and feelings.',
      category: 'coping',
      iconName: 'edit_note',
      priority: 3,
      reasoning: 'Writing helps process emotions and thoughts.',
      tags: ['wellness', 'journaling', 'reflection'],
    ),
    AISuggestion(
      id: 'music_therapy',
      title: 'Music Therapy',
      description: 'Listen to calming or uplifting music.',
      category: 'coping',
      iconName: 'music_note',
      priority: 2,
      reasoning: 'Music can improve mood and reduce stress.',
      tags: ['wellness', 'music', 'mood'],
    ),
  ];

  /// Generate personalized suggestions based on check-in data
  static List<AISuggestion> generateSuggestions(CheckInData data) {
    final suggestions = <AISuggestion>[];
    
    // Add region-specific pain relief suggestions if pain is present
    if (data.painLevel > 0 && data.painRegions.isNotEmpty) {
      suggestions.addAll(_generatePainReliefSuggestions(data));
    }
    
    // Add biblical healing suggestions if faith mode is activated
    if (data.faithMode.isActivated) {
      suggestions.addAll(_generateBiblicalHealingSuggestions());
    }
    
    // Add existing general suggestions
    suggestions.addAll(_generateGeneralSuggestions(data));
    
    return suggestions;
  }

  /// Generate suggestions using the unified urge theme schema
  static Future<List<AISuggestion>> generateUnifiedSuggestions(CheckInData data) async {
    final suggestions = <AISuggestion>[];
    
    try {
      final themesData = await UrgeThemesRepository.load();
      
      // Process each urge type
      for (final urgeType in data.urgeTypes) {
        final theme = themesData.getAllThemes()[urgeType];
        if (theme == null) continue;
        
        // Get actions for this theme and intensity level
        final actions = await UrgeThemesRepository.getActionsForThemeAndIntensity(
          urgeType, 
          data.urgeLevel,
        );
        
        // Convert actions to AI suggestions
        for (final action in actions) {
          suggestions.add(AISuggestion(
            id: '${urgeType}_${action.title.toLowerCase().replaceAll(' ', '_')}',
            title: action.title,
            description: action.body,
            category: _getCategoryFromUrgeType(urgeType),
            iconName: _getIconFromUrgeType(urgeType),
            priority: _calculatePriority(data.urgeLevel, action.title),
            reasoning: _generateUnifiedReasoning(urgeType, data.urgeLevel, action.title),
            tags: [urgeType, 'unified_schema'],
            requiresFaithMode: themesData.biblicalThemes.containsKey(urgeType),
            faithVerse: null, // Will be populated from passages if needed
            faithPrompt: null, // Will be populated from prompts if needed
          ));
        }
        
        // Add faith-based suggestions if applicable
        if (data.faithMode.isActivated && themesData.biblicalThemes.containsKey(urgeType)) {
          final passages = await UrgeThemesRepository.getPassagesForTheme(urgeType, true);
          final prompts = await UrgeThemesRepository.getPromptsForTheme(urgeType, true);
          
          // Add passage-based suggestions
          for (final passage in passages) {
            if (passage.verses.isNotEmpty) {
              suggestions.add(AISuggestion(
                id: '${urgeType}_passage_${passage.ref.replaceAll(' ', '_')}',
                title: 'Scripture Reflection: ${passage.ref}',
                description: passage.actNow,
                category: 'spiritual',
                iconName: 'menu_book',
                priority: _calculatePriority(data.urgeLevel, 'scripture'),
                reasoning: 'Biblical wisdom for ${theme.label} based on ${passage.ref}',
                tags: [urgeType, 'scripture', 'faith'],
                requiresFaithMode: true,
                faithVerse: passage.verses.first.t, // Use first verse
                faithPrompt: prompts.isNotEmpty ? prompts.first : null,
              ));
            }
          }
        }
      }
      
      // Sort by priority and take top suggestions
      suggestions.sort((a, b) => b.priority.compareTo(a.priority));
      return suggestions.take(12).toList(); // Limit to top 12
      
    } catch (e) {
      print('Error generating unified suggestions: $e');
      // Fallback to original method
      return generateSuggestions(data);
    }
  }

  /// Generate region-specific pain relief suggestions
  static List<AISuggestion> _generatePainReliefSuggestions(CheckInData data) {
    final suggestions = <AISuggestion>[];
    
    for (final region in data.painRegions) {
      final regionSuggestions = PainReliefGuide.getSuggestionsForRegion(region);
      
      // Convert pain relief suggestions to AI suggestions with enhanced scoring
      for (final prs in regionSuggestions) {
        // Skip if faith-based and faith mode is off
        if (prs.category == 'spiritual' && !data.faithMode.isActivated) {
          continue;
        }
        
        // Calculate priority based on pain level and suggestion priority
        int enhancedPriority = prs.priority;
        
        // Boost priority for high pain levels
        if (data.painLevel >= 7) {
          enhancedPriority += 2; // High pain gets priority boost
        } else if (data.painLevel >= 4) {
          enhancedPriority += 1; // Moderate pain gets slight boost
        }
        
        // Boost priority for specific categories based on pain level
        if (data.painLevel >= 6) {
          // High pain - prioritize physical relief
          if (prs.category == 'physical' || prs.category == 'medication') {
            enhancedPriority += 1;
          }
        } else if (data.painLevel <= 3) {
          // Low pain - prioritize prevention and lifestyle
          if (prs.category == 'lifestyle' || prs.category == 'exercise') {
            enhancedPriority += 1;
          }
        }
        
        // Add faith bonus if applicable
        if (prs.category == 'spiritual' && data.faithMode.isActivated) {
          enhancedPriority += 1;
        }
        
        suggestions.add(AISuggestion(
          id: '${region.toLowerCase().replaceAll('/', '_').replaceAll(' ', '_')}_${prs.title.toLowerCase().replaceAll(' ', '_')}',
          title: prs.title,
          description: prs.description,
          category: prs.category,
          iconName: prs.icon,
          priority: enhancedPriority.clamp(1, 5), // Keep within 1-5 range
          reasoning: _generatePainReasoning(region, data.painLevel, prs),
          tags: prs.tags,
          requiresFaithMode: prs.category == 'spiritual',
          faithVerse: prs.faithVerse,
          faithPrompt: prs.category == 'spiritual' ? 'Seek God\'s healing and comfort through this practice.' : null,
        ));
      }
    }
    
    // Sort by priority and take top suggestions per region
    suggestions.sort((a, b) => b.priority.compareTo(a.priority));
    
    // Limit to top 8 pain relief suggestions to avoid overwhelming the user
    return suggestions.take(8).toList();
  }

  /// Generate detailed reasoning for pain relief suggestions
  static String _generatePainReasoning(String region, double painLevel, PainReliefSuggestion prs) {
    String baseReason = 'Recommended for ${region} pain relief based on evidence-based home remedies.';
    
    if (painLevel >= 7) {
      baseReason += ' High pain level (${painLevel.toStringAsFixed(1)}/10) makes this especially important for immediate relief.';
    } else if (painLevel >= 4) {
      baseReason += ' Moderate pain level (${painLevel.toStringAsFixed(1)}/10) indicates this could provide significant relief.';
    } else {
      baseReason += ' Lower pain level (${painLevel.toStringAsFixed(1)}/10) makes this good for prevention and comfort.';
    }
    
    // Add category-specific reasoning
    switch (prs.category) {
      case 'physical':
        baseReason += ' Physical therapy approach helps address the root cause of ${region.toLowerCase()} discomfort.';
        break;
      case 'exercise':
        baseReason += ' Gentle movement and stretching can improve ${region.toLowerCase()} function and reduce stiffness.';
        break;
      case 'lifestyle':
        baseReason += ' Lifestyle adjustments can prevent ${region.toLowerCase()} pain from worsening and promote healing.';
        break;
      case 'mental':
        baseReason += ' Stress and tension often contribute to ${region.toLowerCase()} pain - this addresses the mental component.';
        break;
      case 'medication':
        baseReason += ' Over-the-counter relief can help manage ${region.toLowerCase()} pain while other treatments take effect.';
        break;
      case 'spiritual':
        baseReason += ' Spiritual comfort and prayer can provide strength and peace while dealing with ${region.toLowerCase()} pain.';
        break;
    }
    
    return baseReason;
  }

  /// Generate biblical healing suggestions
  static List<AISuggestion> _generateBiblicalHealingSuggestions() {
    final suggestions = <AISuggestion>[];
    final biblicalSuggestions = PainReliefGuide.getBiblicalHealingSuggestions();
    
    for (final bs in biblicalSuggestions) {
      suggestions.add(AISuggestion(
        id: 'biblical_${bs.title.toLowerCase().replaceAll(' ', '_')}',
        title: bs.title,
        description: bs.description,
        category: 'spiritual',
        iconName: bs.icon,
        priority: bs.priority,
        reasoning: 'Spiritual comfort and healing through faith-based practices.',
        tags: bs.tags,
        requiresFaithMode: true,
        faithVerse: bs.faithVerse,
        faithPrompt: 'Trust in God\'s healing power and find peace in His presence.',
      ));
    }
    
    return suggestions;
  }

  /// Generate general suggestions using existing logic
  static List<AISuggestion> _generateGeneralSuggestions(CheckInData data) {
    final suggestions = <AISuggestion>[];
    final scoredSuggestions = <AISuggestion, int>{};

    // Score each suggestion based on relevance
    for (final suggestion in _allSuggestions) {
      int score = 0;

      // Skip faith-based suggestions if faith mode is off
      if (suggestion.requiresFaithMode && !data.faithMode.isActivated) {
        continue;
      }

      // Pain-based scoring with enhanced region-specific suggestions
      if (data.painLevel > 0) {
        if (suggestion.tags.contains('pain')) {
          score += (data.painLevel * 2).round(); // Higher pain = higher score
        }
        
        // Enhanced region-specific scoring using pain relief guide
        for (final region in data.painRegions) {
          if (_isRegionRelevant(suggestion, region)) {
            score += 3;
          }
          // Add bonus for region-specific pain relief suggestions
          final regionSuggestions = PainReliefGuide.getSuggestionsForRegion(region);
          if (regionSuggestions.any((rs) => rs.title.toLowerCase().contains(suggestion.title.toLowerCase()))) {
            score += 2;
          }
        }
      }

      // Urge/Craving-based scoring
      if (data.urgeLevel > 0) {
        if (suggestion.tags.contains('urge') || suggestion.tags.contains('craving')) {
          score += (data.urgeLevel * 2).round();
        }
        
        // Urge type-specific scoring
        for (final urgeType in data.urgeTypes) {
          if (_isUrgeTypeRelevant(suggestion, urgeType)) {
            score += 2;
          }
        }
      }

      // Exertion-based scoring
      if (data.rpeLevel >= 7) {
        if (suggestion.tags.contains('recovery')) {
          score += 4;
        }
      } else if (data.rpeLevel <= 3) {
        if (suggestion.tags.contains('exercise') && !suggestion.tags.contains('recovery')) {
          score += 2;
        }
      }

      // Faith mode bonus
      if (data.faithMode.isActivated && suggestion.requiresFaithMode) {
        score += 2;
      }

      // Priority bonus
      score += suggestion.priority;

      if (score > 0) {
        scoredSuggestions[suggestion] = score;
      }
    }

    // Sort by score and take top suggestions
    final sortedSuggestions = scoredSuggestions.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Take top 4 suggestions, ensuring variety
    final selectedSuggestions = <AISuggestion>[];
    final usedCategories = <String>{};

    for (final entry in sortedSuggestions) {
      if (selectedSuggestions.length >= 4) break;
      
      final suggestion = entry.key;
      
      // Ensure category variety (max 2 per category)
      final categoryCount = selectedSuggestions.where((s) => s.category == suggestion.category).length;
      if (categoryCount < 2) {
        selectedSuggestions.add(suggestion);
        usedCategories.add(suggestion.category);
      }
    }

    // If we don't have enough suggestions, add some general wellness ones
    if (selectedSuggestions.length < 2) {
      for (final suggestion in _allSuggestions) {
        if (selectedSuggestions.length >= 2) break;
        if (!selectedSuggestions.contains(suggestion) && 
            !suggestion.requiresFaithMode && 
            suggestion.tags.contains('wellness')) {
          selectedSuggestions.add(suggestion);
        }
      }
    }

    return selectedSuggestions;
  }

  /// Check if suggestion is relevant to a specific pain region
  static bool _isRegionRelevant(AISuggestion suggestion, String region) {
    final regionMappings = {
      'Head/Neck': ['pain', 'tension', 'breathing'],
      'Back': ['pain', 'stretching', 'heat'],
      'Legs': ['pain', 'exercise', 'walking'],
      'Shoulders': ['pain', 'tension', 'stretching'],
      'Arms': ['pain', 'exercise'],
      'Chest': ['pain', 'breathing'],
      'Abdomen': ['pain', 'breathing'],
      'Hips': ['pain', 'stretching'],
      'Feet': ['pain', 'walking'],
    };

    final relevantTags = regionMappings[region] ?? [];
    return relevantTags.any((tag) => suggestion.tags.contains(tag));
  }

  /// Check if suggestion is relevant to a specific urge type
  static bool _isUrgeTypeRelevant(AISuggestion suggestion, String urgeType) {
    final urgeMappings = {
      'substance': ['urge', 'craving', 'social', 'exercise'],
      'food': ['urge', 'craving', 'mindfulness', 'exercise'],
      'shopping': ['urge', 'craving', 'gratitude', 'service'],
      'social_media': ['urge', 'craving', 'social', 'mindfulness'],
      'gaming': ['urge', 'craving', 'exercise', 'social'],
      'work': ['urge', 'craving', 'mindfulness', 'breathing'],
      'relationships': ['urge', 'craving', 'social', 'prayer'],
      'pride': ['humility', 'prayer', 'service'],
      'envy': ['gratitude', 'service', 'contentment'],
      'lust': ['prayer', 'mindfulness', 'exercise'],
      'greed': ['gratitude', 'service', 'contentment'],
      'anger': ['breathing', 'prayer', 'mindfulness'],
      'sloth': ['exercise', 'service', 'motivation'],
      'gluttony': ['mindfulness', 'exercise', 'gratitude'],
      'lost': ['prayer', 'scripture', 'guidance'],
    };

    final relevantTags = urgeMappings[urgeType] ?? [];
    return relevantTags.any((tag) => suggestion.tags.contains(tag));
  }

  /// Get explanation for why suggestions were made
  static String getExplanation(CheckInData data, List<AISuggestion> suggestions) {
    final explanations = <String>[];

    if (data.painLevel > 0) {
      String painDesc = _getPainLevelDescription(data.painLevel);
      explanations.add('your ${painDesc} pain level (${data.painLevel.toStringAsFixed(1)}/10)');
      
      if (data.painRegions.isNotEmpty) {
        if (data.painRegions.length == 1) {
          explanations.add('in your ${data.painRegions.first}');
        } else {
          explanations.add('affecting your ${data.painRegions.join(', ')}');
        }
      }
    }

    if (data.urgeLevel > 0) {
      String urgeDesc = _getUrgeLevelDescription(data.urgeLevel);
      explanations.add('your ${urgeDesc} urge level (${data.urgeLevel.toStringAsFixed(1)}/10)');
      
      if (data.urgeTypes.isNotEmpty) {
        if (data.urgeTypes.length == 1) {
          explanations.add('with ${data.urgeTypes.first}');
        } else {
          explanations.add('including ${data.urgeTypes.join(', ')}');
        }
      }
    }

    if (data.rpeLevel >= 7) {
      explanations.add('your high physical exertion level (${data.rpeLevel}/10)');
    } else if (data.rpeLevel <= 3) {
      explanations.add('your low physical exertion level (${data.rpeLevel}/10)');
    }

    if (data.faithMode.isActivated) {
      explanations.add('your faith journey in ${data.faithMode.name} mode');
    }

    if (explanations.isEmpty) {
      return 'Here are some general wellness suggestions for you today:';
    }

    return 'Based on ${explanations.join(', ')}, here are personalized suggestions:';
  }

  /// Get descriptive text for pain level
  static String _getPainLevelDescription(double painLevel) {
    if (painLevel >= 8) return 'severe';
    if (painLevel >= 6) return 'significant';
    if (painLevel >= 4) return 'moderate';
    if (painLevel >= 2) return 'mild';
    return 'low';
  }

  /// Get descriptive text for urge level
  static String _getUrgeLevelDescription(double urgeLevel) {
    if (urgeLevel >= 8) return 'very strong';
    if (urgeLevel >= 6) return 'strong';
    if (urgeLevel >= 4) return 'moderate';
    if (urgeLevel >= 2) return 'mild';
    return 'low';
  }

  /// Helper methods for unified schema
  static String _getCategoryFromUrgeType(String urgeType) {
    switch (urgeType) {
      case 'substance_use':
      case 'food':
      case 'shopping':
      case 'social_media':
      case 'gaming':
        return 'coping';
      case 'work':
        return 'exercise';
      case 'relationships':
        return 'social';
      case 'pride':
      case 'envy':
      case 'lust':
      case 'greed':
      case 'anger':
      case 'sloth':
      case 'gluttony':
      case 'feeling_lost':
        return 'spiritual';
      default:
        return 'coping';
    }
  }

  static String _getIconFromUrgeType(String urgeType) {
    switch (urgeType) {
      case 'substance_use': return 'local_drink';
      case 'food': return 'restaurant';
      case 'shopping': return 'shopping_cart';
      case 'social_media': return 'share';
      case 'gaming': return 'sports_esports';
      case 'work': return 'work';
      case 'relationships': return 'people';
      case 'pride': return 'trending_up';
      case 'envy': return 'visibility';
      case 'lust': return 'favorite';
      case 'greed': return 'attach_money';
      case 'anger': return 'flash_on';
      case 'sloth': return 'bedtime';
      case 'gluttony': return 'restaurant';
      case 'feeling_lost': return 'explore_off';
      default: return 'psychology';
    }
  }

  static int _calculatePriority(double urgeLevel, String actionTitle) {
    int basePriority = 3;
    
    // Boost priority for high urge levels
    if (urgeLevel >= 8) basePriority += 2;
    else if (urgeLevel >= 6) basePriority += 1;
    
    // Boost priority for critical actions
    if (actionTitle.toLowerCase().contains('help') || 
        actionTitle.toLowerCase().contains('support')) {
      basePriority += 1;
    }
    
    return basePriority.clamp(1, 5);
  }

  static String _generateUnifiedReasoning(String urgeType, double urgeLevel, String actionTitle) {
    final urgeDesc = _getUrgeLevelDescription(urgeLevel);
    return 'Recommended for ${urgeDesc} ${urgeType.replaceAll('_', ' ')} urges (${urgeLevel.toStringAsFixed(1)}/10). This action helps address the specific challenge you\'re facing right now.';
  }
}
