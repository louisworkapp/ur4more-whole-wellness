import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design/tokens.dart';
import '../../theme/brand_tokens.dart';
import '../../theme/tokens.dart';

class HeroProgress extends StatelessWidget {
  final int totalPoints;
  final double bodyProgress;
  final double mindProgress;
  final double spiritProgress;
  final VoidCallback onBuilderTap;
  final bool showSpirit;

  const HeroProgress({
    super.key,
    required this.totalPoints,
    required this.bodyProgress,
    required this.mindProgress,
    required this.spiritProgress,
    required this.onBuilderTap,
    this.showSpirit = true,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = <_Metric>[
      _Metric('Body', bodyProgress, Brand.primary),
      _Metric('Mind', mindProgress, Brand.mint),
      if (showSpirit) _Metric('Spirit', spiritProgress, T.gold),
    ];

    final overall = metrics.isEmpty
        ? 0.0
        : metrics
                .map((m) => m.value.clamp(0.0, 1.0))
                .reduce((a, b) => a + b) /
            metrics.length;

    final disableAnims =
        MediaQuery.maybeOf(context)?.disableAnimations == true;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxW = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 360.0;
        final size = math.max(280.0, math.min(360.0, maxW));
        final t = Theme.of(context).textTheme;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: size,
              width: size,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // soft radial glow
                  Container(
                    width: size * 0.9,
                    height: size * 0.9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Brand.primary.withOpacity(0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // animated ring
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: overall),
                    duration: disableAnims
                        ? Duration.zero
                        : const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, value, __) {
                      return CustomPaint(
                        size: Size.square(size * 0.9),
                        painter: _HeroRingPainter(
                          progress: value,
                          baseColor: T.ink600,
                        ),
                      );
                    },
                  ),
                  // center body image
                  _HeroBodyImage(size: size * 0.58),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.x2),
            Semantics(
              label: 'Total points $totalPoints',
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: disableAnims
                        ? Duration.zero
                        : const Duration(milliseconds: 250),
                    child: Text(
                      '$totalPoints',
                      key: ValueKey(totalPoints),
                      style: t.displayMedium?.copyWith(
                        color: Brand.onDark,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: metrics
                  .map(
                    (m) => _MetricStat(
                      metric: m,
                      disableAnims: disableAnims,
                    ),
                  )
                  .toList(),
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
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: T.gold, width: 1.2),
                  foregroundColor: T.gold,
                  backgroundColor: T.gold.withOpacity(0.12),
                ),
                icon: const Icon(Icons.search, size: 20),
                label: Text(
                  'Builder',
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: T.gold,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroRingPainter extends CustomPainter {
  final double progress;
  final Color baseColor;

  _HeroRingPainter({
    required this.progress,
    required this.baseColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final stroke = size.width * 0.06;

    final background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = baseColor.withOpacity(0.35);

    canvas.drawCircle(center, radius - stroke, background);

    final rect = Rect.fromCircle(center: center, radius: radius - stroke);

    final gradient = SweepGradient(
      startAngle: -math.pi / 2,
      endAngle: 1.5 * math.pi,
      colors: [
        Brand.primary,
        Brand.mint,
        T.gold,
        Brand.primary,
      ],
      stops: const [0.0, 0.38, 0.72, 1.0],
    );

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    final sweep = (progress.clamp(0.0, 1.0)) * 2 * math.pi;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 2);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(rect, 0, sweep, false, progressPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HeroRingPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.baseColor != baseColor;
  }
}

class _HeroBodyImage extends StatelessWidget {
  final double size;

  const _HeroBodyImage({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Brand.accent.withOpacity(0.25),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/Whole Wellness Hero body.png',
              fit: BoxFit.cover,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric {
  final String label;
  final double value;
  final Color color;

  const _Metric(this.label, this.value, this.color);
}

class _MetricStat extends StatelessWidget {
  final _Metric metric;
  final bool disableAnims;

  const _MetricStat({
    required this.metric,
    required this.disableAnims,
  });

  @override
  Widget build(BuildContext context) {
    final pct = metric.value.clamp(0.0, 1.0);
    final t = Theme.of(context).textTheme;

    return Semantics(
      label: '${metric.label} ${(pct * 100).round()} percent',
      child: Column(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: metric.color,
              boxShadow: [
                BoxShadow(
                  color: metric.color.withOpacity(0.45),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            metric.label,
            style: t.titleMedium?.copyWith(
              color: Brand.onDark,
              fontWeight: FontWeight.w700,
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: pct),
            duration: disableAnims
                ? Duration.zero
                : const Duration(milliseconds: 500),
            curve: Curves.easeOut,
            builder: (_, value, __) {
              return Text(
                '${(value * 100).round()}%',
                style: t.bodyMedium?.copyWith(
                  color: Brand.onDarkMuted,
                  fontWeight: FontWeight.w600,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

