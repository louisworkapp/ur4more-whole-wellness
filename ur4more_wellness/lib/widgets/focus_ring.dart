import 'package:flutter/material.dart';
import '../theme/tokens.dart';

class FocusRing extends StatefulWidget {
  const FocusRing({
    super.key, 
    required this.child, 
    this.active = false,
    this.duration = const Duration(milliseconds: 160),
  });
  
  final Widget child;
  final bool active;
  final Duration duration;

  @override
  State<FocusRing> createState() => _FocusRingState();
}

class _FocusRingState extends State<FocusRing> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _shadowAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    _shadowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void didUpdateWidget(FocusRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active != oldWidget.active) {
      if (widget.active) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shadowAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.active ? [
              BoxShadow(
                color: T.blue.withOpacity(.4 * _shadowAnimation.value),
                blurRadius: 18 * _shadowAnimation.value,
                spreadRadius: 2 * _shadowAnimation.value,
              ),
            ] : [],
          ),
          child: widget.child,
        );
      },
    );
  }
}
