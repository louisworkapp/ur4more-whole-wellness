import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemSound, SystemSoundType;
import 'package:flutter/scheduler.dart' show Ticker;
import 'package:flutter/semantics.dart';
import 'package:vibration/vibration.dart';
import '../../../../core/settings/settings_scope.dart';
import '../../../../core/settings/settings_model.dart';
import '../../../../services/faith_service.dart';
import '../../breath/logic/box_levels.dart';
import '../../breath/widgets/animated_breath_circle.dart';
import '../../quotes/quote_picker.dart';
import '../../faith/faith_consent.dart';

enum BreathStep { inhale, hold1, exhale, hold2 }

class BoxBreathingScreen extends StatefulWidget {
  final FaithTier faithMode;
  final String exerciseId;

  const BoxBreathingScreen({
    Key? key,
    required this.faithMode,
    required this.exerciseId,
  }) : super(key: key);

  @override
  State<BoxBreathingScreen> createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen> with SingleTickerProviderStateMixin {
  late BoxLevel _level;
  // Per-second counters
  Timer? _secondTimer;
  int _totalRemaining = 0; // seconds
  int _stepRemaining = 0;  // seconds for current step
  BreathStep _step = BreathStep.inhale;
  bool _running = false;
  // Smooth animation progress (0..1) driven by ticker
  late final Ticker _ticker;
  int _stepElapsedMs = 0;
  double _stepProgress = 0.0;

  // Quotes (inline carousel)
  List<QuoteItem> _quotePool = [];
  int _quoteIndex = -1; // -1 = None
  bool _quoteAllowed = false;
  bool _lightConsentGiven = false;

  @override
  void initState() {
    super.initState();
    // default to l1
    _level = BoxLevels.l1;
    _totalRemaining = _level.defaultTotalSeconds;
    _stepRemaining = _level.inhale;
    // Smooth ticker (~60fps). Only updates visual progress; counters remain 1s.
    _ticker = Ticker((_) {
      if (!_running) return;
      final stepMs = (_currentStepDuration() * 1000).clamp(1, 360000);
      _stepElapsedMs = (_stepElapsedMs + 16).clamp(0, stepMs); // ~60fps
      final p = _stepElapsedMs / stepMs;
      if (mounted) setState(() => _stepProgress = p.clamp(0, 1));
    });
    // Build initial quote pool after first frame (needs settings)
    WidgetsBinding.instance.addPostFrameCallback((_) => _ensureQuotePool());
  }

  @override
  void dispose() {
    _ticker.dispose();
    _secondTimer?.cancel();
    super.dispose();
  }

  void _selectLevel(BoxLevel lvl) {
    setState(() {
      _level = lvl;
      _resetInternal();
    });
  }

  void _resetInternal() {
    _ticker.stop();
    _secondTimer?.cancel();
    _running = false;
    _totalRemaining = _level.defaultTotalSeconds;
    _step = BreathStep.inhale;
    _stepRemaining = _level.inhale;
    _stepElapsedMs = 0;
    _stepProgress = 0;
  }

  Future<void> _start() async {
    if (_running) return;
    setState(() => _running = true);
    _track('breath_started', {'level': _level.id, 'total_seconds': _totalRemaining});
    _ticker.start();
    _startSecondTick();
  }

  void _pause() {
    if (!_running) return;
    _ticker.stop();
    _secondTimer?.cancel();
    setState(() => _running = false);
    _track('breath_paused', {'level': _level.id, 'total_remaining_s': _totalRemaining});
  }

  void _reset() {
    _track('breath_reset', {'level': _level.id});
    setState(_resetInternal);
  }

  void _finish() {
    _ticker.stop();
    _secondTimer?.cancel();
    setState(() => _running = false);
    _track('breath_completed', {'level': _level.id});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session complete')));
  }

  int _currentStepDuration() {
    switch (_step) {
      case BreathStep.inhale: return _level.inhale;
      case BreathStep.hold1: return _level.hold1;
      case BreathStep.exhale: return _level.exhale;
      case BreathStep.hold2: return _level.hold2;
    }
  }

  void _announceStep() {
    try {
      SemanticsService.announce(_stepLabel(), TextDirection.ltr);
    } catch (_) {}
  }

  Future<void> _haptic() async {
    try {
      if (await Vibration.hasVibrator() ?? false) {
        Vibration.vibrate(duration: 20, amplitude: 32);
      }
    } catch (_) {}
  }

  void _advanceStep() {
    _haptic();
    setState(() {
      if (_step == BreathStep.inhale) {
        _step = BreathStep.hold1;
        _stepRemaining = _level.hold1;
      } else if (_step == BreathStep.hold1) {
        _step = BreathStep.exhale;
        _stepRemaining = _level.exhale;
      } else if (_step == BreathStep.exhale) {
        _step = BreathStep.hold2;
        _stepRemaining = _level.hold2;
      } else {
        _step = BreathStep.inhale;
        _stepRemaining = _level.inhale;
      }
      _stepElapsedMs = 0;
      _stepProgress = 0.0;
      _track('breath_step_changed', {
        'level': _level.id,
        'step': _step.name,
        'remaining_step_s': _stepRemaining,
        'total_remaining_s': _totalRemaining
      });
    });
    _announceStep();
  }

  // New: per-second counters + soft audio tick
  void _startSecondTick() {
    _secondTimer?.cancel();
    _secondTimer = Timer.periodic(const Duration(seconds: 1), (t) async {
      if (!mounted || !_running) return;
      try { await SystemSound.play(SystemSoundType.click); } catch (_) {}
      setState(() {
        _totalRemaining = (_totalRemaining - 1).clamp(0, 99999);
        _stepRemaining  = (_stepRemaining - 1).clamp(0, 99999);
        if (_stepRemaining <= 0) _advanceStep();
        if (_totalRemaining <= 0) _finish();
      });
    });
  }

  // ---------- Quotes: inline carousel ----------
  Future<void> _ensureQuotePool() async {
    final settings = SettingsScope.of(context).value;
    final faithActivated = settings.faithTier != FaithTier.off;
    final hideFaith = false; // TODO: Add hideFaithOverlaysInMind to settings
    final isLight = settings.faithTier == FaithTier.light;

    _quoteAllowed = faithActivated && !hideFaith &&
        (settings.faithTier == FaithTier.disciple ||
         settings.faithTier == FaithTier.kingdom ||
         (isLight && _lightConsentGiven));

    final lib = await QuoteLibrary.load();
    final pool = lib.filtered(
      allowFaith: _quoteAllowed,
      allowSecular: true,
    );
    setState(() {
      _quotePool = pool;
      _quoteIndex = _quotePool.isEmpty ? -1 : 0;
    });
  }

  void _nextQuote() {
    if (_quotePool.isEmpty) return;
    setState(() => _quoteIndex = (_quoteIndex + 1) % _quotePool.length);
    _track('quote_next', {
      'quote_id': _quotePool[_quoteIndex].id,
      'pool': _quoteAllowed ? 'faith+secular' : 'secular'
    });
  }

  void _clearQuote() {
    setState(() => _quoteIndex = -1);
    _track('quote_cleared', {});
  }

  Future<void> _maybeAskLightConsent() async {
    final settings = SettingsScope.of(context).value;
    final isLight = settings.faithTier == FaithTier.light;
    final hideFaith = false; // TODO: Add hideFaithOverlaysInMind to settings
    final faithActivated = settings.faithTier != FaithTier.off;
    if (faithActivated && isLight && !_lightConsentGiven && !hideFaith) {
      _lightConsentGiven = await askLightConsentIfNeeded(
        context: context,
        faithMode: settings.faithTier,
        hideFaithOverlaysInMind: hideFaith,
      );
      _track('light_consent_set', {'allowed': _lightConsentGiven});
      await _ensureQuotePool();
    }
  }



  String _stepLabel() {
    switch (_step) {
      case BreathStep.inhale: return 'Inhale';
      case BreathStep.hold1: return 'Hold';
      case BreathStep.exhale: return 'Exhale';
      case BreathStep.hold2: return 'Hold';
    }
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(1, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  void _track(String event, Map<String, dynamic> props) {
    // hook to your analytics
    // e.g., Analytics.track(event, props);
    print('Analytics: $event - $props');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final settings = SettingsScope.of(context).value;
    final faithActivated = settings.faithTier != FaithTier.off;
    final hideFaith = false; // TODO: Add hideFaithOverlaysInMind to settings
    final levels = BoxLevels.available(
      faithActivated: faithActivated,
      hideFaithOverlaysInMind: hideFaith,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Box Breathing')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Title + quote controls
              Row(
                children: [
                  Expanded(
                    child: Text(_level.title,
                      style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  // Inline carousel controls (only show Next/None when allowed or a quote is active)
                  if ((_quoteAllowed && _quotePool.isNotEmpty) || _quoteIndex >= 0) ...[
                    if (_quoteIndex >= 0)
                      TextButton(onPressed: _clearQuote, child: const Text('None')),
                    if (_quoteAllowed && _quotePool.isNotEmpty)
                      TextButton(
                        onPressed: () async { await _maybeAskLightConsent(); _nextQuote(); },
                        child: const Text('Next'),
                      ),
                  ],
                ],
              ),
              // Smooth quote area
              if (_quoteIndex >= 0 && _quoteIndex < _quotePool.length) ...[
                const SizedBox(height: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  switchInCurve: Curves.easeOut,
                  switchOutCurve: Curves.easeOut,
                  child: Padding(
                    key: ValueKey(_quotePool[_quoteIndex].id),
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '"${_quotePool[_quoteIndex].text}" — ${_quotePool[_quoteIndex].author}',
                        style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Animated circle
              Expanded(
                child: AnimatedBreathCircle(
                  progress: _stepProgress,
                  phase: _step == BreathStep.inhale ? 'inhale' : (_step == BreathStep.exhale ? 'exhale' : 'hold'),
                ),
              ),
              const SizedBox(height: 8),
              // Timers row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _TimerPill(label: 'Step', value: _fmt(_stepRemaining)),
                  Text(_stepLabel(), style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  _TimerPill(label: 'Total', value: _fmt(_totalRemaining)),
                ],
              ),
              const SizedBox(height: 12),
              // Leaf level selector
              _LeafLevelsBar(
                selected: _level.id,
                levels: levels,
                onTap: (lvl) {
                  if (_running) _pause();
                  _selectLevel(lvl);
                },
              ),
              const SizedBox(height: 12),
              // Controls
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _running ? _pause : () async {
                        // Ensure consent/pool before starting, so first quote appears if allowed
                        await _maybeAskLightConsent();
                        if (_quotePool.isEmpty && _quoteAllowed) { await _ensureQuotePool(); }
                        _start();
                      },
                      icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                      label: Text(_running ? 'Pause' : 'Start'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.replay),
                      label: const Text('Reset'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerPill extends StatelessWidget {
  final String label, value;
  const _TimerPill({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          Text(value, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _LeafLevelsBar extends StatelessWidget {
  final String selected;
  final List<BoxLevel> levels;
  final Function(BoxLevel) onTap;

  const _LeafLevelsBar({
    required this.selected,
    required this.levels,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    
    return Row(
      children: levels.map((level) {
        final isSelected = level.id == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: GestureDetector(
              onTap: () => onTap(level),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? cs.primary : cs.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  level.title,
                  textAlign: TextAlign.center,
                  style: t.textTheme.bodySmall?.copyWith(
                    color: isSelected ? cs.onPrimary : cs.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}