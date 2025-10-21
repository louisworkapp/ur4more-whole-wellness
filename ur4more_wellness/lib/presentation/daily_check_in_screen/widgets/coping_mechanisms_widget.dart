import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../services/faith_service.dart';

class CopingItem {
  final String key;
  final String label;
  final String desc;
  final String asset; // image path
  final int points;
  final bool selected;
  
  const CopingItem({
    required this.key,
    required this.label,
    required this.desc,
    required this.asset,
    this.points = 5,
    this.selected = false,
  });

  CopingItem copyWith({bool? selected}) => CopingItem(
    key: key,
    label: label,
    desc: desc,
    asset: asset,
    points: points,
    selected: selected ?? this.selected,
  );
}

class CopingMechanismsWidget extends StatefulWidget {
  final List<String> selectedMechanisms;
  final FaithMode faithMode;
  final double urgeLevel;
  final Function(List<String>) onChanged;

  const CopingMechanismsWidget({
    super.key,
    required this.selectedMechanisms,
    required this.faithMode,
    required this.urgeLevel,
    required this.onChanged,
  });

  @override
  State<CopingMechanismsWidget> createState() => _CopingMechanismsWidgetState();
}

class _CopingMechanismsWidgetState extends State<CopingMechanismsWidget> {
  int _faithXpEarned = 0;
  bool _scriptureUsedToday = false;
  bool _prayerUsedToday = false;

  final List<CopingItem> _copingStrategies = [
    CopingItem(
      key: 'read_scripture',
      label: 'Read Scripture',
      desc: 'Reflect and center your mind with the Word.',
        asset: 'assets/images/coping/scripture.png',
      points: 5,
    ),
    CopingItem(
      key: 'physical_exercise',
      label: 'Physical Exercise',
      desc: 'Move your body to release stress and boost mood.',
        asset: 'assets/images/coping/exercise.png',
      points: 5,
    ),
    CopingItem(
      key: 'journaling',
      label: 'Journaling',
      desc: 'Write thoughts to process emotions clearly.',
        asset: 'assets/images/coping/journaling.png',
      points: 5,
    ),
    CopingItem(
      key: 'listen_music',
      label: 'Listen to Music',
      desc: 'Use calming or uplifting tracks to reset.',
        asset: 'assets/images/coping/music.png',
      points: 5,
    ),
    CopingItem(
      key: 'call_friend',
      label: 'Call a Friend',
      desc: 'Reach out for support and connection.',
        asset: 'assets/images/coping/call_friend.png',
      points: 5,
    ),
    CopingItem(
      key: 'take_walk',
      label: 'Take a Walk',
      desc: 'Get fresh air and a change of scenery.',
        asset: 'assets/images/coping/walk.png',
      points: 5,
    ),
    CopingItem(
      key: 'practice_gratitude',
      label: 'Practice Gratitude',
      desc: 'List a few things you are thankful for.',
        asset: 'assets/images/coping/gratitude.png',
      points: 5,
    ),
    CopingItem(
      key: 'creative_activity',
      label: 'Creative Activity',
      desc: 'Draw, craft, or create to express yourself.',
        asset: 'assets/images/coping/creative.png',
      points: 5,
    ),
    CopingItem(
      key: 'mindful_eating',
      label: 'Mindful Eating',
      desc: 'Slow, intentional meal or snack.',
        asset: 'assets/images/coping/mindful_eating.png',
      points: 5,
    ),
    CopingItem(
      key: 'cold_shower',
      label: 'Cold Shower',
      desc: 'Short reset to energize the body.',
        asset: 'assets/images/coping/cold_shower.png',
      points: 5,
    ),
    CopingItem(
      key: 'deep_breathing',
      label: 'Deep Breathing',
      desc: 'Calm your nervous system with focused breath.',
        asset: 'assets/images/coping/breathing.png',
      points: 5,
    ),
    CopingItem(
      key: 'pray',
      label: 'Pray',
      desc: 'Connect with your spiritual side through prayer.',
        asset: 'assets/images/coping/pray.png',
      points: 5,
    ),
  ];

  void _toggleMechanism(String key) {
    setState(() {
      if (widget.selectedMechanisms.contains(key)) {
        widget.selectedMechanisms.remove(key);
      } else {
        widget.selectedMechanisms.add(key);
        
        // Award faith XP for first-time scripture/prayer use today
        if (widget.faithMode != FaithMode.off) {
          if (key == 'read_scripture' && !_scriptureUsedToday) {
            _scriptureUsedToday = true;
            _awardFaithXp(3);
          } else if (key == 'pray' && !_prayerUsedToday) {
            _prayerUsedToday = true;
            _awardFaithXp(3);
          }
        }
      }
      widget.onChanged(widget.selectedMechanisms);
    });
  }

  void _awardFaithXp(int amount) async {
    final xpAwarded = await FaithService.awardFaithXp(amount, DateTime.now());
    if (xpAwarded > 0) {
      setState(() {
        _faithXpEarned += xpAwarded;
      });
    }
  }

  int _calculateTotalPoints() {
    return widget.selectedMechanisms.fold(0, (total, key) {
      final strategy = _copingStrategies.firstWhere(
        (s) => s.key == key,
        orElse: () => CopingItem(key: '', label: '', desc: '', asset: '', points: 0),
      );
      return total + strategy.points;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final totalPoints = _calculateTotalPoints();
    final selectedCount = widget.selectedMechanisms.length;

    return Column(
      children: [
        // Header section
        Padding(
          padding: Pad.card,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary bar - shows selection count, total points, and faith XP
              if (selectedCount > 0) ...[
                Container(
                  width: double.infinity,
                  padding: Pad.card,
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.lightTheme.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CustomIconWidget(
                            iconName: 'check_circle',
                            color: AppTheme.lightTheme.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Selected $selectedCount • +$totalPoints pts',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppTheme.lightTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      // Faith XP indicator
                      if (_faithXpEarned > 0) ...[
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'stars',
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Faith XP +$_faithXpEarned',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: Colors.amber.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpace.x3),
              ],
              Text(
                'What helped today?',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: AppSpace.x2),
            ],
          ),
        ),
        
        // Coping strategies list (single column like body fitness)
        Expanded(
          child: Builder(
            builder: (context) {
              // Get ordered coping strategies based on faith mode and urge level
              final baseKeys = _copingStrategies.map((s) => s.key).toList();
              final orderedKeys = FaithService.orderedCoping(
                widget.faithMode, 
                baseKeys, 
                widget.urgeLevel >= 7
              );
              
              // Reorder strategies based on ordered keys
              final orderedStrategies = orderedKeys
                  .map((key) => _copingStrategies.firstWhere((s) => s.key == key))
                  .toList();
              
              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  16, 0, 16,
                  kBottomNavigationBarHeight + 16, // keep last row above buttons
                ),
                itemCount: orderedStrategies.length,
                itemBuilder: (context, index) {
                  final strategy = orderedStrategies[index];
                  final isSelected = widget.selectedMechanisms.contains(strategy.key);
                  return CopingTile(
                    item: strategy.copyWith(selected: isSelected),
                    onTap: () => _toggleMechanism(strategy.key),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class CopingTile extends StatelessWidget {
  const CopingTile({super.key, required this.item, required this.onTap});
  final CopingItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final selected = item.selected;

    return Semantics(
      label: '${item.label} coping strategy, ${selected ? 'selected' : 'not selected'}, ${item.points} points',
      button: true,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x1), // Same as body fitness
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: cs.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: selected ? cs.primary : cs.outlineVariant, width: 1.5),
              ),
            padding: Pad.card, // Use same padding as body fitness
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Title and Points
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.label,
                            style: GoogleFonts.inter(
                              fontSize: 16, // Same as body fitness
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: AppSpace.x1),
                          Text(
                            item.desc,
                            style: GoogleFonts.inter(
                              fontSize: 12, // Same as body fitness
                              fontWeight: FontWeight.w400,
                              color: cs.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: AppSpace.x3),
                    // Thumbnail (like body fitness)
                    Container(
                      width: 80, // Same as body fitness
                      height: 48, // Same as body fitness
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: cs.surfaceContainerHighest,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          item.asset,
                          width: 80,
                          height: 48,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 80, 
                            height: 48,
                            color: cs.surfaceContainerHighest,
                            alignment: Alignment.center,
                            child: Icon(Icons.image_not_supported_outlined, size: 24, color: cs.onSurface),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpace.x2),
                // Points chip at bottom
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade500,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('+${item.points} pts',
                        style: GoogleFonts.inter(
                          color: Colors.white, 
                          fontSize: 12, 
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Selection indicator
                    if (selected)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryLight,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            ),
          ),
        ),
      ),
    );
  }
}

