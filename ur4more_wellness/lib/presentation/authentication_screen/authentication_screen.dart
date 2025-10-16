import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../design/tokens.dart';
import '../../widgets/brand_logo.dart';
import '../../routes/app_routes.dart';

class AuthenticationScreen extends StatelessWidget {
  const AuthenticationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(AppSpace.x6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Brand section
                  Column(
                    children: [
                      // Logo
                      const BrandLogo(size: 80),
                      const SizedBox(height: AppSpace.x3),
                      Text(
                        'UR4MORE', 
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ), 
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpace.x4),
                      Text(
                        'Made for more.', 
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ), 
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: AppSpace.x6),

                  // Primary action (Continue)
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Semantics(
                      button: true,
                      label: 'Continue to Home',
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 120),
                        curve: Curves.easeOut,
                        scale: 1.0,
                        child: ElevatedButton(
                          onPressed: () {
                            // Use your router if present; else fallback to Navigator.
                            // context.go('/home');
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.main,
                            );
                          },
                          child: Text(
                            'Continue',
                            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
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
        ),
      ),

      // Hide any floating overlays on web (they're causing the right-side boxes).
      floatingActionButton: kIsWeb ? null : null,
    );
  }
}