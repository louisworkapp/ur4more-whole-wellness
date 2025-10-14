import 'package:flutter/material.dart';

class BrandGlyphText extends StatelessWidget {
  const BrandGlyphText({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme.primary;

    // Stroke layer keeps edges sharp at tiny sizes
    final stroke = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      foreground:
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.4
            ..color = c,
    );

    final fill = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: c,
    );

    return Stack(
      alignment: Alignment.centerLeft,
      children: [Text('4>', style: stroke), Text('4>', style: fill)],
    );
  }
}
