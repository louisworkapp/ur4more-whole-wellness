import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/tokens.dart';
import '../../routes/app_routes.dart';
import '../../theme/brand_tokens.dart';
import '../../theme/tokens.dart';

class WellnessStartScreen extends StatelessWidget {
  const WellnessStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/spalsh phone card2.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color.fromARGB(120, 0, 0, 0),
                  Color.fromARGB(170, 0, 0, 0),
                ],
                stops: [0.0, 0.55, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.x5),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo "4>" and brand name at top
                  FadeInUp(
                    delay: const Duration(milliseconds: 80),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo "4>"
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '4',
                              style: t.displayLarge?.copyWith(
                                color: Brand.primary,
                                fontWeight: FontWeight.w800,
                                fontSize: 48,
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward,
                              color: Brand.primary,
                              size: 32,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpace.x2),
                        // UR4MORE
                        Text(
                          'UR4MORE',
                          style: t.displaySmall?.copyWith(
                            color: Brand.accent,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpace.x2),
                        // Body • Mind • Spirit
                        Text(
                          'Body • Mind • Spirit',
                          style: t.bodyLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 4),
                  // Hero text and button at bottom
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Build strength, clarity, and faith—daily.
                        Text(
                          'Build strength, clarity, and faith—daily.',
                          style: t.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpace.x6),
                        _PrimaryCta(onTap: () {
                          HapticFeedback.lightImpact();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.main,
                            (route) => false,
                          );
                        }),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpace.x10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  final VoidCallback onTap;
  const _PrimaryCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: 'Get started',
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.x8,
            vertical: AppSpace.x4,
          ),
          minimumSize: const Size(200, 52),
          shape: const StadiumBorder(),
          backgroundColor: Brand.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Brand.primary.withOpacity(0.5),
        ),
        child: Text(
          'Get started',
          style: t.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class FadeInUp extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Duration delay;

  const FadeInUp({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 450),
    this.delay = Duration.zero,
  });

  @override
  State<FadeInUp> createState() => _FadeInUpState();
}

class _FadeInUpState extends State<FadeInUp>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _anim = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _timer = Timer(widget.delay, _controller.forward);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      child: widget.child,
      builder: (context, child) {
        final value = _anim.value;
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 16),
            child: child,
          ),
        );
      },
    );
  }
}

