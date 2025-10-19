import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class Quote {
  final String id, text, author;
  final bool offSafe, faithOk;
  final bool scriptureEnabled;
  final String scriptureRef, scriptureText;
  
  Quote.from(Map<String, dynamic> m)
      : id = m['id'],
        text = m['text'],
        author = m['author'],
        offSafe = m['modes']?['off_safe'] == true,
        faithOk = m['modes']?['faith_ok'] == true,
        scriptureEnabled = m['scripture_kjv']?['enabled'] == true,
        scriptureRef = (m['scripture_kjv']?['ref'] ?? '').toString(),
        scriptureText = (m['scripture_kjv']?['text'] ?? '').toString();
}

class QuotesManifest {
  final int shardCount;
  final List<String> files;
  
  QuotesManifest({required this.shardCount, required this.files});
  
  static Future<QuotesManifest> load() async {
    final raw = json.decode(await rootBundle.loadString('assets/quotes/manifest.json'));
    return QuotesManifest(
      shardCount: (raw['shard_count'] as num).toInt(),
      files: (raw['files'] as List).map((e) => e.toString()).toList(),
    );
  }
}

class QuotesRepository {
  Future<Quote?> pickDaily({required bool offMode}) async {
    final manifest = await QuotesManifest.load();
    if (manifest.files.isEmpty) return null;
    
    final idx = _shardIndexForToday(manifest.shardCount);
    final shardPath = manifest.files[idx % manifest.files.length];
    final data = json.decode(await rootBundle.loadString(shardPath)) as Map<String, dynamic>;
    final list = (data['quotes'] as List).cast<Map>();
    
    final pool = list.where((m) => 
      offMode ? (m['modes']?['off_safe'] == true) : (m['modes']?['faith_ok'] == true)
    ).toList();
    
    if (pool.isEmpty) return null;
    
    final rnd = Random(DateTime.now().toUtc().day + DateTime.now().toUtc().month * 31);
    return Quote.from(pool[rnd.nextInt(pool.length)].cast<String, dynamic>());
  }

  int _shardIndexForToday(int shardCount) {
    final now = DateTime.now().toUtc();
    final yday = DateTime.utc(now.year, now.month, now.day)
        .difference(DateTime.utc(now.year, 1, 1)).inDays;
    return ((now.year * 1000) + yday) % (shardCount == 0 ? 1 : shardCount);
  }
}
