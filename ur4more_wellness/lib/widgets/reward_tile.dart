import 'package:flutter/material.dart';
import '../theme/brand_tokens.dart';
import 'brand_card.dart';

class RewardTile extends StatelessWidget {
  final String title;
  final int cost;
  final String iconPath; // png or svg (use flutter_svg if svg)

  const RewardTile({
    super.key,
    required this.title,
    required this.cost,
    required this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return BrandCard(
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            decoration: BoxDecoration(
              color: const Color(0x14FFFFFF),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(child: Image.asset(iconPath, width: 32)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: t.titleLarge),
                const SizedBox(height: 6),
                Text('$cost pts', style: t.bodyMedium),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            child: const Text('Redeem'),
          )
        ],
      ),
    );
  }
}
