import 'package:flutter/material.dart';

class BrandGlyph extends StatelessWidget {
  const BrandGlyph({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/no-image.jpg',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to text-based glyph if image fails to load
        final c = Theme.of(context).colorScheme.primary;
        return Text(
          '4>',
          style: TextStyle(
            fontSize: size * 0.8,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: c,
          ),
        );
      },
    );
  }
}
