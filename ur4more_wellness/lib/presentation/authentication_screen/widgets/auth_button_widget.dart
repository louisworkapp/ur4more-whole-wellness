import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

enum AuthButtonType { primary, secondary }

class AuthButtonWidget extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final AuthButtonType type;
  final bool isEnabled;

  const AuthButtonWidget({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = AuthButtonType.primary,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      height: 6.h,
      constraints: BoxConstraints(
        minHeight: 48,
        maxHeight: 60,
      ),
      child: ElevatedButton(
        onPressed: (isEnabled && !isLoading) ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: type == AuthButtonType.primary
              ? colorScheme.primary
              : colorScheme.surface,
          foregroundColor: type == AuthButtonType.primary
              ? colorScheme.onPrimary
              : colorScheme.primary,
          disabledBackgroundColor:
              colorScheme.onSurfaceVariant.withOpacity( 0.12),
          disabledForegroundColor:
              colorScheme.onSurfaceVariant.withOpacity( 0.38),
          elevation: type == AuthButtonType.primary ? 2 : 0,
          shadowColor: colorScheme.shadow.withOpacity( 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: type == AuthButtonType.secondary
                ? BorderSide(
                    color: isEnabled
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant.withOpacity( 0.12),
                    width: 1.5,
                  )
                : BorderSide.none,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: 6.w,
            vertical: 1.5.h,
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 5.w,
                height: 5.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    type == AuthButtonType.primary
                        ? colorScheme.onPrimary
                        : colorScheme.primary,
                  ),
                ),
              )
            : Text(
                text,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: type == AuthButtonType.primary
                      ? colorScheme.onPrimary
                      : colorScheme.primary,
                ),
              ),
      ),
    );
  }
}
