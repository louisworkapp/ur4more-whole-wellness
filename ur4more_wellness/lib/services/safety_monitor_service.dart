import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Safety monitoring service to detect signs of self-harm or threats to others
/// and provide immediate access to official resources and hotlines
class SafetyMonitorService {
  
  /// Keywords and phrases that indicate potential self-harm or suicidal ideation
  static const List<String> _selfHarmKeywords = [
    // Direct statements
    'kill myself', 'end my life', 'not want to live', 'better off dead',
    'suicide', 'suicidal', 'want to die', 'end it all', 'give up',
    'hurt myself', 'harm myself', 'cut myself', 'overdose',
    
    // Indirect statements
    'no point', 'hopeless', 'worthless', 'burden', 'everyone would be better',
    'can\'t go on', 'too much', 'can\'t handle', 'overwhelmed',
    'no way out', 'trapped', 'stuck', 'no future',
    
    // Emotional indicators
    'hate myself', 'deserve to die', 'punish myself', 'self-punishment',
    'self-destructive', 'self-sabotage', 'ruin everything',
    
    // Method-specific
    'pills', 'medication overdose', 'cutting', 'burning', 'hanging',
    'jumping', 'driving off', 'crash', 'accident',
  ];

  /// Keywords and phrases that indicate threats to others
  static const List<String> _threatKeywords = [
    'kill you', 'hurt you', 'harm you', 'attack', 'violence',
    'revenge', 'payback', 'get even', 'destroy you', 'ruin you',
    'threaten', 'threat', 'warning', 'last chance', 'final warning',
    'going to hurt', 'planning to', 'thinking about hurting',
    'weapon', 'gun', 'knife', 'bomb', 'explosive',
  ];

  /// Crisis hotlines and resources by country
  static const Map<String, Map<String, String>> _crisisResources = {
    'US': {
      'name': 'National Suicide Prevention Lifeline',
      'phone': '988',
      'text': 'Text HOME to 741741',
      'chat': 'https://suicidepreventionlifeline.org/chat/',
      'website': 'https://suicidepreventionlifeline.org/',
    },
    'CA': {
      'name': 'Crisis Services Canada',
      'phone': '1-833-456-4566',
      'text': 'Text 45645',
      'chat': 'https://www.crisisservicescanada.ca/en/',
      'website': 'https://www.crisisservicescanada.ca/',
    },
    'UK': {
      'name': 'Samaritans',
      'phone': '116 123',
      'text': 'Text SHOUT to 85258',
      'chat': 'https://www.samaritans.org/how-we-can-help/contact-samaritan/',
      'website': 'https://www.samaritans.org/',
    },
    'AU': {
      'name': 'Lifeline Australia',
      'phone': '13 11 14',
      'text': 'Text 0477 13 11 14',
      'chat': 'https://www.lifeline.org.au/crisis-chat',
      'website': 'https://www.lifeline.org.au/',
    },
    'DEFAULT': {
      'name': 'International Association for Suicide Prevention',
      'phone': 'Emergency: 112 or 911',
      'text': 'Find local crisis text line',
      'chat': 'https://www.iasp.info/resources/Crisis_Centres/',
      'website': 'https://www.iasp.info/resources/Crisis_Centres/',
    },
  };

  /// Analyze text for signs of self-harm or threats
  static SafetyAnalysisResult analyzeText(String text) {
    if (text.isEmpty) return SafetyAnalysisResult.safe();
    
    final lowerText = text.toLowerCase();
    
    // Check for self-harm indicators
    final selfHarmMatches = _selfHarmKeywords.where((keyword) => 
        lowerText.contains(keyword.toLowerCase())).toList();
    
    // Check for threat indicators
    final threatMatches = _threatKeywords.where((keyword) => 
        lowerText.contains(keyword.toLowerCase())).toList();
    
    // Determine risk level
    SafetyRiskLevel riskLevel = SafetyRiskLevel.safe;
    List<String> concerns = [];
    
    if (threatMatches.isNotEmpty) {
      riskLevel = SafetyRiskLevel.high; // Threats to others are always high risk
      concerns.add('Potential threat to others detected');
    } else if (selfHarmMatches.length >= 3) {
      riskLevel = SafetyRiskLevel.high; // Multiple self-harm indicators
      concerns.add('Multiple signs of self-harm detected');
    } else if (selfHarmMatches.length >= 2) {
      riskLevel = SafetyRiskLevel.medium; // Some self-harm indicators
      concerns.add('Signs of self-harm detected');
    } else if (selfHarmMatches.isNotEmpty) {
      riskLevel = SafetyRiskLevel.low; // Single indicator
      concerns.add('Possible concern detected');
    }
    
    return SafetyAnalysisResult(
      riskLevel: riskLevel,
      concerns: concerns,
      matchedKeywords: [...selfHarmMatches, ...threatMatches],
      requiresImmediateAction: riskLevel == SafetyRiskLevel.high,
    );
  }

  /// Analyze check-in data for concerning patterns
  static SafetyAnalysisResult analyzeCheckInData({
    required double painLevel,
    required List<String> painRegions,
    required double urgeLevel,
    required List<String> urgeTypes,
    required int rpeLevel,
    required String? journalText,
    required String? mood,
  }) {
    final concerns = <String>[];
    SafetyRiskLevel riskLevel = SafetyRiskLevel.safe;
    
    // Analyze journal text if provided
    if (journalText != null && journalText.isNotEmpty) {
      final textAnalysis = analyzeText(journalText);
      if (textAnalysis.riskLevel != SafetyRiskLevel.safe) {
        concerns.addAll(textAnalysis.concerns);
        riskLevel = textAnalysis.riskLevel;
      }
    }
    
    // Check for concerning pain patterns
    if (painLevel >= 9) {
      concerns.add('Extremely high pain level reported');
      if (riskLevel == SafetyRiskLevel.safe) riskLevel = SafetyRiskLevel.low;
    }
    
    // Check for concerning urge patterns
    if (urgeLevel >= 9) {
      concerns.add('Extremely high urge level reported');
      if (riskLevel == SafetyRiskLevel.safe) riskLevel = SafetyRiskLevel.low;
    }
    
    // Check for concerning mood indicators
    if (mood != null) {
      final lowerMood = mood.toLowerCase();
      if (lowerMood.contains('hopeless') || lowerMood.contains('worthless') || 
          lowerMood.contains('despair') || lowerMood.contains('suicidal')) {
        concerns.add('Concerning mood indicators');
        riskLevel = SafetyRiskLevel.medium;
      }
    }
    
    return SafetyAnalysisResult(
      riskLevel: riskLevel,
      concerns: concerns,
      matchedKeywords: [],
      requiresImmediateAction: riskLevel == SafetyRiskLevel.high,
    );
  }

  /// Get crisis resources for the user's region
  static Map<String, String> getCrisisResources([String? countryCode]) {
    return _crisisResources[countryCode ?? 'US'] ?? _crisisResources['DEFAULT']!;
  }

  /// Launch emergency call
  static Future<void> launchEmergencyCall([String? countryCode]) async {
    final resources = getCrisisResources(countryCode);
    final phoneNumber = resources['phone']!;
    
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  /// Launch crisis text line
  static Future<void> launchCrisisText([String? countryCode]) async {
    final resources = getCrisisResources(countryCode);
    final textNumber = resources['text']!;
    
    // Extract phone number from text instruction
    final phoneMatch = RegExp(r'\d+').firstMatch(textNumber);
    if (phoneMatch != null) {
      final phoneNumber = phoneMatch.group(0)!;
      final uri = Uri.parse('sms:$phoneNumber');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  /// Launch crisis chat
  static Future<void> launchCrisisChat([String? countryCode]) async {
    final resources = getCrisisResources(countryCode);
    final chatUrl = resources['chat']!;
    
    final uri = Uri.parse(chatUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  /// Launch crisis website
  static Future<void> launchCrisisWebsite([String? countryCode]) async {
    final resources = getCrisisResources(countryCode);
    final websiteUrl = resources['website']!;
    
    final uri = Uri.parse(websiteUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

/// Safety risk levels
enum SafetyRiskLevel {
  safe,
  low,
  medium,
  high,
}

/// Result of safety analysis
class SafetyAnalysisResult {
  final SafetyRiskLevel riskLevel;
  final List<String> concerns;
  final List<String> matchedKeywords;
  final bool requiresImmediateAction;

  const SafetyAnalysisResult({
    required this.riskLevel,
    required this.concerns,
    required this.matchedKeywords,
    required this.requiresImmediateAction,
  });

  factory SafetyAnalysisResult.safe() {
    return const SafetyAnalysisResult(
      riskLevel: SafetyRiskLevel.safe,
      concerns: [],
      matchedKeywords: [],
      requiresImmediateAction: false,
    );
  }

  bool get isSafe => riskLevel == SafetyRiskLevel.safe;
  bool get hasConcerns => concerns.isNotEmpty;
  bool get needsImmediateHelp => requiresImmediateAction;
}
