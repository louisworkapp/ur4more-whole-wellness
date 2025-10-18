import 'package:flutter/material.dart';
import '../theme/brand_tokens.dart';

class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;

  const BrandAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Brand.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: leading,
      actions: actions,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Brand mark - replace with actual asset when available
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Brand.primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Brand.onDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
