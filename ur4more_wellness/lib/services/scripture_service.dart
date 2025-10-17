import 'dart:convert';
import 'package:flutter/services.dart';

class ScriptureService {
  static final ScriptureService _instance = ScriptureService._internal();
  factory ScriptureService() => _instance;
  ScriptureService._internal();

  Map<String, String> _scriptures = {};

  Future<void> initialize() async {
    if (_scriptures.isNotEmpty) return;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/data/scriptures.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      _scriptures = Map<String, String>.from(jsonData);
    } catch (e) {
      print('Error loading scriptures: $e');
      // Fallback to some common scriptures
      _loadFallbackScriptures();
    }
  }

  void _loadFallbackScriptures() {
    _scriptures = {
      'John 3:16': 'For God so loved the world that he gave his one and only Son, that whoever believes in him shall not perish but have eternal life.',
      'Romans 8:28': 'And we know that in all things God works for the good of those who love him, who have been called according to his purpose.',
      'Jeremiah 29:11': 'For I know the plans I have for you," declares the Lord, "plans to prosper you and not to harm you, to give you hope and a future.',
      'Philippians 4:13': 'I can do all this through him who gives me strength.',
      'Proverbs 3:5-6': 'Trust in the Lord with all your heart and lean not on your own understanding; in all your ways submit to him, and he will make your paths straight.',
      'Matthew 28:19-20': 'Therefore go and make disciples of all nations, baptizing them in the name of the Father and of the Son and of the Holy Spirit, and teaching them to obey everything I have commanded you. And surely I am with you always, to the very end of the age.',
      'Ephesians 2:8-10': 'For it is by grace you have been saved, through faith—and this is not from yourselves, it is the gift of God—not by works, so that no one can boast. For we are God\'s handiwork, created in Christ Jesus to do good works, which God prepared in advance for us to do.',
      'Galatians 5:22-23': 'But the fruit of the Spirit is love, joy, peace, forbearance, kindness, goodness, faithfulness, gentleness and self-control. Against such things there is no law.',
      '1 Corinthians 13:4-7': 'Love is patient, love is kind. It does not envy, it does not boast, it is not proud. It does not dishonor others, it is not self-seeking, it is not easily angered, it keeps no record of wrongs. Love does not delight in evil but rejoices with the truth. It always protects, always trusts, always hopes, always perseveres.',
      'Psalm 23:1-6': 'The Lord is my shepherd, I lack nothing. He makes me lie down in green pastures, he leads me beside quiet waters, he refreshes my soul. He guides me along the right paths for his name\'s sake. Even though I walk through the darkest valley, I will fear no evil, for you are with me; your rod and your staff, they comfort me. You prepare a table before me in the presence of my enemies. You anoint my head with oil; my cup overflows. Surely your goodness and love will follow me all the days of my life, and I will dwell in the house of the Lord forever.',
      '2 Cor 5:17': 'Therefore, if anyone is in Christ, the new creation has come: The old has gone, the new is here!',
      'Eph 1:3–5': 'Praise be to the God and Father of our Lord Jesus Christ, who has blessed us in the heavenly realms with every spiritual blessing in Christ. For he chose us in him before the creation of the world to be holy and blameless in his sight. In love he predestined us for adoption to sonship through Jesus Christ, in accordance with his pleasure and will.',
      'John 1:12': 'Yet to all who did receive him, to those who believed in his name, he gave the right to become children of God.',
      'Eph 2:8-10': 'For it is by grace you have been saved, through faith—and this is not from yourselves, it is the gift of God—not by works, so that no one can boast. For we are God\'s handiwork, created in Christ Jesus to do good works, which God prepared in advance for us to do.',
      'Rom 5:8': 'But God demonstrates his own love for us in this: While we were still sinners, Christ died for us.',
    };
  }

  String? getScriptureText(String reference) {
    return _scriptures[reference];
  }

  bool hasScripture(String reference) {
    return _scriptures.containsKey(reference);
  }
}
