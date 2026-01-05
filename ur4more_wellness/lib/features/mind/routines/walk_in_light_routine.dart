import 'package:flutter/material.dart';

import '../../../services/faith_service.dart';
import '../presentation/screens/walk_in_light_screen.dart';

class WalkInLightRoutine extends StatelessWidget {
  final bool isFaithActivated;
  final bool hideFaithOverlaysInMind;
  final Function(String event, Map<String, dynamic> props) analytics;
  final Function(int xp) onAwardXp;

  const WalkInLightRoutine({
    super.key,
    required this.isFaithActivated,
    required this.hideFaithOverlaysInMind,
    required this.analytics,
    required this.onAwardXp,
  });

  @override
  Widget build(BuildContext context) {
    // Convert boolean to FaithTier
    final faithMode = isFaithActivated ? FaithTier.light : FaithTier.off;
    
    return WalkInLightScreen(
      faithMode: faithMode,
      onAnalytics: analytics,
      onAwardXp: onAwardXp,
    );
  }
}