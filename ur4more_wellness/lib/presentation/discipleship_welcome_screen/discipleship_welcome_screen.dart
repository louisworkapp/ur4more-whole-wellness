import 'package:flutter/material.dart';
import 'dart:math';
import '../../theme/tokens.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/discipleship_background.dart';

class DiscipleshipWelcomeScreen extends StatefulWidget {
  const DiscipleshipWelcomeScreen({super.key});

  @override
  State<DiscipleshipWelcomeScreen> createState() => _DiscipleshipWelcomeScreenState();
}

class _DiscipleshipWelcomeScreenState extends State<DiscipleshipWelcomeScreen>
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
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
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
      curve: Curves.linear,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
    _sparkleController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Custom background gradient
          const DiscipleshipBackground(),
          
          // Content overlay
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top section with fish logo in center
                  Container(
                    height: 200,
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: T.gold.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: T.gold.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: T.gold.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Image.asset(
                                'assets/images/fish_logo.png',
                                color: T.gold,
                                colorBlendMode: BlendMode.modulate,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Content section with proper spacing
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        // Welcome message positioned to work with the design
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                'Follow Me',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 12),
                              
                              Text(
                                'Begin your journey of learning Jesus, living His word, and leading others.',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: T.gold,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 16),
                              
                              // Scripture card with enhanced styling for background
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: T.gold.withOpacity(0.5),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '"And he saith unto them, Follow me, and I will make you fishers of men."',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.white,
                                        fontStyle: FontStyle.italic,
                                        height: 1.5,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    Text(
                                      'Matthew 4:19 (KJV)',
                                      style: theme.textTheme.titleMedium?.copyWith(
                                        color: T.gold,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 20),
                              
                              // Course overview with enhanced styling
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: T.gold.withOpacity(0.4),
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        const CustomIconWidget(
                                          iconName: 'school',
                                          color: T.gold,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            '12-Week Core Discipleship',
                                            style: theme.textTheme.titleMedium?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    Text(
                                      'A comprehensive journey through the foundations of Christian faith, designed to deepen your relationship with God and equip you for spiritual growth.',
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                        height: 1.4,
                                      ),
                                    ),
                                    
                                    const SizedBox(height: 12),
                                    
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFeatureItem(
                                            'Foundation',
                                            'Biblical basics',
                                            'book',
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildFeatureItem(
                                            'Growth',
                                            'Spiritual development',
                                            'trending_up',
                                          ),
                                        ),
                                      ],
                                    ),
                                    
                                    const SizedBox(height: 8),
                                    
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildFeatureItem(
                                            'Community',
                                            'Fellowship & support',
                                            'group',
                                          ),
                                        ),
                                        Expanded(
                                          child: _buildFeatureItem(
                                            'Mission',
                                            'Serving others',
                                            'volunteer_activism',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              const SizedBox(height: 24),
                              
                              // Continue button with enhanced styling
                              Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: T.gold,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: T.gold.withOpacity(0.4),
                                      blurRadius: 15,
                                      offset: const Offset(0, 6),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      Navigator.of(context).pushReplacementNamed('/courses/detail');
                                    },
                                    child: Center(
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const CustomIconWidget(
                                            iconName: 'play_arrow',
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          const SizedBox(width: 12),
                                          Text(
                                            'Follow Me',
                                            style: theme.textTheme.titleLarge?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Waves footer at bottom of scroll
                  Container(
                    height: 120,
                    width: double.infinity,
                    child: Center(
                      child: Image.asset(
                        'assets/images/waves_logo.png',
                        width: 300,
                        height: 80,
                        color: T.gold.withOpacity(0.3),
                        colorBlendMode: BlendMode.modulate,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String title, String subtitle, String iconName) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: T.gold.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: iconName,
            color: T.gold,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}