import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../theme/app_colors.dart';

class PointsProgressRing extends StatefulWidget {
  final int totalPoints;
  final double bodyProgress;
  final double mindProgress;
  final double spiritualProgress;
  final bool showSpiritualProgress;

  const PointsProgressRing({
    super.key,
    required this.totalPoints,
    required this.bodyProgress,
    required this.mindProgress,
    required this.spiritualProgress,
    required this.showSpiritualProgress,
  });

  @override
  State<PointsProgressRing> createState() => _PointsProgressRingState();
}

class _PointsProgressRingState extends State<PointsProgressRing>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _ringAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _ringAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 50.w,
      child: Column(
        children: [
          // Single brand blue ring with inner label
          Container(
            width: 40.w,
            height: 40.w,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                AnimatedBuilder(
                  animation: _ringAnimation,
                  builder: (context, child) {
                    return CustomPaint(
                      size: Size(40.w, 40.w),
                      painter: _SingleRingPainter(
                        progress: _ringAnimation.value,
                        color: theme.colorScheme.primary,
                        backgroundColor:
                            theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                    );
                  },
                ),
                // Inner points label
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${widget.totalPoints}',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.primary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      'pts',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF475569),
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 3.h),

          // Row of 3 mini progress bars below
          _buildPillarBarsRow(context),
        ],
      ),
    );
  }

  Widget _buildPillarBarsRow(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Body bar
          _buildMiniProgressBar(
            context,
            'Body',
            widget.bodyProgress,
            AppColors.primary, // Blue 60%
          ),
          // Mind bar
          _buildMiniProgressBar(
            context,
            'Mind',
            widget.mindProgress,
            AppColors.mind, // Green 60%
          ),
          // Spirit bar (only if enabled)
          if (widget.showSpiritualProgress)
            _buildMiniProgressBar(
              context,
              'Spirit',
              widget.spiritualProgress,
              AppColors.gold, // Gold 85%
            ),
        ],
      ),
    );
  }

  Widget _buildMiniProgressBar(
      BuildContext context, String label, double progress, Color color) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 1.w),
        child: Column(
          children: [
            // Mini progress bar
            Container(
              height: 6.h,
              width: 8,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 1000),
                    height: 6.h * progress,
                    width: 8,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 1.h),

            // Label and percentage
            Column(
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                      ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF475569),
                      ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SingleRingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color backgroundColor;

  _SingleRingPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.4;
    final strokeWidth = size.width * 0.08;

    // Background ring
    final backgroundPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = backgroundColor;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress ring
    final progressPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = color;

    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -1.5708; // Start from top (-π/2)
    final sweepAngle = 6.2832 * progress; // Full circle * progress (2π)

    canvas.drawArc(rect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
