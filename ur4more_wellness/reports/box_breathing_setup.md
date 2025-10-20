# Box Breathing Setup Report

## Feature Overview

**Screen Name:** `BoxBreathingScreen`  
**Route:** Accessed via `Navigator.push(MaterialPageRoute(...))` from Mind tab  
**Entry Points:** Mind tab → Exercise cards → "breathing", "breathing_60_l1", "breathing_60_l2", "breathing_60_l3"  

**Current Visual Behavior:**
- Animated breathing circle that inflates/deflates with 4-4-4-4 pattern
- Per-step countdown timer (mm:ss format)
- Total session countdown timer
- 4 level tabs (L1-L4) with different breathing patterns
- Start/Pause/Reset controls
- Optional quote picker (faith mode only)
- Haptic feedback on step transitions

**Screenshot:** *No screenshot found in repo - placeholder for future addition*

## Files & Key Symbols

### Core Implementation Files

✅ **lib/features/mind/presentation/screens/box_breathing_screen.dart**
- Main screen implementation with timer logic and UI
- Classes: `BoxBreathingScreen`, `_BoxBreathingScreenState`, `_TimerPill`, `_LeafLevelsBar`
- Key methods: `_start()`, `_pause()`, `_reset()`, `_finish()`, `_advanceStep()`, `_pickQuote()`

✅ **lib/features/mind/breath/widgets/animated_breath_circle.dart**
- Animated circle widget with scale-based breathing animation
- Class: `AnimatedBreathCircle`
- Key properties: `progress` (0.0-1.0), `phase` ("inhale"|"hold"|"exhale")

✅ **lib/features/mind/breath/logic/box_levels.dart**
- Level definitions and gating logic
- Classes: `BoxLevel`, `BoxLevels`
- Key method: `BoxLevels.available(faithActivated, hideFaithOverlaysInMind)`

✅ **lib/features/mind/quotes/quote_picker.dart**
- Quote selection modal with filtering
- Classes: `QuoteItem`, `QuoteLibrary`
- Key function: `showQuotePicker(context, faithActivated, hideFaithOverlaysInMind, lightConsentGiven)`

✅ **lib/features/mind/faith/faith_consent.dart**
- Light mode consent dialog
- Key function: `askLightConsentIfNeeded(context, faithMode, hideFaithOverlaysInMind)`

### Settings Integration

✅ **lib/core/settings/settings_model.dart**
- `FaithTier` enum: `off`, `light`, `disciple`, `kingdom`
- `AppSettings` class with `faithTier` property
- **Gap:** No `hideFaithOverlaysInMind` property (hardcoded to `false`)

✅ **lib/services/faith_service.dart**
- `FaithMode` enum: `off`, `light`, `disciple`, `kingdom`
- Faith progression and XP system

### Tests

✅ **test/mind/box_levels_test.dart**
- Unit tests for `BoxLevels.available()` gating logic
- Tests: OFF mode, overlays hidden, faith ON scenarios

## Setup & Lifecycle

### Initialization (box_breathing_screen.dart:42-49)
```dart
@override
void initState() {
  super.initState();
  // default to l1
  _level = BoxLevels.l1;
  _totalRemaining = _level.defaultTotalSeconds;
  _stepRemaining = _level.inhale;
}
```

### State Variables
- `_level`: Current breathing level (BoxLevel)
- `_tick`: Timer for 1-second intervals
- `_totalRemaining`: Total session time remaining
- `_stepRemaining`: Current step time remaining
- `_step`: Current breathing phase (inhale/hold1/exhale/hold2)
- `_running`: Session active state
- `_stepProgress`: Animation progress (0.0-1.0)
- `_quote`: Selected quote for session
- `_lightConsentGiven`: Per-session consent flag

### Timer Logic (box_breathing_screen.dart:73-93)
```dart
Future<void> _start() async {
  if (_running) return;
  setState(() => _running = true);
  _track('breath_started', {'level': _level.id, 'total_seconds': _totalRemaining});
  _tick = Timer.periodic(const Duration(seconds: 1), (t) {
    if (!mounted) return;
    if (_totalRemaining <= 0) {
      _finish();
      return;
    }
    setState(() {
      _totalRemaining -= 1;
      _stepRemaining -= 1;
      final stepDuration = _currentStepDuration();
      _stepProgress = 1.0 - (_stepRemaining / stepDuration).clamp(0, 1);
      if (_stepRemaining <= 0) {
        _advanceStep();
      }
    });
  });
}
```

### Step Advancement (box_breathing_screen.dart:131-155)
```dart
void _advanceStep() {
  _haptic();
  setState(() {
    if (_step == BreathStep.inhale) {
      _step = BreathStep.hold1;
      _stepRemaining = _level.hold1;
    } else if (_step == BreathStep.hold1) {
      _step = BreathStep.exhale;
      _stepRemaining = _level.exhale;
    } else if (_step == BreathStep.exhale) {
      _step = BreathStep.hold2;
      _stepRemaining = _level.hold2;
    } else {
      _step = BreathStep.inhale;
      _stepRemaining = _level.inhale;
    }
    _stepProgress = 0.0;
    _track('breath_step_changed', {
      'level': _level.id,
      'step': _step.name,
      'remaining_step_s': _stepRemaining,
      'total_remaining_s': _totalRemaining
    });
  });
}
```

### Formatting Helper (box_breathing_screen.dart:208-212)
```dart
String _fmt(int s) {
  final m = (s ~/ 60).toString().padLeft(1, '0');
  final ss = (s % 60).toString().padLeft(2, '0');
  return '$m:$ss';
}
```

### Analytics Implementation (box_breathing_screen.dart:214-218)
```dart
void _track(String event, Map<String, dynamic> props) {
  // hook to your analytics
  // e.g., Analytics.track(event, props);
  print('Analytics: $event - $props');
}
```

## Animation Wiring

### Progress Calculation (box_breathing_screen.dart:86-87)
```dart
final stepDuration = _currentStepDuration();
_stepProgress = 1.0 - (_stepRemaining / stepDuration).clamp(0, 1);
```

### Phase Mapping (box_breathing_screen.dart:270)
```dart
phase: _step == BreathStep.inhale ? 'inhale' : (_step == BreathStep.exhale ? 'exhale' : 'hold')
```

### Scale Math (animated_breath_circle.dart:22-29)
```dart
double scale = 0.9;
if (phase == 'inhale') {
  scale = 0.75 + 0.25 * progress;
} else if (phase == 'exhale') {
  scale = 1.0 - 0.25 * progress;
} else {
  scale = 1.0;
}
```

### Animation Properties (animated_breath_circle.dart:32-35)
```dart
AnimatedScale(
  scale: scale,
  duration: const Duration(milliseconds: 200),
  curve: Curves.easeOut,
```

**Frame Rate Considerations:** Uses `Timer.periodic(Duration(seconds: 1))` for 1Hz updates, `AnimatedScale` with 200ms duration for smooth transitions. No `Ticker` usage - relies on Flutter's animation system.

## Level Presets & Gating

### Level Definitions (box_levels.dart:22-60)
```dart
static const l1 = BoxLevel(
  id: 'l1', title: 'L1 · 4-4-4-4',
  inhale: 4, hold1: 4, exhale: 4, hold2: 4,
  defaultTotalSeconds: 60,
);
static const l2 = BoxLevel(
  id: 'l2', title: 'L2 · 5-5-5-5',
  inhale: 5, hold1: 5, exhale: 5, hold2: 5,
  defaultTotalSeconds: 120,
);
static const l3 = BoxLevel(
  id: 'l3', title: 'L3 · 6-6-6-6',
  inhale: 6, hold1: 6, exhale: 6, hold2: 6,
  defaultTotalSeconds: 180,
);
static const l4 = BoxLevel(
  id: 'l4', title: 'L4 · 4-7-8-4',
  inhale: 4, hold1: 7, exhale: 8, hold2: 4,
  defaultTotalSeconds: 180,
);
```

### Gating Logic (box_levels.dart:64-70)
```dart
static List<BoxLevel> available({
  required bool faithActivated,
  required bool hideFaithOverlaysInMind,
}) {
  if (!faithActivated || hideFaithOverlaysInMind) return [l1];
  return all;
}
```

### Call Site (box_breathing_screen.dart:227-230)
```dart
final levels = BoxLevels.available(
  faithActivated: faithActivated,
  hideFaithOverlaysInMind: hideFaith,
);
```

**Gating Rules:**
- OFF mode OR `hideFaithOverlaysInMind` → only L1
- Faith ON → L1-L4 available

## Faith Consent (Light mode)

### Implementation (faith_consent.dart:6-76)
```dart
Future<bool> askLightConsentIfNeeded({
  required BuildContext context,
  required FaithMode faithMode,
  required bool hideFaithOverlaysInMind,
}) async {
  // Off or user hides overlays globally → never allow overlays.
  if (faithMode == FaithMode.off || hideFaithOverlaysInMind) return false;

  // Disciple/Kingdom → overlays allowed by default
  if (faithMode == FaithMode.disciple || faithMode == FaithMode.kingdom) return true;

  // Light → ask once per session.
  return await showDialog<bool>(...);
}
```

### Caller (box_breathing_screen.dart:165-171)
```dart
if (lightMode && canShowFaith && !_lightConsentGiven) {
  _lightConsentGiven = await askLightConsentIfNeeded(
    context: context,
    faithMode: _faithModeFromTier(settings.faithTier),
    hideFaithOverlaysInMind: hideFaith,
  );
}
```

### Storage (box_breathing_screen.dart:40)
```dart
bool _lightConsentGiven = false;
```

**Behavior:**
- OFF → no overlays
- Light → ask per session (stored in `_lightConsentGiven`)
- Disciple/KB → allowed by default (unless `hideFaithOverlaysInMind`)

**Gap:** No persistence across app restarts - consent resets on navigation.

## Quotes Picker Integration

### Implementation (box_breathing_screen.dart:157-188)
```dart
Future<void> _pickQuote() async {
  final settings = SettingsScope.of(context).value;
  final faithActivated = settings.faithTier != FaithTier.off;
  final hideFaith = false; // TODO: Add hideFaithOverlaysInMind to settings
  bool lightMode = settings.faithTier == FaithTier.light;
  
  // Light: require consent per session
  bool canShowFaith = faithActivated && !hideFaith;
  if (lightMode && canShowFaith && !_lightConsentGiven) {
    _lightConsentGiven = await askLightConsentIfNeeded(...);
  }
  
  bool allowed = canShowFaith ? (!lightMode || _lightConsentGiven) : false;
  
  final selected = await showQuotePicker(
    context: context,
    faithActivated: allowed,
    hideFaithOverlaysInMind: hideFaith,
    lightConsentGiven: allowed,
  );
  
  setState(() => _quote = selected);
  if (selected == null) {
    _track('quote_cleared', {});
  } else {
    _track('quote_selected', {'quote_id': selected.id});
  }
}
```

### Filtering Logic (quote_picker.dart:33-46)
```dart
List<QuoteItem> filtered({
  required bool allowFaith, 
  required bool allowSecular, 
  String q = '',
}) {
  return items.where((it) {
    final isFaith = it.tags.contains('faith');
    final isSec = it.tags.contains('secular');
    if (isFaith && !allowFaith) return false;
    if (isSec && !allowSecular) return false;
    if (q.isNotEmpty && !('${it.text} ${it.author}'.toLowerCase()).contains(q.toLowerCase())) return false;
    return true;
  }).toList();
}
```

### "None" Handling (quote_picker.dart:85)
```dart
TextButton(onPressed: () => Navigator.pop(ctx, null), child: const Text('None'))
```

**Filtering Rules:**
- Faith OFF → only secular quotes
- Faith ON + consent → faith + secular with "Faith quotes only" toggle
- Always includes "None" option

## Timers & Durations

### Step Durations by Level
- **L1:** 4-4-4-4 (16s per cycle)
- **L2:** 5-5-5-5 (20s per cycle)  
- **L3:** 6-6-6-6 (24s per cycle)
- **L4:** 4-7-8-4 (23s per cycle)

### Total Session Defaults
- **L1:** 60s
- **L2:** 120s
- **L3:** 180s
- **L4:** 180s

### Step Labels & Transitions (box_breathing_screen.dart:199-206)
```dart
String _stepLabel() {
  switch (_step) {
    case BreathStep.inhale: return 'Inhale';
    case BreathStep.hold1: return 'Hold';
    case BreathStep.exhale: return 'Exhale';
    case BreathStep.hold2: return 'Hold';
  }
}
```

**Transitions:** Inhale → Hold → Exhale → Hold → (repeat)

## Haptics & Accessibility

### Haptic Implementation (box_breathing_screen.dart:123-129)
```dart
Future<void> _haptic() async {
  try {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 20, amplitude: 32);
    }
  } catch (_) {}
}
```

### Trigger Site (box_breathing_screen.dart:132)
```dart
void _advanceStep() {
  _haptic();
  // ... step logic
}
```

**Accessibility Gap:** No `Semantics` labels or announcements found. Missing accessibility support for screen readers.

## Assets & Wiring

### pubspec.yaml (line 59)
```yaml
assets:
  - assets/mind/quotes/
```

### Quotes JSON Structure (assets/mind/quotes/quotes.json)
```json
[
  { "id": "q1", "text": "Between stimulus and response there is a space.", "author": "Viktor Frankl", "tags": ["secular","mind"] },
  { "id": "q3", "text": "Let this mind be in you, which was also in Christ Jesus.", "author": "Philippians 2:5 (KJV)", "tags": ["faith","renewal"] },
  { "id": "q6", "text": "Small order today strengthens tomorrow's mission.", "author": "UR4MORE", "tags": ["secular","aimup"] }
]
```

**Structure:** `id`, `text`, `author`, `tags` array with "faith" or "secular" markers

## Analytics

### Emitted Events with Payloads

**breath_started**
```dart
{'level': _level.id, 'total_seconds': _totalRemaining}
```

**breath_step_changed**
```dart
{
  'level': _level.id,
  'step': _step.name,
  'remaining_step_s': _stepRemaining,
  'total_remaining_s': _totalRemaining
}
```

**breath_paused**
```dart
{'level': _level.id, 'total_remaining_s': _totalRemaining}
```

**breath_reset**
```dart
{'level': _level.id}
```

**breath_completed**
```dart
{'level': _level.id}
```

**quote_selected**
```dart
{'quote_id': selected.id}
```

**quote_cleared**
```dart
{}
```

**Missing Events:** `breath_resumed`, `light_consent_set`

### Implementation Site (box_breathing_screen.dart:214-218)
```dart
void _track(String event, Map<String, dynamic> props) {
  // hook to your analytics
  // e.g., Analytics.track(event, props);
  print('Analytics: $event - $props');
}
```

## Tests & Status

### Existing Tests
✅ **test/mind/box_levels_test.dart** - BoxLevels.available gating tests

### Test Coverage
```dart
test('OFF → only L1', () {
  final list = BoxLevels.available(faithActivated: false, hideFaithOverlaysInMind: false);
  expect(list.length, 1);
  expect(list.first.id, 'l1');
});

test('Faith ON but overlays hidden → only L1', () {
  final list = BoxLevels.available(faithActivated: true, hideFaithOverlaysInMind: true);
  expect(list.length, 1);
  expect(list.first.id, 'l1');
});

test('Faith ON and overlays allowed → L1..L4', () {
  final list = BoxLevels.available(faithActivated: true, hideFaithOverlaysInMind: false);
  expect(list.length, 4);
  expect(list.map((e) => e.id), ['l1','l2','l3','l4']);
});
```

### Missing Tests (TODOs)
- Timer logic and step advancement
- Animation progress calculation
- Quote picker filtering
- Faith consent dialog
- Haptic feedback
- Analytics event emission
- UI widget rendering

## Spec Compliance Checklist

| Requirement | Status | Notes |
|-------------|--------|-------|
| 430px clamp; no overflow | ✅ | Uses `ConstrainedBox(maxWidth: 430)` in quote picker |
| Animated circle syncs with steps | ✅ | `_stepProgress` and `phase` properly calculated |
| Per-step + total countdown | ✅ | `_TimerPill` widgets show both timers |
| L1 only in Faith OFF / overlays hidden | ✅ | `BoxLevels.available()` gating works |
| L1–L4 in Faith ON, with Light consent per session | ✅ | Full level access with consent dialog |
| Quote picker: user choice; "None" option; faith/secular filters | ✅ | All features implemented |
| Analytics events present | ⚠️ | Most events present, missing `breath_resumed`, `light_consent_set` |
| Haptic on step change | ✅ | `_haptic()` called in `_advanceStep()` |
| Accessibility (labels/announce) | ❌ | No Semantics or screen reader support |

## Gaps & Suggested Fixes

### Gap: Missing hideFaithOverlaysInMind Setting
**Current:** Hardcoded to `false` in box_breathing_screen.dart:160, 226  
**Suggested Fix:** Add `hideFaithOverlaysInMind` property to `AppSettings` class

### Gap: Light Consent Not Persisted
**Current:** `_lightConsentGiven` resets on navigation  
**Suggested Fix:** Store consent in SharedPreferences with session key

### Gap: Missing Analytics Events
**Current:** No `breath_resumed` or `light_consent_set` events  
**Suggested Fix:** Add `_track('breath_resumed', ...)` in `_start()` and `_track('light_consent_set', ...)` in consent dialog

### Gap: No Accessibility Support
**Current:** No Semantics labels or announcements  
**Suggested Fix:** Add `Semantics` widgets with labels and `announceForAccessibility()` calls

### Gap: Missing Test Coverage
**Current:** Only level gating tests exist  
**Suggested Fix:** Add widget tests for timer logic, animation, and user interactions

---

**Report Generated:** $(date)  
**Implementation Status:** ✅ Functional with minor gaps  
**Ready for Production:** ⚠️ Needs accessibility and persistence improvements
