import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../services/faith_service.dart';

class GoDeeperCardData {
  final String title;
  final String body;
  final List<String> bullets;
  final String primaryLabel;
  final String primaryAction;
  final String? secondaryLabel;
  final String? secondaryAction;
  final Duration cooldown;
  final Duration snoozeOnDismiss;
  GoDeeperCardData({
    required this.title,
    required this.body,
    required this.bullets,
    required this.primaryLabel,
    required this.primaryAction,
    this.secondaryLabel,
    this.secondaryAction,
    required this.cooldown,
    required this.snoozeOnDismiss,
  });

  static Future<GoDeeperCardData> load(FaithTier mode) async {
    final raw = json.decode(await rootBundle.loadString('assets/mind/go_deeper_card.json')) as Map<String, dynamic>;
    final m = raw[mode.isOff ? 'off' : 'activated'] as Map<String, dynamic>;
    final rl = (raw['off']?['rateLimit'] ?? {}) as Map<String, dynamic>;
    return GoDeeperCardData(
      title: m['title'] ?? (mode.isOff ? 'Go deeper' : 'Walk in the Light'),
      body: m['body'] ?? '',
      bullets: (m['bullets'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      primaryLabel: (m['primaryCta']?['label'] ?? 'Explore') as String,
      primaryAction: (m['primaryCta']?['action'] ?? 'none') as String,
      secondaryLabel: m['secondaryCta']?['label'],
      secondaryAction: m['secondaryCta']?['action'],
      cooldown: Duration(hours: (rl['cooldownHours'] ?? 24) as int),
      snoozeOnDismiss: Duration(days: (rl['snoozeDaysOnDismiss'] ?? 7) as int),
    );
  }
}

class GoDeeperCard extends StatelessWidget {
  final FaithTier mode;
  final Future<bool> Function(Duration cooldown) onExplore;   // returns true if action taken
  final Future<void> Function(Duration snooze) onDismiss;     // snooze invites
  final VoidCallback? onOpenSettings;                         // for activated state
  final List<String> contextTags;                             // e.g., ["week_complete"]
  final bool eligible;                                        // rate-limit checked outside
  const GoDeeperCard({
    super.key,
    required this.mode,
    required this.onExplore,
    required this.onDismiss,
    required this.contextTags,
    required this.eligible,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    if (!eligible) return const SizedBox.shrink();
    return FutureBuilder<GoDeeperCardData>(
      future: GoDeeperCardData.load(mode),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final data = snap.data!;
        final cs = Theme.of(context).colorScheme;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cs.primary.withOpacity(0.18), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(data.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(data.body, style: Theme.of(context).textTheme.bodyMedium),
              if (mode.isOff && data.bullets.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...data.bullets.map((b) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6.0, right: 8.0),
                      child: Icon(Icons.check, size: 16),
                    ),
                    Expanded(child: Text(b)),
                  ],
                )),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (mode.isOff && data.primaryAction == 'activate_light') {
                          final ok = await onExplore(data.cooldown);
                          if (ok && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Faith Mode: Light activated')),
                            );
                          }
                        } else if (!mode.isOff && data.primaryAction == 'open_settings') {
                          onOpenSettings?.call();
                        }
                      },
                      child: Text(data.primaryLabel),
                    ),
                  ),
                  if (mode.isOff && data.secondaryLabel != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await onDismiss(data.snoozeOnDismiss);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('We\'ll keep the secular tools front and center.')),
                            );
                          }
                        },
                        child: Text(data.secondaryLabel!),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              // Accessibility hint
              Semantics(
                label: 'Go deeper invitation',
                hint: mode.isOff
                    ? 'Explore Faith Mode or continue with secular tools'
                    : 'Manage faith overlay settings',
                child: const SizedBox.shrink(),
              )
            ],
          ),
        );
      },
    );
  }
}
