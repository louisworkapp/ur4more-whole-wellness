import 'dart:convert';
import 'dart:io';

void main() {
  print('Sample quotes from both libraries:\n');
  
  // Load quotes
  final faithQuotes = jsonDecode(File('assets/quotes/quotes_faith_seed.json').readAsStringSync()) as List;
  final secularQuotes = jsonDecode(File('assets/quotes/quotes_secular_seed.json').readAsStringSync()) as List;
  
  print('=== FAITH-EXPLICIT QUOTES ===');
  for (int i = 0; i < 5; i++) {
    final quote = faithQuotes[i] as Map<String, dynamic>;
    print('${i + 1}. "${quote['text']}"');
    print('   Tags: ${quote['tags']} | Tier: ${quote['tierMin']} | Length: ${quote['length']}');
    print('');
  }
  
  print('=== SECULAR-SUBTLE QUOTES ===');
  for (int i = 0; i < 5; i++) {
    final quote = secularQuotes[i] as Map<String, dynamic>;
    print('${i + 1}. "${quote['text']}"');
    print('   Tags: ${quote['tags']} | Tier: ${quote['tierMin']} | Length: ${quote['length']}');
    print('');
  }
  
  // Check for key themes
  print('=== THEME CHECK ===');
  checkTheme('die to self', faithQuotes, secularQuotes);
  checkTheme('fight from victory', faithQuotes, secularQuotes);
  checkTheme('surrender', faithQuotes, secularQuotes);
  checkTheme('identity', faithQuotes, secularQuotes);
}

void checkTheme(String theme, List faithQuotes, List secularQuotes) {
  final faithCount = faithQuotes.where((q) => 
    (q['text'] as String).toLowerCase().contains(theme) ||
    (q['tags'] as List).any((tag) => tag.toString().toLowerCase().contains(theme))
  ).length;
  
  final secularCount = secularQuotes.where((q) => 
    (q['text'] as String).toLowerCase().contains(theme) ||
    (q['tags'] as List).any((tag) => tag.toString().toLowerCase().contains(theme))
  ).length;
  
  print('Theme "$theme": Faith=$faithCount, Secular=$secularCount');
}
