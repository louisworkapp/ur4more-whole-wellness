import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
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
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _backgroundAnimation;

  bool _isInitializing = true;
  String _initializationStatus = 'Initializing...';

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

    // Start animations
    _backgroundAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _logoAnimationController.forward();
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

      // Navigate after initialization
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 500));
        _navigateToNextScreen();
      }
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
                    const Color(0xFF1E3A8A),
                    const Color(0xFF1E40AF),
                    _backgroundAnimation.value,
                  )!,
                  Color.lerp(
                    const Color(0xFF1E40AF),
                    const Color(0xFF1E3A8A),
                    _backgroundAnimation.value,
                  )!,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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

                          const SizedBox(height: 32),

                          // Brand Text
                          AnimatedBuilder(
                            animation: _logoFadeAnimation,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _logoFadeAnimation,
                                child: Text(
                                  'UR4MORE',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 24.sp,
                                        letterSpacing: 2.0,
                                      ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 16),

                          // Tagline
                          AnimatedBuilder(
                            animation: _logoFadeAnimation,
                            builder: (context, child) {
                              return FadeTransition(
                                opacity: _logoFadeAnimation,
                                child: Text(
                                  'Wellness Beyond Limits',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color:
                                            Colors.white.withOpacity(0.8),
                                        fontSize: 14.sp,
                                        letterSpacing: 1.0,
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Loading Section
                  Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: Column(
                      children: [
                        // Loading Indicator
                        SizedBox(
                          width: 8.w,
                          height: 8.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Status Text
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: Text(
                            _initializationStatus,
                            key: ValueKey(_initializationStatus),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 12.sp,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 30.w,
      height: 30.w,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: Image.asset(
            'assets/images/logo-ur4more-4-1760393143197.png',
            width: 88,
            height: 88,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback to a simple icon if image fails to load
              return Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  Icons.favorite,
                  size: 12.w,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
