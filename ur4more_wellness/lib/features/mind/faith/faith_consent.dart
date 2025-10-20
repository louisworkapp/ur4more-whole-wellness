import 'package:flutter/material.dart';
import '../../../services/faith_service.dart';

/// Ask once per session whether Light users want faith overlays (quotes/verses).
/// Returns `true` if faith overlays are allowed for this session.
Future<bool> askLightConsentIfNeeded({
  required BuildContext context,
  required FaithMode faithMode,
  required bool hideFaithOverlaysInMind,
}) async {
  // Off or user hides overlays globally → never allow overlays.
  if (faithMode == FaithMode.off || hideFaithOverlaysInMind) return false;

  // Disciple/Kingdom → overlays allowed by default (user can still hide via global toggle).
  if (faithMode == FaithMode.disciple || faithMode == FaithMode.kingdom) return true;

  // Light → ask once per session.
  return await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          final t = Theme.of(ctx);
          final cs = t.colorScheme;
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.wb_sunny_outlined, color: cs.primary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Show faith overlays this session?',
                        style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    'You\'ll see optional verses/quotes aligned to your practice. '
                    'You can choose "Secular only" anytime.',
                    style: t.textTheme.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Secular only'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Allow this session'),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          );
        },
      ) ??
      false;
}
