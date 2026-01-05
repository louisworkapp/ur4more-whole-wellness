import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'exercise_model.dart';
import '../faith/faith_consent.dart';
import '../../../core/settings/settings_model.dart';
import '../../../services/faith_service.dart';

class ExerciseRunnerScreen extends StatefulWidget {
  final Exercise exercise;
  const ExerciseRunnerScreen({super.key, required this.exercise});

  @override
  State<ExerciseRunnerScreen> createState() => _ExerciseRunnerScreenState();
}

class _ExerciseRunnerScreenState extends State<ExerciseRunnerScreen> {
  int idx = -1; // -1 = intro
  bool _lightConsentGiven = false;
  bool _asked = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeAskLight();
  }

  Future<void> _maybeAskLight() async {
    // For now, we'll use a simple approach since we don't have access to AppSettings
    // In a real implementation, you'd get this from context.read<AppSettings>()
    final faithMode = FaithTier.off; // This should come from settings
    final hideFaith = false; // This should come from settings

    if (faithMode == FaithTier.light && !_asked && !hideFaith) {
      _asked = true;
      _lightConsentGiven = await askLightConsentIfNeeded(
        context: context,
        faithMode: FaithTier.light,
        hideFaithOverlaysInMind: hideFaith,
      );
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final e = widget.exercise;

    // For now, we'll use simple defaults - in real implementation, get from settings
    final faithMode = FaithTier.off; // This should come from context.read<AppSettings>()
    final hideFaith = false; // This should come from context.read<AppSettings>()

    final faithOn = faithMode != FaithTier.off;
    final canShowFaith = faithOn && !hideFaith && (faithMode == FaithTier.light ? _lightConsentGiven : true);

    final overlay = faithMode == FaithTier.disciple
        ? e.overlays.disciple
        : faithMode == FaithTier.kingdom
            ? e.overlays.kingdom
            : e.overlays.light;

    final overlayBlocks = canShowFaith ? overlay : const OverlayBlock();

    return Scaffold(
      appBar: AppBar(title: Text(e.title)),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Safety notes
                  if (e.safetyNotes.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.primary.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.primary.withOpacity(0.15)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: e.safetyNotes.map((s) =>
                          Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $s', style: t.textTheme.bodySmall))).toList(),
                      ),
                    ),
                  const SizedBox(height: 8),

                  // Intro or step content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (idx == -1) ...[
                            Text(e.summary, style: t.textTheme.bodyMedium),
                            const SizedBox(height: 8),
                            Text(e.offCopy.intro, style: t.textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
                          ] else ...[
                            Text(e.offCopy.steps[idx].label, style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                            const SizedBox(height: 6),
                            Text(e.offCopy.steps[idx].body, style: t.textTheme.bodyMedium),
                          ],
                          const SizedBox(height: 12),
                          if (overlayBlocks.verseKJV.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: cs.outline.withOpacity(0.2)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (overlayBlocks.prompt != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: Text(overlayBlocks.prompt!, style: t.textTheme.bodySmall),
                                    ),
                                  ...overlayBlocks.verseKJV.map((v) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Text('"${v['text']}" — ${v['ref']} (KJV)', style: t.textTheme.bodySmall),
                                  )),
                                  if (overlayBlocks.identity != null)
                                    Text(overlayBlocks.identity!, style: t.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                                  if (overlayBlocks.commission != null)
                                    Text(overlayBlocks.commission!, style: t.textTheme.bodySmall?.copyWith(fontStyle: FontStyle.italic)),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Controls
                  Row(
                    children: [
                      if (idx > -1)
                        TextButton(
                          onPressed: () => setState(() => idx = math.max(-1, idx - 1)),
                          child: const Text('Back'),
                        ),
                      const Spacer(),
                      FilledButton(
                        onPressed: () {
                          if (idx < e.offCopy.steps.length - 1) {
                            setState(() => idx += 1);
                          } else if (idx == e.offCopy.steps.length - 1) {
                            // completion
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Great job'),
                                content: Text(e.offCopy.completion),
                                actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))],
                              ),
                            );
                          } else {
                            setState(() => idx = 0);
                          }
                        },
                        child: Text(idx == -1 ? 'Start' : idx < e.offCopy.steps.length - 1 ? 'Next' : 'Finish'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
