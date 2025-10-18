import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

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
      // Week 1 - The Gospel of Grace
      'Ephesians 2:8-9': 'For by grace are ye saved through faith; and that not of yourselves: it is the gift of God: Not of works, lest any man should boast.',
      'Romans 3:24-26': 'Being justified freely by his grace through the redemption that is in Christ Jesus: Whom God hath set forth to be a propitiation through faith in his blood, to declare his righteousness for the remission of sins that are past, through the forbearance of God; To declare, I say, at this time his righteousness: that he might be just, and the justifier of him which believeth in Jesus.',
      '2 Corinthians 5:21': 'For he hath made him to be sin for us, who knew no sin; that we might be made the righteousness of God in him.',
      
      // Week 2 - Regeneration
      'John 3:3-8': 'Jesus answered and said unto him, Verily, verily, I say unto thee, Except a man be born again, he cannot see the kingdom of God. Nicodemus saith unto him, How can a man be born when he is old? can he enter the second time into his mother\'s womb, and be born? Jesus answered, Verily, verily, I say unto thee, Except a man be born of water and of the Spirit, he cannot enter into the kingdom of God. That which is born of the flesh is flesh; and that which is born of the Spirit is spirit. Marvel not that I said unto thee, Ye must be born again. The wind bloweth where it listeth, and thou hearest the sound thereof, but canst not tell whence it cometh, and whither it goeth: so is every one that is born of the Spirit.',
      'Titus 3:5': 'Not by works of righteousness which we have done, but according to his mercy he saved us, by the washing of regeneration, and renewing of the Holy Ghost;',
      'Ezekiel 36:26-27': 'A new heart also will I give you, and a new spirit will I put within you: and I will take away the stony heart out of your flesh, and I will give you an heart of flesh. And I will put my spirit within you, and cause you to walk in my statutes, and ye shall keep my judgments, and do them.',
      '2 Corinthians 5:17': 'Therefore if any man be in Christ, he is a new creature: old things are passed away; behold, all things are become new.',
      
      // Week 3 - Adam → Christ & Union with Christ
      'Romans 5:12-19': 'Wherefore, as by one man sin entered into the world, and death by sin; and so death passed upon all men, for that all have sinned: (For until the law sin was in the world: but sin is not imputed when there is no law. Nevertheless death reigned from Adam to Moses, even over them that had not sinned after the similitude of Adam\'s transgression, who is the figure of him that was to come. But not as the offence, so also is the free gift. For if through the offence of one many be dead, much more the grace of God, and the gift by grace, which is by one man, Jesus Christ, hath abounded unto many. And not as it was by one that sinned, so is the gift: for the judgment was by one to condemnation, but the free gift is of many offences unto justification. For if by one man\'s offence death reigned by one; much more they which receive abundance of grace and of the gift of righteousness shall reign in life by one, Jesus Christ.) Therefore as by the offence of one judgment came upon all men to condemnation; even so by the righteousness of one the free gift came upon all men unto justification of life. For as by one man\'s disobedience many were made sinners, so by the obedience of one shall many be made righteous.',
      '1 Corinthians 15:22': 'For as in Adam all die, even so in Christ shall all be made alive.',
      '1 Corinthians 15:45-49': 'And so it is written, The first man Adam was made a living soul; the last Adam was made a quickening spirit. Howbeit that was not first which is spiritual, but that which is natural; and afterward that which is spiritual. The first man is of the earth, earthy: the second man is the Lord from heaven. As is the earthy, such are they also that are earthy: and as is the heavenly, such are they also that are heavenly. And as we have borne the image of the earthy, we shall also bear the image of the heavenly.',
      'Romans 6:3-5': 'Know ye not, that so many of us as were baptized into Jesus Christ were baptized into his death? Therefore we are buried with him by baptism into death: that like as Christ was raised up from the dead by the glory of the Father, even so we also should walk in newness of life. For if we have been planted together in the likeness of his death, we shall be also in the likeness of his resurrection:',
      
      // Week 4 - Repentance & Faith
      'Mark 1:15': 'And saying, The time is fulfilled, and the kingdom of God is at hand: repent ye, and believe the gospel.',
      'Acts 3:19': 'Repent ye therefore, and be converted, that your sins may be blotted out, when the times of refreshing shall come from the presence of the Lord;',
      '1 John 1:9': 'If we confess our sins, he is faithful and just to forgive us our sins, and to cleanse us from all unrighteousness.',
      
      // Week 5 - Lordship & Obedience
      'John 14:15': 'If ye love me, keep my commandments.',
      'James 2:17': 'Even so faith, if it hath not works, is dead, being alone.',
      'Galatians 5:6': 'For in Jesus Christ neither circumcision availeth any thing, nor uncircumcision; but faith which worketh by love.',
      'Matthew 7:24-27': 'Therefore whosoever heareth these sayings of mine, and doeth them, I will liken him unto a wise man, which built his house upon a rock: And the rain descended, and the floods came, and the winds blew, and beat upon that house; and it fell not: for it was founded upon a rock. And every one that heareth these sayings of mine, and doeth them not, shall be likened unto a foolish man, which built his house upon the sand: And the rain descended, and the floods came, and the winds blew, and beat upon that house; and it fell: and great was the fall of it.',
      
      // Week 6 - Scripture
      '2 Timothy 3:16-17': 'All scripture is given by inspiration of God, and is profitable for doctrine, for reproof, for correction, for instruction in righteousness: That the man of God may be perfect, throughly furnished unto all good works.',
      'Joshua 1:8': 'This book of the law shall not depart out of thy mouth; but thou shalt meditate therein day and night, that thou mayest observe to do according to all that is written therein: for then thou shalt make thy way prosperous, and then thou shalt have good success.',
      'Psalm 1:2-3': 'But his delight is in the law of the Lord; and in his law doth he meditate day and night. And he shall be like a tree planted by the rivers of water, that bringeth forth his fruit in his season; his leaf also shall not wither; and whatsoever he doeth shall prosper.',
      'Hebrews 4:12': 'For the word of God is quick, and powerful, and sharper than any twoedged sword, piercing even to the dividing asunder of soul and spirit, and of the joints and marrow, and is a discerner of the thoughts and intents of the heart.',
      
      // Week 7 - Prayer
      'Matthew 6:9-13': 'After this manner therefore pray ye: Our Father which art in heaven, Hallowed be thy name. Thy kingdom come. Thy will be done in earth, as it is in heaven. Give us this day our daily bread. And forgive us our debts, as we forgive our debtors. And lead us not into temptation, but deliver us from evil: For thine is the kingdom, and the power, and the glory, for ever. Amen.',
      'Philippians 4:6-7': 'Be careful for nothing; but in every thing by prayer and supplication with thanksgiving let your requests be made known unto God. And the peace of God, which passeth all understanding, shall keep your hearts and minds through Christ Jesus.',
      '1 Thessalonians 5:17': 'Pray without ceasing.',
      
      // Week 8 - Holy Spirit
      'Romans 8:5-14': 'For they that are after the flesh do mind the things of the flesh; but they that are after the Spirit the things of the Spirit. For to be carnally minded is death; but to be spiritually minded is life and peace. Because the carnal mind is enmity against God: for it is not subject to the law of God, neither indeed can be. So then they that are in the flesh cannot please God. But ye are not in the flesh, but in the Spirit, if so be that the Spirit of God dwell in you. Now if any man have not the Spirit of Christ, he is none of his. And if Christ be in you, the body is dead because of sin; but the Spirit is life because of righteousness. But if the Spirit of him that raised up Jesus from the dead dwell in you, he that raised up Christ from the dead shall also quicken your mortal bodies by his Spirit that dwelleth in you. Therefore, brethren, we are debtors, not to the flesh, to live after the flesh. For if ye live after the flesh, ye shall die: but if ye through the Spirit do mortify the deeds of the body, ye shall live. For as many as are led by the Spirit of God, they are the sons of God.',
      'Galatians 5:16-25': 'This I say then, Walk in the Spirit, and ye shall not fulfil the lust of the flesh. For the flesh lusteth against the Spirit, and the Spirit against the flesh: and these are contrary the one to the other: so that ye cannot do the things that ye would. But if ye be led of the Spirit, ye are not under the law. Now the works of the flesh are manifest, which are these; Adultery, fornication, uncleanness, lasciviousness, Idolatry, witchcraft, hatred, variance, emulations, wrath, strife, seditions, heresies, Envyings, murders, drunkenness, revellings, and such like: of the which I tell you before, as I have also told you in time past, that they which do such things shall not inherit the kingdom of God. But the fruit of the Spirit is love, joy, peace, longsuffering, gentleness, goodness, faith, Meekness, temperance: against such there is no law. And they that are Christ\'s have crucified the flesh with the affections and lusts. If we live in the Spirit, let us also walk in the Spirit.',
      'Acts 1:8': 'But ye shall receive power, after that the Holy Ghost is come upon you: and ye shall be witnesses unto me both in Jerusalem, and in all Judaea, and in Samaria, and unto the uttermost part of the earth.',
      
      // Week 9 - Identity & Holiness
      '1 Peter 2:9': 'But ye are a chosen generation, a royal priesthood, an holy nation, a peculiar people; that ye should shew forth the praises of him who hath called you out of darkness into his marvellous light:',
      'Romans 12:1-2': 'I beseech you therefore, brethren, by the mercies of God, that ye present your bodies a living sacrifice, holy, acceptable unto God, which is your reasonable service. And be not conformed to this world: but be ye transformed by the renewing of your mind, that ye may prove what is that good, and acceptable, and perfect, will of God.',
      '1 Thessalonians 4:3': 'For this is the will of God, even your sanctification, that ye should abstain from fornication:',
      
      // Week 10 - Community
      'Hebrews 10:24-25': 'And let us consider one another to provoke unto love and to good works: Not forsaking the assembling of ourselves together, as the manner of some is; but exhorting one another: and so much the more, as ye see the day approaching.',
      'Acts 2:42': 'And they continued stedfastly in the apostles\' doctrine and fellowship, and in breaking of bread, and in prayers.',
      'James 5:16': 'Confess your faults one to another, and pray one for another, that ye may be healed. The effectual fervent prayer of a righteous man availeth much.',
      
      // Week 11 - Mission
      'Matthew 28:18-20': 'And Jesus came and spake unto them, saying, All power is given unto me in heaven and in earth. Go ye therefore, and teach all nations, baptizing them in the name of the Father, and of the Son, and of the Holy Ghost: Teaching them to observe all things whatsoever I have commanded you: and, lo, I am with you alway, even unto the end of the world. Amen.',
      '1 Peter 3:15': 'But sanctify the Lord God in your hearts: and be ready always to give an answer to every man that asketh you a reason of the hope that is in you with meekness and fear:',
      'Mark 10:45': 'For even the Son of man came not to be ministered unto, but to minister, and to give his life a ransom for many.',
      'Matthew 5:16': 'Let your light so shine before men, that they may see your good works, and glorify your Father which is in heaven.',
      
      // Week 12 - Perseverance
      'John 15:5': 'I am the vine, ye are the branches: He that abideth in me, and I in him, the same bringeth forth much fruit: for without me ye can do nothing.',
      'James 1:2-4': 'My brethren, count it all joy when ye fall into divers temptations; Knowing this, that the trying of your faith worketh patience. But let patience have her perfect work, that ye may be perfect and entire, wanting nothing.',
      'Colossians 2:6-7': 'As ye have therefore received Christ Jesus the Lord, so walk ye in him: Rooted and built up in him, and stablished in the faith, as ye have been taught, abounding therein with thanksgiving.',
      'Psalm 90:12': 'So teach us to number our days, that we may apply our hearts unto wisdom.',
      
      // Common fallback verses
      'John 3:16': 'For God so loved the world, that he gave his only begotten Son, that whosoever believeth in him should not perish, but have everlasting life.',
      'Romans 8:28': 'And we know that all things work together for good to them that love God, to them who are the called according to his purpose.',
      'Philippians 4:13': 'I can do all things through Christ which strengtheneth me.',
    };
  }

  String? getScriptureText(String reference) {
    return _scriptures[reference];
  }

  bool hasScripture(String reference) {
    return _scriptures.containsKey(reference);
  }

  /// Open a Bible verse in an external Bible website
  Future<void> openBibleVerse(String reference) async {
    try {
      // Convert reference to URL-friendly format
      final cleanRef = reference.replaceAll(' ', '+').replaceAll(':', '%3A');
      
      // Use Bible Gateway (KJV) as the default Bible website
      final url = Uri.parse('https://www.biblegateway.com/passage/?search=$cleanRef&version=KJV');
      
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        print('Could not launch Bible verse: $reference');
      }
    } catch (e) {
      print('Error opening Bible verse: $e');
    }
  }

  /// Get a clickable Bible verse reference with URL launcher
  String getBibleUrl(String reference) {
    final cleanRef = reference.replaceAll(' ', '+').replaceAll(':', '%3A');
    return 'https://www.biblegateway.com/passage/?search=$cleanRef&version=KJV';
  }
}
