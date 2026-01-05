import 'package:flutter/material.dart';
import '../core/services/settings_service.dart';
import '../data/creed_repository.dart';
import '../services/faith_service.dart';
import 'verse_reveal_chip.dart';

class HomeTruthCallout extends StatelessWidget {
  final FaithTier mode;

  const HomeTruthCallout({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    
    return FutureBuilder<CreedData>(
      future: CreedRepository().load(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceVariant.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text('Staying oriented to truth…'),
          );
        }
        
        final creed = snap.data!;
        final title = mode.isOff
            ? 'Choose what leads to life'
            : 'Walk in the Light';
        final body = mode.isOff
            ? 'Culture and habits shape thoughts. Aim up with honesty, responsibility, and courage.'
            : creed.short;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: scheme.surfaceVariant.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: scheme.primary.withOpacity(0.18)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              if (mode.isActivated && creed.kvs.isNotEmpty) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: VerseRevealChip(
                    mode: mode,
                    ref: creed.kvs.first['ref']!,
                    text: creed.kvs.first['text']!,
                    askConsentLight: creed.showConsentForFaithOverlays,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
