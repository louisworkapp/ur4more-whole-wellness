import 'package:flutter/material.dart';
import 'insight_service.dart';

class MicroInsightCard extends StatelessWidget {
  final String exerciseId;
  final InsightService service;
  
  const MicroInsightCard({
    super.key, 
    required this.exerciseId, 
    required this.service
  });

  String _fmt(double v) => (v >= 0 ? "+" : "") + v.toStringAsFixed(1);

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    
    return FutureBuilder<MicroInsight?>(
      future: service.forExercise(exerciseId),
      builder: (context, snap) {
        if (!snap.hasData) return const SizedBox.shrink();
        final mi = snap.data!;
        if (mi.count < 2) return const SizedBox.shrink();
        
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cs.surfaceVariant.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.primary.withOpacity(0.15))
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your recent results", 
                style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 12, 
                runSpacing: 6, 
                children: [
                  if (mi.avgDeltaMood != null) 
                    Chip(label: Text("Mood ${_fmt(mi.avgDeltaMood!)}")),
                  if (mi.avgDeltaUrge != null) 
                    Chip(label: Text("Urge ${_fmt(mi.avgDeltaUrge!)}")),
                  if (mi.avgPostConfidence != null) 
                    Chip(label: Text("Confidence ${mi.avgPostConfidence!.toStringAsFixed(1)}")),
                  Chip(label: Text("Last ${mi.count} runs"))
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
