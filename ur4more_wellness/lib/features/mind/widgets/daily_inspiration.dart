import 'package:flutter/material.dart';
import '../../../services/faith_service.dart';
import '../../../widgets/verse_reveal_chip.dart';
import '../../../quotes/quotes_repository.dart';

class DailyInspiration extends StatelessWidget {
  final FaithMode mode;
  final bool hideFaithOverlaysInMind;
  
  const DailyInspiration({
    super.key, 
    required this.mode, 
    required this.hideFaithOverlaysInMind,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final offMode = mode.isOff;
    
    return FutureBuilder<Quote?>(
      future: QuotesRepository().pickDaily(offMode: offMode),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceVariant.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('Finding something good for today…'),
          );
        }
        
        final q = snap.data!;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Daily Inspiration', 
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"${q.text}"', 
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 6),
              Text(
                '— ${q.author}', 
                style: Theme.of(context).textTheme.bodySmall,
              ),
              if (!offMode && 
                  !hideFaithOverlaysInMind && 
                  q.scriptureEnabled && 
                  q.scriptureRef.isNotEmpty) ...[
                const SizedBox(height: 10),
                VerseRevealChip(
                  mode: mode,
                  ref: q.scriptureRef,
                  text: q.scriptureText,
                  askConsentLight: true,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
