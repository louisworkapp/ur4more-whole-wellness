import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../services/faith_service.dart';

class TruthAnchor {
  final String concept;
  final String summaryOff;
  final String summaryOn;
  final List<Map<String, String>> scriptureKJV;

  const TruthAnchor({
    required this.concept,
    required this.summaryOff,
    required this.summaryOn,
    required this.scriptureKJV,
  });
}

class TruthService {
  static const String _path = 'assets/core/truth_anchors.json';
  List<TruthAnchor>? _anchors;

  Future<void> load() async {
    if (_anchors != null) return;
    
    try {
      final raw = json.decode(await rootBundle.loadString(_path));
      final anchorsList = raw['anchors'] as List;
      
      _anchors = anchorsList.map((anchor) {
        final kvs = (anchor['scriptureKJV'] as List?)?.cast<Map>() ?? [];
        final scriptureKJV = kvs.map((m) =>
          m.map((k, v) => MapEntry(k.toString(), v.toString()))).toList();
        
        return TruthAnchor(
          concept: anchor['concept'] ?? '',
          summaryOff: anchor['summaryOff'] ?? '',
          summaryOn: anchor['summaryOn'] ?? '',
          scriptureKJV: scriptureKJV.cast<Map<String, String>>(),
        );
      }).toList();
    } catch (e) {
      // Fallback data if asset loading fails
      _anchors = [
        const TruthAnchor(
          concept: 'Objective truth',
          summaryOff: 'Tell the truth to reduce cognitive dissonance.',
          summaryOn: 'Truth is grounded in God; lies enslave.',
          scriptureKJV: [
            {'ref': 'John 14:6', 'text': 'I am the way, the truth, and the life.'}
          ],
        ),
      ];
    }
  }

  TruthAnchor? _get(String concept) {
    if (_anchors == null) return null;
    try {
      return _anchors!.firstWhere((a) => a.concept.toLowerCase() == concept.toLowerCase());
    } catch (e) {
      return null;
    }
  }

  String summarize(String concept, FaithTier mode) {
    final anchor = _get(concept);
    if (anchor == null) return concept;
    
    return mode.isOff ? anchor.summaryOff : anchor.summaryOn;
  }

  List<Map<String, String>> scripture(String concept, FaithTier mode) {
    if (!mode.isActivated) return const [];
    
    final anchor = _get(concept);
    return anchor?.scriptureKJV ?? [];
  }

  String getReframeSuccessMessage(String concept, FaithTier mode) {
    if (mode.isOff) {
      return 'Aligned to truth.';
    } else {
      final anchor = _get(concept);
      if (anchor != null && anchor.scriptureKJV.isNotEmpty) {
        return 'Aligned to Christ\'s truth — ${anchor.scriptureKJV.first['ref']}';
      }
      return 'Aligned to Christ\'s truth.';
    }
  }

  String getHabitFooter(FaithTier mode) {
    if (mode.isOff) {
      return 'Choose what leads to life.';
    } else {
      return 'Present your body a living sacrifice (Rom 12:1).';
    }
  }

  String getLightStreakText(FaithTier mode) {
    return summarize('Responsibility', mode);
  }
}
