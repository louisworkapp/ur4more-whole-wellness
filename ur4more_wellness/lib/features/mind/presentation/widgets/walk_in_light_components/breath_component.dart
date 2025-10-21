import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/app_export.dart';
import '../../../../../design/tokens.dart';
import '../../../../../services/faith_service.dart';
import '../../../../breath/logic/breath_engine.dart';
import '../../../../breath/logic/presets.dart';
import '../../../../breath/widgets/animated_circle.dart';
import 'scripture_rotator.dart';

class BreathComponent extends StatefulWidget {
  final FaithMode faithMode;
  final int duration;
  final Function(Map<String, dynamic>) onData;
  final VoidCallback onComplete;

  const BreathComponent({
    super.key,
    required this.faithMode,
    required this.duration,
    required this.onData,
    required this.onComplete,
  });

  @override
  State<BreathComponent> createState() => _BreathComponentState();
}

class _BreathComponentState extends State<BreathComponent>
    with TickerProviderStateMixin {
  late BreathEngine _breathEngine;
  
  Timer? _timer;
  int _timeRemaining = 0;
  bool _isActive = false;
  bool _isCompleted = false;
  bool _showCadenceSelector = true;
  
  // Breath cycle data
  int _breathCount = 0;
  double _averageBreathRate = 0.0;
  String _breathQuality = '';
  BreathPreset _selectedPreset = Presets.fourSevenEight;

  @override
  void initState() {
    super.initState();
    _initializeBreathEngine();
    _timeRemaining = _breathEngine.totalRemaining.value;
  }
  
  void _initializeBreathEngine() {
    _breathEngine = BreathEngine(
      _selectedPreset.config,
      onStep: _onBreathStep,
      onFinish: _onBreathComplete,
    );
  }
  
  void _onBreathStep() {
    _breathCount++;
  }
  
  void _onBreathComplete() {
    _completeBreathing();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathEngine.dispose();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
      _showCadenceSelector = false;
    });
    
    _breathEngine.start();
    
    // Use the engine's timing instead of our own timer
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        // Update our local timer to match the engine's total remaining
        _timeRemaining = _breathEngine.totalRemaining.value;
      });
      
      if (_breathEngine.totalRemaining.value <= 0) {
        _completeBreathing();
      }
    });
  }
  
  void _selectPreset(BreathPreset preset) {
    setState(() {
      _selectedPreset = preset;
    });
    _initializeBreathEngine();
    _timeRemaining = _breathEngine.totalRemaining.value;
  }

  void _completeBreathing() {
    _timer?.cancel();
    _breathEngine.pause();
    
    setState(() {
      _isActive = false;
      _isCompleted = true;
    });
    
    // Calculate breath quality
    _averageBreathRate = _breathCount / (widget.duration / 60.0); // breaths per minute
    if (_averageBreathRate >= 4 && _averageBreathRate <= 8) {
      _breathQuality = 'Excellent - Deep and steady';
    } else if (_averageBreathRate >= 6 && _averageBreathRate <= 12) {
      _breathQuality = 'Good - Calm and controlled';
    } else {
      _breathQuality = 'Noticeable - Room for improvement';
    }
    
    widget.onData({
      'breath_count': _breathCount,
      'average_rate': _averageBreathRate,
      'quality': _breathQuality,
      'duration': widget.duration,
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Auto-advance after 2 seconds
    Timer(const Duration(seconds: 2), widget.onComplete);
  }

  String _getBreathInstruction() {
    if (!_isActive) return 'Choose your breathing pattern and tap to begin';
    
    return _breathEngine.phaseLabel;
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
  
  String _getPatternText(BreathEngineConfig config) {
    final parts = <String>[];
    if (config.inhale > 0) parts.add('${config.inhale}');
    if (config.hold1 > 0) parts.add('${config.hold1}');
    if (config.exhale > 0) parts.add('${config.exhale}');
    if (config.hold2 > 0) parts.add('${config.hold2}');
    return parts.join('-');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.air,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Breathe',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Center yourself with mindful breathing',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Cadence selector
          if (_showCadenceSelector)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Breathing Pattern',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...Presets.all.map((preset) => 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => _selectPreset(preset),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _selectedPreset == preset 
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _selectedPreset == preset 
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _selectedPreset == preset 
                                      ? Theme.of(context).colorScheme.primary
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: _selectedPreset == preset 
                                        ? Theme.of(context).colorScheme.primary
                                        : Theme.of(context).colorScheme.outline,
                                  ),
                                ),
                                child: _selectedPreset == preset 
                                    ? Icon(
                                        Icons.check,
                                        size: 14,
                                        color: Theme.of(context).colorScheme.onPrimary,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      preset.name,
                                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: _selectedPreset == preset 
                                            ? Theme.of(context).colorScheme.onPrimaryContainer
                                            : null,
                                      ),
                                    ),
                                    Text(
                                      preset.subtitle,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: _selectedPreset == preset 
                                            ? Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8)
                                            : Theme.of(context).colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${preset.config.inhale}-${preset.config.hold1}-${preset.config.exhale}${preset.config.hold2 > 0 ? '-${preset.config.hold2}' : ''}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: _selectedPreset == preset 
                                      ? Theme.of(context).colorScheme.onPrimaryContainer
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ],
              ),
            ),
          
          const SizedBox(height: 20),
          
          // Enhanced timer display with phase countdown
          if (_isActive || _isCompleted)
            Column(
              children: [
                // Phase countdown and label
                ValueListenableBuilder<Phase>(
                  valueListenable: _breathEngine.phase,
                  builder: (context, phase, child) {
                    return ValueListenableBuilder<int>(
                      valueListenable: _breathEngine.stepRemaining,
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
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: _getPhaseColor(phase),
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Phase label
                              Text(
                                _breathEngine.phaseLabel,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Total ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          ValueListenableBuilder<int>(
                            valueListenable: _breathEngine.totalRemaining,
                            builder: (context, totalRemaining, child) {
                              return Text(
                                '${totalRemaining}s',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    // Pattern info
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Pattern ',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            _getPatternText(_selectedPreset.config),
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          
          const SizedBox(height: 24),
          
          // Scripture rotator (Walk in the Light always shows scriptures)
          ScriptureRotator(
            isActive: _isActive,
            rotationInterval: const Duration(seconds: 10),
          ),
          
          // Breathing circle - using the same AnimatedBreathCircle as Breath Coach V2
          SizedBox(
            height: 300,
            child: Center(
              child: GestureDetector(
                onTap: _isActive ? null : _startBreathing,
                child: ValueListenableBuilder<Phase>(
                  valueListenable: _breathEngine.phase,
                  builder: (context, phase, child) {
                    return ValueListenableBuilder<double>(
                      valueListenable: _breathEngine.stepProgress,
                      builder: (context, progress, child) {
                        return AnimatedBreathCircle(
                          progress: progress,
                          phase: phase,
                          dimUi: _selectedPreset.dimUi,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Instruction text
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  _getBreathInstruction(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_isActive) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Breath count: $_breathCount',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Faith overlay for Light mode
          if (widget.faithMode == FaithMode.light && _isActive)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.wb_sunny,
                    color: Theme.of(context).colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Breathe in God\'s peace, breathe out your worries',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Faith overlay for Disciple/Kingdom modes
          if ((widget.faithMode == FaithMode.disciple || widget.faithMode == FaithMode.kingdom) && _isActive)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.menu_book,
                        color: Theme.of(context).colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Scripture: "Be still and know that I am God" - Psalm 46:10',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Let each breath draw you closer to His presence',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
