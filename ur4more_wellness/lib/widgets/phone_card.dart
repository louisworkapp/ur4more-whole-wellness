import 'package:flutter/material.dart';
import '../design/tokens.dart';

class PhoneCard extends StatelessWidget {
  const PhoneCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppMaxW.card),
        child: Card(
          child: Padding(padding: Pad.card, child: child),
        ),
      ),
    );
  }
}







