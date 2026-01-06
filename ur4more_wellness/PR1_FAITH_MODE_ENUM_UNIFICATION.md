# PR #1: Canonical Faith Mode Enum Unification

**Goal:** Unify all faith mode enum definitions to use a single canonical `FaithTier` enum with consistent string values.

**Scope:** NO behavior changes beyond making the app consistent. Pure refactoring.

---

## A) Audit: All Files Where FaithMode/FaithTier Appears

### Canonical Location (KEEP)
- ✅ `lib/core/settings/settings_model.dart` - `enum FaithTier { off, light, disciple, kingdom }` + conversion helpers

### Duplicate Enum Definitions (REMOVE/REPLACE)
1. **`lib/services/faith_service.dart`** - `enum FaithMode { off, light, disciple, kingdom }` + extension
   - **Action:** Remove enum, import `FaithTier` from canonical, update all `FaithMode` → `FaithTier`
   
2. **`lib/core/services/settings_service.dart`** - `enum FaithMode { off, light, disciple, kingdom }`
   - **Action:** Remove enum, import `FaithTier` from canonical, update all `FaithMode` → `FaithTier`

3. **`lib/features/shared/faith_mode.dart`** - `enum FaithTier { off, light, disciple, kingdom }` + extension
   - **Action:** DELETE file, update imports to use canonical

4. **`lib/features/focus_calendar/domain/faith_mode.dart`** - `enum FaithTier { off, light, disciple, kingdom }` + extension
   - **Action:** DELETE file, update imports to use canonical

5. **`lib/features/courses/models/course_models.dart`** - `enum FaithTier { off, light, disciple, kingdomBuilder }`
   - **Action:** Remove enum, import `FaithTier` from canonical, fix `kingdomBuilder` → `kingdom` usages

### Files Using FaithMode/FaithTier (UPDATE IMPORTS/USAGE)
- All files importing from duplicate locations (see grep results)
- Gateway already uses correct strings ("off","light","disciple","kingdom")

### String Value Issues (FIX)
- `"kingdomBuilder"` → `"kingdom"` (in course_models.dart, some string comparisons)
- `"Full"` → `"disciple"` (legacy migration in faith_service.dart - keep for backward compat)
- `"KingdomBuilder"` → `"kingdom"` (display names)

---

## B) Plan: Step-by-Step Changes

### Step 1: Enhance Canonical Enum (settings_model.dart)
- Add `FaithFlags` extension to canonical file
- Ensure conversion helpers are correct: `parseFaithTier` (fromString), `faithTierToString`

### Step 2: Update faith_service.dart
- Remove `enum FaithMode` and `extension FaithFlags on FaithMode`
- Import `FaithTier` and `FaithFlags` from canonical
- Replace all `FaithMode` → `FaithTier`
- Update conversion methods to use canonical helpers
- Keep backward-compat string parsing ("Full" → disciple)

### Step 3: Update settings_service.dart (OLD)
- This file appears to be old/unused (has different AppSettings structure)
- Check if it's actually used, if not skip
- If used: Remove `enum FaithMode`, import `FaithTier` from canonical

### Step 4: Delete Duplicate Files
- Delete `lib/features/shared/faith_mode.dart`
- Delete `lib/features/focus_calendar/domain/faith_mode.dart`
- Update all imports to use canonical location

### Step 5: Fix course_models.dart
- Remove `enum FaithTier` definition
- Import `FaithTier` from canonical
- Replace `FaithTier.kingdomBuilder` → `FaithTier.kingdom`
- Update `fromString` to use canonical helper (or remove if canonical has it)
- Update string comparisons: `"kingdom builder"` → `"kingdom"`

### Step 6: Update All Import Statements
- Find all files importing from deleted/updated locations
- Update imports to: `import 'package:ur4more_wellness/core/settings/settings_model.dart';`
- Or relative: `import '../../core/settings/settings_model.dart';`

### Step 7: Update Gateway (Verify)
- Gateway already uses correct strings ("off","light","disciple","kingdom")
- Verify no changes needed

### Step 8: Add Unit Tests
- Test `parseFaithTier` (fromString) - valid + invalid inputs
- Test `faithTierToString` - all enum values
- Test `FaithFlags` extension - isOff, isActivated, isDeep
- Test gating logic (OFF hides faith content, disciple+ allows)

### Step 9: Build & Verify
- Run `flutter analyze`
- Run `flutter test`
- Verify app compiles and runs

---

## C) Patch: Implementation

[Implementation will follow in code changes]

---

## D) Tests: What Was Added and How to Run

### Test File: `test/core/settings/faith_tier_test.dart`

**Tests Added:**
1. `parseFaithTier_validInputs` - Tests all valid string inputs ("off", "light", "disciple", "kingdom")
2. `parseFaithTier_invalidInputs` - Tests invalid/edge cases (null, empty, unknown values)
3. `faithTierToString_allValues` - Tests conversion of all enum values to strings
4. `faithFlags_extension` - Tests isOff, isActivated, isDeep flags
5. `faithTier_gating` - Tests gating logic (OFF hides, activated shows)

**Run Tests:**
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/core/settings/faith_tier_test.dart

# Run with coverage
flutter test --coverage
```

---

## E) Notes: Follow-Up for PR #2 (Consent System)

### Issues Found That Need PR #2:
1. **String conversion inconsistencies:**
   - `faith_service.dart` uses capitalized strings ("Off", "Light", "Disciple", "Kingdom")
   - Should use lowercase ("off", "light", "disciple", "kingdom") to match gateway
   - **PR #2:** Standardize all string conversions to lowercase

2. **FaithService methods need refactoring:**
   - `FaithService` has many methods that operate on `FaithMode` (now `FaithTier`)
   - Some methods like `getFaithModeLabel` return display names ("Kingdom Builder")
   - **PR #2:** Review if these methods should be in FaithService or moved to settings_model

3. **Backward compatibility:**
   - `_parseFaithMode` in faith_service.dart handles "Full" → disciple migration
   - **PR #2:** Document migration strategy, consider data migration script

4. **Extension methods:**
   - `FaithFlags` extension now in canonical location
   - **PR #2:** Ensure all files use canonical extension, no duplicates

5. **Gateway alignment:**
   - Gateway uses lowercase strings (correct)
   - Flutter should use lowercase strings consistently
   - **PR #2:** Audit all string conversions to ensure lowercase

### Files That May Need Updates in PR #2:
- `lib/services/faith_service.dart` - Review methods, consider refactoring
- `lib/features/mind/faith/faith_consent.dart` - Will use unified `FaithTier`
- All files with string comparisons - Ensure lowercase consistency

