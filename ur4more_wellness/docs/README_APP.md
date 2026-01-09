# UR4MORE App Guide

## A) One-line Pitch
UR4MORE is a Christ-centered whole-wellness coach that unites Body, Mind, Spirit, and Discipleship into one daily journey.

## B) Brand Vision / Mission
- **Mission:** Help people pursue holistic health anchored in biblical truth, building strength, clarity, and faithfulness.
- **Problem:** Fragmented wellness tools ignore spiritual formation; UR4MORE integrates workouts, mindset, and faith practices.
- **Who:** Believers and seekers who want practical guidance for body fitness, mental resilience, and spiritual growth.
- **Tone:** Truth-centered, Christ-centered, encouraging—never political or inflammatory.

## C) Core Pillars
- **Body:** Guided workouts, progress tracking, and equipment-aware plans (resistance bands, pull-up bar, bodyweight).
- **Mind:** Mind coach screens for reflection, coping, and mental resilience.
- **Spirit:** Spiritual growth flows (devotions/prayer) and discipleship pathways.
- **Discipleship:** Courses and welcome/discipleship screens for faith formation and follow-up.
- **Planned – Stand Firm / Spiritual Warfare Field Guide:** A resilience module framed around the Armor of God and biblical grounding (non-mystical).

## D) Monetization + Store
- **In-app products (planned/partially described):** resistance band sets, pull-up bars, workout gear, apparel (t-shirts, hoodies), digital products (courses, guides).
- **Rewards / Marketplace screen:** Present in main navigation; current code shows marketplace UI, but transactions are not wired to a backend (considered Planned for commerce).
- **Subscriptions:** Future tiers (Planned) could gate premium courses, advanced programs, or coaching.

## E) Feature Inventory
**Implemented (per repo today)**
- Bottom navigation with five tabs: Home, Body Fitness, Mind Coach, Spiritual Growth, Rewards/Store (`lib/presentation/main_scaffold/main_scaffold.dart`).
- Home dashboard (`lib/presentation/home_dashboard/home_dashboard.dart`): points hero, daily check-in CTA, inspiration, wellness cards.
- Body Fitness (`lib/presentation/body_fitness_screen/body_fitness_screen.dart`): workout list, equipment filters, workout timer overlay, points award on completion.
- Mind Coach (`lib/features/mind/presentation/mind_coach_screen.dart`): mind wellness content.
- Spiritual Growth (`lib/presentation/spiritual_growth_screen/spiritual_growth_screen.dart`): faith/spirit content.
- Rewards / Marketplace (`lib/presentation/rewards_marketplace_screen/rewards_marketplace_screen.dart`).
- Check-in flow (`lib/presentation/daily_check_in_screen/daily_check_in_screen.dart`) and alarm/clock (`lib/presentation/alarm_clock_screen/alarm_clock_screen.dart`).
- Discipleship courses (`lib/presentation/discipleship_courses_screen/discipleship_courses_screen.dart`) and welcome (`lib/presentation/discipleship_welcome_screen/discipleship_welcome_screen.dart`).
- Routing via `lib/routes/app_routes.dart`.

**Planned / Not yet implemented or partially stubbed**
- Commerce back-end for store purchases and apparel.
- Subscription tiers for premium courses/programs.
- Stand Firm / Spiritual Warfare Field Guide module.
- Formal debug access routes (debug screens exist in codebase but not exposed to users).

## F) Sitemap
- **Public / Onboarding**
  - Splash / Welcome: `lib/features/splash/splash_screen.dart` (AppRoutes.splash), `lib/screens/splash/welcome_splash_screen.dart` (AppRoutes.welcomeSplash)
  - Auth: `lib/presentation/authentication_screen/authentication_screen.dart` (AppRoutes.authentication)
  - Wellness Start: `lib/screens/onboarding/wellness_start_screen.dart` (AppRoutes.wellnessStart)
- **Main App (Bottom Navigation)** — `lib/presentation/main_scaffold/main_scaffold.dart`
  - Home Dashboard: `lib/presentation/home_dashboard/home_dashboard.dart` (via AppRoutes.main → `MainScaffold`, tab index 0). Actions: view points hero, daily check-in CTA, inspiration, wellness cards, (dev) long-press header to debug in some builds.
  - Body Fitness: `lib/presentation/body_fitness_screen/body_fitness_screen.dart` (tab index 1). Actions: browse workouts, start workout, timer overlay, award points on completion.
  - Mind Wellness: `lib/features/mind/presentation/mind_coach_screen.dart` (tab index 2). Actions: mind coaching content.
  - Spirit / Faith: `lib/presentation/spiritual_growth_screen/spiritual_growth_screen.dart` (tab index 3). Actions: spiritual growth content.
  - Rewards / Store: `lib/presentation/rewards_marketplace_screen/rewards_marketplace_screen.dart` (tab index 4). Actions: browse rewards/marketplace (commerce backend planned).
  - Settings: `lib/presentation/settings_profile_screen/settings_profile_screen.dart` (AppRoutes.settings; accessible from profile links, not in bottom nav). Actions: profile, notifications, theme, privacy, faith mode, etc.
- **Secondary Screens**
  - Daily Check-in: `lib/presentation/daily_check_in_screen/daily_check_in_screen.dart` (AppRoutes.checkin). Actions: daily check flow.
  - Alarm Clock: `lib/presentation/alarm_clock_screen/alarm_clock_screen.dart` (AppRoutes.alarmClock). Actions: planner/alarm settings.
  - Discipleship Courses: `lib/presentation/discipleship_courses_screen/discipleship_courses_screen.dart` (AppRoutes.discipleshipCourses). Actions: view courses.
  - Discipleship Welcome: `lib/presentation/discipleship_welcome_screen/discipleship_welcome_screen.dart` (AppRoutes.discipleshipWelcome). Actions: onboarding to discipleship.
  - Course Detail / Week Lesson: `lib/features/courses/presentation/course_detail_screen.dart` (AppRoutes.courseDetail); `lib/features/courses/presentation/week_lesson_screen.dart` (AppRoutes.weekLesson). Actions: view course/lesson content.
  - Breath Presets: `lib/features/breath/presentation/breath_presets_screen.dart` (AppRoutes.breathPresets).
  - Safety Monitoring: `lib/presentation/safety_monitoring_screen.dart` (AppRoutes.safetyMonitoring).
  - Faith Congratulations: `lib/presentation/faith_congratulations_screen/faith_congratulations_screen.dart` (AppRoutes.faithCongratulations).
  - Planner / Calendar / Suggestions / Commit: `lib/features/planner/presentation/*.dart` (AppRoutes.planner, plannerCalendar, plannerSuggestions, plannerCommit, plannerMorningCheckin).
  - Rewards Marketplace: also reachable via bottom nav (no explicit route constant).
  - Workout overlay / timer: `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` (invoked from BodyFitnessScreen; no route).
  - Debug tools: `lib/presentation/debug/debug_points_screen.dart` exists; no public route in main. Treat as debug-only (internal).
- **Planned Screens (not present)**
  - Stand Firm / Spiritual Warfare Field Guide (planned module). Suggested route: `/stand-firm` (AppRoutes.standFirm – planned), suggested path: `lib/presentation/stand_firm/stand_firm_screen.dart`.
  - Commerce checkout (planned). Suggested route: `/store/checkout`, path: `lib/presentation/store/checkout_screen.dart`.

## G) Navigation + Routes Map
Routes are defined in `lib/routes/app_routes.dart`. Current constants:
- splash `/splash`
- welcomeSplash `/welcome-splash`
- wellnessStart `/wellness-start`
- main `/`
- checkin `/check-in`
- settings `/settings`
- authentication `/authentication-screen`
- home `/home`
- courses `/courses`
- courseDetail `/courses/detail`
- weekLesson `/courses/week`
- discipleshipCourses `/discipleship-courses`
- breathPresets `/breath-presets`
- safetyMonitoring `/safety-monitoring`
- faithCongratulations `/faith-congratulations`
- discipleshipWelcome `/discipleship-welcome`
- alarmClock `/alarm-clock`
- morningCheckin `/morning-checkin`
- plannerMorningCheckin `/planner/morning-checkin`
- planner `/planner`
- dailyCalendar `/daily-calendar`
- plannerSuggestions `/planner/suggestions`
- plannerCalendar `/planner/calendar`
- plannerCommit `/planner/commit`

Main navigation is an IndexedStack inside `MainScaffold`, with tab order: Home, Body, Mind, Spirit, Rewards.

## H) Developer Notes
- **State management:** Points stored in `lib/core/state/points_store.dart` (ChangeNotifier singleton). PointsService in `lib/core/services/points_service.dart` handles award logging and fallback persistence via SharedPreferences.
- **Themes/tokens:** Design tokens under `lib/design/tokens.dart`; theme definitions under `lib/theme/*`.
- **Assets:** Located under `/assets`; register in `pubspec.yaml` under `flutter/assets`.
- **Adding a new module screen (checklist):**
  1. Create screen in `lib/presentation/<module>/<module>_screen.dart`.
  2. Add route constant + entry in `lib/routes/app_routes.dart`.
  3. Wire navigation (from buttons or tabs) in relevant screen or scaffold.
  4. If it needs bottom-nav exposure, add to `MainScaffold` `_pages` and NavigationBar destinations.
  5. If it needs persistence/state, add ChangeNotifier/Service under `lib/core` and follow existing patterns (SharedPreferences where applicable).
  6. Add any assets and update `pubspec.yaml`.

### Notes on terminology
- Keep language Christ-centered and practical (avoid mystical terms).
- Use existing pillars: Body, Mind, Spirit, Discipleship. Mark new modules as “Planned” until implemented.
