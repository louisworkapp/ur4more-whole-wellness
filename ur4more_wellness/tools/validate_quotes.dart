import 'dart:convert';
import 'dart:io';

void main() {
  print('Validating quote libraries...');
  
  // Load and validate faith quotes
  final faithFile = File('assets/quotes/quotes_faith_seed.json');
  final faithQuotes = jsonDecode(faithFile.readAsStringSync()) as List;
  print('Faith quotes: ${faithQuotes.length}');
  
  // Load and validate secular quotes
  final secularFile = File('assets/quotes/quotes_secular_seed.json');
  final secularQuotes = jsonDecode(secularFile.readAsStringSync()) as List;
  print('Secular quotes: ${secularQuotes.length}');
  
  print('Total quotes: ${faithQuotes.length + secularQuotes.length}');
  
  // Validate schema
  validateSchema(faithQuotes, 'faith');
  validateSchema(secularQuotes, 'secular');
  
  // Check tier distribution
  checkTierDistribution([...faithQuotes, ...secularQuotes]);
  
  print('Validation complete!');
}

void validateSchema(List quotes, String category) {
  print('\nValidating $category quotes schema...');
  
  for (int i = 0; i < quotes.length; i++) {
    final quote = quotes[i] as Map<String, dynamic>;
    
    // Check required fields
    final requiredFields = ['id', 'text', 'author', 'source', 'tags', 'tierMin', 'lang', 'length', 'weight', 'origin', 'category'];
    for (final field in requiredFields) {
      if (!quote.containsKey(field)) {
        throw Exception('Quote $i missing field: $field');
      }
    }
    
    // Check text length
    final text = quote['text'] as String;
    if (text.length < 1 || text.length > 140) {
      throw Exception('Quote $i invalid length: ${text.length}');
    }
    
    // Check category
    if (quote['category'] != category) {
      throw Exception('Quote $i wrong category: ${quote['category']}');
    }
    
    // Check tierMin
    if (!['off', 'light', 'disciple', 'kingdom'].contains(quote['tierMin'])) {
      throw Exception('Quote $i invalid tierMin: ${quote['tierMin']}');
    }
  }
  
  print('$category quotes schema validation passed!');
}

void checkTierDistribution(List quotes) {
  print('\nChecking tier distribution...');
  
  final counts = <String, int>{};
  for (final quote in quotes) {
    final tier = quote['tierMin'] as String;
    counts[tier] = (counts[tier] ?? 0) + 1;
  }
  
  final total = quotes.length;
  final expectedDistribution = {
    'off': 0.20,
    'light': 0.40,
    'disciple': 0.30,
    'kingdom': 0.10,
  };
  
  for (final entry in expectedDistribution.entries) {
    final expected = (total * entry.value).round();
    final actual = counts[entry.key] ?? 0;
    final percentage = (actual / total * 100).toStringAsFixed(1);
    print('${entry.key}: $actual/$total ($percentage%) - expected: $expected');
  }
}
