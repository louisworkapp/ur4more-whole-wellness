import 'package:flutter/material.dart';
import 'dart:ui';

class BrandNumberDisplay extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String? suffix;

  const BrandNumberDisplay({
    super.key,
    required this.value,
    this.style,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultStyle = theme.textTheme.headlineLarge?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
      fontWeight: FontWeight.w700,
    );
    
    final finalStyle = style?.copyWith(
      fontFeatures: const [FontFeature.tabularFigures()],
    ) ?? defaultStyle;

    return RichText(
      text: TextSpan(
        style: finalStyle,
        children: [
          TextSpan(text: value.toString()),
          if (suffix != null) TextSpan(
            text: suffix!,
            style: finalStyle?.copyWith(
              fontSize: (finalStyle?.fontSize ?? 28) * 0.7,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
