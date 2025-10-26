import 'package:flutter/material.dart';
import '../../../../design/mind_tokens.dart';

class InspirationBanner extends StatelessWidget {
  final String title; final String body; final String? caption;
  const InspirationBanner({super.key, required this.title, required this.body, this.caption});

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
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height:6),
        Text(body, style: const TextStyle(color: MindColors.textSub, height:1.45)),
        if (caption != null) ...[
          const SizedBox(height:8),
          Text(caption!, style: const TextStyle(color: MindColors.textSub, fontSize: 12)),
        ],
      ]),
    );
  }
}
