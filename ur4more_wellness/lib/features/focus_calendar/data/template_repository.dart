import '../domain/block_models.dart';

class TemplateRepository {
  // Simple weekly anchors; expand later.
  List<PlanBlock> mondayMorningAnchors(DateTime base) {
    final s1 = DateTime(base.year, base.month, base.day, 9, 0);
    return [
      PlanBlock(
        id:'deep_${s1.millisecondsSinceEpoch}', title:'Mind: Deep Focus Block',
        category: CoachCategory.mind, start:s1, end:s1.add(const Duration(minutes:90)),
        fromCoach:true, impl: const ImplementationIntent(cue:'After planning', location:'Desk', firstStep:'Open doc'),
      ),
    ];
  }
}
