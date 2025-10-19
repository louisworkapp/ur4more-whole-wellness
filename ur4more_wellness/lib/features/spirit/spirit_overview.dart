import 'package:flutter/material.dart';
import '../../data/creed_repository.dart';
import '../../services/faith_service.dart';
import '../../widgets/verse_reveal_chip.dart';

class SpiritOverview extends StatelessWidget {
  final FaithMode mode;

  const SpiritOverview({super.key, required this.mode});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CreedData>(
      future: CreedRepository().load(),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final creed = snap.data!;
        
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Our Creed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              creed.hero,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            if (mode.isActivated) ...[
              Text(
                'Scripture (KJV)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: creed.kvs.map((v) => VerseRevealChip(
                  mode: mode,
                  ref: v['ref']!,
                  text: v['text']!,
                  askConsentLight: creed.showConsentForFaithOverlays,
                )).toList(),
              ),
            ] else ...[
              // OFF mode invitation
              const SizedBox(height: 8),
              Text(
                'You can explore this with gentle faith overlays any time. Faith Mode is optional and consent-driven.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 24),
            FilledButton(
              onPressed: mode.isOff ? () => _promptActivateLight(context) : null,
              child: Text(mode.isOff ? 'Explore Faith Mode' : 'Faith Mode Active'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _promptActivateLight(BuildContext context) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Try Faith Mode: Light'),
        content: const Text('Same tools, gentle faith overlays. You can turn them off anytime.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Activate Light'),
          ),
        ],
      ),
    );
    
    if (ok == true) {
      // TODO: set faith mode to Light via your AppSettings
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Faith Mode: Light activated')),
        );
      }
    }
  }
}
