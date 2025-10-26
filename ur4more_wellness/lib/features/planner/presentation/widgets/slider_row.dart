import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SliderRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  const SliderRow({super.key, required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        Slider(
          min: 1, max: 10, divisions: 9, value: value.toDouble(),
          onChanged: (v){ onChanged(v.round()); },
          onChangeEnd: (_) { HapticFeedback.lightImpact(); },
        ),
      ],
    );
  }
}
