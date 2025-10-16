import 'dart:convert';
import 'dart:io';
import 'dart:math';

void main() {
  final generator = QuoteGenerator();
  generator.generateQuotes();
}

class QuoteGenerator {
  static const int faithCount = 600;
  static const int secularCount = 400;
  static const int maxLength = 140;
  static const double nearDuplicateThreshold = 0.8;
  
  final Random _random = Random(42); // Fixed seed for reproducibility
  final Set<String> _usedTexts = <String>{};
  final List<Map<String, dynamic>> _allQuotes = [];
  
  // Banned terms from brand rules
  static const List<String> bannedTerms = [
    'yoga', 'chakra', 'mantra', 'tarot', 'astrology', 'namaste'
  ];
  
  // Tier distribution percentages
  static const Map<String, double> tierDistribution = {
    'off': 0.20,
    'light': 0.40,
    'disciple': 0.30,
    'kingdom': 0.10,
  };
  
  // Available tags
  static const List<String> allTags = [
    'identity', 'surrender', 'peace', 'courage', 'humility', 'service',
    'compassion', 'hope', 'wisdom', 'discipline', 'gratitude', 'patience',
    'forgiveness', 'resilience', 'purpose', 'prayer', 'rest', 'perseverance',
    'justice', 'mercy', 'love', 'grace', 'faith', 'trust', 'strength',
    'healing', 'freedom', 'joy', 'contentment', 'generosity', 'kindness'
  ];
  
  // Faith-explicit phrase banks
  final Map<String, List<String>> faithPhrases = {
    'identity': [
      'You are chosen and loved',
      'Your worth is settled in grace',
      'You belong to something greater',
      'Your identity is secure in love',
      'You are a child of the King',
      'Your value comes from above',
      'You are fearfully and wonderfully made',
      'You are called and equipped',
      'Your purpose is written in love',
      'You are redeemed and restored',
      'You are precious in His sight',
      'Your life has eternal value',
      'You are created for a purpose',
      'Your worth is unshakeable',
      'You are loved beyond measure',
      'Your identity is found in Christ',
      'You are a masterpiece of grace',
      'Your value is not determined by performance',
      'You are accepted in the Beloved',
      'Your worth is established forever'
    ],
    'surrender': [
      'Let the small self step back so love can lead',
      'Release the need to be first; become free to serve',
      'Quiet the ego; let grace grow strong',
      'Surrender your way to find His way',
      'Die to self so Christ can live in you',
      'Lay down your crown to receive His crown',
      'Let go of control to find true freedom',
      'Release your grip to receive His grip',
      'Empty yourself to be filled with Him',
      'Step aside so God can step in'
    ],
    'victory': [
      'You don\'t fight for worth—you live from it',
      'Start from the win: you are already chosen and loved',
      'Fight from victory, not for victory',
      'You are already seated in heavenly places',
      'Live from the victory Christ won for you',
      'You don\'t earn love—you receive it',
      'Stand firm in the victory already given',
      'You are more than a conqueror through Him',
      'Live from the finished work of the cross',
      'You are victorious because He is victorious'
    ],
    'prayer': [
      'Pray before you push; peace often answers first',
      'When words fail, prayer speaks',
      'Prayer changes things, starting with you',
      'In prayer, you find both strength and surrender',
      'Prayer is not asking for what you want but aligning with what He wants',
      'Pray without ceasing; live without worry',
      'Prayer moves mountains, starting with the one in your heart',
      'In prayer, you discover you are never alone',
      'Prayer is the bridge between your need and His provision',
      'When you pray, heaven listens and earth responds'
    ],
    'grace': [
      'Grace is not earned; it is received',
      'In your weakness, His grace is sufficient',
      'Grace covers what effort cannot',
      'You are saved by grace, not by works',
      'Grace is the gift that keeps on giving',
      'In grace, you find both acceptance and transformation',
      'Grace meets you where you are but doesn\'t leave you there',
      'The grace of God is greater than your greatest failure',
      'Grace is not a license to sin but freedom from sin',
      'In grace, you discover unconditional love'
    ],
    'peace': [
      'Peace is not the absence of trouble but the presence of God',
      'In Christ, you have peace that surpasses understanding',
      'Peace comes not from perfect circumstances but from perfect trust',
      'Be still and know that He is God',
      'Peace is a fruit of the Spirit, not a product of effort',
      'In His presence, you find perfect peace',
      'Peace is not something you find but Someone who finds you',
      'Cast your anxiety on Him because He cares for you',
      'Peace is the result of surrender, not control',
      'In prayer, you exchange worry for peace'
    ],
    'service': [
      'The greatest among you will be your servant',
      'Serve others as Christ served you',
      'In serving, you discover your true greatness',
      'Service is love in action',
      'The way up is the way down—serve',
      'In serving others, you serve Christ',
      'Service transforms both the giver and receiver',
      'True leadership is humble service',
      'Serve not to be seen but to be like Him',
      'In service, you find your highest calling'
    ],
    'hope': [
      'Hope is not wishful thinking but confident expectation',
      'In Christ, you have a hope that does not disappoint',
      'Hope is the anchor for your soul',
      'Your hope is built on nothing less than Jesus\' blood and righteousness',
      'Hope sees beyond the present to the promise',
      'In hope, you find strength for today and vision for tomorrow',
      'Hope is not optimism but faith in God\'s faithfulness',
      'Your hope is secure because His promises are sure',
      'Hope is the light that shines in the darkest night',
      'In hope, you discover that the best is yet to come'
    ]
  };
  
  // Secular-subtle phrase banks (biblically resonant but not obvious)
  final Map<String, List<String>> secularPhrases = {
    'identity': [
      'You are enough, just as you are',
      'Your worth is not earned but inherent',
      'You belong to something greater than yourself',
      'Your value comes from within',
      'You are worthy of love and belonging',
      'Your identity is secure in who you are',
      'You are uniquely and wonderfully made',
      'You are called to something meaningful',
      'Your purpose is written in your heart',
      'You are whole and complete',
      'You are valuable beyond measure',
      'Your life has inherent meaning',
      'You are created for connection',
      'Your worth is unshakeable',
      'You are loved for who you are',
      'Your identity is found in authenticity',
      'You are a masterpiece of potential',
      'Your value is not determined by achievement',
      'You are accepted as you are',
      'Your worth is established in being'
    ],
    'surrender': [
      'Let the ego loosen its grip so love can do the guiding',
      'Release the need to be first; discover the joy of serving',
      'Quiet the inner critic; let compassion grow strong',
      'Surrender your way to find the better way',
      'Let go of perfection to embrace progress',
      'Lay down your defenses to receive connection',
      'Let go of control to find true freedom',
      'Release your grip to receive support',
      'Empty yourself to be filled with purpose',
      'Step aside so wisdom can step in'
    ],
    'victory': [
      'Move from settled worth, not toward it',
      'Start from the win: you are already enough',
      'Fight from strength, not for strength',
      'You are already whole and complete',
      'Live from the victory within you',
      'You don\'t earn love—you receive it',
      'Stand firm in your inherent worth',
      'You are more than your circumstances',
      'Live from the truth of who you are',
      'You are victorious because you are you'
    ],
    'wisdom': [
      'Wisdom comes not from knowing all the answers but from asking the right questions',
      'In stillness, you find the answers you seek',
      'Wisdom is not about being right but about being wise',
      'Listen before you speak; understand before you judge',
      'Wisdom grows in the soil of humility',
      'In reflection, you discover what you already know',
      'Wisdom is the art of knowing what to overlook',
      'True wisdom begins with knowing how little you know',
      'In wisdom, you find both strength and gentleness',
      'Wisdom is not about having all the answers but about asking better questions'
    ],
    'peace': [
      'Peace is not the absence of chaos but the presence of calm',
      'In stillness, you find the peace you seek',
      'Peace comes not from perfect circumstances but from inner calm',
      'Be still and know that you are enough',
      'Peace is a state of mind, not a place',
      'In your center, you find perfect peace',
      'Peace is not something you find but something you cultivate',
      'Release your worries and embrace the present moment',
      'Peace is the result of acceptance, not control',
      'In mindfulness, you exchange worry for peace'
    ],
    'service': [
      'The greatest among you will be the most helpful',
      'Serve others as you would want to be served',
      'In serving, you discover your true greatness',
      'Service is love in action',
      'The way up is the way down—help others up',
      'In serving others, you serve humanity',
      'Service transforms both the giver and receiver',
      'True leadership is humble service',
      'Serve not to be seen but to make a difference',
      'In service, you find your highest calling'
    ],
    'hope': [
      'Hope is not wishful thinking but confident expectation',
      'In hope, you find strength for today and vision for tomorrow',
      'Hope is the anchor for your soul',
      'Your hope is built on the foundation of possibility',
      'Hope sees beyond the present to the potential',
      'In hope, you find the courage to keep going',
      'Hope is not optimism but faith in the process',
      'Your hope is secure because change is possible',
      'Hope is the light that shines in the darkest night',
      'In hope, you discover that the best is yet to come'
    ],
    'courage': [
      'Courage is not the absence of fear but action in spite of it',
      'In courage, you find the strength to be vulnerable',
      'Courage grows when you face what you fear',
      'Be brave enough to be yourself',
      'Courage is the foundation of all other virtues',
      'In courage, you discover what you\'re truly capable of',
      'Courage is not about being fearless but about being faithful',
      'Your courage inspires others to be courageous',
      'Courage is the bridge between fear and freedom',
      'In courage, you find the power to transform your life'
    ]
  };
  
  // Templates for combining phrases
  final List<String> faithTemplates = [
    '{phrase}.',
    '{phrase}—{phrase2}.',
    'When {phrase}, {phrase2}.',
    '{phrase}. {phrase2}.',
    'In {phrase}, you find {phrase2}.',
    '{phrase}. This is the way.',
    '{phrase}. Trust the process.',
    '{phrase}. You are not alone.',
    '{phrase}. Grace is sufficient.',
    '{phrase}. Love wins.',
    'Remember: {phrase}.',
    'Today, {phrase}.',
    '{phrase}. Rest in this truth.',
    '{phrase}. Walk in this reality.',
    '{phrase}. Live from this place.',
    '{phrase}. Stand firm in this.',
    '{phrase}. Hold fast to this.',
    '{phrase}. Believe this deeply.',
    '{phrase}. Receive this fully.',
    '{phrase}. Embrace this completely.'
  ];
  
  final List<String> secularTemplates = [
    '{phrase}.',
    '{phrase}—{phrase2}.',
    'When {phrase}, {phrase2}.',
    '{phrase}. {phrase2}.',
    'In {phrase}, you find {phrase2}.',
    '{phrase}. This is the way.',
    '{phrase}. Trust the process.',
    '{phrase}. You are not alone.',
    '{phrase}. Growth is possible.',
    '{phrase}. Love wins.',
    'Remember: {phrase}.',
    'Today, {phrase}.',
    '{phrase}. Rest in this truth.',
    '{phrase}. Walk in this reality.',
    '{phrase}. Live from this place.',
    '{phrase}. Stand firm in this.',
    '{phrase}. Hold fast to this.',
    '{phrase}. Believe this deeply.',
    '{phrase}. Receive this fully.',
    '{phrase}. Embrace this completely.'
  ];
  
  void generateQuotes() {
    print('Generating quotes...');
    
    // Generate faith-explicit quotes
    generateCategoryQuotes('faith', faithCount, faithPhrases, faithTemplates);
    
    // Generate secular-subtle quotes
    generateCategoryQuotes('secular', secularCount, secularPhrases, secularTemplates);
    
    // Split into two files
    final faithQuotes = _allQuotes.where((q) => q['category'] == 'faith').toList();
    final secularQuotes = _allQuotes.where((q) => q['category'] == 'secular').toList();
    
    // Write files
    writeQuoteFile('assets/quotes/quotes_faith_seed.json', faithQuotes);
    writeQuoteFile('assets/quotes/quotes_secular_seed.json', secularQuotes);
    
    // Validate
    validateQuotes(faithQuotes, secularQuotes);
    
    print('Quote generation complete!');
    print('Faith quotes: ${faithQuotes.length}');
    print('Secular quotes: ${secularQuotes.length}');
  }
  
  void generateCategoryQuotes(String category, int count, Map<String, List<String>> phrases, List<String> templates) {
    int generated = 0;
    int attempts = 0;
    final maxAttempts = count * 5; // Allow more retries
    
    while (generated < count && attempts < maxAttempts) {
      attempts++;
      
      try {
        final quote = generateSingleQuote(category, phrases, templates);
        if (quote != null && !isDuplicate(quote['text'])) {
          _allQuotes.add(quote);
          _usedTexts.add(quote['text']);
          generated++;
        }
      } catch (e) {
        // Skip this attempt and try again
        continue;
      }
    }
    
    if (generated < count) {
      print('Warning: Only generated $generated $category quotes (target: $count)');
    }
  }
  
  Map<String, dynamic>? generateSingleQuote(String category, Map<String, List<String>> phrases, List<String> templates) {
    // Select theme
    final themeKeys = phrases.keys.toList();
    final theme = themeKeys[_random.nextInt(themeKeys.length)];
    final themePhrases = phrases[theme]!;
    
    // Select phrases
    final phrase1 = themePhrases[_random.nextInt(themePhrases.length)];
    String? phrase2;
    if (_random.nextDouble() < 0.3) { // 30% chance of second phrase
      final otherThemes = themeKeys.where((k) => k != theme).toList();
      if (otherThemes.isNotEmpty) {
        final otherTheme = otherThemes[_random.nextInt(otherThemes.length)];
        final otherPhrases = phrases[otherTheme]!;
        phrase2 = otherPhrases[_random.nextInt(otherPhrases.length)];
      }
    }
    
    // Select template
    final template = templates[_random.nextInt(templates.length)];
    
    // Generate text
    String text = template
        .replaceAll('{phrase}', phrase1)
        .replaceAll('{phrase2}', phrase2 ?? '');
    
    // Clean up
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    text = text.replaceAll(RegExp(r'\s+[.!?]'), '.');
    if (!text.endsWith('.')) text += '.';
    
    // Check length
    if (text.length > maxLength) return null;
    
    // Check banned terms
    if (containsBannedTerms(text)) return null;
    
    // Generate metadata
    final id = 'ur4-${category}-${(_allQuotes.length + 1).toString().padLeft(4, '0')}';
    final tags = selectTags(theme, phrase2 != null ? phrases.keys.toList() : [theme]);
    final tierMin = selectTier();
    final weight = 0.7 + (_random.nextDouble() * 0.3); // 0.7 to 1.0
    
    return {
      'id': id,
      'text': text,
      'author': 'UR4MORE',
      'source': 'UR4MORE Originals',
      'tags': tags,
      'tierMin': tierMin,
      'lang': 'en',
      'length': text.length,
      'weight': weight,
      'origin': 'seed',
      'category': category
    };
  }
  
  List<String> selectTags(String primaryTheme, List<String> availableThemes) {
    final tags = <String>[primaryTheme];
    
    // Add 1-2 more tags
    final additionalTags = allTags.where((tag) => 
        tag != primaryTheme && 
        availableThemes.contains(tag) &&
        _random.nextDouble() < 0.4
    ).take(2).toList();
    
    tags.addAll(additionalTags);
    
    // Ensure we have at least 2 tags
    while (tags.length < 2) {
      final randomTag = allTags[_random.nextInt(allTags.length)];
      if (!tags.contains(randomTag)) {
        tags.add(randomTag);
      }
    }
    
    return tags.take(3).toList(); // Max 3 tags
  }
  
  String selectTier() {
    final rand = _random.nextDouble();
    double cumulative = 0.0;
    
    for (final entry in tierDistribution.entries) {
      cumulative += entry.value;
      if (rand <= cumulative) {
        return entry.key;
      }
    }
    
    return 'light'; // Fallback
  }
  
  bool containsBannedTerms(String text) {
    final lowerText = text.toLowerCase();
    return bannedTerms.any((term) => lowerText.contains(term));
  }
  
  bool isDuplicate(String text) {
    if (_usedTexts.contains(text)) return true;
    
    // Check for near duplicates using trigram similarity
    for (final usedText in _usedTexts) {
      if (calculateSimilarity(text, usedText) >= nearDuplicateThreshold) {
        return true;
      }
    }
    
    return false;
  }
  
  double calculateSimilarity(String text1, String text2) {
    final trigrams1 = getTrigrams(text1);
    final trigrams2 = getTrigrams(text2);
    
    if (trigrams1.isEmpty || trigrams2.isEmpty) return 0.0;
    
    final intersection = trigrams1.intersection(trigrams2).length;
    final union = trigrams1.union(trigrams2).length;
    
    return intersection / union;
  }
  
  Set<String> getTrigrams(String text) {
    final trigrams = <String>{};
    final cleanText = text.toLowerCase().replaceAll(RegExp(r'[^a-z\s]'), '');
    
    for (int i = 0; i <= cleanText.length - 3; i++) {
      trigrams.add(cleanText.substring(i, i + 3));
    }
    
    return trigrams;
  }
  
  void writeQuoteFile(String filename, List<Map<String, dynamic>> quotes) {
    final file = File(filename);
    file.createSync(recursive: true);
    
    final jsonString = const JsonEncoder.withIndent('  ').convert(quotes);
    file.writeAsStringSync(jsonString);
    
    print('Written $filename with ${quotes.length} quotes');
  }
  
  void validateQuotes(List<Map<String, dynamic>> faithQuotes, List<Map<String, dynamic>> secularQuotes) {
    print('\nValidating quotes...');
    
    // Check counts
    if (faithQuotes.length < 580) {
      throw Exception('Faith quotes count too low: ${faithQuotes.length} (min: 580)');
    }
    if (secularQuotes.length < 380) {
      throw Exception('Secular quotes count too low: ${secularQuotes.length} (min: 380)');
    }
    
    // Validate all quotes
    for (final quote in [...faithQuotes, ...secularQuotes]) {
      validateSingleQuote(quote);
    }
    
    // Check tier distribution
    checkTierDistribution([...faithQuotes, ...secularQuotes]);
    
    print('Validation passed!');
  }
  
  void validateSingleQuote(Map<String, dynamic> quote) {
    // Check required fields
    final requiredFields = ['id', 'text', 'author', 'source', 'tags', 'tierMin', 'lang', 'length', 'weight', 'origin', 'category'];
    for (final field in requiredFields) {
      if (!quote.containsKey(field)) {
        throw Exception('Missing required field: $field');
      }
    }
    
    // Check text length
    final text = quote['text'] as String;
    if (text.length < 1 || text.length > 140) {
      throw Exception('Invalid text length: ${text.length} (must be 1-140)');
    }
    
    // Check banned terms
    if (containsBannedTerms(text)) {
      throw Exception('Banned term found in: $text');
    }
    
    // Check category
    if (!['faith', 'secular'].contains(quote['category'])) {
      throw Exception('Invalid category: ${quote['category']}');
    }
    
    // Check tierMin
    if (!['off', 'light', 'disciple', 'kingdom'].contains(quote['tierMin'])) {
      throw Exception('Invalid tierMin: ${quote['tierMin']}');
    }
    
    // Check tags
    final tags = quote['tags'] as List;
    if (tags.isEmpty) {
      throw Exception('Tags cannot be empty');
    }
    
    // Check weight
    final weight = quote['weight'] as double;
    if (weight < 0.0 || weight > 1.0) {
      throw Exception('Invalid weight: $weight (must be 0.0-1.0)');
    }
  }
  
  void checkTierDistribution(List<Map<String, dynamic>> quotes) {
    final counts = <String, int>{};
    for (final quote in quotes) {
      final tier = quote['tierMin'] as String;
      counts[tier] = (counts[tier] ?? 0) + 1;
    }
    
    final total = quotes.length;
    print('\nTier distribution:');
    for (final entry in tierDistribution.entries) {
      final expected = (total * entry.value).round();
      final actual = counts[entry.key] ?? 0;
      final percentage = (actual / total * 100).toStringAsFixed(1);
      print('${entry.key}: $actual/$total ($percentage%) - expected: $expected');
    }
  }
}
