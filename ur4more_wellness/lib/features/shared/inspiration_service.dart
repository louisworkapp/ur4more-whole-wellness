import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class InspirationService {
  List<Map<String,String>> _secular = [];
  List<Map<String,String>> _scripture = [];

  Future<void> load() async {
    final s = await rootBundle.loadString('assets/inspiration/secular_quotes.json');
    final b = await rootBundle.loadString('assets/inspiration/scripture_kjv.json');
    _secular = (jsonDecode(s) as List).cast<Map<String, dynamic>>()
      .map((e)=>{'text':'${e['text']}', 'author':'${e['author']}'}).toList();
    _scripture = (jsonDecode(b) as List).cast<Map<String, dynamic>>()
      .map((e)=>{'text':'${e['text']}', 'ref':'${e['ref']}'}).toList();
  }

  Map<String,String>? secular(){ if (_secular.isEmpty) return null; _secular.shuffle(); return _secular.first; }
  Map<String,String>? scripture(){ if (_scripture.isEmpty) return null; _scripture.shuffle(); return _scripture.first; }
}
