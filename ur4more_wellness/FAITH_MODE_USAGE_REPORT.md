# FaithMode vs FaithTier Usage Report

## Summary
- **Correct Enum:** `FaithTier` (defined in `lib/core/settings/settings_model.dart`)
- **Wrong Enum:** `FaithMode` (defined in `lib/core/services/settings_service.dart`)

## Files Using Wrong Enum (`FaithMode`)

### Core Files (Definition/Service)
1. **`lib/core/services/settings_service.dart`** ⚠️ **DEFINES `FaithMode`** - Should be removed/replaced
   - Defines `enum FaithMode` (lines 4-9)
   - Uses `FaithMode` throughout the class

### Files Importing/Using `FaithMode`

#### Core & Services
2. **`lib/core/brand_rules.dart`**
   - Imports `FaithMode` from `settings_service.dart`
   - Uses `FaithMode` in conversion functions

3. **`lib/services/ai_suggestion_service.dart`**
   - Uses `FaithMode`

4. **`lib/core/app_export.dart`**
   - Exports `FaithMode`

#### Widgets
5. **`lib/widgets/verse_reveal_chip.dart`**
   - Uses `FaithMode.light`

6. **`lib/widgets/home_truth_callout.dart`**
   - Uses `FaithMode`

#### Presentation Layer
7. **`lib/presentation/daily_check_in_screen/daily_check_in_screen.dart`**
   - Uses `FaithMode` (multiple references)

8. **`lib/presentation/settings_profile_screen/widgets/faith_mode_section_widget.dart`**
   - Uses `FaithMode` (multiple references)

9. **`lib/presentation/settings_profile_screen/settings_profile_screen.dart`**
   - Uses `FaithMode` (multiple references, switch cases)

10. **`lib/presentation/safety_monitoring_screen.dart`**
    - Uses `FaithMode.values` and `FaithMode`

11. **`lib/presentation/daily_check_in_screen/widgets/urge_intensity_widget.dart`**
    - Uses `FaithMode`

12. **`lib/presentation/daily_check_in_screen/widgets/safety_alert_widget.dart`**
    - Uses `FaithMode`

13. **`lib/presentation/daily_check_in_screen/widgets/micro_intervention_card.dart`**
    - Uses `FaithMode` (multiple references)

14. **`lib/presentation/daily_check_in_screen/widgets/journal_entry_widget.dart`**
    - Uses `FaithMode` (multiple references)

15. **`lib/presentation/daily_check_in_screen/widgets/completion_summary_widget.dart`**
    - Uses `FaithMode` (multiple references)

16. **`lib/presentation/daily_check_in_screen/widgets/ai_suggestions_widget.dart`**
    - Uses `FaithMode`

17. **`lib/presentation/daily_check_in_screen/widgets/coping_mechanisms_widget.dart`**
    - Uses `FaithMode`

18. **`lib/presentation/daily_check_in_screen/widgets/bible_passage_card.dart`**
    - Uses `FaithMode`

#### Features - Planner
19. **`lib/features/planner/presentation/morning_checkin_screen.dart`**
    - Uses `FaithMode` (multiple references)

#### Features - Mind
20. **`lib/features/mind/widgets/daily_inspiration.dart`**
    - Uses `FaithMode`

21. **`lib/features/mind/widgets/go_deeper_card.dart`**
    - Uses `FaithMode`

22. **`lib/features/mind/services/mind_exercises_service.dart`**
    - Uses `FaithMode` (multiple references)

23. **`lib/features/mind/services/conversion_funnel_service.dart`**
    - Uses `FaithMode` (switch cases)

24. **`lib/features/mind/routines/walk_in_light_routine.dart`**
    - Uses `FaithMode`

25. **`lib/features/mind/repositories/mind_coach_repository.dart`**
    - Uses `FaithMode` (switch cases)

26. **`lib/features/mind/presentation/widgets/walk_in_light_components/welcome_component.dart`**
    - Uses `FaithMode`

27. **`lib/features/mind/presentation/widgets/walk_in_light_components/truth_component.dart`**
    - Uses `FaithMode`

28. **`lib/features/mind/presentation/widgets/walk_in_light_components/gratitude_component.dart`**
    - Uses `FaithMode` (multiple references)

29. **`lib/features/mind/presentation/widgets/walk_in_light_components/completion_component.dart`**
    - Uses `FaithMode` (multiple references)

30. **`lib/features/mind/presentation/widgets/walk_in_light_components/breath_component.dart`**
    - Uses `FaithMode` (multiple references)

31. **`lib/features/mind/presentation/widgets/mind_exercises_tab.dart`**
    - Uses `FaithMode`

32. **`lib/features/mind/presentation/widgets/mind_courses_tab.dart`**
    - Uses `FaithMode`

33. **`lib/features/mind/presentation/widgets/mind_coach_tab.dart`**
    - Uses `FaithMode`

34. **`lib/features/mind/presentation/screens/walk_in_light_screen.dart`**
    - Uses `FaithMode`

35. **`lib/features/mind/presentation/screens/thought_record_screen.dart`**
    - Uses `FaithMode`

36. **`lib/features/mind/presentation/screens/values_clarification_screen.dart`**
    - Uses `FaithMode`

37. **`lib/features/mind/presentation/screens/mindful_observation_screen.dart`**
    - Uses `FaithMode`

38. **`lib/features/mind/presentation/screens/gratitude_practice_screen.dart`**
    - Uses `FaithMode`

39. **`lib/features/mind/presentation/screens/implementation_intention_screen.dart`**
    - Uses `FaithMode`

40. **`lib/features/mind/models/mind_coach_copy.dart`**
    - Uses `FaithMode` (switch cases)

41. **`lib/features/mind/presentation/mind_coach_screen.dart`**
    - Uses `FaithMode` (switch cases)

42. **`lib/features/mind/faith/faith_consent.dart`**
    - Uses `FaithMode` (multiple references)

43. **`lib/features/mind/exercises/exercise_runner_screen.dart`**
    - Uses `FaithMode` (multiple references)

44. **`lib/features/mind/breath/box_breathing_screen.dart`**
    - Uses `FaithMode` (multiple references, switch cases)

45. **`lib/features/mind/presentation/screens/box_breathing_screen.dart`**
    - Uses `FaithMode` (conversion from `FaithTier`)

46. **`lib/features/mind/presentation/widgets/coach_faith_exercises.dart`**
    - Uses `FaithMode` (switch cases)

47. **`lib/features/mind/widgets/faith_exercise_tile.dart`**
    - Uses `FaithMode`

48. **`lib/features/mind/services/truth_integration_service.dart`**
    - Uses `FaithMode`

49. **`lib/features/mind/services/crisis_resolution_service.dart`**
    - Uses `FaithMode` (switch cases)

#### Features - Breath
50. **`lib/features/breath/presentation/breath_session_screen.dart`**
    - Uses `FaithMode` (switch cases)

#### Features - Spirit
51. **`lib/features/spirit/spirit_overview.dart`**
    - Uses `FaithMode`

#### Data Layer
52. **`lib/data/truth_service.dart`**
    - Uses `FaithMode`

#### Test Files
53. **`test/mind/urge/suggester_test.dart`**
    - Uses `FaithMode` (multiple test cases)

54. **`test/mind/urge/faith_gating_test.dart`**
    - Uses `FaithMode.values`

## Files Using Correct Enum (`FaithTier`)

These files are already using the correct enum:
- `lib/core/settings/settings_model.dart` ✅ (canonical definition)
- `lib/services/faith_service.dart` ✅
- `lib/services/gateway_service.dart` ✅
- `lib/features/shared/faith_mode.dart` ✅ (duplicate definition, should be deleted)
- `lib/features/focus_calendar/domain/faith_mode.dart` ✅ (duplicate definition, should be deleted)
- `lib/features/courses/models/course_models.dart` ✅ (has duplicate definition, but uses `FaithTier`)
- Most files in `lib/features/mind/presentation/widgets/` ✅
- Most files in `lib/features/courses/` ✅
- Most files in `lib/features/spirit/` ✅

## Action Required

1. **Remove `enum FaithMode` definition** from `lib/core/services/settings_service.dart`
2. **Replace all `FaithMode` references** with `FaithTier` in the 54 files listed above
3. **Update imports** to use `lib/core/settings/settings_model.dart` instead of `lib/core/services/settings_service.dart`
4. **Delete duplicate enum files:**
   - `lib/features/shared/faith_mode.dart`
   - `lib/features/focus_calendar/domain/faith_mode.dart`
5. **Update `lib/features/courses/models/course_models.dart`** to remove duplicate `FaithTier` definition

## Notes

- Some files (like `lib/features/mind/presentation/screens/box_breathing_screen.dart`) already convert between `FaithTier` and `FaithMode` - these conversions should be removed once unified
- The `lib/core/brand_rules.dart` file has conversion functions between `FaithMode` and `FaithTier` - these should be updated to only work with `FaithTier`

