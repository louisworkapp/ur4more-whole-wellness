import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import '../../../core/settings/settings_scope.dart';
import '../../../core/settings/settings_model.dart';
import '../../../services/faith_service.dart';
import 'logic/box_levels.dart';
import 'widgets/animated_breath_circle.dart';
import '../quotes/quote_picker.dart';
import '../faith/faith_consent.dart';

enum BreathStep { inhale, hold1, exhale, hold2 }

class BoxBreathingScreen extends StatefulWidget {
  const BoxBreathingScreen({super.key});

  @override
  State<BoxBreathingScreen> createState() => _BoxBreathingScreenState();
}

class _BoxBreathingScreenState extends State<BoxBreathingScreen> with SingleTickerProviderStateMixin {
  late BoxLevel _level;
  Timer? _tick;
  int _totalRemaining = 0; // seconds
  int _stepRemaining = 0; // seconds for current step
  BreathStep _step = BreathStep.inhale;
  bool _running = false;
  double _stepProgress = 0.0; // 0..1 for animation

  // Quotes
  QuoteItem? _quote;
  bool _lightConsentGiven = false;

  @override
  void initState() {
    super.initState();
    // default to l1
    _level = BoxLevels.l1;
    _totalRemaining = _level.defaultTotalSeconds;
    _stepRemaining = _level.inhale;
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  void _selectLevel(BoxLevel lvl) {
    setState(() {
      _level = lvl;
      _resetInternal();
    });
  }

  void _resetInternal() {
    _tick?.cancel();
    _running = false;
    _totalRemaining = _level.defaultTotalSeconds;
    _step = BreathStep.inhale;
    _stepRemaining = _level.inhale;
    _stepProgress = 0;
  }

  Future<void> _start() async {
    if (_running) return;
    setState(() => _running = true);
    _track('breath_started', {'level': _level.id, 'total_seconds': _totalRemaining});

    _tick = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      if (_totalRemaining <= 0) {
        _finish();
        return;
      }

      setState(() {
        _totalRemaining -= 1;
        _stepRemaining -= 1;
        final stepDuration = _currentStepDuration();
        _stepProgress = 1.0 - (_stepRemaining / stepDuration).clamp(0, 1);

        if (_stepRemaining <= 0) {
          _advanceStep();
        }
      });
    });
  }

  void _pause() {
    if (!_running) return;
    _tick?.cancel();
    setState(() => _running = false);
    _track('breath_paused', {'level': _level.id, 'total_remaining_s': _totalRemaining});
  }

  void _reset() {
    _track('breath_reset', {'level': _level.id});
    setState(_resetInternal);
  }

  void _finish() {
    _tick?.cancel();
    setState(() => _running = false);
    _track('breath_completed', {'level': _level.id});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Session complete')));
  }

  int _currentStepDuration() {
    switch (_step) {
      case BreathStep.inhale: return _level.inhale;
      case BreathStep.hold1:  return _level.hold1;
      case BreathStep.exhale: return _level.exhale;
      case BreathStep.hold2:  return _level.hold2;
    }
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
        _step = BreathStep.hold1; _stepRemaining = _level.hold1;
      } else if (_step == BreathStep.hold1) {
        _step = BreathStep.exhale; _stepRemaining = _level.exhale;
      } else if (_step == BreathStep.exhale) {
        _step = BreathStep.hold2; _stepRemaining = _level.hold2;
      } else {
        _step = BreathStep.inhale; _stepRemaining = _level.inhale;
      }
      _stepProgress = 0.0;
      _track('breath_step_changed', {
        'level': _level.id,
        'step': _step.name,
        'remaining_step_s': _stepRemaining,
        'total_remaining_s': _totalRemaining
      });
    });
  }

  Future<void> _pickQuote() async {
    final settingsController = SettingsScope.of(context);
    final settings = settingsController.value;
    final faithTier = settings.faithTier;
    final faithActivated = faithTier != FaithTier.off;
    final hideFaith = false; // TODO: Add this setting to AppSettings

    // Convert FaithTier to FaithTier for the consent helper
    FaithTier faithMode;
    switch (faithTier) {
      case FaithTier.off:
        faithMode = FaithTier.off;
        break;
      case FaithTier.light:
        faithMode = FaithTier.light;
        break;
      case FaithTier.disciple:
        faithMode = FaithTier.disciple;
        break;
      case FaithTier.kingdom:
        faithMode = FaithTier.kingdom;
        break;
    }

    // If Light and we haven't asked yet, prompt once per session:
    final isLight = faithMode == FaithTier.light;
    if (faithActivated && isLight && !_lightConsentGiven && !hideFaith) {
      _lightConsentGiven = await askLightConsentIfNeeded(
        context: context,
        faithMode: faithMode,
        hideFaithOverlaysInMind: hideFaith,
      );
      // optional analytics:
      _track('light_consent_set', {'allowed': _lightConsentGiven});
    }

    // Determine whether faith quotes are allowed right now:
    final canShowFaith = faithActivated && !hideFaith && (
      faithMode == FaithTier.disciple ||
      faithMode == FaithTier.kingdom ||
      (faithMode == FaithTier.light && _lightConsentGiven)
    );

    final selected = await showQuotePicker(
      context: context,
      faithActivated: canShowFaith,          // <- pass final permission
      hideFaithOverlaysInMind: hideFaith,
      lightConsentGiven: canShowFaith,       // <- align picker filter
    );

    setState(() => _quote = selected);
    if (selected == null) {
      _track('quote_cleared', {});
    } else {
      _track('quote_selected', {'quote_id': selected.id});
    }
  }

  String _stepLabel() {
    switch (_step) {
      case BreathStep.inhale: return 'Inhale';
      case BreathStep.hold1:  return 'Hold';
      case BreathStep.exhale: return 'Exhale';
      case BreathStep.hold2:  return 'Hold';
    }
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(1, '0');
    final ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss';
  }

  void _track(String event, Map<String, dynamic> props) {
    // hook to your analytics
    print('Analytics: $event - $props');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final settingsController = SettingsScope.of(context);
    final settings = settingsController.value;
    final faithTier = settings.faithTier;
    final faithActivated = faithTier != FaithTier.off;
    final hideFaith = false; // TODO: Add this setting to AppSettings

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
              // Title + quote chip
              Row(
                children: [
                  Expanded(
                    child: Text(_level.title,
                      style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ),
                  if (faithActivated && !hideFaith) // quote chip allowed zone
                    TextButton.icon(
                      onPressed: _pickQuote,
                      icon: const Icon(Icons.format_quote),
                      label: Text(_quote == null ? 'Quote' : 'Change'),
                    ),
                ],
              ),
              if (_quote != null) ...[
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '"${_quote!.text}" — ${_quote!.author}',
                    style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              const SizedBox(height: 8),

              // Animated circle
              Expanded(
                child: AnimatedBreathCircle(
                  progress: _stepProgress,
                  phase: _step == BreathStep.inhale
                      ? 'inhale'
                      : (_step == BreathStep.exhale ? 'exhale' : 'hold'),
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
                      onPressed: _running ? _pause : _start,
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.primary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Text('$label ', style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          Text(value, style: t.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _LeafLevelsBar extends StatelessWidget {
  final String selected;
  final List<BoxLevel> levels;
  final void Function(BoxLevel) onTap;
  const _LeafLevelsBar({required this.selected, required this.levels, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: levels.map((lvl) {
        final isSel = lvl.id == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onTap(lvl),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSel ? cs.primary.withOpacity(0.15) : cs.surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: isSel ? cs.primary : cs.outline.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.eco, size: 18, color: isSel ? cs.primary : cs.onSurfaceVariant),
                    const SizedBox(height: 4),
                    Text(lvl.id.toUpperCase(), style: t.textTheme.labelMedium),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
