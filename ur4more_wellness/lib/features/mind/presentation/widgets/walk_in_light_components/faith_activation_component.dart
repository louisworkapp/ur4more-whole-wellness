import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/app_export.dart';
import '../../../../../core/settings/settings_scope.dart';
import '../../../../../core/settings/settings_model.dart';
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

class FaithActivationComponent extends StatelessWidget {
  final VoidCallback onActivated;

  const FaithActivationComponent({
    super.key,
    required this.onActivated,
  });

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

            // Title
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
              'Faith Activation Required',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Message container
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
                    'Faith Activation Required',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Walk in the Light is a spiritual wellness routine that requires faith activation to access. This sacred practice combines mindful breathing with scripture reflection and gratitude to help you seek wisdom through faith in Jesus Christ.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  Text(
                    'Activating faith mode will enable spiritual content throughout the app, including this powerful 5-minute journey to deeper truths.',
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

            // Activation message
            Text(
              'Activate faith mode to begin your spiritual journey.',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Colors.blue.shade700,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 40),

            // Activate button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () async {
                  HapticFeedback.lightImpact();
                  await _activateFaithMode(context);
                  onActivated();
                },
                icon: Icon(
                  Icons.auto_awesome,
                  size: 24,
                ),
                label: Text(
                  'Activate Faith Mode',
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

            const SizedBox(height: 16),

            // Settings button
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.settings);
              },
              child: Text(
                'Go to Settings',
                style: TextStyle(
                  color: Colors.blue.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _activateFaithMode(BuildContext context) async {
    try {
      final settingsCtl = SettingsScope.of(context);
      await settingsCtl.updateFaith(FaithTier.light);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Faith Mode: Light activated! Welcome to Walk in the Light.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error activating faith mode: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}