import 'package:flutter/material.dart';
import '../presentation/daily_check_in_screen/daily_check_in_screen.dart';
import '../features/splash/splash_screen.dart';
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
import '../presentation/faith_congratulations_screen/faith_congratulations_screen.dart';
import '../presentation/discipleship_welcome_screen/discipleship_welcome_screen.dart';
import '../presentation/alarm_clock_screen/alarm_clock_screen.dart';
import '../presentation/morning_checkin_screen/morning_checkin_screen.dart';
import '../features/planner/presentation/morning_checkin_screen.dart';
import '../features/planner/presentation/planner_screen.dart';
import '../features/planner/presentation/daily_calendar_screen.dart';
import '../features/planner/presentation/suggestions_screen.dart';
import '../features/planner/presentation/calendar_screen.dart';
import '../features/planner/presentation/commit_screen.dart';
import '../screens/onboarding/wellness_start_screen.dart';
import '../screens/splash/welcome_splash_screen.dart';
import '../presentation/debug/debug_points_screen.dart';
import '../presentation/stand_firm_screen.dart';
import '../presentation/stand_firm_complete_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String welcomeSplash = '/welcome-splash';
  static const String wellnessStart = '/wellness-start';
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
  static const String faithCongratulations = '/faith-congratulations';
  static const String discipleshipWelcome = '/discipleship-welcome';
  static const String alarmClock = '/alarm-clock';
  static const String morningCheckin = '/morning-checkin';
  static const String plannerMorningCheckin = '/planner/morning-checkin';
  static const String planner = '/planner';
  static const String dailyCalendar = '/daily-calendar';
  static const String plannerSuggestions = '/planner/suggestions';
  static const String plannerCalendar = '/planner/calendar';
  static const String plannerCommit = '/planner/commit';
  static const String debugPoints = '/debug/points';
  static const String standFirm = '/stand-firm';
  static const String standFirmComplete = '/stand-firm/complete';
  
  // Special course IDs
  static const String ur4moreCoreId = 'ur4more_core_12w';


  static Map<String, WidgetBuilder> routes = {
    splash: (context) => const SplashScreen(),
    welcomeSplash: (context) => const WelcomeSplashScreen(),
    wellnessStart: (context) => const WellnessStartScreen(),
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
    faithCongratulations: (context) => const FaithCongratulationsScreen(),
    discipleshipWelcome: (context) => const DiscipleshipWelcomeScreen(),
    alarmClock: (context) => const AlarmClockScreen(),
    morningCheckin: (context) => const MorningCheckinScreen(),
    plannerMorningCheckin: (context) => const MorningCheckInScreen(),
    planner: (context) => const PlannerScreen(),
    dailyCalendar: (context) => DailyCalendarScreen(selectedDate: DateTime.now()),
    plannerSuggestions: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return SuggestionsScreen(
        suggestions: args?['suggestions'] ?? [],
        focusMind: args?['focusMind'] ?? false,
        focusBody: args?['focusBody'] ?? false,
        focusSpirit: args?['focusSpirit'] ?? false,
        faithActivated: args?['faithActivated'] ?? false,
        showFaithOverlay: args?['showFaithOverlay'] ?? false,
        morningAlarmTime: args?['morningAlarmTime'] ?? const TimeOfDay(hour: 7, minute: 0),
        pmCheckinTime: args?['pmCheckinTime'] ?? const TimeOfDay(hour: 20, minute: 0),
        morningAlarmEnabled: args?['morningAlarmEnabled'] ?? true,
        pmCheckinAlarmEnabled: args?['pmCheckinAlarmEnabled'] ?? true,
      );
    },
    plannerCalendar: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return CalendarScreen(
        suggestions: args?['suggestions'] ?? [],
        morningAlarmTime: args?['morningAlarmTime'] ?? const TimeOfDay(hour: 7, minute: 0),
        pmCheckinTime: args?['pmCheckinTime'] ?? const TimeOfDay(hour: 20, minute: 0),
        morningAlarmEnabled: args?['morningAlarmEnabled'] ?? true,
        pmCheckinAlarmEnabled: args?['pmCheckinAlarmEnabled'] ?? true,
      );
    },
    plannerCommit: (context) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      return CommitScreen(
        plan: args?['plan'] ?? [],
        morningAlarmTime: args?['morningAlarmTime'] ?? const TimeOfDay(hour: 7, minute: 0),
        pmCheckinTime: args?['pmCheckinTime'] ?? const TimeOfDay(hour: 20, minute: 0),
        morningAlarmEnabled: args?['morningAlarmEnabled'] ?? true,
        pmCheckinAlarmEnabled: args?['pmCheckinAlarmEnabled'] ?? true,
      );
    },
    debugPoints: (context) => const DebugPointsScreen(),
    standFirm: (context) => const StandFirmScreen(),
    standFirmComplete: (context) => const StandFirmCompleteScreen(),
  };
}
