import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class VerseItem {
  final String id;
  final String ref;
  final String text;
  final String theme;
  
  VerseItem(this.id, this.ref, this.text, this.theme);
}

class RenewingMindSet {
  final List<VerseItem> verses;
  
  RenewingMindSet(this.verses);

  static Future<RenewingMindSet> load() async {
    final raw = await rootBundle.loadString('assets/mind/scripture_sets/renewing_mind_kjv.json');
    final map = json.decode(raw) as Map<String, dynamic>;
    final items = (map['verses'] as List).map((v) =>
      VerseItem(v['id'], v['ref'], v['text'], v['theme'])
    ).toList();
    return RenewingMindSet(items);
  }

  VerseItem pick({String? theme}) {
    final pool = theme == null ? verses : verses.where((v) => v.theme == theme).toList();
    if (pool.isEmpty) return verses.first; // fallback
    pool.shuffle();
    return pool.first;
  }

  List<VerseItem> getByTheme(String theme) {
    return verses.where((v) => v.theme == theme).toList();
  }

  List<String> get themes {
    return verses.map((v) => v.theme).toSet().toList();
  }
}
