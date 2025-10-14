import 'package:flutter/material.dart';

class BrandLogo extends StatelessWidget {
  final double size;

  const BrandLogo({
    super.key,
    this.size = 48,
  });

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.mode(
        Theme.of(context).colorScheme.primary,
        BlendMode.srcIn,
      ),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          'assets/images/logo-ur4more-4.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback icon with brand primary color
            return Icon(
              Icons.favorite,
              size: size,
              color: Theme.of(context).colorScheme.primary,
            );
          },
        ),
      ),
    );
  }
}
