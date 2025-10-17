import 'dart:convert';
import 'package:flutter/services.dart';

/// Scripture service providing King James Version (KJV) Bible verses
/// for the UR4MORE Discipleship Course
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
      'John 3:16': 'For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.',
      'Romans 8:28': 'And we know that all things work together for good to them that love God, to them who are the called according to his purpose.',
      'Jeremiah 29:11': 'For I know the thoughts that I think toward you, saith the Lord, thoughts of peace, and not of evil, to give you an expected end.',
      'Philippians 4:13': 'I can do all things through Christ which strengtheneth me.',
      'Proverbs 3:5-6': 'Trust in the Lord with all thine heart; and lean not unto thine own understanding. In all thy ways acknowledge him, and he shall direct thy paths.',
      'Matthew 28:19-20': 'Go ye therefore, and teach all nations, baptizing them in the name of the Father, and of the Son, and of the Holy Ghost: Teaching them to observe all things whatsoever I have commanded you: and, lo, I am with you alway, even unto the end of the world. Amen.',
      'Ephesians 2:8-10': 'For by grace are ye saved through faith; and that not of yourselves: it is the gift of God: Not of works, lest any man should boast. For we are his workmanship, created in Christ Jesus unto good works, which God hath before ordained that we should walk in them.',
      'Galatians 5:22-23': 'But the fruit of the Spirit is love, joy, peace, longsuffering, gentleness, goodness, faith, Meekness, temperance: against such there is no law.',
      '1 Corinthians 13:4-7': 'Charity suffereth long, and is kind; charity envieth not; charity vaunteth not itself, is not puffed up, Doth not behave itself unseemly, seeketh not her own, is not easily provoked, thinketh no evil; Rejoiceth not in iniquity, but rejoiceth in the truth; Beareth all things, believeth all things, hopeth all things, endureth all things.',
      'Psalm 23:1-6': 'The Lord is my shepherd; I shall not want. He maketh me to lie down in green pastures: he leadeth me beside the still waters. He restoreth my soul: he leadeth me in the paths of righteousness for his name\'s sake. Yea, though I walk through the valley of the shadow of death, I will fear no evil: for thou art with me; thy rod and thy staff they comfort me. Thou preparest a table before me in the presence of mine enemies: thou anointest my head with oil; my cup runneth over. Surely goodness and mercy shall follow me all the days of my life: and I will dwell in the house of the Lord for ever.',
      '2 Cor 5:17': 'Therefore if any man be in Christ, he is a new creature: old things are passed away; behold, all things are become new.',
      'Eph 1:3–5': 'Blessed be the God and Father of our Lord Jesus Christ, who hath blessed us with all spiritual blessings in heavenly places in Christ: According as he hath chosen us in him before the foundation of the world, that we should be holy and without blame before him in love: Having predestinated us unto the adoption of children by Jesus Christ to himself, according to the good pleasure of his will.',
      'John 1:12': 'But as many as received him, to them gave he power to become the sons of God, even to them that believe on his name.',
      'Eph 2:8-10': 'For by grace are ye saved through faith; and that not of yourselves: it is the gift of God: Not of works, lest any man should boast. For we are his workmanship, created in Christ Jesus unto good works, which God hath before ordained that we should walk in them.',
      'Rom 5:8': 'But God commendeth his love toward us, in that, while we were yet sinners, Christ died for us.',
    };
  }

  String? getScriptureText(String reference) {
    return _scriptures[reference];
  }

  bool hasScripture(String reference) {
    return _scriptures.containsKey(reference);
  }
}
