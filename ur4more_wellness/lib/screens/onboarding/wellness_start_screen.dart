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
          // Background image - scaled down to show full width
          Center(
            child: FractionallySizedBox(
              widthFactor: 0.85,
              heightFactor: 0.85,
              child: Image.asset(
                'assets/images/wellness_journey_start_card.png',
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Subtle dark overlay for text/button contrast
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

          // Hero text and button
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: AppSpace.x10),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Hero text
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpace.x6),
                      child: Text(
                        'Build strength, clarity, and faith—daily.',
                        style: t.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Get started button
                    Semantics(
                      button: true,
                      label: 'Get started',
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
                          'Get started',
                          style: t.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

