# Fitness Flow + Feature Inventory

**Last Updated:** 2024  
**Module:** Body Fitness  
**Primary Screen:** `lib/presentation/body_fitness_screen/body_fitness_screen.dart`

---

## User Flow

### Happy Path: Complete a Workout

1. **User opens Body Fitness tab** (via bottom navigation)
   - Screen loads with `FitnessHeader` showing current points (1250) and weekly progress (62.5%)
   - Default equipment filter: "Bodyweight" selected
   - Default difficulty filter: "All"
   - Default sort: "Recommended"
   - 6 hardcoded workouts displayed in list

2. **User browses workouts**
   - Scrolls through workout cards
   - Each card shows: name, description, thumbnail, duration, calories, difficulty badge, equipment icons, points
   - Can swipe left on card to reveal actions: Favorite, Schedule, Share

3. **User filters workouts**
   - Toggles equipment chips (Bodyweight, Bands, Pullup Bar) - multi-select
   - Changes difficulty filter (All, Beginner, Intermediate, Advanced) - single select
   - Changes sort mode via popup menu (Recommended, Points High→Low, Time Short→Long)
   - List updates in real-time

4. **User selects a workout**
   - Taps on workout card
   - `WorkoutTimerOverlay` appears as full-screen overlay with dark background
   - Start screen shows: workout name, "Ready to start?", exercise count, duration, pulsing play button

5. **User starts workout**
   - Taps "Start Workout" button
   - Transitions to exercise screen showing:
     - Exercise number (e.g., "Exercise 1 of 4")
     - Exercise name (large text)
     - Exercise description
     - Circular progress indicator with current rep / total reps
     - "Complete Rep" button

6. **User completes exercises**
   - Taps "Complete Rep" for each rep
   - Progress circle updates
   - When all reps completed, automatically transitions to rest screen
   - Rest screen shows: countdown timer, "Next: [Exercise Name]"
   - After rest completes, automatically moves to next exercise

7. **User completes workout**
   - After final exercise, calls `_onWorkoutComplete()`
   - Points added to `currentPoints` (in-memory only)
   - Weekly progress recalculated
   - Points animation plays (scale animation on header)
   - Snackbar shows: "Workout completed! +[points] points earned"
   - Overlay closes, returns to workout list

### Edge Cases & Alternative Flows

**Empty State:**
- If filters result in no workouts, shows empty state with:
  - Fitness center icon
  - "No workouts found" message
  - "Try adjusting your equipment filters or create a custom workout" hint
  - "Reset Filters" button (resets to Bodyweight only)

**Workout Interruption:**
- User can tap "Exit Workout" button at any time
- Closes overlay without awarding points
- No confirmation dialog
- No progress saved

**Skip Exercise:**
- During active workout, "Skip Exercise" button available
- Immediately moves to next exercise (or rest)
- No penalty, no points deduction

**Refresh:**
- Pull-to-refresh available on workout list
- Shows loading state for 2 seconds
- Snackbar: "Workouts refreshed successfully"
- Does not actually refresh data (workouts are hardcoded)

**Favorite/Schedule/Share Actions:**
- Swipe left on workout card reveals actions
- Favorite: Shows snackbar "Added '[workout name]' to favorites" (no persistence)
- Schedule: Shows snackbar "Scheduled '[workout name]' for later" (no actual scheduling)
- Share: Shows snackbar "Shared '[workout name]' workout" (no actual sharing)

**Create Custom Workout:**
- Floating Action Button (FAB) opens modal bottom sheet
- Modal shows: "Create Custom Workout" title, description, "Create Workout" button
- Button shows snackbar: "Custom workout creation coming soon!"
- Modal closes, no actual creation

---

## Feature Inventory

### ✅ Currently Implemented

**Core Features:**
- ✅ Workout list display (6 hardcoded workouts)
- ✅ Equipment filtering (multi-select chips: Bodyweight, Bands, Pullup Bar)
- ✅ Difficulty filtering (All, Beginner, Intermediate, Advanced)
- ✅ Sorting (Recommended, Points High→Low, Time Short→Long)
- ✅ Workout timer overlay with exercise-by-exercise guidance
- ✅ Rest timer between exercises
- ✅ Rep counting with visual progress indicator
- ✅ Points display in header (current points, weekly goal, progress bar)
- ✅ Points animation on workout completion
- ✅ Pull-to-refresh gesture
- ✅ Empty state handling
- ✅ Swipe actions (Favorite, Schedule, Share) - UI only
- ✅ Create workout modal - placeholder only

**UI Components:**
- ✅ `FitnessHeader` - Shows title, points badge, weekly progress bar
- ✅ `EquipmentFilterChips` - Horizontal scrollable filter chips
- ✅ `WorkoutCard` - Displays workout details with thumbnail, metadata chips
- ✅ `WorkoutTimerOverlay` - Full-screen workout execution interface
- ✅ `_DifficultyAndSortRow` - Difficulty chips + sort dropdown

**Data Structure:**
- ✅ Workout model (in-memory Map):
  - `id`, `name`, `description`
  - `duration` (minutes), `calories`, `difficulty` (string)
  - `equipment` (List<String>)
  - `points` (int)
  - `thumbnail` (URL string)
  - `thumbnailSemanticLabel` (accessibility)
  - `exercises` (List<Map> with name, reps/duration, rest)

**State Management:**
- ✅ Local state in `_BodyFitnessScreenState`
- ✅ Filter state (equipment, difficulty, sort)
- ✅ Workout list state
- ✅ Active workout state
- ✅ Points state (in-memory only)

### ❌ Missing Features

**Data Persistence:**
- ❌ No workout history storage
- ❌ No favorite workouts persistence
- ❌ No scheduled workouts storage
- ❌ Points not persisted (lost on app restart)
- ❌ Weekly progress not persisted
- ❌ No workout completion history
- ❌ No exercise performance tracking

**Workout Management:**
- ❌ Cannot create custom workouts
- ❌ Cannot edit existing workouts
- ❌ Cannot delete workouts
- ❌ No workout templates/library
- ❌ No workout sharing (actual implementation)
- ❌ No workout import/export

**Workout Execution:**
- ❌ Cannot pause/resume workout
- ❌ No workout progress saving (if interrupted)
- ❌ No exercise form tips/videos
- ❌ No audio cues/voice guidance
- ❌ No background timer (app must stay open)
- ❌ No workout statistics (time taken, actual vs planned)

**Progress Tracking:**
- ❌ No workout streak tracking
- ❌ No weekly/monthly statistics
- ❌ No personal records (PRs)
- ❌ No body metrics tracking (weight, measurements)
- ❌ No progress photos
- ❌ No calendar view of completed workouts

**Social/Sharing:**
- ❌ No actual workout sharing (only UI placeholder)
- ❌ No social feed/community features
- ❌ No workout challenges
- ❌ No leaderboards

**Integration:**
- ❌ No integration with PointsService (points are local only)
- ❌ No integration with planner/scheduling system
- ❌ No integration with daily check-in
- ❌ No integration with health apps (Apple Health, Google Fit)
- ❌ No calendar integration for scheduled workouts

**Advanced Features:**
- ❌ No workout recommendations based on history
- ❌ No adaptive difficulty/progression
- ❌ No workout plans/programs (multi-day)
- ❌ No rest day suggestions
- ❌ No injury prevention tips
- ❌ No warm-up/cool-down routines

---

## Missing Screens/Features for Complete Fitness Module

### High Priority

1. **Workout Detail Screen**
   - Full workout information before starting
   - Exercise list preview
   - Equipment checklist
   - Estimated calories/points
   - Start button

2. **Workout History Screen**
   - List of completed workouts with dates
   - Filter by date range
   - View workout details/completion stats
   - Delete history entries

3. **Favorites Screen**
   - Dedicated screen for favorited workouts
   - Quick access to frequently used workouts
   - Remove from favorites

4. **Scheduled Workouts Screen**
   - Calendar view of scheduled workouts
   - Daily/weekly view
   - Edit/delete scheduled workouts
   - Notifications/reminders

5. **Create/Edit Workout Screen**
   - Form to create custom workouts
   - Add/remove exercises
   - Set reps, duration, rest times
   - Set difficulty, equipment, points
   - Save to local library

### Medium Priority

6. **Workout Statistics Screen**
   - Weekly/monthly summaries
   - Total workouts completed
   - Total points earned
   - Average workout duration
   - Most used equipment
   - Difficulty distribution

7. **Streak Tracking**
   - Current streak display
   - Streak history
   - Streak milestones/badges
   - Streak recovery after missed days

8. **Workout Plans/Programs**
   - Multi-day workout programs
   - Progressive difficulty
   - Program completion tracking
   - Program recommendations

9. **Exercise Library**
   - Browse all available exercises
   - Exercise details (form tips, muscle groups)
   - Exercise videos/GIFs
   - Search/filter exercises

10. **Settings Screen (Fitness-specific)**
    - Weekly goal customization
    - Default equipment preferences
    - Rest timer preferences
    - Units (metric/imperial)
    - Notification settings

### Low Priority

11. **Social Features**
    - Share workout completions
    - Follow friends
    - Workout challenges
    - Leaderboards

12. **Health Integration**
    - Apple Health sync
    - Google Fit sync
    - Heart rate monitoring
    - Activity rings integration

13. **Advanced Analytics**
    - Body metrics tracking
    - Progress photos
    - Strength progression charts
    - Volume/intensity trends

---

## Proposed Next 5 Improvements (Prioritized)

### 1. **Persist Workout Completion & Points** (Highest Impact)
**Priority:** Critical  
**Impact:** High  
**Effort:** Medium

**What:** Integrate with `PointsService` to persist workout completions and points to database.

**Why:** Currently points are lost on app restart. This breaks the core value proposition of earning points for workouts.

**Implementation:**
- Call `PointsService.award()` on workout completion
- Store workout completion record in database
- Load current points from database on screen init
- Update weekly progress calculation based on persisted data

**Files to modify:**
- `lib/presentation/body_fitness_screen/body_fitness_screen.dart` - Add PointsService integration
- Create `lib/services/fitness_service.dart` - Workout completion persistence

**Dependencies:**
- `PointsService` (already exists)
- Database schema for workout_completions table

---

### 2. **Workout History Screen** (High Impact)
**Priority:** High  
**Impact:** High  
**Effort:** Medium

**What:** Create a dedicated screen showing completed workouts with dates, duration, points earned.

**Why:** Users need to see their progress over time. This provides motivation and helps track consistency.

**Implementation:**
- Create `lib/presentation/workout_history_screen/workout_history_screen.dart`
- Load workout completions from database
- Display in chronological list (newest first)
- Show: workout name, date, duration, points earned
- Add route: `AppRoutes.workoutHistory`
- Add navigation from FitnessHeader or bottom nav

**Files to create:**
- `lib/presentation/workout_history_screen/workout_history_screen.dart`
- `lib/presentation/workout_history_screen/widgets/workout_history_card.dart`

**Files to modify:**
- `lib/routes/app_routes.dart` - Add route
- `lib/presentation/body_fitness_screen/widgets/fitness_header.dart` - Add history button

**Dependencies:**
- Workout completion persistence (from #1)

---

### 3. **Favorite Workouts Persistence** (High Impact)
**Priority:** High  
**Impact:** Medium  
**Effort:** Low

**What:** Persist favorite workouts to SharedPreferences or database, add Favorites screen.

**Why:** Currently favorites are lost immediately. Users expect favorites to persist across sessions.

**Implementation:**
- Create `lib/services/fitness_service.dart` with `saveFavorite()`, `removeFavorite()`, `getFavorites()`
- Use SharedPreferences or database
- Update `_onFavorite()` to persist
- Add visual indicator (heart icon) on favorited workout cards
- Create Favorites screen or filter view

**Files to create:**
- `lib/services/fitness_service.dart`

**Files to modify:**
- `lib/presentation/body_fitness_screen/body_fitness_screen.dart` - Persist favorites
- `lib/presentation/body_fitness_screen/widgets/workout_card.dart` - Show favorite indicator

---

### 4. **Workout Detail Preview Screen** (Medium Impact)
**Priority:** Medium  
**Impact:** Medium  
**Effort:** Low

**What:** Show full workout details before starting (exercise list, equipment, estimated time).

**Why:** Users should know what they're committing to before starting a workout.

**Implementation:**
- Create `lib/presentation/workout_detail_screen/workout_detail_screen.dart`
- Display: workout name, description, full exercise list, equipment needed, total duration, points
- "Start Workout" button navigates to timer overlay
- Add route and navigation from WorkoutCard tap

**Files to create:**
- `lib/presentation/workout_detail_screen/workout_detail_screen.dart`
- `lib/presentation/workout_detail_screen/widgets/exercise_preview_card.dart`

**Files to modify:**
- `lib/routes/app_routes.dart` - Add route
- `lib/presentation/body_fitness_screen/body_fitness_screen.dart` - Navigate to detail instead of directly to timer

---

### 5. **Streak Tracking** (Medium Impact)
**Priority:** Medium  
**Impact:** Medium  
**Effort:** Medium

**What:** Track daily workout streaks, display in header, show streak milestones.

**Why:** Streaks are powerful motivators. Similar to faith streak system already in app.

**Implementation:**
- Create `lib/services/fitness_streak_service.dart` (similar to `FaithService`)
- Track consecutive days with at least one workout
- Display current streak in FitnessHeader
- Reset streak if no workout completed in 24 hours
- Show streak milestones/badges

**Files to create:**
- `lib/services/fitness_streak_service.dart`

**Files to modify:**
- `lib/presentation/body_fitness_screen/widgets/fitness_header.dart` - Add streak display
- `lib/presentation/body_fitness_screen/body_fitness_screen.dart` - Update streak on completion

**Dependencies:**
- Workout completion persistence (from #1)

---

## UX Issues & Recommendations

### Layout Issues

1. **Workout Timer Overlay - Exercise Data Mismatch**
   - **Issue:** `WorkoutTimerOverlay` uses hardcoded exercises (`_initializeExercises()`) instead of `widget.workout['exercises']`
   - **Impact:** User sees different exercises than what's listed in workout card
   - **Fix:** Use `widget.workout['exercises']` and handle both `reps` and `duration` types

2. **FitnessHeader Progress Calculation Bug**
   - **Issue:** Line 135: `'${(currentPoints * weeklyProgress).toInt()} / $weeklyGoal points'` - multiplies points by progress instead of showing actual points
   - **Impact:** Progress display shows incorrect numbers
   - **Fix:** Should show `currentPoints` directly, not `currentPoints * weeklyProgress`

3. **Points Animation Not Synced**
   - **Issue:** Points animation plays but points are updated immediately (no smooth transition)
   - **Impact:** Animation feels disconnected from actual point update
   - **Fix:** Animate the actual points value using `TweenAnimationBuilder` or similar

### State Handling Issues

4. **No Workout Progress Persistence**
   - **Issue:** If user closes app during workout, all progress is lost
   - **Impact:** Poor user experience, no recovery
   - **Fix:** Save workout state to SharedPreferences, restore on app resume

5. **Filter State Not Persisted**
   - **Issue:** Equipment/difficulty filters reset on screen reload
   - **Impact:** User must reconfigure filters each time
   - **Fix:** Persist filter preferences to SharedPreferences

6. **Workout List Hardcoded**
   - **Issue:** Workouts are hardcoded in `_initializeWorkouts()`, no API/database integration
   - **Impact:** Cannot add/update workouts without code changes
   - **Fix:** Move to database/API, create workout management system

### Interaction Issues

7. **No Confirmation on Workout Exit**
   - **Issue:** "Exit Workout" immediately closes without confirmation
   - **Impact:** Accidental exits lose progress
   - **Fix:** Show confirmation dialog: "Exit workout? Progress will not be saved."

8. **Rest Timer Cannot Be Skipped**
   - **Issue:** User must wait for full rest timer countdown
   - **Impact:** Frustrating for users who want shorter rests
   - **Fix:** Add "Skip Rest" button

9. **No Exercise Form Guidance**
   - **Issue:** Only text description, no visual/video guidance
   - **Impact:** Users may perform exercises incorrectly
   - **Fix:** Add exercise images/GIFs, link to form videos

10. **Share/Schedule Actions Don't Work**
    - **Issue:** Actions show snackbars but don't actually share/schedule
    - **Impact:** Misleading UX, broken expectations
    - **Fix:** Implement actual sharing (share_plus package) and scheduling (integrate with planner)

### Performance Issues

11. **No Image Caching**
    - **Issue:** Workout thumbnails loaded from URLs without caching
    - **Impact:** Slow loading, data usage
    - **Fix:** Use `cached_network_image` package

12. **No Pagination**
    - **Issue:** All workouts loaded at once (though only 6 currently)
    - **Impact:** Will be slow with many workouts
    - **Fix:** Implement pagination or lazy loading

---

## Code Map

### Core Files

**`lib/presentation/body_fitness_screen/body_fitness_screen.dart`** (799 lines)
- Main screen widget (`BodyFitnessScreen`)
- State management for filters, workouts, active workout
- Workout filtering/sorting logic
- Workout completion handling
- Points management (in-memory)
- Empty state UI
- Create workout modal
- `_DifficultyAndSortRow` widget (inline)

**`lib/presentation/body_fitness_screen/widgets/fitness_header.dart`** (161 lines)
- Header component showing:
  - "Body Fitness" title and subtitle
  - Current points badge
  - Weekly progress bar with percentage
- Receives: `currentPoints`, `weeklyGoal`, `weeklyProgress`
- Uses `AppTheme.lightTheme.primaryColor` for background

**`lib/presentation/body_fitness_screen/widgets/equipment_filter_chips.dart`** (54 lines)
- Horizontal scrollable filter chips
- Multi-select equipment filtering
- Receives: `selectedEquipment`, `onEquipmentToggle`, `availableEquipment`
- Uses `FilterChip` widgets

**`lib/presentation/body_fitness_screen/widgets/workout_card.dart`** (277 lines)
- Workout card display component
- Shows: name, description, thumbnail, duration, calories, difficulty, equipment icons, points
- Handles tap to start workout
- Receives callbacks: `onTap`, `onFavorite`, `onSchedule`, `onShare`
- Helper methods: `_buildInfoChip()`, `_buildDifficultyChip()`, `_buildEquipmentRow()`, `_getEquipmentIcon()`

**`lib/presentation/body_fitness_screen/widgets/workout_timer_overlay.dart`** (460 lines)
- Full-screen workout execution overlay
- Three states: Start screen, Exercise screen, Rest screen
- Exercise-by-exercise progression
- Rep counting with circular progress
- Rest timer countdown
- Controls: Exit, Skip Exercise
- **BUG:** Uses hardcoded exercises instead of `widget.workout['exercises']`

### Related Services (Not Fitness-Specific)

**`lib/core/services/points_service.dart`**
- `PointsService.award()` - Awards points to user
- `PointsService.awardWorkoutCompletion()` - Specific method for workouts (100 points)
- **NOT CURRENTLY USED** by fitness screen

**`lib/services/faith_service.dart`**
- Faith XP and streak tracking (similar pattern could be used for fitness streaks)
- Uses SharedPreferences for persistence

### Data Models

**Workout Model (In-Memory Map):**
```dart
{
  'id': int,
  'name': String,
  'description': String,
  'duration': int, // minutes
  'calories': int,
  'difficulty': String, // 'Beginner', 'Intermediate', 'Advanced'
  'equipment': List<String>,
  'points': int,
  'thumbnail': String, // URL
  'thumbnailSemanticLabel': String,
  'exercises': List<Map> // [{name, reps/duration, rest}]
}
```

**Exercise Model (In-Memory Map):**
```dart
{
  'name': String,
  'reps': int?, // if time-based, use 'duration' instead
  'duration': int?, // seconds
  'rest': int, // seconds
  'restTime': int, // alias for 'rest'
  'description': String?
}
```

### State Variables

**`_BodyFitnessScreenState`:**
- `selectedEquipment: List<String>` - Currently selected equipment filters
- `availableEquipment: List<String>` - All available equipment types
- `workouts: List<Map>` - All workouts (hardcoded)
- `filteredWorkouts: List<Map>` - Filtered/sorted workout list
- `isLoading: bool` - Loading state (not really used)
- `showTimerOverlay: bool` - Whether timer overlay is visible
- `activeWorkout: Map?` - Currently active workout
- `currentPoints: int` - Current points (in-memory, default 1250)
- `weeklyGoal: int` - Weekly goal (default 2000)
- `weeklyProgress: double` - Progress percentage (default 0.625)
- `difficultyFilter: DifficultyFilter` - Current difficulty filter
- `sortMode: WorkoutSort` - Current sort mode

### Enums

**`DifficultyFilter`** (in body_fitness_screen.dart):
- `all`, `beginner`, `intermediate`, `advanced`

**`WorkoutSort`** (in body_fitness_screen.dart):
- `recommended`, `pointsHigh`, `durationShort`

---

## Summary

The Body Fitness module provides a solid foundation with a clean UI and basic workout execution flow. However, it lacks persistence, history tracking, and several key features that would make it a complete fitness solution. The highest priority improvements are integrating with the points system, adding workout history, and persisting favorites. The codebase is well-structured with clear separation of concerns, making it relatively straightforward to add these features.

