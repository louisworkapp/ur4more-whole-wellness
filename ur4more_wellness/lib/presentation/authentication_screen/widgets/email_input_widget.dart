import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

class EmailInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final VoidCallback? onChanged;

  const EmailInputWidget({
    super.key,
    required this.controller,
    this.errorText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          constraints: BoxConstraints(
            minHeight: 48,
            maxHeight: 64,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            onChanged: (value) => onChanged?.call(),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: math.min(16.0, (theme.textTheme.bodyLarge?.fontSize ?? 16)),
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your email address',
              hintStyle: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity( 0.6),
                fontSize: math.min(16.0, (theme.textTheme.bodyMedium?.fontSize ?? 16)),
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.all(AppSpace.x3),
                child: CustomIconWidget(
                  iconName: 'email',
                  color: errorText != null
                      ? colorScheme.error
                      : colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              filled: true,
              fillColor: colorScheme.surface,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpace.x4,
                vertical: AppSpace.x2,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.outline.withOpacity( 0.3),
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: errorText != null
                      ? colorScheme.error.withOpacity( 0.5)
                      : colorScheme.outline.withOpacity( 0.3),
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: errorText != null
                      ? colorScheme.error
                      : colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 1,
                ),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: colorScheme.error,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        errorText != null ? const SizedBox(height: AppSpace.x1) : const SizedBox.shrink(),
        errorText != null
            ? Padding(
                padding: const EdgeInsets.only(left: AppSpace.x3),
                child: Text(
                  errorText!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.error,
                    fontSize: math.min(12.0, (theme.textTheme.bodySmall?.fontSize ?? 12)),
                  ),
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}
