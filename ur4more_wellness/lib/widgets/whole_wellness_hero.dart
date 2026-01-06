import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../theme/brand_tokens.dart';
import '../design/tokens.dart';

class WholeWellnessHero extends StatelessWidget {
  final int totalPoints;
  final double bodyProgress;
  final double mindProgress;
  final double spiritProgress;
  final VoidCallback onBuilderTap;
  final bool reduceMotion;

  const WholeWellnessHero({
    super.key,
    required this.totalPoints,
    required this.bodyProgress,
    required this.mindProgress,
    required this.spiritProgress,
    required this.onBuilderTap,
    this.reduceMotion = false,
  });

  static const _ringSize = 260.0;
  static const _glowSize = 18.0;
  static const _silhouetteOpacity = 0.14;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final disableAnims =
        reduceMotion || MediaQuery.maybeOf(context)?.disableAnimations == true;

    return Semantics(
      label: 'Whole wellness hero',
      child: Column(
        children: [
          SizedBox(
            height: _ringSize + 120,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // subtle background glow
                  Container(
                    width: _ringSize * 1.05,
                    height: _ringSize * 1.05,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Brand.primary.withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // ring
                  CustomPaint(
                    size: const Size.square(_ringSize),
                    painter: _RingPainter(
                      baseColor: Brand.primary,
                      glowColor: Brand.accent,
                    ),
                  ),
                  // silhouette
                  Opacity(
                    opacity: _silhouetteOpacity,
                    child: CustomPaint(
                      size: const Size.square(_ringSize * 0.7),
                      painter: _SilhouettePainter(color: Brand.onDark),
                    ),
                  ),
                  // glow points
                  _GlowPoint(
                    offset: const Offset(0, -78),
                    color: Brand.mint,
                    intensity: mindProgress,
                    disableAnims: disableAnims,
                    label: 'Mind progress: ${(mindProgress * 100).round()} percent',
                  ),
                  _GlowPoint(
                    offset: const Offset(0, -20),
                    color: Brand.primary,
                    intensity: bodyProgress,
                    disableAnims: disableAnims,
                    label: 'Body progress: ${(bodyProgress * 100).round()} percent',
                  ),
                  _GlowPoint(
                    offset: const Offset(0, 26),
                    color: _spiritColor(cs),
                    intensity: spiritProgress,
                    disableAnims: disableAnims,
                    label:
                        'Spirit progress: ${(spiritProgress * 100).round()} percent',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpace.x2),
          Semantics(
            label: 'Total points: $totalPoints',
            child: Column(
              children: [
                Text(
                  '$totalPoints',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: Brand.onDark,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'pts',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Brand.onDarkMuted,
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.x3),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PillarStat(
                  label: 'Body',
                  value: bodyProgress,
                  color: Brand.primary,
                  semanticsLabel:
                      'Body progress: ${(bodyProgress * 100).round()} percent',
                ),
                _PillarStat(
                  label: 'Mind',
                  value: mindProgress,
                  color: Brand.mint,
                  semanticsLabel:
                      'Mind progress: ${(mindProgress * 100).round()} percent',
                ),
                _PillarStat(
                  label: 'Spirit',
                  value: spiritProgress,
                  color: _spiritColor(cs),
                  semanticsLabel:
                      'Spirit progress: ${(spiritProgress * 100).round()} percent',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.x4),
          Semantics(
            button: true,
            label: 'Open builder',
            child: OutlinedButton.icon(
              onPressed: onBuilderTap,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpace.x6,
                  vertical: AppSpace.x3,
                ),
                foregroundColor: _spiritColor(cs),
                side: BorderSide(color: _spiritColor(cs), width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                backgroundColor: Colors.transparent,
              ),
              icon: Icon(Icons.search, size: 20, color: _spiritColor(cs)),
              label: Text(
                'Builder',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: _spiritColor(cs),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _spiritColor(ColorScheme cs) {
    // Prefer accent/gold tones if available
    return Brand.accent;
  }
}

class _RingPainter extends CustomPainter {
  final Color baseColor;
  final Color glowColor;

  _RingPainter({
    required this.baseColor,
    required this.glowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    // soft outer glow
    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 24
      ..color = glowColor.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
    canvas.drawCircle(center, radius - 8, glowPaint);

    // main ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..shader = SweepGradient(
        colors: [
          baseColor.withOpacity(0.95),
          glowColor.withOpacity(0.9),
          baseColor.withOpacity(0.95),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 6, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SilhouettePainter extends CustomPainter {
  final Color color;

  _SilhouettePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final w = size.width;
    final h = size.height;
    final headRadius = w * 0.13;
    final headCenter = Offset(w / 2, h * 0.18 + headRadius);
    path.addOval(Rect.fromCircle(center: headCenter, radius: headRadius));

    // torso
    path.moveTo(w * 0.3, h * 0.35);
    path.quadraticBezierTo(w * 0.25, h * 0.55, w * 0.33, h * 0.75);
    path.quadraticBezierTo(w * 0.5, h * 0.9, w * 0.67, h * 0.75);
    path.quadraticBezierTo(w * 0.75, h * 0.55, w * 0.7, h * 0.35);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowPoint extends StatelessWidget {
  final Offset offset;
  final Color color;
  final double intensity;
  final bool disableAnims;
  final String label;

  const _GlowPoint({
    required this.offset,
    required this.color,
    required this.intensity,
    required this.disableAnims,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = intensity.clamp(0.0, 1.0);
    final baseSize = WholeWellnessHero._glowSize;
    final opacity = 0.3 + 0.4 * clamped;

    Widget dot = Container(
      width: baseSize,
      height: baseSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.8),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(opacity),
            blurRadius: 24 + 20 * clamped,
            spreadRadius: 2 + 2 * clamped,
          ),
        ],
      ),
    );

    if (!disableAnims) {
      dot = _Pulse(
        color: color,
        child: dot,
      );
    }

    return Transform.translate(
      offset: offset,
      child: Semantics(
        label: label,
        child: dot,
      ),
    );
  }
}

class _Pulse extends StatefulWidget {
  final Widget child;
  final Color color;

  const _Pulse({required this.child, required this.color});

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        final scale = 0.92 + (_controller.value * 0.14);
        final opacity = 0.8 + (_controller.value * 0.15);
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity.clamp(0, 1),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _PillarStat extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final String semanticsLabel;

  const _PillarStat({
    required this.label,
    required this.value,
    required this.color,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (value.clamp(0.0, 1.0) * 100).round();
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Semantics(
      label: semanticsLabel,
      child: Column(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: t.titleMedium?.copyWith(
              color: cs.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '$pct%',
            style: t.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

