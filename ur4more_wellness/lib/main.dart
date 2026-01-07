import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../core/app_export.dart';
import '../widgets/custom_error_widget.dart';
import 'design/tokens.dart';
import 'core/settings/settings_controller.dart';
import 'core/settings/settings_service.dart';
import 'core/settings/settings_scope.dart';
import 'core/settings/settings_model.dart';
import 'theme/dark_theme.dart';
import 'theme/light_theme.dart';
import 'theme/app_theme.dart';
import 'services/gateway_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Create and hydrate settings controller
  final controller = SettingsController(SettingsService());
  await controller.hydrate();

  // Perform startup health probe (non-blocking)
  GatewayService.performStartupHealthProbe().catchError((e) {
    // Fail gracefully - app will use demo mode
    debugPrint('Startup health probe failed: $e');
  });

  bool _hasShownError = false;

  // 🚨 CRITICAL: Custom error handling - DO NOT REMOVE
  ErrorWidget.builder = (FlutterErrorDetails details) {
    if (!_hasShownError) {
      _hasShownError = true;

      // Reset flag after 3 seconds to allow error widget on new screens
      Future.delayed(Duration(seconds: 5), () {
        _hasShownError = false;
      });

      return CustomErrorWidget(
        errorDetails: details,
      );
    }
    return SizedBox.shrink();
  };

  // 🚨 CRITICAL: Device orientation lock - DO NOT REMOVE
  Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp])
  ]).then((value) {
    runApp(MyApp(controller: controller));
  });
}

class MyApp extends StatelessWidget {
  final SettingsController controller;
  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, screenType) {
      return SettingsScope(
        controller: controller,
        child: Builder(
          builder: (context) {
            final settings = SettingsScope.of(context);
            final themeMode = _getThemeMode(settings.value.themeMode);
            return MaterialApp(
              title: 'UR4MORE',
              theme: buildLightTheme(),
              darkTheme: darkFrameTheme(context),
              themeMode: themeMode,
              // Use hash routing for GitHub Pages compatibility
              useInheritedMediaQuery: true,
              // 🚨 CRITICAL: NEVER REMOVE OR MODIFY
        builder: (context, child) {
          // Normalize desktop/web layout with centered content and max width
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(textScaler: const TextScaler.linear(1.0)),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppMaxW.phone),
                child: Padding(
                  padding: Pad.page,
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          );
        },
        // 🚨 END CRITICAL SECTION
        debugShowCheckedModeBanner: false,
        routes: AppRoutes.routes,
        initialRoute: AppRoutes.welcomeSplash,
            );
          },
        ),
      );
    });
  }

  ThemeMode _getThemeMode(AppThemeMode appThemeMode) {
    switch (appThemeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}