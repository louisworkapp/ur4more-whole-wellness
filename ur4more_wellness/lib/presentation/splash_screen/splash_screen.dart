import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _backgroundAnimationController;
  late AnimationController _buttonPulseController;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _backgroundAnimation;
  late Animation<double> _buttonPulse;

  bool _isInitializing = true;
  String _initializationStatus = 'Initializing...';
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    // Logo animation controller
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Background animation controller
    _backgroundAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Logo scale animation
    _logoScaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.elasticOut,
    ));

    // Logo fade animation
    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeInOut),
    ));

    // Background gradient animation
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundAnimationController,
      curve: Curves.easeInOut,
    ));

    _buttonPulseController = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
      lowerBound: 0.0,
      upperBound: 1.0,
    );

    _buttonPulse = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonPulseController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Start animations
    _backgroundAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _logoAnimationController.forward();
      _buttonPulseController.forward();
    });
  }

  Future<void> _initializeApp() async {
    try {
      // Set system UI overlay style
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: Color(0xFF1E3A8A),
          systemNavigationBarIconBrightness: Brightness.light,
        ),
      );

      // Simulate initialization steps
      await _performInitializationSteps();

      // Ready state — wait for user to tap Continue
    } catch (e) {
      if (mounted) {
        setState(() {
          _initializationStatus = 'Initialization failed. Retrying...';
        });
        // Retry after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            _initializeApp();
          }
        });
      }
    }
  }

  Future<void> _performInitializationSteps() async {
    // Step 1: Validate authentication tokens
    if (mounted) {
      setState(() {
        _initializationStatus = 'Validating session...';
      });
    }
    await Future.delayed(const Duration(milliseconds: 600));

    // Step 2: Load user preferences
    if (mounted) {
      setState(() {
        _initializationStatus = 'Loading preferences...';
      });
    }
    await Future.delayed(const Duration(milliseconds: 500));

    // Step 3: Fetch essential configuration
    if (mounted) {
      setState(() {
        _initializationStatus = 'Fetching configuration...';
      });
    }
    await Future.delayed(const Duration(milliseconds: 400));

    // Step 4: Prepare cached wellness content
    if (mounted) {
      setState(() {
        _initializationStatus = 'Preparing content...';
      });
    }
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {
        _isInitializing = false;
        _initializationStatus = 'Ready!';
      });
    }
  }

  Future<void> _navigateToNextScreen() async {
    // Check authentication status
    bool isAuthenticated = await _checkAuthenticationStatus();

    if (mounted) {
      if (isAuthenticated) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.authentication);
      }
    }
  }

  Future<bool> _checkAuthenticationStatus() async {
    try {
      // Check if user is authenticated using the auth service
      final isAuthenticated = await AuthService.isAuthenticated();
      
      if (isAuthenticated) {
        // Log successful authentication check
        final userId = await AuthService.getCurrentUserId();
        if (userId != null) {
          Telemetry.appOpened(userId);
        }
      }
      
      return isAuthenticated;
    } catch (e) {
      debugPrint('Error checking authentication status: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _backgroundAnimationController.dispose();
    _buttonPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundAnimation,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(
                    const Color(0xFF0E1420),
                    const Color(0xFF122035),
                    _backgroundAnimation.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF0B1021),
                    const Color(0xFF0E182B),
                    _backgroundAnimation.value,
                  )!,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          center: Alignment(0, -0.2),
                          radius: 1.1,
                          colors: [
                            Colors.white.withOpacity(0.05),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.x5,
                    ),
                    child: Column(
                      children: [
                        _HeaderAction(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.authentication);
                          },
                        ),
                        const SizedBox(height: AppSpace.x5),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpace.x8),
                              // Logo Section
                              AnimatedBuilder(
                                animation: _logoAnimationController,
                                builder: (context, child) {
                                  return FadeTransition(
                                    opacity: _logoFadeAnimation,
                                    child: ScaleTransition(
                                      scale: _logoScaleAnimation,
                                      child: _buildLogo(),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: AppSpace.x6),
                              // Brand Text
                              FadeTransition(
                                opacity: _logoFadeAnimation,
                                child: Text(
                                  'UR4MORE',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.4,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: AppSpace.x2),
                              FadeTransition(
                                opacity: _logoFadeAnimation,
                                child: Text(
                                  'Track your Body, Mind, and Spirit—one daily check-in.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        color: Colors.white.withOpacity(0.82),
                                        fontWeight: FontWeight.w500,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(height: AppSpace.x4),
                              const _MotifRow(),
                              const SizedBox(height: AppSpace.x6),
                              _buildContinueButton(context),
                              const SizedBox(height: AppSpace.x2),
                              Text(
                                'Takes ~30 seconds to get you set up.',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withOpacity(0.7),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                              const SizedBox(height: AppSpace.x6),
                              _StatusLine(
                                status: _initializationStatus,
                                initializing: _isInitializing,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 132,
      height: 132,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.12),
            blurRadius: 34,
            spreadRadius: 8,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 24,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.x4),
        child: Center(
          child: Image.asset(
            'assets/images/logo-ur4more-4-1760393143197.png',
            width: 96,
            height: 96,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to a simple icon if image fails to load
              return Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.favorite,
                  size: 48,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContinueButton(BuildContext context) {
    final isDisabled = _isInitializing || _isNavigating;
    final button = ScaleTransition(
      scale: Tween<double>(begin: 0.98, end: 1.02)
          .animate(CurvedAnimation(parent: _buttonPulseController, curve: Curves.easeOut)),
      child: FilledButton(
        onPressed: isDisabled
            ? null
            : () async {
                HapticFeedback.lightImpact();
                setState(() => _isNavigating = true);
                await _navigateToNextScreen();
                if (mounted) {
                  setState(() => _isNavigating = false);
                }
              },
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.x8,
            vertical: AppSpace.x3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            const SizedBox(width: AppSpace.x2),
            Text(
              'Continue to your day',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      button: true,
      label: 'Continue to your day',
      child: button,
    );
  }
}

class _MotifRow extends StatelessWidget {
  const _MotifRow();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _DotLabel(label: 'Body', color: Brand.primary),
        SizedBox(width: AppSpace.x4),
        _DotLabel(label: 'Mind', color: Brand.mint),
        SizedBox(width: AppSpace.x4),
        _DotLabel(label: 'Spirit', color: T.gold),
      ],
    );
  }
}

class _DotLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _DotLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 12,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpace.x1),
        Text(
          label,
          style: t.labelMedium?.copyWith(
            color: Colors.white.withOpacity(0.86),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  final VoidCallback onTap;

  const _HeaderAction({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: onTap,
          child: const Text('Sign in'),
        ),
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  final String status;
  final bool initializing;

  const _StatusLine({
    required this.status,
    required this.initializing,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (initializing)
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withOpacity(0.8),
              ),
            ),
          ),
        if (initializing) const SizedBox(width: AppSpace.x2),
        Flexible(
          child: Text(
            status,
            style: t.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.78),
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
