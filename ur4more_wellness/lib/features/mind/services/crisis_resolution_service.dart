import 'package:flutter/material.dart';
import '../../../services/faith_service.dart';
import '../../../core/settings/settings_scope.dart';
import '../../../core/settings/settings_model.dart';
import 'conversion_funnel_service.dart';

/// Service for handling crisis resolution and faith mode invites
class CrisisResolutionService {
  /// Handle urge resolution and check for conversion opportunities
  static Future<void> handleUrgeResolution(
    BuildContext context, {
    required int initialUrgeScore,
    required int resolvedUrgeScore,
    required String resolutionMethod,
  }) async {
    final settings = SettingsScope.of(context).value;
    final currentMode = _faithTierToMode(settings.faithTier);
    
    // Record the urge score for conversion tracking
    ConversionFunnelService.recordUrgeScore(initialUrgeScore);
    
    // Check if this was a high-urge crisis that was successfully resolved
    if (initialUrgeScore >= 7 && resolvedUrgeScore <= 3 && currentMode.isOff) {
      // Wait a moment for the user to feel the relief
      await Future.delayed(const Duration(seconds: 2));
      
      if (context.mounted) {
        await context.maybeInviteToFaith(
          context: InviteContext.crisisResolved,
        );
      }
    }
  }

  /// Handle daily check-in completion with urge tracking
  static Future<void> handleDailyCheckInCompletion(
    BuildContext context, {
    required int urgeScore,
    required List<String> copingStrategiesUsed,
    required bool crisisResolved,
  }) async {
    final settings = SettingsScope.of(context).value;
    final currentMode = _faithTierToMode(settings.faithTier);
    
    if (currentMode.isOff && crisisResolved && urgeScore >= 7) {
      // Record the high urge score
      ConversionFunnelService.recordUrgeScore(urgeScore);
      
      // Show crisis resolution invite after a brief delay
      await Future.delayed(const Duration(seconds: 3));
      
      if (context.mounted) {
        await context.maybeInviteToFaith(
          context: InviteContext.crisisResolved,
        );
      }
    }
  }

  /// Convert FaithTier to FaithTier
  static FaithTier _faithTierToMode(FaithTier tier) {
    switch (tier) {
      case FaithTier.off:
        return FaithTier.off;
      case FaithTier.light:
        return FaithTier.light;
      case FaithTier.disciple:
        return FaithTier.disciple;
      case FaithTier.kingdom:
        return FaithTier.kingdom;
    }
  }
}

/// Extension for easy crisis resolution handling
extension CrisisResolutionExtension on BuildContext {
  /// Handle urge resolution with conversion tracking
  Future<void> handleUrgeResolution({
    required int initialUrgeScore,
    required int resolvedUrgeScore,
    required String resolutionMethod,
  }) async {
    await CrisisResolutionService.handleUrgeResolution(
      this,
      initialUrgeScore: initialUrgeScore,
      resolvedUrgeScore: resolvedUrgeScore,
      resolutionMethod: resolutionMethod,
    );
  }

  /// Handle daily check-in completion with conversion tracking
  Future<void> handleDailyCheckInCompletion({
    required int urgeScore,
    required List<String> copingStrategiesUsed,
    required bool crisisResolved,
  }) async {
    await CrisisResolutionService.handleDailyCheckInCompletion(
      this,
      urgeScore: urgeScore,
      copingStrategiesUsed: copingStrategiesUsed,
      crisisResolved: crisisResolved,
    );
  }
}
