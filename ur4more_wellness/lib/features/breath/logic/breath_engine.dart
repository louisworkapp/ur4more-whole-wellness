import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'presets.dart';

/// Breathing phases for the engine
enum Phase { inhale, hold1, exhale, hold2 }

/// Breath Engine - Core breathing exercise logic with Ticker animation and 1s timer
/// 
/// Features:
/// - Frame-driven animation with Ticker (~60fps)
/// - 1-second timer for counters and soft tick sound
/// - Phase progression and timing
/// - Configurable breathing patterns
class BreathEngine {
  final BreathEngineConfig _config;
  final VoidCallback? _onStep;
  final VoidCallback? _onFinish;

  // Animation and timing
  late Ticker _ticker;
  Timer? _secondTimer;
  bool _isRunning = false;
  bool _isPaused = false;

  // Current state
  Phase _currentPhase = Phase.inhale;
  int _totalRemaining = 0;
  int _stepRemaining = 0;
  double _stepProgress = 0.0; // 0..1 for animation

  // Notifiers for UI binding
  final ValueNotifier<Phase> phase = ValueNotifier(Phase.inhale);
  final ValueNotifier<double> stepProgress = ValueNotifier(0.0);
  final ValueNotifier<int> totalRemaining = ValueNotifier(0);
  final ValueNotifier<int> stepRemaining = ValueNotifier(0);

  BreathEngine(
    BreathEngineConfig config, {
    VoidCallback? onStep,
    VoidCallback? onFinish,
  })  : _config = config,
        _onStep = onStep,
        _onFinish = onFinish {
    _initialize();
  }

  void _initialize() {
    _totalRemaining = _config.totalSeconds;
    _stepRemaining = _config.inhale;
    _currentPhase = Phase.inhale;
    _stepProgress = 0.0;

    // Create ticker for smooth animation
    _ticker = Ticker(_onTick);
  }

  void _onTick(Duration elapsed) {
    if (!_isRunning || _isPaused) return;

    // Calculate step progress based on current phase duration
    final phaseDuration = _getPhaseDuration(_currentPhase);
    if (phaseDuration > 0) {
      final elapsedInPhase = _config.totalSeconds - _totalRemaining - _getPhaseStartTime();
      _stepProgress = (elapsedInPhase / phaseDuration).clamp(0.0, 1.0);
      stepProgress.value = _stepProgress;
    }
  }

  int _getPhaseStartTime() {
    int startTime = 0;
    switch (_currentPhase) {
      case Phase.inhale:
        startTime = 0;
        break;
      case Phase.hold1:
        startTime = _config.inhale;
        break;
      case Phase.exhale:
        startTime = _config.inhale + _config.hold1;
        break;
      case Phase.hold2:
        startTime = _config.inhale + _config.hold1 + _config.exhale;
        break;
    }
    return startTime;
  }

  int _getPhaseDuration(Phase phase) {
    switch (phase) {
      case Phase.inhale:
        return _config.inhale;
      case Phase.hold1:
        return _config.hold1;
      case Phase.exhale:
        return _config.exhale;
      case Phase.hold2:
        return _config.hold2;
    }
  }

  void _onSecondTick() {
    if (!_isRunning || _isPaused) return;

    setState(() {
      _totalRemaining--;
      _stepRemaining--;
    });

    // Play soft tick sound
    _playTickSound();

    // Check if current step is complete
    if (_stepRemaining <= 0) {
      _advanceToNextPhase();
    }

    // Check if session is complete
    if (_totalRemaining <= 0) {
      _finish();
    }
  }

  void _advanceToNextPhase() {
    setState(() {
      switch (_currentPhase) {
        case Phase.inhale:
          _currentPhase = Phase.hold1;
          _stepRemaining = _config.hold1;
          break;
        case Phase.hold1:
          _currentPhase = Phase.exhale;
          _stepRemaining = _config.exhale;
          break;
        case Phase.exhale:
          _currentPhase = Phase.hold2;
          _stepRemaining = _config.hold2;
          break;
        case Phase.hold2:
          _currentPhase = Phase.inhale;
          _stepRemaining = _config.inhale;
          break;
      }
      _stepProgress = 0.0;
    });

    phase.value = _currentPhase;
    _onStep?.call();
  }

  void _playTickSound() {
    try {
      SystemSound.play(SystemSoundType.click);
    } catch (e) {
      // Silently ignore if sound is not supported on platform
    }
  }

  void setState(VoidCallback fn) {
    fn();
    stepProgress.value = _stepProgress;
    totalRemaining.value = _totalRemaining;
    stepRemaining.value = _stepRemaining;
  }

  /// Start the breathing exercise
  void start() {
    if (_isRunning) return;

    _isRunning = true;
    _isPaused = false;

    // Start ticker for smooth animation
    _ticker.start();

    // Start 1-second timer for counters and sound
    _secondTimer = Timer.periodic(const Duration(seconds: 1), (_) => _onSecondTick());
  }

  /// Pause the breathing exercise
  void pause() {
    if (!_isRunning || _isPaused) return;

    _isPaused = true;
    _ticker.stop();
    _secondTimer?.cancel();
  }

  /// Resume the breathing exercise
  void resume() {
    if (!_isRunning || !_isPaused) return;

    _isPaused = false;
    _ticker.start();
    _secondTimer = Timer.periodic(const Duration(seconds: 1), (_) => _onSecondTick());
  }

  /// Reset the breathing exercise to initial state
  void reset([BreathEngineConfig? newConfig]) {
    _isRunning = false;
    _isPaused = false;

    _ticker.stop();
    _secondTimer?.cancel();

    if (newConfig != null) {
      // Update config and reinitialize
      _initialize();
    } else {
      // Reset to current config
      _initialize();
    }

    // Update notifiers
    phase.value = _currentPhase;
    stepProgress.value = _stepProgress;
    totalRemaining.value = _totalRemaining;
    stepRemaining.value = _stepRemaining;
  }

  /// Finish the breathing exercise
  void _finish() {
    _isRunning = false;
    _isPaused = false;

    _ticker.stop();
    _secondTimer?.cancel();

    _onFinish?.call();
  }

  /// Get current phase label for UI
  String get phaseLabel {
    switch (_currentPhase) {
      case Phase.inhale:
        return 'Inhale';
      case Phase.hold1:
        return 'Hold';
      case Phase.exhale:
        return 'Exhale';
      case Phase.hold2:
        return 'Hold';
    }
  }

  /// Get current configuration
  BreathEngineConfig get config => _config;

  /// Check if engine is running
  bool get isRunning => _isRunning;

  /// Check if engine is paused
  bool get isPaused => _isPaused;

  /// Dispose resources
  void dispose() {
    _ticker.dispose();
    _secondTimer?.cancel();
    phase.dispose();
    stepProgress.dispose();
    totalRemaining.dispose();
    stepRemaining.dispose();
  }
}
