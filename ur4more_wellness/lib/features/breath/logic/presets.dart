/// Breath Coach v2 Presets
/// 
/// Four preset breathing patterns with different cadences and purposes:
/// - Quick Calm: Physiological sigh for rapid stress relief
/// - HRV: Heart rate variability resonance breathing
/// - Focus: Traditional box breathing for concentration
/// - Sleep: Extended exhale for relaxation and sleep preparation

class BreathEngineConfig {
  final int inhale;        // seconds
  final int hold1;         // seconds (0 for no hold)
  final int exhale;        // seconds
  final int hold2;         // seconds (0 for no hold)
  final int totalSeconds;  // default session duration
  final bool exhaleWeighted; // true if exhale is longer than inhale

  const BreathEngineConfig({
    required this.inhale,
    required this.hold1,
    required this.exhale,
    required this.hold2,
    required this.totalSeconds,
    required this.exhaleWeighted,
  });

  /// Get total cycle duration in seconds
  int get cycleDuration => inhale + hold1 + exhale + hold2;

  /// Get breaths per minute
  double get breathsPerMinute => 60.0 / cycleDuration;
}

class BreathPreset {
  final String id;
  final String name;
  final String subtitle;
  final BreathEngineConfig config;
  final bool dimUi; // true for sleep preset (lower contrast)

  const BreathPreset({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.config,
    this.dimUi = false,
  });
}

class Presets {
  /// Quick Calm - Physiological Sigh
  /// Short inhale + micro top-up + long exhale for rapid stress relief
  static const quickCalm = BreathPreset(
    id: 'quick_calm',
    name: 'Quick Calm',
    subtitle: 'Physiological sigh • 2 min',
    config: BreathEngineConfig(
      inhale: 2,
      hold1: 0,
      exhale: 6,
      hold2: 0,
      totalSeconds: 120,
      exhaleWeighted: true,
    ),
  );

  /// HRV - Heart Rate Variability Resonance
  /// Even 5-5 breathing at ~6 breaths/min for HRV optimization
  static const hrv = BreathPreset(
    id: 'hrv',
    name: 'HRV',
    subtitle: '~6 breaths/min • 6 min',
    config: BreathEngineConfig(
      inhale: 5,
      hold1: 0,
      exhale: 5,
      hold2: 0,
      totalSeconds: 360,
      exhaleWeighted: false,
    ),
  );

  /// Focus - Traditional Box Breathing
  /// 4-4-4-4 pattern for concentration and focus
  static const focus = BreathPreset(
    id: 'focus',
    name: 'Focus',
    subtitle: 'Box 4-4-4-4 • 3 min',
    config: BreathEngineConfig(
      inhale: 4,
      hold1: 4,
      exhale: 4,
      hold2: 4,
      totalSeconds: 180,
      exhaleWeighted: false,
    ),
  );

  /// Sleep - Extended Exhale
  /// 4-6 breathing pattern for relaxation and sleep preparation
  static const sleep = BreathPreset(
    id: 'sleep',
    name: 'Sleep',
    subtitle: '4-6 downshift • 6 min',
    config: BreathEngineConfig(
      inhale: 4,
      hold1: 0,
      exhale: 6,
      hold2: 0,
      totalSeconds: 360,
      exhaleWeighted: true,
    ),
    dimUi: true,
  );

  static const all = [quickCalm, hrv, focus, sleep];

  /// Get preset by ID, fallback to focus if not found
  static BreathPreset byId(String id) {
    return all.firstWhere(
      (preset) => preset.id == id,
      orElse: () => focus,
    );
  }

  /// Get available presets based on faith mode
  static List<BreathPreset> available({
    required bool faithActivated,
    required bool hideFaithOverlaysInMind,
  }) {
    // All presets are available regardless of faith mode
    // Faith filtering happens at the quote level
    return all;
  }
}
