# Points Testing Guide

## Background Testing (No UI Required)

You can test points programmatically in the background using `PointsTestService`. This is useful for:
- Automated testing
- Debugging point calculations
- Setting up test scenarios
- Verifying point persistence

## Quick Start

```dart
import 'package:ur4more_wellness/core/services/points_test_service.dart';

// Ensure points are loaded
await PointsTestService.ensureLoaded();

// Award 10 points to each category
await PointsTestService.quickTest();

// Get current points
final points = PointsTestService.getCurrentPoints();
print('Total: ${points['total']}');
```

## Common Operations

### Award Points
```dart
await PointsTestService.awardPoints(
  category: 'body',  // 'body', 'mind', or 'spirit'
  delta: 25,         // Positive or negative
  action: 'workout_completed',
  note: 'Test workout',
);
```

### Set Specific Values
```dart
await PointsTestService.setPoints(
  body: 1000,
  mind: 500,
  spirit: 750,
);
```

### Reset All Points
```dart
await PointsTestService.resetPoints();
```

### Get Current Points
```dart
final points = PointsTestService.getCurrentPoints();
// Returns: {
//   'total': int,
//   'body': int,
//   'mind': int,
//   'spirit': int,
//   'bodyProgress': double,
//   'mindProgress': double,
//   'spiritProgress': double,
//   'loaded': bool,
// }
```

## Debug UI Components

### Floating Action Button (FAB)
In debug mode, a small orange FAB appears on the home dashboard. Tap it to open the debug bottom sheet.

### Long Press Gestures
Long press on:
- **Header** (points display) → Opens debug screen
- **Hero Progress** (progress bars) → Opens debug screen

### Debug Bottom Sheet
- Shows current point values
- Quick buttons to add/subtract 10 points per category
- Updates in real-time

### Debug Screen
- Full-screen debug interface
- Shows detailed point information
- Award points with custom amounts
- Reload from disk button

## Testing in Code

### Example: Test Workout Completion
```dart
// In your test or debug code
await PointsTestService.ensureLoaded();
await PointsTestService.awardPoints(
  category: 'body',
  delta: 25,
  action: 'workout_completed',
);
```

### Example: Set Up Test Scenario
```dart
// Set up a specific test scenario
await PointsTestService.setPoints(
  body: 1500,   // 75% progress (1500/2000)
  mind: 1200,   // 60% progress (1200/2000)
  spirit: 1700, // 85% progress (1700/2000)
);
```

### Example: Test Point Persistence
```dart
// Award points
await PointsTestService.awardPoints(category: 'body', delta: 100);

// Get current values
final before = PointsTestService.getCurrentPoints();

// Reload from disk
await PointsStore.i.load(await AuthService.getCurrentUserId() ?? 'test_user');

// Verify persistence
final after = PointsTestService.getCurrentPoints();
assert(before['body'] == after['body']);
```

## Troubleshooting

### Debug UI Not Showing
- Ensure you're running in **debug mode** (`kDebugMode == true`)
- Check that `kDebugMode` is imported from `package:flutter/foundation.dart`

### Points Not Updating
- Ensure `PointsTestService.ensureLoaded()` is called first
- Check that a user ID exists (service will create one automatically)
- Verify `PointsStore` listeners are set up in your widgets

### Points Not Persisting
- Points are saved to `SharedPreferences` automatically
- Check console logs for errors
- Use `_reloadFromDisk()` in debug screen to verify

## Notes

- All operations are logged to the debug console
- Points persist across app restarts (stored in SharedPreferences)
- Test user ID is created automatically if none exists
- Points are stored per user ID (supports multiple users)
