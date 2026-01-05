import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/app_export.dart';
import '../../../../core/settings/settings_scope.dart';
import '../../../../core/settings/settings_model.dart';
import '../../../../design/tokens.dart';
import '../../../../services/faith_service.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../../mind/faith/faith_consent.dart';
import '../logic/breath_engine.dart';
import '../logic/presets.dart';
import '../widgets/animated_circle.dart';
import '../widgets/quote_rotator.dart';

/// Breath Coach v2 Session Screen
/// 
/// Features:
/// - Shared breath engine for all presets
/// - Inline quote rotator with faith filtering
/// - Pre/Post calm slider tracking
/// - Safety tips for first-time users
/// - Analytics tracking
/// - 430px clamp responsive design
class BreathSessionScreen extends StatefulWidget {
  final String presetId;

  const BreathSessionScreen({
    super.key,
    required this.presetId,
  });

  @override
  State<BreathSessionScreen> createState() => _BreathSessionScreenState();
}

class _BreathSessionScreenState extends State<BreathSessionScreen>
    with TickerProviderStateMixin {
  late BreathPreset _preset;
  late BreathEngine _engine;
  
  // Session state
  bool _isSessionActive = false;
  bool _hasShownSafetyTip = false;
  bool _lightConsentGiven = false;
  
  // Calm tracking
  int? _preCalmValue;
  int? _postCalmValue;
  bool _showingCalmSlider = false;
  
  // Settings
  late FaithTier _faithTier;
  late bool _hideFaithOverlaysInMind;

  @override
  void initState() {
    super.initState();
    _initializePreset();
    _checkSafetyTip();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadSettings();
  }

  void _initializePreset() {
    _preset = Presets.byId(widget.presetId);
    _engine = BreathEngine(
      _preset.config,
      onStep: _onStepChanged,
      onFinish: _onSessionComplete,
    );
  }

  void _loadSettings() {
    final settingsController = SettingsScope.of(context);
    final settings = settingsController.value;
    
    setState(() {
      _faithTier = settings.faithTier;
      _hideFaithOverlaysInMind = settings.hideFaithOverlaysInMind;
    });
  }

  void _checkSafetyTip() {
    // Check if this is the first time using this preset
    // For now, always show safety tip
    _hasShownSafetyTip = false;
  }

  Future<void> _askLightConsentIfNeeded() async {
    if (_faithTier != FaithTier.light || _lightConsentGiven) return;
    
    // Convert FaithTier to FaithTier
    final faithMode = _convertFaithTierToFaithTier(_faithTier);
    
    _lightConsentGiven = await askLightConsentIfNeeded(
      context: context,
      faithMode: faithMode,
      hideFaithOverlaysInMind: _hideFaithOverlaysInMind,
    );
    
    _trackAnalytics('light_consent_set', {'allowed': _lightConsentGiven});
  }

  FaithTier _convertFaithTierToFaithTier(FaithTier tier) {
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

  void _onStepChanged() {
    // Handle step changes if needed
  }

  void _onSessionComplete() {
    setState(() {
      _isSessionActive = false;
    });
    
    _trackAnalytics('breath_completed', {
      'preset': _preset.id,
      'total_seconds': _preset.config.totalSeconds,
    });
    
    // Show post-session calm slider
    _showPostCalmSlider();
  }

  void _showPreCalmSlider() {
    setState(() {
      _showingCalmSlider = true;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CalmSliderDialog(
        title: 'How calm do you feel right now?',
        onValueSelected: (value) {
          setState(() {
            _preCalmValue = value;
            _showingCalmSlider = false;
          });
          _trackAnalytics('calm_check', {
            'when': 'pre',
            'value': value,
          });
          Navigator.of(context).pop(); // Close the calm slider dialog
          _startSession();
        },
      ),
    );
  }

  void _showPostCalmSlider() {
    setState(() {
      _showingCalmSlider = true;
    });
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CalmSliderDialog(
        title: 'How calm do you feel now?',
        onValueSelected: (value) {
          setState(() {
            _postCalmValue = value;
            _showingCalmSlider = false;
          });
          
          final calmDelta = _preCalmValue != null 
              ? value - _preCalmValue! 
              : null;
          
          _trackAnalytics('calm_check', {
            'when': 'post',
            'value': value,
          });
          
          if (calmDelta != null) {
            _trackAnalytics('calm_delta', {
              'delta': calmDelta,
              'pre': _preCalmValue,
              'post': value,
            });
          }
          
          Navigator.of(context).pop(); // Close the calm slider dialog
          _showCompletionDialog();
        },
      ),
    );
  }

  void _showCompletionDialog() {
    final calmDelta = _preCalmValue != null && _postCalmValue != null
        ? _postCalmValue! - _preCalmValue!
        : null;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Session Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Great job! You\'ve completed your breathing practice.'),
            if (calmDelta != null) ...[
              const SizedBox(height: 16),
              Text(
                calmDelta > 0 
                    ? 'You feel ${calmDelta} point${calmDelta == 1 ? '' : 's'} more calm!'
                    : calmDelta < 0
                        ? 'You feel ${calmDelta.abs()} point${calmDelta.abs() == 1 ? '' : 's'} less calm.'
                        : 'Your calm level stayed the same.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _startSession() async {
    // Ask for light consent if needed
    await _askLightConsentIfNeeded();
    
    // Show safety tip if first time
    if (!_hasShownSafetyTip) {
      _showSafetyTip();
      _hasShownSafetyTip = true;
    }
    
    setState(() {
      _isSessionActive = true;
    });
    
    _engine.start();
    
    _trackAnalytics('breath_started', {
      'preset': _preset.id,
      'cadence': _getPatternText(_preset.config),
      'total_seconds': _preset.config.totalSeconds,
    });
  }

  void _showSafetyTip() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Safety Tip'),
        content: const Text(
          'Breathe lightly through the nose. If you feel dizzy, slow down or stop the exercise.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _pauseSession() {
    _engine.pause();
    _trackAnalytics('breath_paused', {'preset': _preset.id});
  }

  void _resumeSession() {
    _engine.resume();
    _trackAnalytics('breath_resumed', {'preset': _preset.id});
  }

  void _resetSession() {
    _engine.reset();
    setState(() {
      _isSessionActive = false;
    });
    _trackAnalytics('breath_reset', {'preset': _preset.id});
  }

  String _getPatternText(BreathEngineConfig config) {
    final parts = <String>[];
    if (config.inhale > 0) parts.add('${config.inhale}');
    if (config.hold1 > 0) parts.add('${config.hold1}');
    if (config.exhale > 0) parts.add('${config.exhale}');
    if (config.hold2 > 0) parts.add('${config.hold2}');
    return parts.join('-');
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(1, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _trackAnalytics(String event, Map<String, dynamic> props) {
    // Hook to your analytics system
    print('Analytics: $event - $props');
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: _preset.name,
        variant: CustomAppBarVariant.centered,
        showBackButton: true,
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Header with preset info
                _buildHeader(theme, colorScheme),
                
                const SizedBox(height: AppSpace.x4),
                
                // Quote rotator
                _buildQuoteRotator(theme, colorScheme),
                
                const SizedBox(height: AppSpace.x4),
                
                // Animated circle
                Expanded(
                  child: ValueListenableBuilder<Phase>(
                    valueListenable: _engine.phase,
                    builder: (context, phase, child) {
                      return ValueListenableBuilder<double>(
                        valueListenable: _engine.stepProgress,
                        builder: (context, progress, child) {
                          return AnimatedBreathCircle(
                            progress: progress,
                            phase: phase,
                            dimUi: _preset.dimUi,
                          );
                        },
                      );
                    },
                  ),
                ),
                
                const SizedBox(height: AppSpace.x4),
                
                // Timer display
                _buildTimerDisplay(theme, colorScheme),
                
                const SizedBox(height: AppSpace.x4),
                
                // Controls
                _buildControls(theme, colorScheme),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _preset.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                _preset.subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        
        // Duration picker (when not active)
        if (!_isSessionActive)
          _DurationPicker(
            currentSeconds: _preset.config.totalSeconds,
            onChanged: (seconds) {
              // Update preset config with new duration
              final newConfig = BreathEngineConfig(
                inhale: _preset.config.inhale,
                hold1: _preset.config.hold1,
                exhale: _preset.config.exhale,
                hold2: _preset.config.hold2,
                totalSeconds: seconds,
                exhaleWeighted: _preset.config.exhaleWeighted,
              );
              _engine.reset(newConfig);
            },
          ),
      ],
    );
  }

  Widget _buildQuoteRotator(ThemeData theme, ColorScheme colorScheme) {
    final faithActivated = _faithTier != FaithTier.off;
    
    return QuoteRotator(
      faithActivated: faithActivated,
      hideFaithOverlaysInMind: _hideFaithOverlaysInMind,
      lightConsentGiven: _lightConsentGiven,
      onAnalytics: _trackAnalytics,
    );
  }

  Widget _buildTimerDisplay(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        // Phase countdown and label
        ValueListenableBuilder<Phase>(
          valueListenable: _engine.phase,
          builder: (context, phase, child) {
            return ValueListenableBuilder<int>(
              valueListenable: _engine.stepRemaining,
              builder: (context, stepRemaining, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    color: _getPhaseColor(phase).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getPhaseColor(phase).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      // Large countdown number
                      Text(
                        stepRemaining.toString(),
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: _getPhaseColor(phase),
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Phase label
                      Text(
                        _engine.phaseLabel,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: _getPhaseColor(phase),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
        
        const SizedBox(height: 16),
        
        // Total timer and pattern info
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Total timer
            ValueListenableBuilder<int>(
              valueListenable: _engine.totalRemaining,
              builder: (context, totalRemaining, child) {
                return _TimerPill(
                  label: 'Total',
                  value: _formatTime(totalRemaining),
                );
              },
            ),
            
            // Pattern info
            _TimerPill(
              label: 'Pattern',
              value: _getPatternText(_preset.config),
            ),
          ],
        ),
      ],
    );
  }
  
  Color _getPhaseColor(Phase phase) {
    switch (phase) {
      case Phase.inhale:
        return Colors.blue.shade400;
      case Phase.hold1:
        return Colors.blue.shade600;
      case Phase.exhale:
        return Colors.blue.shade300;
      case Phase.hold2:
        return Colors.blue.shade200;
    }
  }

  Widget _buildControls(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        // Start/Pause button
        Expanded(
          child: FilledButton.icon(
            onPressed: _isSessionActive 
                ? (_engine.isPaused ? _resumeSession : _pauseSession)
                : _showPreCalmSlider,
            icon: Icon(_isSessionActive 
                ? (_engine.isPaused ? Icons.play_arrow : Icons.pause)
                : Icons.play_arrow),
            label: Text(_isSessionActive 
                ? (_engine.isPaused ? 'Resume' : 'Pause')
                : 'Start'),
          ),
        ),
        
        const SizedBox(width: 12),
        
        // Reset button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetSession,
            icon: const Icon(Icons.replay),
            label: const Text('Reset'),
          ),
        ),
      ],
    );
  }
}

class _TimerPill extends StatelessWidget {
  final String label;
  final String value;

  const _TimerPill({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationPicker extends StatelessWidget {
  final int currentSeconds;
  final ValueChanged<int> onChanged;

  const _DurationPicker({
    required this.currentSeconds,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final durations = [60, 120, 180, 240, 300, 360, 420, 480, 540, 600];
    
    return PopupMenuButton<int>(
      initialValue: currentSeconds,
      onSelected: onChanged,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${currentSeconds ~/ 60}m',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
      itemBuilder: (context) => durations.map((seconds) {
        final minutes = seconds ~/ 60;
        return PopupMenuItem<int>(
          value: seconds,
          child: Text('${minutes}m'),
        );
      }).toList(),
    );
  }
}

class _CalmSliderDialog extends StatefulWidget {
  final String title;
  final ValueChanged<int> onValueSelected;

  const _CalmSliderDialog({
    required this.title,
    required this.onValueSelected,
  });

  @override
  State<_CalmSliderDialog> createState() => _CalmSliderDialogState();
}

class _CalmSliderDialogState extends State<_CalmSliderDialog> {
  double _value = 5.0;
  
  final List<int> _calmValues = [0, 2, 4, 6, 8, 10];
  final List<String> _calmLabels = [
    'Very Stressed',
    'Stressed',
    'Neutral',
    'Calm',
    'Very Calm',
    'Completely Calm',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return AlertDialog(
      title: Text(widget.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Slider
          Slider(
            value: _value,
            min: 0,
            max: 10,
            divisions: 5,
            onChanged: (value) {
              setState(() {
                _value = value;
              });
            },
          ),
          
          // Value display
          Text(
            _value.round().toString(),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.primary,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Label
          Text(
            _getCalmLabel(_value.round()),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => widget.onValueSelected(_value.round()),
          child: const Text('Continue'),
        ),
      ],
    );
  }

  String _getCalmLabel(int value) {
    if (value <= 1) return _calmLabels[0];
    if (value <= 3) return _calmLabels[1];
    if (value <= 5) return _calmLabels[2];
    if (value <= 7) return _calmLabels[3];
    if (value <= 9) return _calmLabels[4];
    return _calmLabels[5];
  }
}
