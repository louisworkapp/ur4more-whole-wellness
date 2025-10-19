import 'package:flutter/material.dart';
import '../../../services/faith_service.dart';
import '../../../core/settings/settings_scope.dart';
import '../../../core/settings/settings_model.dart';
import '../presentation/widgets/meaning_horizon_card.dart';
import '../presentation/widgets/switch_to_faith_mode_modal.dart';

/// Service for managing the conversion funnel from OFF mode to Faith modes
class ConversionFunnelService {
  // Conversion signals thresholds
  static const int minCompletionsThisWeek = 3;
  static const int highUrgeThreshold = 7;
  static const List<String> serviceValuesKeywords = ['service', 'legacy', 'sacrifice', 'mission', 'calling'];
  
  // Tracking for conversion signals
  static int _completionsThisWeek = 0;
  static int _lastUrgeScore = 0;
  static List<String> _valuesChosen = [];
  static DateTime? _lastInviteShown;
  static const Duration inviteCooldown = Duration(hours: 24);

  /// Check if user should be invited to faith mode based on current signals
  static bool shouldShowInvite(FaithMode currentMode) {
    if (!currentMode.isOff) return false;
    
    // Don't show invites too frequently
    if (_lastInviteShown != null && 
        DateTime.now().difference(_lastInviteShown!) < inviteCooldown) {
      return false;
    }
    
    return _hasConversionSignals();
  }

  /// Check if user has triggered conversion signals
  static bool _hasConversionSignals() {
    return _completionsThisWeek >= minCompletionsThisWeek ||
           _lastUrgeScore >= highUrgeThreshold ||
           _valuesChosen.any((value) => 
             serviceValuesKeywords.any((keyword) => 
               value.toLowerCase().contains(keyword)));
  }

  /// Record a week completion (for course completions)
  static void recordWeekCompletion() {
    _completionsThisWeek++;
  }

  /// Record an urge score (for crisis resolution)
  static void recordUrgeScore(int score) {
    _lastUrgeScore = score;
  }

  /// Record values chosen (for values clarification exercises)
  static void recordValuesChosen(List<String> values) {
    _valuesChosen = values;
  }

  /// Reset weekly tracking (call this weekly)
  static void resetWeeklyTracking() {
    _completionsThisWeek = 0;
  }

  /// Show appropriate invite based on context
  static Future<void> maybeInviteToFaith(
    BuildContext context, {
    String? customHeadline,
    String? customBody,
    InviteContext inviteContext = InviteContext.general,
  }) async {
    final settings = SettingsScope.of(context).value;
    final currentMode = _faithTierToMode(settings.faithTier);
    
    if (!shouldShowInvite(currentMode)) return;

    _lastInviteShown = DateTime.now();

    switch (inviteContext) {
      case InviteContext.weekCompletion:
        await _showWeekCompletionInvite(context, customHeadline, customBody);
        break;
      case InviteContext.crisisResolved:
        await _showCrisisResolvedInvite(context);
        break;
      case InviteContext.valuesMilestone:
        await _showValuesMilestoneInvite(context);
        break;
      case InviteContext.general:
      default:
        await _showGeneralInvite(context);
        break;
    }
  }

  /// Show week completion invite
  static Future<void> _showWeekCompletionInvite(
    BuildContext context,
    String? customHeadline,
    String? customBody,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MeaningHorizonCard(
        headline: customHeadline ?? "Where does meaning finally land?",
        body: customBody ?? "Order and truth change your life. We believe their deepest end is found in Jesus Christ.",
        onKeepSecular: () {
          // Reset tracking to avoid immediate re-invites
          _completionsThisWeek = 0;
        },
      ),
    );

    if (result == true) {
      // User activated faith mode
      _resetAllTracking();
    }
  }

  /// Show crisis resolved invite
  static Future<void> _showCrisisResolvedInvite(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MeaningHorizonCard(
        headline: "You steadied the storm",
        body: "Would you like a peace that keeps watch over your mind? Explore Faith Mode: Light for gentle faith integration.",
        onKeepSecular: () {
          _lastUrgeScore = 0; // Reset to avoid immediate re-invites
        },
      ),
    );

    if (result == true) {
      _resetAllTracking();
    }
  }

  /// Show values milestone invite
  static Future<void> _showValuesMilestoneInvite(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => MeaningHorizonCard(
        headline: "Your values aim higher than comfort",
        body: "Explore the calling that outlasts you. Try Faith Mode: Light to discover purpose beyond yourself.",
        onKeepSecular: () {
          _valuesChosen.clear(); // Reset to avoid immediate re-invites
        },
      ),
    );

    if (result == true) {
      _resetAllTracking();
    }
  }

  /// Show general invite
  static Future<void> _showGeneralInvite(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => const SwitchToFaithModeModal(),
    );

    if (result == true) {
      _resetAllTracking();
    }
  }

  /// Reset all tracking after successful conversion
  static void _resetAllTracking() {
    _completionsThisWeek = 0;
    _lastUrgeScore = 0;
    _valuesChosen.clear();
    _lastInviteShown = DateTime.now();
  }

  /// Convert FaithTier to FaithMode
  static FaithMode _faithTierToMode(FaithTier tier) {
    switch (tier) {
      case FaithTier.off:
        return FaithMode.off;
      case FaithTier.light:
        return FaithMode.light;
      case FaithTier.disciple:
        return FaithMode.disciple;
      case FaithTier.kingdom:
        return FaithMode.kingdom;
    }
  }

  /// Get conversion metrics for analytics
  static Map<String, dynamic> getConversionMetrics() {
    return {
      'completionsThisWeek': _completionsThisWeek,
      'lastUrgeScore': _lastUrgeScore,
      'valuesChosen': _valuesChosen,
      'lastInviteShown': _lastInviteShown?.toIso8601String(),
      'hasConversionSignals': _hasConversionSignals(),
    };
  }
}

/// Context for different types of invites
enum InviteContext {
  weekCompletion,
  crisisResolved,
  valuesMilestone,
  general,
}

/// Extension for easy access to conversion service
extension ConversionFunnelExtension on BuildContext {
  /// Show faith mode invite if appropriate
  Future<void> maybeInviteToFaith({
    String? customHeadline,
    String? customBody,
    InviteContext context = InviteContext.general,
  }) async {
    await ConversionFunnelService.maybeInviteToFaith(
      this,
      customHeadline: customHeadline,
      customBody: customBody,
      inviteContext: context,
    );
  }
}
