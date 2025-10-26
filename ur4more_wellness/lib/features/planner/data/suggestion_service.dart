import '../domain/plan_models.dart';

class SuggestionService {
  // Replace with ContentGateway calls later; this is faith-aware via flags.
  List<PlanBlock> suggest({
    required DateTime startAt,
    required bool focusMind,
    required bool focusBody,
    required bool focusSpirit,
    required bool faithActivated,
    required bool showFaithOverlay,
  }) {
    final List<PlanBlock> out = [];
    DateTime t = startAt;

    if (focusMind) {
      out.add(PlanBlock(
        id: 'mind_breath_${t.millisecondsSinceEpoch}',
        title: 'Mind: Box Breathing',
        category: CoachCategory.mind,
        start: t, end: t.add(const Duration(minutes: 3)),
        fromCoach: true,
        verseRef: faithActivated ? 'Phil 4:6–7' : null,
        verseEnabled: faithActivated && showFaithOverlay,
      ));
      t = t.add(const Duration(minutes: 4));
    }

    if (focusBody) {
      out.add(PlanBlock(
        id: 'body_mobility_${t.millisecondsSinceEpoch}',
        title: 'Body: Mobility Snack',
        category: CoachCategory.body,
        start: t, end: t.add(const Duration(minutes: 3)),
        fromCoach: true,
      ));
      t = t.add(const Duration(minutes: 4));
      
      out.add(PlanBlock(
        id: 'body_walk_${t.millisecondsSinceEpoch}',
        title: 'Body: 10-min Walk',
        category: CoachCategory.body,
        start: t, end: t.add(const Duration(minutes: 10)),
        fromCoach: true,
      ));
      t = t.add(const Duration(minutes: 11));
      
      out.add(PlanBlock(
        id: 'body_water_${t.millisecondsSinceEpoch}',
        title: 'Body: Hydration Reminder',
        category: CoachCategory.body,
        start: t, end: t.add(const Duration(minutes: 1)),
        fromCoach: true,
      ));
      t = t.add(const Duration(minutes: 2));
    }

    if (focusSpirit && faithActivated) {
      out.add(PlanBlock(
        id: 'spirit_dev_${t.millisecondsSinceEpoch}',
        title: 'Spirit: 60-sec Verse & Prayer',
        category: CoachCategory.spirit,
        start: t, end: t.add(const Duration(minutes: 1)),
        fromCoach: true,
        verseRef: 'Matt 4:19',
        verseEnabled: showFaithOverlay,
      ));
      t = t.add(const Duration(minutes: 2));
      
      // Add Walk in the Light exercise
      out.add(PlanBlock(
        id: 'spirit_walk_${t.millisecondsSinceEpoch}',
        title: 'Spirit: Walk in the Light',
        category: CoachCategory.spirit,
        start: t, end: t.add(const Duration(minutes: 5)),
        fromCoach: true,
        verseRef: 'John 8:12',
        verseEnabled: showFaithOverlay,
      ));
    }
    return out;
  }
}
