import 'package:flutter/material.dart';
import '../theme/space.dart';

class BrandAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BrandAppBar({
    super.key, 
    this.trailing,
    this.title = 'UR4MORE',
  });
  
  final Widget? trailing;
  final String title;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(
        title, 
        style: Theme.of(context).textTheme.titleLarge,
      ),
      actions: [
        if (trailing != null) 
          Padding(
            padding: const EdgeInsets.only(right: Sp.d12), 
            child: trailing!,
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}