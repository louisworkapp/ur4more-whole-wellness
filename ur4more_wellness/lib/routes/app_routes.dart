import 'package:flutter/material.dart';
import '../presentation/daily_check_in_screen/daily_check_in_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/settings_profile_screen/settings_profile_screen.dart';
import '../presentation/authentication_screen/authentication_screen.dart';
import '../presentation/main_scaffold/main_scaffold.dart';
import '../screens/home_screen.dart';
import '../features/courses/presentation/courses_screen.dart';
import '../features/courses/presentation/course_detail_screen.dart';
import '../features/courses/presentation/week_lesson_screen.dart';
import '../presentation/discipleship_courses_screen/discipleship_courses_screen.dart';
import '../features/breath/presentation/breath_presets_screen.dart';
import '../presentation/safety_monitoring_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String main = '/'; // host with bottom nav
  static const String checkin = '/check-in';
  static const String settings = '/settings';
  static const String authentication = '/authentication-screen';
  static const String home = '/home';
  static const String courses = '/courses';
  static const String courseDetail = '/courses/detail';
  static const String weekLesson = '/courses/week';
  static const String discipleshipCourses = '/discipleship-courses';
  static const String breathPresets = '/breath-presets';
  static const String safetyMonitoring = '/safety-monitoring';
  
  // Special course IDs
  static const String ur4moreCoreId = 'ur4more_core_12w';


  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    main: (context) => const MainScaffold(),
    checkin: (context) => const DailyCheckInScreen(),
    settings: (context) => const SettingsProfileScreen(),
    authentication: (context) => const AuthenticationScreen(),
    home: (context) => const HomeScreen(),
    courses: (context) => const CoursesScreen(),
    courseDetail: (context) => const CourseDetailScreen(),
    weekLesson: (context) => const WeekLessonScreen(),
    discipleshipCourses: (context) => const DiscipleshipCoursesScreen(),
    breathPresets: (context) => const BreathPresetsScreen(),
    safetyMonitoring: (context) => const SafetyMonitoringScreen(),
  };
}
