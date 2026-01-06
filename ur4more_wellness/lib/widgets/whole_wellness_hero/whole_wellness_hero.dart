import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../theme/brand_tokens.dart';
import '../../theme/tokens.dart';

class WholeWellnessHero extends StatefulWidget {
  final int totalPoints;
  final double bodyProgress;
  final double mindProgress;
  final double spiritProgress;
  final VoidCallback onBuilderTap;

  const WholeWellnessHero({
    super.key,
    required this.totalPoints,
    required this.bodyProgress,
    required this.mindProgress,
    required this.spiritProgress,
    required this.onBuilderTap,
  });

  @override
  State<WholeWellnessHero> createState() => _WholeWellnessHeroState();
}

class _WholeWellnessHeroState extends State<WholeWellnessHero>
    with TickerProviderStateMixin {
  late final AnimationController _ringController;
  late final AnimationController _headPulse;
  late final AnimationController _chestPulse;
  late final AnimationController _corePulse;

  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    );
    _headPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );
    _chestPulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    );
    _corePulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncMotionPreference();
  }

  void _syncMotionPreference() {
    final shouldReduce =
        MediaQuery.maybeOf(context)?.disableAnimations == true;
    if (_reduceMotion != shouldReduce) {
      setState(() => _reduceMotion = shouldReduce);
    }

    if (shouldReduce) {
      _ringController.stop();
      _headPulse.stop();
      _chestPulse.stop();
      _corePulse.stop();
      return;
    }

    if (!_ringController.isAnimating) _ringController.repeat();
    if (!_headPulse.isAnimating) _headPulse.repeat(reverse: true);
    if (!_chestPulse.isAnimating) _chestPulse.repeat(reverse: true);
    if (!_corePulse.isAnimating) _corePulse.repeat(reverse: true);
  }

  @override
  void dispose() {
    _ringController.dispose();
    _headPulse.dispose();
    _chestPulse.dispose();
    _corePulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Semantics(
      label: 'Whole wellness hero',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Brand.ink,
              Brand.ink2,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.x4,
            vertical: AppSpace.x4,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 360,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _StarfieldPainter(),
                      ),
                    ),
                    Container(
                      width: 280,
                      height: 280,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Brand.accent.withOpacity(0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    RepaintBoundary(
                      child: _reduceMotion
                          ? CustomPaint(
                              size: const Size.square(260),
                              painter: _RingPainter(
                                baseColor: Brand.primary,
                                glowColor: Brand.accent,
                                shimmerValue: 0,
                                showShimmer: false,
                              ),
                              isComplex: true,
                            )
                          : AnimatedBuilder(
                              animation: _ringController,
                              builder: (_, __) {
                                return CustomPaint(
                                  size: const Size.square(260),
                                  painter: _RingPainter(
                                    baseColor: Brand.primary,
                                    glowColor: Brand.accent,
                                    shimmerValue: _ringController.value,
                                    showShimmer: true,
                                  ),
                                  isComplex: true,
                                );
                              },
                            ),
                    ),
                    Opacity(
                      opacity: 0.16,
                      child: CustomPaint(
                        size: const Size.square(184),
                        painter: _SilhouettePainter(color: Brand.onDark),
                      ),
                    ),
                    _GlowNode(
                      offset: const Offset(0, -82),
                      color: Brand.mint,
                      controller: _headPulse,
                      reduceMotion: _reduceMotion,
                      intensity: widget.mindProgress,
                      semanticsLabel:
                          'Mind progress ${(widget.mindProgress * 100).round()} percent',
                    ),
                    _GlowNode(
                      offset: const Offset(0, -18),
                      color: Brand.primary,
                      controller: _chestPulse,
                      reduceMotion: _reduceMotion,
                      intensity: widget.bodyProgress,
                      semanticsLabel:
                          'Body progress ${(widget.bodyProgress * 100).round()} percent',
                    ),
                    _GlowNode(
                      offset: const Offset(0, 34),
                      color: T.gold,
                      controller: _corePulse,
                      reduceMotion: _reduceMotion,
                      intensity: widget.spiritProgress,
                      semanticsLabel:
                          'Spirit progress ${(widget.spiritProgress * 100).round()} percent',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.x2),
              Semantics(
                label: 'Total points ${widget.totalPoints}',
                child: Column(
                  children: [
                    Text(
                      '${widget.totalPoints}',
                      style: t.displayMedium?.copyWith(
                        color: Brand.accent,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'pts',
                      style: t.titleMedium?.copyWith(
                        color: Brand.onDarkMuted,
                        fontWeight: FontWeight.w600,
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
                      value: widget.bodyProgress,
                      color: Brand.primary,
                      semanticsLabel:
                          'Body progress ${(widget.bodyProgress * 100).round()} percent',
                    ),
                    _PillarStat(
                      label: 'Mind',
                      value: widget.mindProgress,
                      color: Brand.mint,
                      semanticsLabel:
                          'Mind progress ${(widget.mindProgress * 100).round()} percent',
                    ),
                    _PillarStat(
                      label: 'Spirit',
                      value: widget.spiritProgress,
                      color: T.gold,
                      semanticsLabel:
                          'Spirit progress ${(widget.spiritProgress * 100).round()} percent',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.x4),
              Semantics(
                button: true,
                label: 'Open builder',
                child: ElevatedButton.icon(
                  onPressed: widget.onBuilderTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: T.gold.withOpacity(0.18),
                    foregroundColor: T.gold,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.x6,
                      vertical: AppSpace.x3,
                    ),
                    shape: const StadiumBorder(
                      side: BorderSide(color: T.gold, width: 1.2),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.search, size: 20),
                  label: Text(
                    'Builder',
                    style: t.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color baseColor;
  final Color glowColor;
  final double shimmerValue;
  final bool showShimmer;

  _RingPainter({
    required this.baseColor,
    required this.glowColor,
    required this.shimmerValue,
    required this.showShimmer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;

    final outerGlow = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 26
      ..color = glowColor.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24);
    canvas.drawCircle(center, radius - 6, outerGlow);

    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..shader = SweepGradient(
        colors: [
          baseColor.withOpacity(0.95),
          glowColor.withOpacity(0.9),
          baseColor.withOpacity(0.95),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius - 10, ringPaint);

    final innerFade = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..color = Colors.white.withOpacity(0.04);
    canvas.drawCircle(center, radius - 18, innerFade);

    if (showShimmer) {
      final start = shimmerValue * 2 * math.pi;
      final sweep = math.pi * 0.35;
      final shimmerPaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..shader = SweepGradient(
          startAngle: start,
          endAngle: start + sweep,
          colors: [
            Colors.white.withOpacity(0.0),
            Colors.white.withOpacity(0.45),
            Colors.white.withOpacity(0.0),
          ],
          stops: const [0.0, 0.5, 1.0],
          transform: GradientRotation(start),
        ).createShader(Rect.fromCircle(center: center, radius: radius));
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - 10),
        start,
        sweep,
        false,
        shimmerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return shimmerValue != oldDelegate.shimmerValue ||
        showShimmer != oldDelegate.showShimmer ||
        baseColor != oldDelegate.baseColor ||
        glowColor != oldDelegate.glowColor;
  }
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
    final headRadius = w * 0.14;
    final headCenter = Offset(w / 2, h * 0.2 + headRadius);
    path.addOval(Rect.fromCircle(center: headCenter, radius: headRadius));

    path.moveTo(w * 0.32, h * 0.36);
    path.quadraticBezierTo(w * 0.26, h * 0.58, w * 0.35, h * 0.8);
    path.quadraticBezierTo(w * 0.5, h * 0.94, w * 0.65, h * 0.8);
    path.quadraticBezierTo(w * 0.74, h * 0.58, w * 0.68, h * 0.36);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StarfieldPainter extends CustomPainter {
  final List<Offset> _stars = const [
    Offset(0.1, 0.2),
    Offset(0.25, 0.1),
    Offset(0.4, 0.28),
    Offset(0.6, 0.16),
    Offset(0.72, 0.32),
    Offset(0.85, 0.18),
    Offset(0.18, 0.38),
    Offset(0.52, 0.42),
    Offset(0.68, 0.48),
    Offset(0.82, 0.4),
    Offset(0.12, 0.54),
    Offset(0.32, 0.6),
    Offset(0.58, 0.56),
    Offset(0.76, 0.62),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.35);

    for (final star in _stars) {
      final pos = Offset(star.dx * size.width, star.dy * size.height);
      canvas.drawCircle(pos, 0.8, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _GlowNode extends StatelessWidget {
  final Offset offset;
  final Color color;
  final double intensity;
  final AnimationController controller;
  final bool reduceMotion;
  final String semanticsLabel;

  const _GlowNode({
    required this.offset,
    required this.color,
    required this.intensity,
    required this.controller,
    required this.reduceMotion,
    required this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final clamped = intensity.clamp(0.0, 1.0);

    Widget dot = AnimatedBuilder(
      animation: controller,
      builder: (_, child) {
        final base = reduceMotion ? 0.0 : controller.value;
        final wave = math.sin(base * 2 * math.pi) * 0.5 + 0.5;
        final scale = reduceMotion ? 1.0 : (0.95 + 0.1 * wave);
        final opacity = 0.6 + 0.3 * clamped + (reduceMotion ? 0 : 0.1 * wave);

        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: child,
          ),
        );
      },
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.9),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.45 + 0.25 * clamped),
              blurRadius: 28,
              spreadRadius: 3,
            ),
          ],
        ),
      ),
    );

    if (reduceMotion) {
      dot = Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.85),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.4),
              blurRadius: 22,
              spreadRadius: 2,
            ),
          ],
        ),
      );
    }

    return Transform.translate(
      offset: offset,
      child: Semantics(
        label: semanticsLabel,
        child: dot,
      ),
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
    final t = Theme.of(context).textTheme;
    final pct = (value.clamp(0.0, 1.0) * 100).round();
    return Semantics(
      label: semanticsLabel,
      child: Column(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: t.titleMedium?.copyWith(
              color: Brand.onDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            '$pct%',
            style: t.bodyMedium?.copyWith(
              color: Brand.onDarkMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

