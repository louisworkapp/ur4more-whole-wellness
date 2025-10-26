import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class InspirationService {
  List<Map<String,String>> _secular = [];
  List<Map<String,String>> _scripture = [];

  Future<void> load() async {
    final s = await rootBundle.loadString('assets/inspiration/secular_quotes.json');
    final b = await rootBundle.loadString('assets/inspiration/scripture_kjv.json');
    _secular = (jsonDecode(s) as List).cast<Map<String, dynamic>>()
        .map((e)=>{'text':e['text'].toString(),'author':e['author'].toString()}).toList();
    _scripture = (jsonDecode(b) as List).cast<Map<String, dynamic>>()
        .map((e)=>{'text':e['text'].toString(),'ref':e['ref'].toString()}).toList();
  }

  Map<String,String>? randomSecular() {
    if (_secular.isEmpty) return null;
    _secular.shuffle(); return _secular.first;
  }
  Map<String,String>? randomScripture() {
    if (_scripture.isEmpty) return null;
    _scripture.shuffle(); return _scripture.first;
  }
}
