import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/tokens.dart';
import '../../routes/app_routes.dart';
import '../../theme/brand_tokens.dart';

class WellnessJourneyStartScreen extends StatelessWidget {
  const WellnessJourneyStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen background image
          Image.asset(
            'assets/images/wellness_journey_start_card.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Dark gradient scrim from mid to bottom for button contrast
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.center,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Color.fromARGB(100, 0, 0, 0),
                  Color.fromARGB(180, 0, 0, 0),
                ],
                stops: [0.4, 0.7, 1.0],
              ),
            ),
          ),

          // Overlay UI
          SafeArea(
            child: Column(
              children: [
                // Optional Sign in button (top-right)
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpace.x4),
                    child: TextButton(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.authentication);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white.withOpacity(0.9),
                      ),
                      child: const Text('Sign in'),
                    ),
                  ),
                ),

                const Spacer(),

                // Hero CTA button centered near bottom
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpace.x10),
                  child: _ContinueButton(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.main,
                        (route) => false,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ContinueButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ContinueButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Semantics(
      button: true,
      label: 'Continue to app',
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 52),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.x8,
            vertical: AppSpace.x4,
          ),
          shape: const StadiumBorder(),
          backgroundColor: Brand.primary,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Brand.primary.withOpacity(0.5),
        ),
        child: Text(
          'Continue',
          style: t.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

