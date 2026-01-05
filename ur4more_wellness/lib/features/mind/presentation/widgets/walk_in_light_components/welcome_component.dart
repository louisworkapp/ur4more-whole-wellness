import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/app_export.dart';
import '../../../../../design/tokens.dart';
import '../../../../../services/faith_service.dart';

class MeditativeFigurePainter extends CustomPainter {
  final Color color;

  MeditativeFigurePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 2.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // Draw the simple meditative figure in cross-legged position
    final path = Path();

    // Head (small circle)
    final headRadius = size.width * 0.12;
    canvas.drawCircle(
      Offset(centerX, centerY - size.height * 0.25),
      headRadius,
      paint,
    );

    // Body (torso) - upright
    final bodyTop = centerY - size.height * 0.1;
    final bodyBottom = centerY + size.height * 0.15;
    final bodyWidth = size.width * 0.15;

    // Torso rectangle
    final torsoRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX, (bodyTop + bodyBottom) / 2),
        width: bodyWidth,
        height: bodyBottom - bodyTop,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(torsoRect, paint);

    // Arms bent at elbows, hands resting on knees
    final armY = bodyTop + (bodyBottom - bodyTop) * 0.3;
    final armLength = size.width * 0.2;
    
    // Left arm (bent, hand on knee)
    path.moveTo(centerX - bodyWidth / 2, armY);
    path.lineTo(centerX - bodyWidth / 2 - armLength * 0.3, armY + armLength * 0.2);
    path.lineTo(centerX - bodyWidth / 2 - armLength * 0.6, armY + armLength * 0.4);
    path.lineTo(centerX - bodyWidth / 2 - armLength * 0.4, armY + armLength * 0.6);
    path.lineTo(centerX - bodyWidth / 2 - armLength * 0.2, armY + armLength * 0.3);
    path.close();

    // Right arm (bent, hand on knee)
    path.moveTo(centerX + bodyWidth / 2, armY);
    path.lineTo(centerX + bodyWidth / 2 + armLength * 0.3, armY + armLength * 0.2);
    path.lineTo(centerX + bodyWidth / 2 + armLength * 0.6, armY + armLength * 0.4);
    path.lineTo(centerX + bodyWidth / 2 + armLength * 0.4, armY + armLength * 0.6);
    path.lineTo(centerX + bodyWidth / 2 + armLength * 0.2, armY + armLength * 0.3);
    path.close();

    canvas.drawPath(path, paint);

    // Legs in cross-legged position
    final legY = bodyBottom;
    final legLength = size.width * 0.25;
    final legWidth = size.width * 0.08;

    // Left leg (crossed, closer to viewer)
    final leftLegRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX - bodyWidth * 0.2, legY + legLength * 0.2),
        width: legWidth,
        height: legLength * 0.8,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(leftLegRect, paint);

    // Right leg (crossed, further from viewer)
    final rightLegRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(centerX + bodyWidth * 0.1, legY + legLength * 0.3),
        width: legWidth,
        height: legLength * 0.7,
      ),
      const Radius.circular(3),
    );
    canvas.drawRRect(rightLegRect, paint);

    // Feet (tucked in)
    final footRadius = size.width * 0.06;
    canvas.drawCircle(
      Offset(centerX - bodyWidth * 0.2, legY + legLength * 0.8),
      footRadius,
      paint,
    );
    canvas.drawCircle(
      Offset(centerX + bodyWidth * 0.1, legY + legLength * 0.9),
      footRadius,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WelcomeComponent extends StatefulWidget {
  final FaithTier faithMode;
  final VoidCallback onContinue;

  const WelcomeComponent({
    super.key,
    required this.faithMode,
    required this.onContinue,
  });

  @override
  State<WelcomeComponent> createState() => _WelcomeComponentState();
}

class _WelcomeComponentState extends State<WelcomeComponent>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
  }

  void _startAnimations() {
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 64, // Account for padding
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated welcome content
            AnimatedBuilder(
              animation: Listenable.merge([_fadeAnimation, _scaleAnimation]),
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        // Light icon with glow effect
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue.withOpacity(0.2),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.lightbulb,
                            size: 60,
                            color: Colors.blue.shade600,
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Welcome title
                        Text(
                          'Walk in the Light',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.blue.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // Subtitle
                        Text(
                          'A 5-Minute Journey to Deeper Truths',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // Welcome message
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.blue.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                'Welcome, Seeker of Truth',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.blue.shade800,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 16),

                              Text(
                                'As you begin this sacred practice, remember that walking in the light means seeking wisdom that can only be received through faith in Jesus Christ. This journey is about becoming more—more aligned with His truth, more filled with His power, and more transformed by the understanding of His Word.',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  height: 1.6,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 16),

                              Text(
                                'Through this practice, you will breathe in His presence, reflect on His truth, and open your heart to receive the power and understanding that comes only from God\'s Word. Let His light transform you from within.',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                  color: colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 20),
                              
                                  // Scripture verse
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.blue.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          '"I am the light of the world. Whoever follows me will never walk in darkness, but will have the light of life."',
                                          style: theme.textTheme.bodyLarge?.copyWith(
                                            fontStyle: FontStyle.italic,
                                            color: Colors.white,
                                            height: 1.5,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          '— John 8:12',
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade300,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // Encouragement message
                        Text(
                          'Forge ahead with faith, and let His light guide your journey to becoming more through the power and understanding of His Word.',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 40),

                        // Continue button
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              widget.onContinue();
                            },
                            icon: Icon(
                              Icons.light_mode,
                              size: 24,
                            ),
                            label: Text(
                              'Begin in His Light',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.blue.shade600,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}