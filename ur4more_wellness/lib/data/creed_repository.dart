import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class CreedData {
  final String short;
  final String hero;
  final List<String> full;
  final List<Map<String, String>> kvs;
  final int maxVerseSentences;
  final bool showConsentForFaithOverlays;

  const CreedData({
    required this.short,
    required this.hero,
    required this.full,
    required this.kvs,
    required this.maxVerseSentences,
    required this.showConsentForFaithOverlays,
  });
}

class CreedRepository {
  static const String _path = 'assets/core/creed.json';
  CreedData? _cache;

  Future<CreedData> load() async {
    if (_cache != null) return _cache!;
    
    try {
      final raw = json.decode(await rootBundle.loadString(_path));
      final c = raw['creed'];
      final kvs = (c['kvs'] as List).cast<Map>().map((m) =>
        m.map((k, v) => MapEntry(k.toString(), v.toString()))).toList();
      
      _cache = CreedData(
        short: c['short'] ?? '',
        hero: c['hero'] ?? '',
        full: (c['full'] as List?)?.cast<String>() ?? [],
        kvs: kvs.cast<Map<String, String>>(),
        maxVerseSentences: (c['ui']?['maxVerseSentences'] ?? 2) as int,
        showConsentForFaithOverlays: (c['ui']?['showConsentForFaithOverlays'] ?? true) as bool,
      );
    } catch (e) {
      // Fallback data if asset loading fails
      _cache = const CreedData(
        short: 'Two powers shape our lives—Light and Darkness. We believe the true Light is God the Father, and Jesus Christ His Son is Lord of all.',
        hero: 'We live in a world of Light and Darkness. God the Father created all things, and Jesus Christ His Son is Lord of all.',
        full: [],
        kvs: [],
        maxVerseSentences: 2,
        showConsentForFaithOverlays: true,
      );
    }
    
    return _cache!;
  }
}
