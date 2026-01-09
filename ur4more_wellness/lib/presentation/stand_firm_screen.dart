import 'package:flutter/material.dart';

import '../core/app_export.dart';
import '../design/tokens.dart';

class StandFirmScreen extends StatelessWidget {
  const StandFirmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stand Firm'),
        backgroundColor: cs.surface,
      ),
      body: Center(
        child: Padding(
          padding: Pad.page,
          child: Text(
            'Stand Firm coming soon',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
