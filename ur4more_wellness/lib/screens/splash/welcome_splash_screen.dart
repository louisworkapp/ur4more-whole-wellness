import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design/tokens.dart';
import '../../routes/app_routes.dart';
import '../../theme/brand_tokens.dart';

class WelcomeSplashScreen extends StatelessWidget {
  const WelcomeSplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Full-screen background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/splash_phone_card2.png',
              fit: BoxFit.cover,
            ),
          ),

          // Subtle bottom scrim for text/button readability
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    Colors.black.withOpacity(0.6),
                  ],
                ),
              ),
            ),
          ),

          // Entry CTAs - pinned to bottom
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpace.x5,
                  0,
                  AppSpace.x5,
                  AppSpace.x12,
                ),
                child: Semantics(
                  button: true,
                  label: 'Start Stand Firm or explore the app',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.standFirm,
                              (route) => false,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.x8,
                              vertical: AppSpace.x4,
                            ),
                            minimumSize: const Size(double.infinity, 52),
                            shape: const StadiumBorder(),
                            backgroundColor: Brand.primary,
                            foregroundColor: Colors.white,
                            elevation: 4,
                            shadowColor: Brand.primary.withOpacity(0.5),
                          ),
                          child: Text(
                            'Start Stand Firm (60 sec)',
                            style: t.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpace.x2),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              AppRoutes.main,
                              (route) => false,
                            );
                          },
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpace.x8,
                              vertical: AppSpace.x4,
                            ),
                            minimumSize: const Size(double.infinity, 52),
                            shape: const StadiumBorder(),
                            side: BorderSide(color: Colors.white.withOpacity(0.6)),
                            foregroundColor: Colors.white,
                          ),
                          child: Text(
                            'Explore the full app',
                            style: t.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.main,
                            (route) => false,
                          );
                        },
                        child: Text(
                          'Skip for now',
                          style: t.bodyMedium?.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w600,
                          ),
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
    );
  }
}

