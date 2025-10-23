import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../design/tokens.dart';
import '../../widgets/custom_app_bar.dart';

class FaithCongratulationsScreen extends StatefulWidget {
  const FaithCongratulationsScreen({super.key});

  @override
  State<FaithCongratulationsScreen> createState() => _FaithCongratulationsScreenState();
}

class _FaithCongratulationsScreenState extends State<FaithCongratulationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _sparkleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sparkleAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.easeInOut,
    ));
    
    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 500));
    _sparkleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _onContinue() {
    HapticFeedback.mediumImpact();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Deep blue background
      appBar: const CustomAppBar(
        title: 'Welcome to Faith Mode',
        variant: CustomAppBarVariant.centered,
        showBackButton: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.x4),
          child: Column(
            children: [
              const Spacer(),
              
              // Main content
              FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      // Congratulations icon with sparkles
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Main icon
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFC9A227), // Gold
                                  Color(0xFFD4AF37), // Lighter gold
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFC9A227).withOpacity(0.3),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
                              size: 60,
                              color: Colors.white,
                            ),
                          ),
                          
                          // Sparkle animations
                          ...List.generate(8, (index) {
                            final angle = (index * 45.0) * (3.14159 / 180);
                            final radius = 80.0;
                            final x = radius * cos(angle);
                            final y = radius * sin(angle);
                            
                            return AnimatedBuilder(
                              animation: _sparkleAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(x, y),
                                  child: Opacity(
                                    opacity: _sparkleAnimation.value,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC9A227),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFFC9A227).withOpacity(0.8),
                                            blurRadius: 4,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ],
                      ),
                      
                      const SizedBox(height: AppSpace.x6),
                      
                      // Congratulations text
                      Text(
                        'Congratulations!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFFC9A227),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: AppSpace.x4),
                      
                      // Main scripture
                      Container(
                        padding: const EdgeInsets.all(AppSpace.x4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFC9A227).withOpacity(0.1),
                              const Color(0xFFC9A227).withOpacity(0.05),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFFC9A227).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '"The fear of the Lord is the beginning of wisdom"',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                                height: 1.4,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            
                            const SizedBox(height: AppSpace.x3),
                            
                            Text(
                              '— Proverbs 9:10',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: const Color(0xFFC9A227),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpace.x4),
                      
                      // Description text
                      Text(
                        'You\'ve taken the first step on a journey of spiritual growth and wisdom. Your faith-based content is now active throughout the app.',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white.withOpacity(0.8),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              
              const Spacer(),
              
              // Continue button
              FadeTransition(
                opacity: _fadeAnimation,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFC9A227),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpace.x4,
                        horizontal: AppSpace.x6,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 8,
                      shadowColor: const Color(0xFFC9A227).withOpacity(0.3),
                    ),
                    child: Text(
                      'Continue to App',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: AppSpace.x4),
            ],
          ),
        ),
      ),
    );
  }
}

