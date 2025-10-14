import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

class BrandLogoWidget extends StatelessWidget {
  final double? size;
  final Color? tintColor;

  const BrandLogoWidget({
    super.key,
    this.size,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final logoSize = size ?? 20.w;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: logoSize,
          height: logoSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(logoSize * 0.5),
              child: _buildLogoWithFallback(
                  logoSize, tintColor ?? colorScheme.primary, theme),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'UR4MORE',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
            color: tintColor ?? colorScheme.primary,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Made for more.',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: colorScheme.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildLogoWithFallback(
      double logoSize, Color primaryColor, ThemeData theme) {
    return CustomImageWidget(
      imageUrl: "assets/images/logo-ur4more-4-1760393143197.png",
      width: logoSize * 0.8,
      height: logoSize * 0.8,
      fit: BoxFit.contain,
      semanticLabel:
          "UR4MORE wellness app logo featuring the official brand symbol",
      errorWidget: Container(
        width: logoSize * 0.8,
        height: logoSize * 0.8,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primaryColor.withValues(alpha: 0.3),
              primaryColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'UR4',
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: (logoSize * 0.15),
                  fontWeight: FontWeight.w900,
                  color: primaryColor,
                ),
              ),
              Text(
                'MORE',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: (logoSize * 0.08),
                  fontWeight: FontWeight.w600,
                  color: primaryColor.withValues(alpha: 0.8),
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
