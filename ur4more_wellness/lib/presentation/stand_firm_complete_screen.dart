import 'package:flutter/material.dart';

import '../design/tokens.dart';
import '../routes/app_routes.dart';

class StandFirmCompleteScreen extends StatelessWidget {
  const StandFirmCompleteScreen({super.key});

  void _goToMain(BuildContext context, int tabIndex) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.main,
      (route) => false,
      arguments: tabIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = theme.textTheme;
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Stand Firm Complete'),
        backgroundColor: cs.surface,
      ),
      body: SafeArea(
        child: Padding(
          padding: Pad.page,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Stand Firm Complete', style: t.headlineMedium),
              const SizedBox(height: AppSpace.x2),
              Text(
                'You anchored in truth. Now build the day.',
                style: t.bodyLarge,
              ),
              const SizedBox(height: AppSpace.x4),
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: Pad.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Next moves',
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: AppSpace.x2),
                      Text(
                        'Choose where to focus next. You can always return to Stand Firm from Home.',
                        style: t.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _goToMain(context, 0),
                  child: const Text("Go to Today's Plan"),
                ),
              ),
              const SizedBox(height: AppSpace.x2),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _goToMain(context, 3),
                  child: const Text('Explore Spirit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
