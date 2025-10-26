import 'package:flutter/material.dart';

class BadgeChip extends StatelessWidget {
  final String label; final Color color; final IconData? icon;
  const BadgeChip({super.key, required this.label, required this.color, this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:10, vertical:6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon!=null) ...[Icon(icon, size:14, color: color), const SizedBox(width:6)],
        Text(label, style: TextStyle(fontSize:12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}
