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
  final bool showSpirit;
  final VoidCallback? onBuilderTap;

  const HeroProgress({
    super.key,
    required this.totalPoints,
    required this.bodyProgress,
    required this.mindProgress,
    required this.spiritProgress,
    this.showSpirit = true,
    this.onBuilderTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth =
            constraints.maxWidth.isFinite ? constraints.maxWidth : AppMaxW.card;
        final size = availableWidth.clamp(280.0, 360.0);
        final ringStroke = size * 0.08;

        final bool shouldShowSpirit = showSpirit;
        final double body = bodyProgress.clamp(0.0, 1.0);
        final double mind = mindProgress.clamp(0.0, 1.0);
        final double spirit = spiritProgress.clamp(0.0, 1.0);

        final int divisor = shouldShowSpirit ? 3 : 2;
        final double aggregate =
            shouldShowSpirit ? (body + mind + spirit) : (body + mind);
        final double overall = (aggregate / divisor).clamp(0.0, 1.0);

        final List<Color> gradientColors = [
          Brand.primary, // Body
          Brand.mint, // Mind
          T.gold, // Spirit
          Brand.primary,
        ];

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _HeroRing(
                    size: size,
                    strokeWidth: ringStroke,
                    progress: overall,
                    gradientColors: gradientColors,
                  ),
                  const SizedBox(height: AppSpace.x3),
                  _PointsLabel(points: totalPoints),
                  const SizedBox(height: AppSpace.x2),
                  _MetricsRow(
                    body: body,
                    mind: mind,
                    spirit: spirit,
                    showSpirit: shouldShowSpirit,
                  ),
                  const SizedBox(height: AppSpace.x3),
                  _BuilderButton(onTap: onBuilderTap),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _HeroRing extends StatelessWidget {
  final double size;
  final double strokeWidth;
  final double progress;
  final List<Color> gradientColors;

  const _HeroRing({
    required this.size,
    required this.strokeWidth,
    required this.progress,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final double glowSize = size * 1.1;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft radial glow behind the ring
          Container(
            width: glowSize,
            height: glowSize,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  cs.primary.withOpacity(0.16),
                  cs.primary.withOpacity(0.04),
                  Colors.transparent,
                ],
                stops: const [0.35, 0.7, 1.0],
              ),
            ),
          ),

          // Animated gradient ring
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1200),
            curve: Curves.easeOutCubic,
            tween: Tween<double>(begin: 0, end: progress),
            builder: (context, value, _) {
              return CustomPaint(
                size: Size.square(size),
                painter: _GradientRingPainter(
                  progress: value,
                  strokeWidth: strokeWidth,
                  gradientColors: gradientColors,
                  backgroundColor: cs.outline.withOpacity(0.15),
                ),
              );
            },
          ),

          // Outer glow hugging the image
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withOpacity(0.16),
                  blurRadius: 40,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

          // Center hero image
          SizedBox(
            width: size * 0.72,
            height: size * 0.72,
            child: Image.asset(
              'assets/images/whole_wellness_hero_body.png',
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointsLabel extends StatelessWidget {
  final int points;

  const _PointsLabel({required this.points});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      children: [
        Text(
          '$points',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            color: cs.onBackground,
          ),
        ),
        Text(
          'pts',
          style: theme.textTheme.labelLarge?.copyWith(
            color: cs.onBackground.withOpacity(0.68),
          ),
        ),
      ],
    );
  }
}

class _MetricsRow extends StatelessWidget {
  final double body;
  final double mind;
  final double spirit;
  final bool showSpirit;

  const _MetricsRow({
    required this.body,
    required this.mind,
    required this.spirit,
    required this.showSpirit,
  });

  @override
  Widget build(BuildContext context) {
    final metrics = <_Metric>[
      _Metric('Body', body, Brand.primary),
      _Metric('Mind', mind, Brand.mint),
      if (showSpirit) _Metric('Spirit', spirit, T.gold),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: metrics
          .map((m) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpace.x1),
                  child: _MetricTile(metric: m),
                ),
              ))
          .toList(),
    );
  }
}

class _Metric {
  final String label;
  final double progress;
  final Color color;

  _Metric(this.label, this.progress, this.color);
}

class _MetricTile extends StatelessWidget {
  final _Metric metric;

  const _MetricTile({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(
        begin: 0,
        end: metric.progress.clamp(0.0, 1.0),
      ),
      builder: (context, value, _) {
        final percent = (value * 100).round();
        return Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: metric.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: metric.color.withOpacity(0.35),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpace.x1),
                Text(
                  metric.label,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: cs.onBackground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpace.x1),
            Text(
              '$percent%',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: cs.onBackground.withOpacity(0.72),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BuilderButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _BuilderButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FilledButton.icon(
      onPressed: onTap,
      icon: const Icon(Icons.search),
      label: const Text('Builder'),
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.x5,
          vertical: AppSpace.x2,
        ),
        shape: const StadiumBorder(),
        textStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _GradientRingPainter extends CustomPainter {
  final double progress;
  final double strokeWidth;
  final List<Color> gradientColors;
  final Color backgroundColor;

  _GradientRingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradientColors,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;

    // Base track
    final trackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = backgroundColor;
    canvas.drawArc(rect, startAngle, 2 * math.pi, false, trackPaint);

    // Active sweep
    final sweep = (2 * math.pi * progress).clamp(0.0, 2 * math.pi);
    // Smooth wrap so the seam is gentle and all three colors blend
    final gradient = SweepGradient(
      startAngle: startAngle - 0.2, // nudge seam to a less visible spot
      endAngle: startAngle + 2 * math.pi - 0.2,
      colors: [
        gradientColors[0],
        gradientColors[0],
        gradientColors[1],
        gradientColors[1],
        gradientColors[2],
        gradientColors[2],
        gradientColors[0],
        gradientColors[0],
      ],
      stops: const [0.0, 0.08, 0.35, 0.42, 0.68, 0.78, 0.95, 1.0],
      tileMode: TileMode.clamp,
    );

    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..shader = gradient.createShader(rect);

    canvas.drawArc(rect, startAngle, sweep, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant _GradientRingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.gradientColors != gradientColors ||
        oldDelegate.backgroundColor != backgroundColor;
  }
}

