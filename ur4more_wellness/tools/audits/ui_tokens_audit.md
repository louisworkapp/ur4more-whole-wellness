# UI Tokens Audit Report

## Summary
This audit identifies non-universal spacing/typography patterns in the Flutter app that should be refactored to use design tokens from `lib/design/tokens.dart`. The main issues are:

1. **Sizer percentage units** - Extensive use of `.w`, `.h`, `.sp` units that scale with screen size
2. **Hardcoded spacing** - Direct numeric values in EdgeInsets and SizedBox
3. **Hardcoded text sizes** - Direct fontSize values instead of theme/tokens
4. **Missing PhoneCard usage** - Many containers that could benefit from PhoneCard wrapper

## Findings

### 1. Sizer Percentage Units (Critical - 340+ instances)

| File | Line | Snippet | Issue | Suggested Fix |
|------|------|---------|-------|---------------|
| `lib/presentation/splash_screen/splash_screen.dart` | 305-306 | `width: 8.w, height: 8.w` | Sizer width units | `width: AppSpace.x2, height: AppSpace.x2` |
| `lib/presentation/splash_screen/splash_screen.dart` | 347-348 | `width: 30.w, height: 30.w` | Large Sizer units | `width: 120, height: 120` (fixed DP) |
| `lib/presentation/splash_screen/splash_screen.dart` | 382 | `size: 12.w` | Sizer icon size | `size: 48` (fixed DP) |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 20 | `margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h)` | Sizer margins | `margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x1)` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 46 | `padding: EdgeInsets.all(4.w)` | Sizer padding | `padding: Pad.card` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 57 | `padding: EdgeInsets.all(2.w)` | Sizer padding | `padding: EdgeInsets.all(AppSpace.x2)` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 68 | `SizedBox(width: 3.w)` | Sizer spacing | `SizedBox(width: AppSpace.x3)` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 91 | `padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h)` | Sizer padding | `padding: EdgeInsets.symmetric(horizontal: AppSpace.x3, vertical: AppSpace.x1)` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 111 | `padding: EdgeInsets.all(4.w)` | Sizer padding | `padding: Pad.card` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 146-147 | `width: 8.w, height: 8.w` | Sizer icon size | `width: AppSpace.x2, height: AppSpace.x2` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 173-174 | `width: 3.w, height: 3.w` | Sizer icon size | `width: AppSpace.x3, height: AppSpace.x3` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 192 | `SizedBox(width: 4.w)` | Sizer spacing | `SizedBox(width: AppSpace.x4)` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 215 | `horizontal: 2.w, vertical: 0.5.h` | Sizer padding | `horizontal: AppSpace.x2, vertical: AppSpace.x1` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 285 | `SizedBox(width: 1.w)` | Sizer spacing | `SizedBox(width: AppSpace.x1)` |

*Note: This pattern repeats across all presentation widgets. The above is a sample - there are 340+ instances total.*

### 2. Sizer Height Units (Critical - 338+ instances)

| File | Line | Snippet | Issue | Suggested Fix |
|------|------|---------|-------|---------------|
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 20 | `vertical: 1.h` | Sizer height | `vertical: AppSpace.x1` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 80 | `SizedBox(height: 0.5.h)` | Sizer height | `SizedBox(height: AppSpace.x1)` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 91 | `vertical: 1.h` | Sizer height | `vertical: AppSpace.x1` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 186 | `height: 6.h` | Large Sizer height | `height: 120` (fixed DP) |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 188 | `vertical: 1.h` | Sizer height | `vertical: AppSpace.x1` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 195 | `bottom: isLast ? 0 : 2.h` | Sizer height | `bottom: isLast ? 0 : AppSpace.x2` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 215 | `vertical: 0.5.h` | Sizer height | `vertical: AppSpace.x1` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 230 | `SizedBox(height: 0.5.h)` | Sizer height | `SizedBox(height: AppSpace.x1)` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 240 | `SizedBox(height: 1.h)` | Sizer height | `SizedBox(height: AppSpace.x1)` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 262 | `SizedBox(height: 0.5.h)` | Sizer height | `SizedBox(height: AppSpace.x1)` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 270 | `minHeight: 1.h` | Sizer height | `minHeight: AppSpace.x1` |
| `lib/presentation/spiritual_growth_screen/widgets/spiritual_milestone_widget.dart` | 277 | `SizedBox(height: 1.h)` | Sizer height | `SizedBox(height: AppSpace.x1)` |

*Note: This pattern repeats across all presentation widgets. The above is a sample - there are 338+ instances total.*

### 3. Sizer Text Sizes (Critical - 63 instances)

| File | Line | Snippet | Issue | Suggested Fix |
|------|------|---------|-------|---------------|
| `lib/presentation/splash_screen/splash_screen.dart` | 262 | `fontSize: 24.sp` | Sizer text size | Use `AppText.title` or theme |
| `lib/presentation/splash_screen/splash_screen.dart` | 286 | `fontSize: 14.sp` | Sizer text size | Use `AppText.body` or theme |
| `lib/presentation/splash_screen/splash_screen.dart` | 328 | `fontSize: 12.sp` | Sizer text size | Use theme or clamp to max 14 |
| `lib/presentation/rewards_marketplace_screen/widgets/points_balance_card_widget.dart` | 69 | `fontSize: 32.sp` | Large Sizer text | Clamp to max 24 or use theme |
| `lib/presentation/mind_wellness_screen/widgets/journal_timeline_card.dart` | 82 | `fontSize: 10.sp` | Small Sizer text | Use theme or clamp to min 12 |
| `lib/presentation/home_dashboard/widgets/wellness_navigation_card.dart` | 122 | `fontSize: 12.sp` | Sizer text size | Use theme |
| `lib/presentation/home_dashboard/widgets/points_progress_ring.dart` | 103 | `fontSize: 12.sp` | Sizer text size | Use theme |
| `lib/presentation/home_dashboard/widgets/points_progress_ring.dart` | 193 | `fontSize: 10.sp` | Small Sizer text | Use theme or clamp to min 12 |
| `lib/presentation/home_dashboard/widgets/points_progress_ring.dart` | 201 | `fontSize: 9.sp` | Very small Sizer text | Use theme or clamp to min 12 |
| `lib/presentation/daily_check_in_screen/widgets/urge_intensity_widget.dart` | 113 | `fontSize: 36.sp` | Large Sizer text | Clamp to max 24 or use theme |
| `lib/presentation/daily_check_in_screen/widgets/rpe_scale_widget.dart` | 88 | `fontSize: 48.sp` | Very large Sizer text | Clamp to max 32 or use theme |
| `lib/presentation/daily_check_in_screen/widgets/pain_level_widget.dart` | 83 | `fontSize: 36.sp` | Large Sizer text | Clamp to max 24 or use theme |
| `lib/presentation/daily_check_in_screen/widgets/coping_mechanisms_widget.dart` | 268 | `fontSize: 8.sp` | Very small Sizer text | Use theme or clamp to min 12 |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 190 | `fontSize: 20.sp` | Sizer text size | Use `AppText.title` or theme |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 237 | `fontSize: 24.sp` | Sizer text size | Use theme or clamp to max 20 |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 246 | `fontSize: 16.sp` | Sizer text size | Use `AppText.button` or theme |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 261 | `fontSize: 16.sp` | Sizer text size | Use `AppText.button` or theme |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 280 | `fontSize: 24.sp` | Sizer text size | Use theme or clamp to max 20 |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 301 | `fontSize: 32.sp` | Large Sizer text | Clamp to max 24 or use theme |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 312 | `fontSize: 18.sp` | Sizer text size | Use theme |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 334 | `fontSize: 14.sp` | Sizer text size | Use `AppText.body` or theme |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 343 | `fontSize: 28.sp` | Large Sizer text | Clamp to max 24 or use theme |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 353 | `fontSize: 16.sp` | Sizer text size | Use `AppText.button` or theme |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 387 | `fontSize: 32.sp` | Large Sizer text | Clamp to max 24 or use theme |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 395 | `fontSize: 16.sp` | Sizer text size | Use `AppText.button` or theme |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 418 | `fontSize: 16.sp` | Sizer text size | Use `AppText.button` or theme |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 438 | `fontSize: 14.sp` | Sizer text size | Use `AppText.body` or theme |
| `lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart` | 450 | `fontSize: 14.sp` | Sizer text size | Use `AppText.body` or theme |

*Note: This pattern continues across all presentation widgets. The above is a sample - there are 63 instances total.*

### 4. Hardcoded Spacing (Medium Priority - 33 instances)

| File | Line | Snippet | Issue | Suggested Fix |
|------|------|---------|-------|---------------|
| `lib/theme/app_theme.dart` | 91 | `padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14)` | Hardcoded padding | Use `AppSpace` tokens |
| `lib/theme/app_theme.dart` | 156 | `padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)` | Hardcoded padding | Use `AppSpace` tokens |
| `lib/theme/app_theme.dart` | 171 | `padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)` | Hardcoded padding | Use `AppSpace` tokens |
| `lib/theme/app_theme.dart` | 189 | `contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16)` | Hardcoded padding | Use `AppSpace` tokens |
| `lib/presentation/authentication_screen/authentication_screen.dart` | 20 | `padding: const EdgeInsets.all(24)` | Hardcoded padding | Use `Pad.page` or `AppSpace.x6` |
| `lib/widgets/custom_tab_bar.dart` | 58 | `padding: padding ?? const EdgeInsets.symmetric(horizontal: 16)` | Hardcoded padding | Use `AppSpace.x4` |
| `lib/widgets/custom_tab_bar.dart` | 84 | `padding: padding ?? const EdgeInsets.all(16)` | Hardcoded padding | Use `AppSpace.x4` |
| `lib/widgets/custom_tab_bar.dart` | 96 | `padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8)` | Hardcoded padding | Use `AppSpace` tokens |
| `lib/widgets/custom_tab_bar.dart` | 129 | `padding: padding ?? const EdgeInsets.symmetric(horizontal: 16)` | Hardcoded padding | Use `AppSpace.x4` |
| `lib/widgets/custom_tab_bar.dart` | 149 | `padding: const EdgeInsets.symmetric(vertical: 16)` | Hardcoded padding | Use `AppSpace.x4` |
| `lib/widgets/custom_tab_bar.dart` | 182 | `margin: padding ?? const EdgeInsets.all(16)` | Hardcoded margin | Use `AppSpace.x4` |
| `lib/widgets/custom_tab_bar.dart` | 183 | `padding: const EdgeInsets.all(4)` | Hardcoded padding | Use `AppSpace.x1` |
| `lib/widgets/custom_tab_bar.dart` | 200 | `padding: const EdgeInsets.symmetric(vertical: 12)` | Hardcoded padding | Use `AppSpace.x3` |
| `lib/widgets/custom_bottom_bar.dart` | 127 | `margin: const EdgeInsets.all(16)` | Hardcoded margin | Use `AppSpace.x4` |
| `lib/widgets/custom_bottom_bar.dart` | 294 | `padding: const EdgeInsets.symmetric(vertical: 8)` | Hardcoded padding | Use `AppSpace.x2` |
| `lib/presentation/splash_screen/splash_screen.dart` | 300 | `padding: const EdgeInsets.only(bottom: 32)` | Hardcoded padding | Use `AppSpace.x8` |
| `lib/presentation/splash_screen/splash_screen.dart` | 361 | `padding: const EdgeInsets.all(16)` | Hardcoded padding | Use `AppSpace.x4` |
| `lib/presentation/splash_screen/splash_screen.dart` | 246 | `const SizedBox(height: 32)` | Hardcoded spacing | Use `AppSpace.x8` |
| `lib/screens/home_screen.dart` | 36 | `const SizedBox(height: 48)` | Hardcoded spacing | Use `AppSpace.x12` |

### 5. Missing PhoneCard Usage (Low Priority)

Many containers and cards throughout the app could benefit from the `PhoneCard` wrapper to ensure consistent max-width and padding. Examples:

| File | Widget | Issue | Suggested Fix |
|------|--------|-------|---------------|
| All presentation widgets | Card containers | Missing max-width constraint | Wrap in `PhoneCard(child: ...)` |
| `lib/presentation/spiritual_growth_screen/` | Various cards | No width constraint | Use `PhoneCard` wrapper |
| `lib/presentation/rewards_marketplace_screen/` | Reward cards | No width constraint | Use `PhoneCard` wrapper |
| `lib/presentation/settings_profile_screen/` | Section widgets | No width constraint | Use `PhoneCard` wrapper |

### 6. Button Style Duplication (Low Priority)

| File | Line | Snippet | Issue | Suggested Fix |
|------|------|---------|-------|---------------|
| `lib/presentation/spiritual_growth_screen/widgets/prayer_request_widget.dart` | 183 | `style: ElevatedButton.styleFrom(` | Inline button style | Remove, rely on theme |
| `lib/presentation/spiritual_growth_screen/widgets/faith_mode_banner_widget.dart` | 102 | `style: ElevatedButton.styleFrom(` | Inline button style | Remove, rely on theme |

## Recommended Fix Strategy

### Batch 1: Spacing/Radii/Elevation → Tokens
- Replace all `.w` and `.h` Sizer units with `AppSpace` tokens
- Replace hardcoded EdgeInsets with `Pad.page`, `Pad.card`, or `AppSpace` tokens
- Replace hardcoded SizedBox with `AppSpace` tokens

### Batch 2: Typography → Theme/AppText (+ clamps where needed)
- Replace all `.sp` Sizer units with theme or `AppText` tokens
- Add clamps for very large/small text sizes
- Import `dart:math` for clamping functions

### Batch 3: Container Widths → PhoneCard or ConstrainedBox
- Wrap appropriate containers in `PhoneCard`
- Use `ConstrainedBox(maxWidth: AppMaxW.card)` for non-card containers

### Batch 4: Remove Sizer/MediaQuery Percentages
- Remove remaining Sizer dependencies
- Ensure no visual regressions on phone sizes

## Impact Assessment

- **Critical**: Sizer units (740+ instances) - These cause scaling issues on desktop/web
- **Medium**: Hardcoded spacing (33 instances) - Inconsistent spacing system
- **Low**: Missing PhoneCard usage - Layout consistency on larger screens
- **Low**: Button style duplication - Minor theme consistency issues

## Files Requiring Most Attention

1. `lib/presentation/spiritual_growth_screen/` - All widgets heavily use Sizer
2. `lib/presentation/settings_profile_screen/` - All widgets heavily use Sizer  
3. `lib/presentation/rewards_marketplace_screen/` - All widgets heavily use Sizer
4. `lib/presentation/body_fitness_screen/` - Heavy Sizer usage, especially text sizes
5. `lib/presentation/daily_check_in_screen/` - Heavy Sizer usage
6. `lib/theme/app_theme.dart` - Hardcoded spacing in theme definitions

## Next Steps

1. Review this audit report
2. Approve the refactoring approach
3. Create branch `chore/refactor-ui-tokens`
4. Apply fixes in batches with descriptive commits
5. Test on both phone and desktop/web to ensure no regressions
