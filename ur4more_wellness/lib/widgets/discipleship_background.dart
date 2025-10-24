import 'package:flutter/material.dart';
import 'dart:math';
import '../theme/tokens.dart';

class DiscipleshipBackground extends StatelessWidget {
  const DiscipleshipBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: DiscipleshipBackgroundPainter(),
      size: Size.infinite,
    );
  }
}

class DiscipleshipBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Create the background gradient
    final backgroundGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        const Color(0xFF0A1428), // Deep blue
        const Color(0xFF1A2643), // Slightly lighter blue
        const Color(0xFF0A1428), // Back to deep blue
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final backgroundRect = Rect.fromLTWH(0, 0, size.width, size.height);
    final backgroundPaint = Paint()
      ..shader = backgroundGradient.createShader(backgroundRect);
    
    canvas.drawRect(backgroundRect, backgroundPaint);

    // Draw the fish symbol (Ichthys) in the upper-left area
    _drawFishSymbol(canvas, size);

    // Draw water waves in the lower-right area
    _drawWaterWaves(canvas, size);

    // Add subtle sparkle effects
    _drawSparkles(canvas, size);
  }

  void _drawFishSymbol(Canvas canvas, Size size) {
    // Note: This method is now handled by the Stack in the main widget
    // The fish logo is drawn as an Image widget positioned in the Stack
  }

  void _drawWaterWaves(Canvas canvas, Size size) {
    // Note: This method is now handled by the Stack in the main widget
    // The waves logo is drawn as an Image widget positioned in the Stack
  }

  void _drawWave(Canvas canvas, double startX, double endX, double y, Paint paint) {
    final path = Path();
    path.moveTo(startX, y);
    
    final waveLength = (endX - startX) / 4;
    final amplitude = 8.0;
    
    for (int i = 0; i < 4; i++) {
      final x1 = startX + (i * waveLength);
      final x2 = startX + ((i + 0.5) * waveLength);
      final x3 = startX + ((i + 1) * waveLength);
      
      path.cubicTo(
        x1, y,
        x2, y - amplitude,
        x3, y,
      );
    }
    
    canvas.drawPath(path, paint);
  }

  void _drawSparkles(Canvas canvas, Size size) {
    final sparklePaint = Paint()
      ..color = T.gold.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    // Add subtle sparkles around the fish
    final sparklePositions = [
      Offset(size.width * 0.25, size.height * 0.15),
      Offset(size.width * 0.1, size.height * 0.3),
      Offset(size.width * 0.3, size.height * 0.25),
      Offset(size.width * 0.05, size.height * 0.2),
    ];

    for (final position in sparklePositions) {
      canvas.drawCircle(position, 2, sparklePaint);
    }

    // Add sparkles near the waves
    final waveSparkles = [
      Offset(size.width * 0.7, size.height * 0.7),
      Offset(size.width * 0.8, size.height * 0.9),
      Offset(size.width * 0.9, size.height * 0.7),
    ];

    for (final position in waveSparkles) {
      canvas.drawCircle(position, 1.5, sparklePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
