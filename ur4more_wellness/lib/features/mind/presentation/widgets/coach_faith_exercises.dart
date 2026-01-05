import 'package:flutter/material.dart';
import '../../../../services/faith_service.dart';
import '../../../../data/mind_faith_exercises_repository.dart';
import '../../widgets/faith_exercise_tile.dart';
import '../../../../core/settings/settings_scope.dart';

class CoachFaithExercises extends StatelessWidget {
  const CoachFaithExercises({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsScope.of(context).value;
    final mode = _getFaithTierFromTier(settings.faithTier);
    
    if (!mode.isActivated) return const SizedBox.shrink();

    return FutureBuilder<List<FaithExercise>>(
      future: MindFaithExercisesRepository().load(),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final exercises = snap.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Faith Exercises', 
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              )
            ),
            const SizedBox(height: 8),
            Text(
              'Mind Coach provides self-help coaching, not medical care. If you\'re in crisis, call 988 (US) or local emergency services.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 12),
            ...exercises.map((ex) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: FaithExerciseTile(
                mode: mode,
                ex: ex,
                overlaysHidden: false, // TODO: Add hideFaithOverlaysInMind to AppSettings
                onStart: () {
                  // TODO: navigate to exercise runner page
                  // For now, show a demo message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Starting ${ex.title}...'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            )),
          ],
        );
      },
    );
  }

  FaithTier _getFaithTierFromTier(dynamic faithTier) {
    // Convert FaithTier to FaithTier
    switch (faithTier.toString()) {
      case 'FaithTier.off':
        return FaithTier.off;
      case 'FaithTier.light':
        return FaithTier.light;
      case 'FaithTier.disciple':
        return FaithTier.disciple;
      case 'FaithTier.kingdom':
        return FaithTier.kingdom;
      default:
        return FaithTier.off;
    }
  }
}
