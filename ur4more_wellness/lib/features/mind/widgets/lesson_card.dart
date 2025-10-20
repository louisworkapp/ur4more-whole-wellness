import 'package:flutter/material.dart';

class LessonCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? footnote;
  final VoidCallback onStart;

  const LessonCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onStart,
    this.footnote,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: cs.shadow.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: cs.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.wb_sunny_outlined, color: cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: t.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          if (footnote != null) ...[
            const SizedBox(height: 8),
            Text(
              footnote!,
              style: t.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant.withOpacity(0.8),
              ),
            ),
          ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onStart,
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Start 5-minute routine'),
            ),
          ),
        ],
      ),
    );
  }
}