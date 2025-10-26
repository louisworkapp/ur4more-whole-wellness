import 'package:flutter/material.dart';
import '../../../../design/mind_tokens.dart';
import 'badge_chip.dart';

class FreshStartCard extends StatelessWidget {
  final VoidCallback onPlanWeek;
  const FreshStartCard({super.key, required this.onPlanWeek});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MindColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MindColors.outline),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Fresh Start', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height:8),
        const Text('New week or month? Let\'s reset priorities and schedule the important first.',
          style: TextStyle(color: MindColors.textSub)),
        const SizedBox(height:12),
        const Wrap(spacing:8, children: [
          BadgeChip(label: 'Time-block the week', color: MindColors.brandBlue),
          BadgeChip(label: 'Buffers by default', color: MindColors.blue200),
        ]),
        const SizedBox(height:12),
        SizedBox(width: double.infinity,
          child: ElevatedButton(onPressed: onPlanWeek, child: const Text('Plan this week', style: TextStyle(fontWeight: FontWeight.w700))),
        )
      ]),
    );
  }
}
