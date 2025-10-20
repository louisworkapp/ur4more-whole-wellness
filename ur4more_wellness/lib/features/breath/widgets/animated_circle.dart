import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import '../logic/breath_engine.dart';

/// Animated breathing circle that syncs with breath engine phases
/// 
/// Features:
/// - Smooth scaling animation based on step progress
/// - Phase-specific colors and visual feedback
/// - Accessibility announcements on phase changes
/// - 430px clamp for responsive design
class AnimatedBreathCircle extends StatefulWidget {
  final double progress; // 0..1 for current step progress
  final Phase phase;
  final bool dimUi; // true for sleep preset (lower contrast)

  const AnimatedBreathCircle({
    super.key,
    required this.progress,
    required this.phase,
    this.dimUi = false,
  });

  @override
  State<AnimatedBreathCircle> createState() => _AnimatedBreathCircleState();
}

class _AnimatedBreathCircleState extends State<AnimatedBreathCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  Phase? _lastAnnouncedPhase;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void didUpdateWidget(AnimatedBreathCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Announce phase changes for accessibility
    if (widget.phase != oldWidget.phase) {
      _announcePhaseChange();
    }
    
    // Update animation based on progress and phase
    _updateAnimation();
  }

  void _announcePhaseChange() {
    if (_lastAnnouncedPhase != widget.phase) {
      _lastAnnouncedPhase = widget.phase;
      SemanticsService.announce(
        _getPhaseLabel(),
        TextDirection.ltr,
      );
    }
  }

  void _updateAnimation() {
    // Calculate animation value based on phase and progress
    double animationValue;
    
    switch (widget.phase) {
      case Phase.inhale:
        // Scale up during inhale
        animationValue = widget.progress;
        break;
      case Phase.hold1:
        // Hold at max scale
        animationValue = 1.0;
        break;
      case Phase.exhale:
        // Scale down during exhale
        animationValue = 1.0 - widget.progress;
        break;
      case Phase.hold2:
        // Hold at min scale
        animationValue = 0.0;
        break;
    }
    
    _controller.value = animationValue;
  }

  String _getPhaseLabel() {
    switch (widget.phase) {
      case Phase.inhale:
        return 'Inhale';
      case Phase.hold1:
        return 'Hold breath';
      case Phase.exhale:
        return 'Exhale';
      case Phase.hold2:
        return 'Hold empty';
    }
  }

  Color _getPhaseColor() {
    final baseColors = {
      Phase.inhale: Colors.blue,
      Phase.hold1: Colors.blue.shade700,
      Phase.exhale: Colors.green,
      Phase.hold2: Colors.green.shade700,
    };
    
    final color = baseColors[widget.phase] ?? Colors.blue;
    
    // Apply dimming for sleep preset
    if (widget.dimUi) {
      return color.withOpacity(0.7);
    }
    
    return color;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final phaseColor = _getPhaseColor();
    
    return ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: 430,
        maxHeight: 430,
      ),
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: phaseColor.withOpacity(0.15),
                    border: Border.all(
                      color: phaseColor,
                      width: 4,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: phaseColor.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Phase label
                      Text(
                        _getPhaseLabel(),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: phaseColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Progress indicator (circular)
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Stack(
                          children: [
                            // Background circle
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: phaseColor.withOpacity(0.1),
                                border: Border.all(
                                  color: phaseColor.withOpacity(0.3),
                                  width: 2,
                                ),
                              ),
                            ),
                            
                            // Progress circle
                            Positioned.fill(
                              child: CircularProgressIndicator(
                                value: widget.progress,
                                strokeWidth: 3,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(phaseColor),
                              ),
                            ),
                            
                            // Center text
                            Center(
                              child: Text(
                                '${(widget.progress * 100).round()}%',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: phaseColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
