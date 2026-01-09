import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/app_export.dart';
import '../core/services/auth_service.dart';
import '../core/state/points_store.dart';
import '../design/tokens.dart';
import '../routes/app_routes.dart';
import '../theme/tokens.dart';

/// Smoke test:
/// - Launch → Welcome → Start Stand Firm → Complete → Go to Today's Plan
/// - Verify points increase and Home hero animates
/// - Verify "Explore full app" bypass works
class StandFirmScreen extends StatefulWidget {
  const StandFirmScreen({super.key});

  @override
  State<StandFirmScreen> createState() => _StandFirmScreenState();
}

class _StandFirmScreenState extends State<StandFirmScreen> {
  final List<String> _pressures = const [
    'Anxiety',
    'Temptation',
    'Anger',
    'Shame',
    'Distraction',
    'Exhaustion',
  ];

  int _stepIndex = 0;
  String? _selectedPressure;
  bool _isCompleting = false;

  String get _pressureLabel => _selectedPressure ?? 'Pressure';

  void _onPrimary() {
    if (_stepIndex == 0) {
      if (_selectedPressure == null) return;
      HapticFeedback.lightImpact();
      setState(() => _stepIndex = 1);
      return;
    }
    if (_stepIndex == 1) {
      HapticFeedback.lightImpact();
      setState(() => _stepIndex = 2);
      return;
    }
    if (_stepIndex == 2) {
      _completeStandFirm();
    }
  }

  void _onExploreFullApp() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.main,
      (route) => false,
      arguments: 0,
    );
  }

  void _onSkip() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      _onExploreFullApp();
    }
  }

  Future<void> _completeStandFirm() async {
    if (_isCompleting) return;
    setState(() => _isCompleting = true);
    final pressure = _pressureLabel;

    try {
      String? userId = await AuthService.getCurrentUserId();
      if (userId == null && kDebugMode) {
        userId = 'debug_user';
      }

      if (userId != null) {
        await PointsStore.i.load(userId);
        await PointsStore.i.awardCategory(
          userId: userId,
          category: 'spirit',
          delta: 25,
          action: 'stand_firm_completed',
          note: pressure,
        );
      }
    } catch (e) {
      debugPrint('StandFirmScreen: error completing: $e');
    } finally {
      if (!mounted) return;
      setState(() => _isCompleting = false);
      Navigator.pushNamed(
        context,
        AppRoutes.standFirmComplete,
        arguments: {'pressure': pressure},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final t = theme.textTheme;

    final primaryLabel = switch (_stepIndex) {
      0 => 'Start Stand Firm',
      1 => 'Anchor Now',
      _ => 'Complete Stand Firm',
    };

    final primaryEnabled = _stepIndex == 0 ? _selectedPressure != null : true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stand Firm'),
        backgroundColor: cs.surface,
      ),
      body: SafeArea(
        child: Padding(
          padding: Pad.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _StepHeader(stepIndex: _stepIndex),
              const SizedBox(height: AppSpace.x3),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _buildStepContent(t, cs),
                ),
              ),
              const SizedBox(height: AppSpace.x3),
              _Actions(
                primaryLabel: primaryLabel,
                primaryEnabled: primaryEnabled && !_isCompleting,
                isLoading: _isCompleting,
                onPrimary: _onPrimary,
                onExplore: _onExploreFullApp,
                onSkip: _onSkip,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent(TextTheme t, ColorScheme cs) {
    switch (_stepIndex) {
      case 0:
        return _PressureStep(
          pressures: _pressures,
          selectedPressure: _selectedPressure,
          onSelect: (value) => setState(() => _selectedPressure = value),
        );
      case 1:
        return _TruthAnchorStep(pressure: _pressureLabel, textTheme: t, colorScheme: cs);
      default:
        return _NextStepsStep(pressure: _pressureLabel, textTheme: t, colorScheme: cs);
    }
  }
}

class _StepHeader extends StatelessWidget {
  final int stepIndex;
  const _StepHeader({required this.stepIndex});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final steps = ['Pick the pressure', 'Truth Anchor', 'Next Step'];
    final descriptions = [
      'Choose what is pressing you right now.',
      'Read and breathe this anchor.',
      'Take a quick step for Spirit, Mind, Body.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Stand Firm Demo', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpace.x1),
        Row(
          children: List.generate(steps.length, (index) {
            final active = index <= stepIndex;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: index == steps.length - 1 ? 0 : AppSpace.x1),
                decoration: BoxDecoration(
                  color: active ? T.gold : T.ink300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpace.x2),
        Text(steps[stepIndex], style: t.headlineSmall),
        const SizedBox(height: AppSpace.x1),
        Text(descriptions[stepIndex], style: t.bodyMedium),
      ],
    );
  }
}

class _PressureStep extends StatelessWidget {
  final List<String> pressures;
  final String? selectedPressure;
  final ValueChanged<String> onSelect;

  const _PressureStep({
    required this.pressures,
    required this.selectedPressure,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pick the pressure', style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpace.x2),
        Wrap(
          spacing: AppSpace.x2,
          runSpacing: AppSpace.x2,
          children: pressures
              .map((p) => ChoiceChip(
                    label: Text(p),
                    selected: selectedPressure == p,
                    onSelected: (_) => onSelect(p),
                  ))
              .toList(),
        ),
        const SizedBox(height: AppSpace.x3),
        Text(
          '2–3 steps. ~60–90 seconds. You can bail anytime.',
          style: t.bodySmall,
        ),
      ],
    );
  }
}

class _TruthAnchorStep extends StatelessWidget {
  final String pressure;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _TruthAnchorStep({
    required this.pressure,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: Pad.card,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Truth Anchor', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpace.x1),
            Text('Pressure: $pressure', style: textTheme.bodySmall?.copyWith(color: colorScheme.primary)),
            const SizedBox(height: AppSpace.x2),
            Text(
              '"Stand firm then, with the belt of truth buckled around your waist."',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpace.x1),
            Text(
              'Truth: You are steadied by truth, not by the pressure.',
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: AppSpace.x2),
            Text(
              'Breathe slow for 5 seconds. Say the truth once.',
              style: textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}

class _NextStepsStep extends StatelessWidget {
  final String pressure;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _NextStepsStep({
    required this.pressure,
    required this.textTheme,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final cards = [
      {
        'title': 'Spirit',
        'text': 'Ask: "Spirit, steady me here."',
        'icon': Icons.auto_awesome,
        'color': colorScheme.primary,
      },
      {
        'title': 'Mind',
        'text': 'What lie is trying to steer you?',
        'icon': Icons.psychology_alt,
        'color': T.mint,
      },
      {
        'title': 'Body',
        'text': 'Take a 2-min reset: slow breaths + stretch.',
        'icon': Icons.self_improvement,
        'color': T.blue,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          child: Padding(
            padding: Pad.card,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Next Step', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpace.x1),
                Text('Pressure: $pressure', style: textTheme.bodySmall?.copyWith(color: colorScheme.primary)),
                const SizedBox(height: AppSpace.x2),
                ...cards.map(
                  (card) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpace.x1),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(AppSpace.x1),
                          decoration: BoxDecoration(
                            color: (card['color'] as Color).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(card['icon'] as IconData, color: card['color'] as Color),
                        ),
                        const SizedBox(width: AppSpace.x2),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                card['title'] as String,
                                style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(card['text'] as String, style: textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Actions extends StatelessWidget {
  final String primaryLabel;
  final bool primaryEnabled;
  final bool isLoading;
  final VoidCallback onPrimary;
  final VoidCallback onExplore;
  final VoidCallback onSkip;

  const _Actions({
    required this.primaryLabel,
    required this.primaryEnabled,
    required this.isLoading,
    required this.onPrimary,
    required this.onExplore,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton(
          onPressed: primaryEnabled ? onPrimary : null,
          child: isLoading
              ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(primaryLabel),
        ),
        const SizedBox(height: AppSpace.x2),
        OutlinedButton(
          onPressed: onExplore,
          child: const Text('Explore the full app'),
        ),
        TextButton(
          onPressed: onSkip,
          child: const Text('Skip for now'),
        ),
      ],
    );
  }
}
