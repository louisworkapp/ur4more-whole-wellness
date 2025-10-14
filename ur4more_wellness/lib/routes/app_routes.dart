import 'package:flutter/material.dart';
import '../presentation/mind_wellness_screen/mind_wellness_screen.dart';
import '../presentation/daily_check_in_screen/daily_check_in_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/home_dashboard/home_dashboard.dart';
import '../presentation/settings_profile_screen/settings_profile_screen.dart';
import '../presentation/body_fitness_screen/body_fitness_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/spiritual_growth_screen/spiritual_growth_screen.dart';
import '../presentation/rewards_marketplace_screen/rewards_marketplace_screen.dart';
import '../presentation/main_scaffold/main_scaffold.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String main = '/'; // host with bottom nav
  static const String checkin = '/check-in';
  static const String settings = '/settings';
  static const String authentication = '/authentication-screen';

  // Legacy routes for direct navigation
  static const String mindWellness = '/mind-wellness-screen';
  static const String dailyCheckIn = '/daily-check-in-screen';
  static const String homeDashboard = '/home-dashboard';
  static const String settingsProfile = '/settings-profile-screen';
  static const String bodyFitness = '/body-fitness-screen';
  static const String spiritualGrowth = '/spiritual-growth-screen';
  static const String rewardsMarketplace = '/rewards-marketplace-screen';

  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    main: (context) => const MainScaffold(),
    checkin: (context) => const DailyCheckInScreen(),
    settings: (context) => const SettingsProfileScreen(),
    authentication: (context) => const AuthenticationScreen(),

    // Legacy routes for direct access
    mindWellness: (context) => const MindWellnessScreen(),
    dailyCheckIn: (context) => const DailyCheckInScreen(),
    homeDashboard: (context) => const HomeDashboard(),
    settingsProfile: (context) => const SettingsProfileScreen(),
    bodyFitness: (context) => const BodyFitnessScreen(),
    spiritualGrowth: (context) => const SpiritualGrowthScreen(),
    rewardsMarketplace: (context) => const RewardsMarketplaceScreen(),
  };
}
