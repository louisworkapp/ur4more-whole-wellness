import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/tokens.dart';
import '../../routes/app_routes.dart';
import '../../theme/brand_tokens.dart';

class WellnessStartScreen extends StatelessWidget {
  const WellnessStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/images/wellness_journey_start_card.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),

          // Subtle dark overlay for button contrast
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
                stops: [0.5, 0.8, 1.0],
              ),
            ),
          ),

          // Build button
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.x10),
                child: Semantics(
                  button: true,
                  label: 'Build',
                  child: ElevatedButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        AppRoutes.main,
                        (route) => false,
                      );
                    },
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
                      'Build',
                      style: t.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

