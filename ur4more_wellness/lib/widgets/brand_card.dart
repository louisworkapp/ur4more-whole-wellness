import 'package:flutter/material.dart';
import '../theme/brand_tokens.dart';

class BrandCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;

  const BrandCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Brand.card,
        borderRadius: BorderRadius.circular(Brand.radius),
        border: const Border.fromBorderSide(BorderSide(color: Brand.stroke)),
        boxShadow: Brand.shadow,
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
