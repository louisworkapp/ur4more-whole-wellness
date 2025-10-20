import 'package:flutter/material.dart';

class AnimatedBreathCircle extends StatelessWidget {
  final double progress; // 0.0..1.0 of the current step (inhale/hold/exhale/hold)
  final String phase; // "inhale" | "hold" | "exhale"
  
  const AnimatedBreathCircle({
    super.key, 
    required this.progress, 
    required this.phase,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    // Scale mapping:
    // inhale: 0.75 -> 1.0
    // hold: keep 1.0
    // exhale: 1.0 -> 0.75
    double scale = 0.9;
    if (phase == 'inhale') {
      scale = 0.75 + 0.25 * progress;
    } else if (phase == 'exhale') {
      scale = 1.0 - 0.25 * progress;
    } else {
      scale = 1.0;
    }

    return Center(
      child: AnimatedScale(
        scale: scale,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
        child: Container(
          width: 240,
          height: 240,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                cs.primary.withOpacity(0.18),
                cs.primary.withOpacity(0.06),
                Colors.transparent
              ],
              stops: const [0.4, 0.85, 1.0],
            ),
            border: Border.all(color: cs.primary.withOpacity(0.35), width: 2),
          ),
        ),
      ),
    );
  }
}
