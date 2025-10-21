import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/app_export.dart';
import '../../../../../design/tokens.dart';
import '../../../../../services/faith_service.dart';

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
  late AnimationController _breathController;
  late AnimationController _pulseController;
  late Animation<double> _breathAnimation;
  late Animation<double> _pulseAnimation;
  
  Timer? _timer;
  int _timeRemaining = 0;
  bool _isActive = false;
  bool _isCompleted = false;
  
  // Breath cycle data
  int _breathCount = 0;
  double _averageBreathRate = 0.0;
  String _breathQuality = '';

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.duration;
    
    _breathController = AnimationController(
      duration: const Duration(seconds: 4), // 4-second breath cycle
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _breathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    
    _breathController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _breathCount++;
        _breathController.reset();
        _breathController.forward();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startBreathing() {
    setState(() {
      _isActive = true;
    });
    
    _breathController.forward();
    _pulseController.repeat(reverse: true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining--;
      });
      
      if (_timeRemaining <= 0) {
        _completeBreathing();
      }
    });
  }

  void _completeBreathing() {
    _timer?.cancel();
    _breathController.stop();
    _pulseController.stop();
    
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
    if (!_isActive) return 'Tap to begin your breathing practice';
    
    final progress = _breathAnimation.value;
    if (progress < 0.25) return 'Breathe in slowly...';
    if (progress < 0.5) return 'Hold your breath...';
    if (progress < 0.75) return 'Breathe out gently...';
    return 'Rest and prepare...';
  }

  Color _getBreathColor() {
    if (!_isActive) return Theme.of(context).colorScheme.primary;
    
    final progress = _breathAnimation.value;
    if (progress < 0.25) return Colors.blue.shade400; // Inhale
    if (progress < 0.5) return Colors.blue.shade600; // Hold
    if (progress < 0.75) return Colors.blue.shade300; // Exhale
    return Colors.blue.shade200; // Rest
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
          
          const SizedBox(height: 32),
          
          // Timer display
          if (_isActive || _isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_timeRemaining}s remaining',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          
          const SizedBox(height: 40),
          
          // Breathing circle
          Expanded(
            child: Center(
              child: GestureDetector(
                onTap: _isActive ? null : _startBreathing,
                child: AnimatedBuilder(
                  animation: Listenable.merge([_breathAnimation, _pulseAnimation]),
                  builder: (context, child) {
                    final size = 200.0 * (1.0 + _breathAnimation.value * 0.5) * _pulseAnimation.value;
                    return Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _getBreathColor().withOpacity(0.3),
                        border: Border.all(
                          color: _getBreathColor(),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.air,
                          size: size * 0.3,
                          color: _getBreathColor(),
                        ),
                      ),
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
