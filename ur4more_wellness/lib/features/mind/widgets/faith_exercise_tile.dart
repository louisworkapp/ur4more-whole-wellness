import 'package:flutter/material.dart';
import '../../../../services/faith_service.dart';
import '../../../../widgets/verse_reveal_chip.dart';
import '../../../../data/mind_faith_exercises_repository.dart';

class FaithExerciseTile extends StatelessWidget {
  final FaithTier mode;
  final FaithExercise ex;
  final bool overlaysHidden; // settings.hide_faith_overlays_in_mind
  final VoidCallback onStart;
  const FaithExerciseTile({
    super.key, 
    required this.mode, 
    required this.ex, 
    required this.onStart, 
    required this.overlaysHidden
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceVariant.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.primary.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ex.title, 
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700
            )
          ),
          const SizedBox(height: 4),
          Text(ex.summary),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: ex.steps.take(3).map((s) =>
              Chip(
                label: Text(
                  s, 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                )
              )
            ).toList(),
          ),
          if (!overlaysHidden && mode.isActivated && ex.scriptureKJV.isNotEmpty) ...[
            const SizedBox(height: 8),
            VerseRevealChip(
              mode: mode,
              ref: ex.scriptureKJV.first['ref']!,
              text: ex.scriptureKJV.first['text']!,
              askConsentLight: true,
            ),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              child: Text(
                ex.timerSeconds != null 
                  ? 'Start (${ex.timerSeconds}s)' 
                  : 'Start'
              ),
            ),
          ),
        ],
      ),
    );
  }
}
