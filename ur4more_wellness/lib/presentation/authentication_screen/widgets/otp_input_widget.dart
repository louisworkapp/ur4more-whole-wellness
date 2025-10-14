import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'dart:math' as math;
import '../../../design/tokens.dart';

class OtpInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onCompleted;
  final VoidCallback? onChanged;

  const OtpInputWidget({
    super.key,
    required this.controller,
    this.errorText,
    this.onCompleted,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final defaultPinTheme = PinTheme(
      width: 48,
      height: 48,
      textStyle: theme.textTheme.headlineSmall?.copyWith(
        fontSize: math.min(18.0, (theme.textTheme.headlineSmall?.fontSize ?? 18)),
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorText != null
              ? colorScheme.error.withOpacity( 0.5)
              : colorScheme.outline.withOpacity( 0.3),
          width: 1,
        ),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorText != null ? colorScheme.error : colorScheme.primary,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (errorText != null ? colorScheme.error : colorScheme.primary)
                .withOpacity( 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: errorText != null ? colorScheme.error : colorScheme.primary,
          width: 1,
        ),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity( 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.error,
          width: 1,
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Pinput(
          controller: controller,
          length: 6,
          defaultPinTheme: errorText != null ? errorPinTheme : defaultPinTheme,
          focusedPinTheme: focusedPinTheme,
          submittedPinTheme: submittedPinTheme,
          errorPinTheme: errorPinTheme,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          hapticFeedbackType: HapticFeedbackType.lightImpact,
          onCompleted: (pin) {
            HapticFeedback.lightImpact();
            onCompleted?.call();
          },
          onChanged: (pin) => onChanged?.call(),
          cursor: Container(
            width: 2,
            height: 24,
            color: colorScheme.primary,
          ),
          separatorBuilder: (index) => const SizedBox(width: AppSpace.x2),
          enableSuggestions: false,
          autofocus: true,
          showCursor: true,
          pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
        ),
        errorText != null ? const SizedBox(height: AppSpace.x2) : const SizedBox.shrink(),
        errorText != null
            ? Text(
                errorText!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.error,
                  fontSize: math.min(12.0, (theme.textTheme.bodySmall?.fontSize ?? 12)),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
