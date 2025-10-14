import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class ResendCodeWidget extends StatefulWidget {
  final VoidCallback? onResend;
  final int countdownSeconds;

  const ResendCodeWidget({
    super.key,
    this.onResend,
    this.countdownSeconds = 60,
  });

  @override
  State<ResendCodeWidget> createState() => _ResendCodeWidgetState();
}

class _ResendCodeWidgetState extends State<ResendCodeWidget>
    with TickerProviderStateMixin {
  late AnimationController _countdownController;
  late Animation<int> _countdownAnimation;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _initializeCountdown();
  }

  void _initializeCountdown() {
    _countdownController = AnimationController(
      duration: Duration(seconds: widget.countdownSeconds),
      vsync: this,
    );

    _countdownAnimation = IntTween(
      begin: widget.countdownSeconds,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _countdownController,
      curve: Curves.linear,
    ));

    _countdownController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _canResend = true;
        });
      }
    });

    _countdownController.forward();
  }

  void _handleResend() {
    if (_canResend) {
      HapticFeedback.lightImpact();
      setState(() {
        _canResend = false;
      });
      _countdownController.reset();
      _countdownController.forward();
      widget.onResend?.call();
    }
  }

  @override
  void dispose() {
    _countdownController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnimatedBuilder(
      animation: _countdownAnimation,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Didn't receive the code? ",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            GestureDetector(
              onTap: _canResend ? _handleResend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: 2.w,
                  vertical: 1.h,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _canResend
                      ? colorScheme.primary.withOpacity( 0.1)
                      : Colors.transparent,
                ),
                child: Text(
                  _canResend
                      ? 'Resend Code'
                      : 'Resend in ${_countdownAnimation.value}s',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: _canResend
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant.withOpacity( 0.6),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
