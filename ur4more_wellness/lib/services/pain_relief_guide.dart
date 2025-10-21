/// Comprehensive Pain Relief Guide for AI Agent
/// This guide provides detailed home remedies and strategies for pain relief
/// across different body regions, helping the AI agent provide personalized suggestions.

class PainReliefGuide {
  /// Get pain relief suggestions for a specific body region
  static List<PainReliefSuggestion> getSuggestionsForRegion(String region) {
    switch (region.toLowerCase()) {
      case 'head/neck':
        return _getHeadNeckSuggestions();
      case 'back':
        return _getBackSuggestions();
      case 'legs':
        return _getLegSuggestions();
      case 'shoulders':
        return _getShoulderSuggestions();
      case 'arms':
        return _getArmSuggestions();
      case 'chest':
        return _getChestSuggestions();
      case 'abdomen':
        return _getAbdominalSuggestions();
      case 'hips':
        return _getHipSuggestions();
      case 'feet':
        return _getFootSuggestions();
      default:
        return _getGeneralSuggestions();
    }
  }

  /// Head/Neck Pain Relief Suggestions
  static List<PainReliefSuggestion> _getHeadNeckSuggestions() {
    return [
      PainReliefSuggestion(
        title: 'Heat Therapy',
        description: 'Apply warmth to relax tight neck muscles and ease stiffness. Use a heating pad, warm compress, or hot shower.',
        category: 'physical',
        priority: 4,
        duration: '15-20 minutes',
        icon: 'local_fire_department',
        tags: ['tension', 'muscle-relaxation', 'circulation'],
      ),
      PainReliefSuggestion(
        title: 'Cold Therapy',
        description: 'Use cold packs to reduce inflammation for acute pain. Apply ice pack (wrapped in cloth) for 10-15 minutes.',
        category: 'physical',
        priority: 3,
        duration: '10-15 minutes',
        icon: 'ac_unit',
        tags: ['inflammation', 'acute-pain', 'swelling'],
      ),
      PainReliefSuggestion(
        title: 'Gentle Neck Stretches',
        description: 'Perform slow neck stretches like chin tucks and side-to-side head rotations to relieve tension.',
        category: 'exercise',
        priority: 4,
        duration: '5-10 minutes',
        icon: 'accessibility_new',
        tags: ['flexibility', 'tension-relief', 'mobility'],
      ),
      PainReliefSuggestion(
        title: 'Posture Improvement',
        description: 'Maintain proper posture with head aligned over shoulders. Adjust workspace to avoid looking down.',
        category: 'lifestyle',
        priority: 5,
        duration: 'ongoing',
        icon: 'straighten',
        tags: ['prevention', 'ergonomics', 'alignment'],
      ),
      PainReliefSuggestion(
        title: 'Stress Reduction',
        description: 'Practice relaxation techniques like deep breathing, meditation, or box breathing to reduce muscle tension.',
        category: 'mental',
        priority: 4,
        duration: '5-15 minutes',
        icon: 'self_improvement',
        tags: ['stress-relief', 'relaxation', 'tension'],
      ),
      PainReliefSuggestion(
        title: 'Hydration and Rest',
        description: 'Stay hydrated and get adequate rest. Use supportive pillow for proper neck alignment during sleep.',
        category: 'lifestyle',
        priority: 3,
        duration: 'ongoing',
        icon: 'water_drop',
        tags: ['hydration', 'rest', 'sleep-position'],
      ),
    ];
  }

  /// Back Pain Relief Suggestions
  static List<PainReliefSuggestion> _getBackSuggestions() {
    return [
      PainReliefSuggestion(
        title: 'Gentle Exercise',
        description: 'Stay active with light exercise like walking, swimming, or gentle aerobics to release endorphins.',
        category: 'exercise',
        priority: 5,
        duration: '20-30 minutes',
        icon: 'directions_walk',
        tags: ['endorphins', 'mobility', 'strength'],
      ),
      PainReliefSuggestion(
        title: 'Back Stretches',
        description: 'Do simple stretches like knee-to-chest pulls and pelvic tilts to relieve tension and improve flexibility.',
        category: 'exercise',
        priority: 4,
        duration: '10-15 minutes',
        icon: 'accessibility_new',
        tags: ['flexibility', 'tension-relief', 'range-of-motion'],
      ),
      PainReliefSuggestion(
        title: 'Heat and Cold Therapy',
        description: 'Use ice packs for acute inflammation, then switch to heat for muscle relaxation and chronic pain.',
        category: 'physical',
        priority: 4,
        duration: '15-20 minutes',
        icon: 'thermostat',
        tags: ['inflammation', 'muscle-relaxation', 'pain-relief'],
      ),
      PainReliefSuggestion(
        title: 'Posture and Ergonomics',
        description: 'Maintain proper posture with back support. Use lumbar cushion and adjust workspace ergonomics.',
        category: 'lifestyle',
        priority: 5,
        duration: 'ongoing',
        icon: 'chair',
        tags: ['prevention', 'ergonomics', 'support'],
      ),
      PainReliefSuggestion(
        title: 'Self-Massage',
        description: 'Gently massage sore back muscles using hands, foam roller, or tennis ball against wall.',
        category: 'physical',
        priority: 3,
        duration: '10-15 minutes',
        icon: 'spa',
        tags: ['circulation', 'muscle-knots', 'relaxation'],
      ),
      PainReliefSuggestion(
        title: 'Over-the-Counter Relief',
        description: 'Use NSAIDs like ibuprofen for inflammation and pain relief, following package directions.',
        category: 'medication',
        priority: 3,
        duration: 'as needed',
        icon: 'medication',
        tags: ['inflammation', 'pain-relief', 'short-term'],
      ),
    ];
  }

  /// Leg Pain Relief Suggestions
  static List<PainReliefSuggestion> _getLegSuggestions() {
    return [
      PainReliefSuggestion(
        title: 'Temperature Therapy',
        description: 'Use cold compress for acute injuries, warm compress for chronic muscle soreness and stiffness.',
        category: 'physical',
        priority: 4,
        duration: '15-20 minutes',
        icon: 'thermostat',
        tags: ['inflammation', 'muscle-relaxation', 'circulation'],
      ),
      PainReliefSuggestion(
        title: 'Epsom Salt Bath',
        description: 'Soak legs in warm water with 1-2 cups Epsom salt for 15-20 minutes to relax muscles.',
        category: 'physical',
        priority: 4,
        duration: '15-20 minutes',
        icon: 'bathtub',
        tags: ['magnesium', 'muscle-relaxation', 'inflammation'],
      ),
      PainReliefSuggestion(
        title: 'Massage and Stretching',
        description: 'Gentle massage with foam roller or hands, plus stretching for calves, hamstrings, and quadriceps.',
        category: 'exercise',
        priority: 4,
        duration: '15-20 minutes',
        icon: 'spa',
        tags: ['flexibility', 'circulation', 'muscle-tension'],
      ),
      PainReliefSuggestion(
        title: 'Compression and Elevation',
        description: 'Use compression socks and elevate legs above heart level to reduce swelling and improve circulation.',
        category: 'physical',
        priority: 3,
        duration: '15-20 minutes',
        icon: 'vertical_align_top',
        tags: ['swelling', 'circulation', 'support'],
      ),
      PainReliefSuggestion(
        title: 'Hydration and Diet',
        description: 'Stay hydrated and include anti-inflammatory foods like turmeric and ginger in your diet.',
        category: 'lifestyle',
        priority: 3,
        duration: 'ongoing',
        icon: 'restaurant',
        tags: ['hydration', 'anti-inflammatory', 'nutrition'],
      ),
      PainReliefSuggestion(
        title: 'Over-the-Counter Aids',
        description: 'Use NSAIDs for inflammation and consider topical analgesic creams for targeted relief.',
        category: 'medication',
        priority: 2,
        duration: 'as needed',
        icon: 'medication',
        tags: ['inflammation', 'pain-relief', 'topical'],
      ),
    ];
  }

  /// Shoulder Pain Relief Suggestions
  static List<PainReliefSuggestion> _getShoulderSuggestions() {
    return [
      PainReliefSuggestion(
        title: 'Rest and Activity Modification',
        description: 'Avoid movements that worsen pain while maintaining gentle range-of-motion exercises.',
        category: 'lifestyle',
        priority: 4,
        duration: 'ongoing',
        icon: 'pause_circle',
        tags: ['rest', 'activity-modification', 'healing'],
      ),
      PainReliefSuggestion(
        title: 'Ice and Heat Therapy',
        description: 'Apply ice for acute inflammation, then heat for chronic muscle tightness and stiffness.',
        category: 'physical',
        priority: 4,
        duration: '15-20 minutes',
        icon: 'thermostat',
        tags: ['inflammation', 'muscle-relaxation', 'pain-relief'],
      ),
      PainReliefSuggestion(
        title: 'Gentle Shoulder Exercises',
        description: 'Perform pendulum swings, wall walks, and across-the-chest stretches to maintain mobility.',
        category: 'exercise',
        priority: 4,
        duration: '10-15 minutes',
        icon: 'accessibility_new',
        tags: ['mobility', 'flexibility', 'range-of-motion'],
      ),
      PainReliefSuggestion(
        title: 'Posture and Ergonomics',
        description: 'Keep shoulders back and down, avoid hunching, and take breaks to roll shoulders.',
        category: 'lifestyle',
        priority: 5,
        duration: 'ongoing',
        icon: 'straighten',
        tags: ['prevention', 'ergonomics', 'alignment'],
      ),
      PainReliefSuggestion(
        title: 'Support and Comfort',
        description: 'Use sling or shoulder brace for rest, and adjust sleeping position to avoid lying on painful shoulder.',
        category: 'lifestyle',
        priority: 3,
        duration: 'as needed',
        icon: 'support',
        tags: ['support', 'sleep-position', 'rest'],
      ),
    ];
  }

  /// Arm Pain Relief Suggestions
  static List<PainReliefSuggestion> _getArmSuggestions() {
    return [
      PainReliefSuggestion(
        title: 'Rest and Avoid Overuse',
        description: 'Take breaks from repetitive activities and avoid motions that reproduce pain.',
        category: 'lifestyle',
        priority: 4,
        duration: 'ongoing',
        icon: 'pause_circle',
        tags: ['rest', 'overuse-prevention', 'healing'],
      ),
      PainReliefSuggestion(
        title: 'Ice and Heat Application',
        description: 'Apply ice for acute injuries and inflammation, then heat for chronic stiffness and muscle tension.',
        category: 'physical',
        priority: 4,
        duration: '15-20 minutes',
        icon: 'thermostat',
        tags: ['inflammation', 'muscle-relaxation', 'pain-relief'],
      ),
      PainReliefSuggestion(
        title: 'Gentle Stretching',
        description: 'Stretch wrist, forearm, biceps, and triceps muscles to improve flexibility and reduce tension.',
        category: 'exercise',
        priority: 4,
        duration: '10-15 minutes',
        icon: 'accessibility_new',
        tags: ['flexibility', 'tension-relief', 'mobility'],
      ),
      PainReliefSuggestion(
        title: 'Ergonomics and Posture',
        description: 'Adjust workstation height, use wrist rests, and maintain proper posture to reduce strain.',
        category: 'lifestyle',
        priority: 5,
        duration: 'ongoing',
        icon: 'chair',
        tags: ['ergonomics', 'prevention', 'strain-reduction'],
      ),
      PainReliefSuggestion(
        title: 'Compression and Support',
        description: 'Use compression bandages or braces for support during activities and healing.',
        category: 'physical',
        priority: 3,
        duration: 'as needed',
        icon: 'support',
        tags: ['support', 'swelling-reduction', 'stability'],
      ),
    ];
  }

  /// Chest Pain Relief Suggestions
  static List<PainReliefSuggestion> _getChestSuggestions() {
    return [
      PainReliefSuggestion(
        title: 'Cold for Muscle Strain',
        description: 'Apply ice pack to tender chest area for 10-15 minutes to reduce pain and inflammation.',
        category: 'physical',
        priority: 4,
        duration: '10-15 minutes',
        icon: 'ac_unit',
        tags: ['inflammation', 'muscle-strain', 'pain-relief'],
      ),
      PainReliefSuggestion(
        title: 'Warm Drinks for Indigestion',
        description: 'Sip warm water, ginger tea, or chamomile tea to soothe esophagus and improve digestion.',
        category: 'lifestyle',
        priority: 3,
        duration: '5-10 minutes',
        icon: 'local_drink',
        tags: ['digestion', 'heartburn', 'soothing'],
      ),
      PainReliefSuggestion(
        title: 'Baking Soda for Heartburn',
        description: 'Mix 1/2 teaspoon baking soda in water to neutralize stomach acid and reduce heartburn.',
        category: 'lifestyle',
        priority: 3,
        duration: 'immediate',
        icon: 'science',
        tags: ['heartburn', 'acid-neutralization', 'quick-relief'],
      ),
      PainReliefSuggestion(
        title: 'Deep Breathing for Anxiety',
        description: 'Practice 4-7-8 breathing or box breathing to calm anxiety-related chest tightness.',
        category: 'mental',
        priority: 4,
        duration: '5-10 minutes',
        icon: 'air',
        tags: ['anxiety-relief', 'relaxation', 'breathing'],
      ),
      PainReliefSuggestion(
        title: 'Avoid Lying Down After Eating',
        description: 'Stay upright for 1-2 hours after meals to prevent acid reflux and chest discomfort.',
        category: 'lifestyle',
        priority: 4,
        duration: '1-2 hours',
        icon: 'vertical_align_top',
        tags: ['prevention', 'digestion', 'heartburn'],
      ),
    ];
  }

  /// Abdominal Pain Relief Suggestions
  static List<PainReliefSuggestion> _getAbdominalSuggestions() {
    return [
      PainReliefSuggestion(
        title: 'Heating Pad for Cramps',
        description: 'Apply gentle heat to abdomen for 15-20 minutes to relax stomach muscles and relieve cramping.',
        category: 'physical',
        priority: 4,
        duration: '15-20 minutes',
        icon: 'local_fire_department',
        tags: ['cramps', 'muscle-relaxation', 'comfort'],
      ),
      PainReliefSuggestion(
        title: 'Herbal Teas',
        description: 'Drink chamomile, peppermint, or ginger tea to soothe stomach and reduce painful spasms.',
        category: 'lifestyle',
        priority: 4,
        duration: '5-10 minutes',
        icon: 'local_drink',
        tags: ['digestion', 'anti-inflammatory', 'soothing'],
      ),
      PainReliefSuggestion(
        title: 'BRAT Diet',
        description: 'Eat bland foods (Bananas, Rice, Applesauce, Toast) to ease upset digestive system.',
        category: 'lifestyle',
        priority: 3,
        duration: '1-2 days',
        icon: 'restaurant',
        tags: ['digestion', 'bland-foods', 'recovery'],
      ),
      PainReliefSuggestion(
        title: 'Hydration',
        description: 'Drink water and electrolyte solutions to prevent dehydration and improve digestion.',
        category: 'lifestyle',
        priority: 4,
        duration: 'ongoing',
        icon: 'water_drop',
        tags: ['hydration', 'digestion', 'electrolytes'],
      ),
      PainReliefSuggestion(
        title: 'Gentle Movement',
        description: 'Take short walks or do gentle yoga poses to help move gas and improve digestion.',
        category: 'exercise',
        priority: 3,
        duration: '10-15 minutes',
        icon: 'directions_walk',
        tags: ['gas-relief', 'digestion', 'mild-activity'],
      ),
    ];
  }

  /// Hip Pain Relief Suggestions
  static List<PainReliefSuggestion> _getHipSuggestions() {
    return [
      PainReliefSuggestion(
        title: 'Rest and Protect Hip',
        description: 'Avoid heavy impact activities and use cushions or assistive devices to reduce strain.',
        category: 'lifestyle',
        priority: 4,
        duration: 'ongoing',
        icon: 'pause_circle',
        tags: ['rest', 'protection', 'strain-reduction'],
      ),
      PainReliefSuggestion(
        title: 'Ice for Inflammation',
        description: 'Apply ice pack to outer hip area for 15 minutes to reduce swelling and ease pain.',
        category: 'physical',
        priority: 4,
        duration: '15 minutes',
        icon: 'ac_unit',
        tags: ['inflammation', 'swelling', 'pain-relief'],
      ),
      PainReliefSuggestion(
        title: 'Heat for Stiffness',
        description: 'Use warm shower, bath, or heating pad to loosen hip joint and surrounding muscles.',
        category: 'physical',
        priority: 4,
        duration: '15-20 minutes',
        icon: 'local_fire_department',
        tags: ['stiffness', 'muscle-relaxation', 'flexibility'],
      ),
      PainReliefSuggestion(
        title: 'Hip Stretches and Exercise',
        description: 'Do figure-four stretches, hip flexor stretches, and low-impact exercises like swimming.',
        category: 'exercise',
        priority: 5,
        duration: '15-20 minutes',
        icon: 'accessibility_new',
        tags: ['flexibility', 'strength', 'mobility'],
      ),
      PainReliefSuggestion(
        title: 'Weight Management',
        description: 'Maintain healthy weight to reduce stress on hip joints with every step.',
        category: 'lifestyle',
        priority: 5,
        duration: 'ongoing',
        icon: 'monitor_weight',
        tags: ['weight-management', 'joint-stress', 'long-term'],
      ),
      PainReliefSuggestion(
        title: 'Assistive Devices',
        description: 'Use cane on opposite side of painful hip and make home adjustments for comfort.',
        category: 'lifestyle',
        priority: 3,
        duration: 'as needed',
        icon: 'support',
        tags: ['support', 'mobility', 'comfort'],
      ),
    ];
  }

  /// Foot Pain Relief Suggestions
  static List<PainReliefSuggestion> _getFootSuggestions() {
    return [
      PainReliefSuggestion(
        title: 'Rest and Ice',
        description: 'Stay off feet and apply ice for 15-20 minutes to reduce inflammation and numb pain.',
        category: 'physical',
        priority: 4,
        duration: '15-20 minutes',
        icon: 'ac_unit',
        tags: ['inflammation', 'rest', 'pain-relief'],
      ),
      PainReliefSuggestion(
        title: 'RICE Protocol',
        description: 'Rest, Ice, Compression, Elevation for foot and ankle injuries to minimize swelling.',
        category: 'physical',
        priority: 5,
        duration: '1-2 days',
        icon: 'healing',
        tags: ['injury-care', 'swelling', 'recovery'],
      ),
      PainReliefSuggestion(
        title: 'Foot Stretches',
        description: 'Do towel curls, marble pickups, and calf stretches to improve flexibility and strength.',
        category: 'exercise',
        priority: 4,
        duration: '10-15 minutes',
        icon: 'accessibility_new',
        tags: ['flexibility', 'strength', 'prevention'],
      ),
      PainReliefSuggestion(
        title: 'Supportive Footwear',
        description: 'Wear well-cushioned shoes with good arch support and consider orthotic insoles.',
        category: 'lifestyle',
        priority: 5,
        duration: 'ongoing',
        icon: 'checkroom',
        tags: ['support', 'prevention', 'comfort'],
      ),
      PainReliefSuggestion(
        title: 'Foot Soaks and Massage',
        description: 'Soak feet in warm water with Epsom salt and massage with lotion for relaxation.',
        category: 'physical',
        priority: 3,
        duration: '15-20 minutes',
        icon: 'spa',
        tags: ['relaxation', 'circulation', 'comfort'],
      ),
      PainReliefSuggestion(
        title: 'Elevation for Swelling',
        description: 'Prop feet above heart level to help fluid drain and reduce swelling.',
        category: 'physical',
        priority: 3,
        duration: '15-20 minutes',
        icon: 'vertical_align_top',
        tags: ['swelling', 'circulation', 'comfort'],
      ),
    ];
  }

  /// General Pain Relief Suggestions
  static List<PainReliefSuggestion> _getGeneralSuggestions() {
    return [
      PainReliefSuggestion(
        title: 'Deep Breathing',
        description: 'Practice slow, deep breathing to activate relaxation response and reduce pain perception.',
        category: 'mental',
        priority: 4,
        duration: '5-10 minutes',
        icon: 'air',
        tags: ['relaxation', 'stress-relief', 'mindfulness'],
      ),
      PainReliefSuggestion(
        title: 'Gentle Movement',
        description: 'Engage in light, comfortable movement to maintain circulation and prevent stiffness.',
        category: 'exercise',
        priority: 3,
        duration: '10-15 minutes',
        icon: 'directions_walk',
        tags: ['circulation', 'mobility', 'stiffness-prevention'],
      ),
      PainReliefSuggestion(
        title: 'Hydration',
        description: 'Stay well-hydrated to support muscle function and prevent cramps.',
        category: 'lifestyle',
        priority: 3,
        duration: 'ongoing',
        icon: 'water_drop',
        tags: ['hydration', 'muscle-function', 'prevention'],
      ),
      PainReliefSuggestion(
        title: 'Rest and Sleep',
        description: 'Get adequate rest and quality sleep to support healing and recovery.',
        category: 'lifestyle',
        priority: 4,
        duration: '7-9 hours',
        icon: 'bedtime',
        tags: ['healing', 'recovery', 'restoration'],
      ),
    ];
  }

  /// Get biblical healing suggestions for spiritual comfort
  static List<PainReliefSuggestion> getBiblicalHealingSuggestions() {
    return [
      PainReliefSuggestion(
        title: 'Prayer for Healing',
        description: 'Seek God\'s comfort and healing through prayer. "Heal me, O Lord, and I will be healed" (Jeremiah 17:14).',
        category: 'spiritual',
        priority: 5,
        duration: '5-15 minutes',
        icon: 'volunteer_activism',
        tags: ['prayer', 'healing', 'comfort'],
        faithVerse: 'Jeremiah 17:14',
      ),
      PainReliefSuggestion(
        title: 'Scripture Meditation',
        description: 'Meditate on God\'s promises of restoration and healing. "I am the LORD, who heals you" (Exodus 15:26).',
        category: 'spiritual',
        priority: 4,
        duration: '10-15 minutes',
        icon: 'menu_book',
        tags: ['scripture', 'meditation', 'hope'],
        faithVerse: 'Exodus 15:26',
      ),
      PainReliefSuggestion(
        title: 'Faith Community Support',
        description: 'Connect with your faith community for prayer and support during times of pain and healing.',
        category: 'spiritual',
        priority: 4,
        duration: 'ongoing',
        icon: 'people',
        tags: ['community', 'support', 'prayer'],
        faithVerse: 'James 5:14-15',
      ),
      PainReliefSuggestion(
        title: 'Trust in God\'s Plan',
        description: 'Find peace in trusting God\'s plan for your healing journey and well-being.',
        category: 'spiritual',
        priority: 4,
        duration: 'ongoing',
        icon: 'favorite',
        tags: ['trust', 'peace', 'hope'],
        faithVerse: '3 John 1:2',
      ),
    ];
  }
}

/// Data model for pain relief suggestions
class PainReliefSuggestion {
  final String title;
  final String description;
  final String category; // 'physical', 'exercise', 'lifestyle', 'mental', 'medication', 'spiritual'
  final int priority; // 1-5, higher is more important
  final String duration;
  final String icon;
  final List<String> tags;
  final String? faithVerse;

  const PainReliefSuggestion({
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.duration,
    required this.icon,
    required this.tags,
    this.faithVerse,
  });
}
