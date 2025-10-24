import 'package:flutter/material.dart';

class BadgeChip extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  
  const BadgeChip({
    super.key, 
    this.icon, 
    required this.label, 
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min, 
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
          ],
          Text(
            label, 
            style: TextStyle(
              fontSize: 12, 
              fontWeight: FontWeight.w600, 
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
