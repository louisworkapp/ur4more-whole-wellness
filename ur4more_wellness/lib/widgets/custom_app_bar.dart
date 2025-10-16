import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes/app_routes.dart';

enum CustomAppBarVariant {
  standard,
  centered,
  minimal,
  withActions,
  withSearch,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final Widget? leading;
  final bool automaticallyImplyLeading;
  final VoidCallback? onSearchTap;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.variant = CustomAppBarVariant.standard,
    this.actions,
    this.leading,
    this.automaticallyImplyLeading = true,
    this.onSearchTap,
    this.showBackButton = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomAppBarVariant.standard:
        return _buildStandardAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.centered:
        return _buildCenteredAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.minimal:
        return _buildMinimalAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.withActions:
        return _buildWithActionsAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.withSearch:
        return _buildWithSearchAppBar(context, theme, colorScheme);
    }
  }

  Widget _buildStandardAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: foregroundColor ?? colorScheme.onSurface,
              ),
            )
          : null,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation ?? 2.0,
      centerTitle: false,
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions ?? _buildDefaultActions(context),
    );
  }

  Widget _buildCenteredAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: foregroundColor ?? colorScheme.onSurface,
              ),
            )
          : null,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation ?? 2.0,
      centerTitle: true,
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions ?? _buildDefaultActions(context),
    );
  }

  Widget _buildMinimalAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: foregroundColor ?? colorScheme.onSurface,
              ),
            )
          : null,
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation ?? 0.0,
      centerTitle: true,
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions,
    );
  }

  Widget _buildWithActionsAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: foregroundColor ?? colorScheme.onSurface,
              ),
            )
          : null,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation ?? 2.0,
      centerTitle: false,
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: actions ??
          [
            IconButton(
              icon: const Icon(Icons.notifications_outlined),
              onPressed: () {
                // Handle notifications
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.settings),
            ),
            const SizedBox(width: 8),
          ],
    );
  }

  Widget _buildWithSearchAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: foregroundColor ?? colorScheme.onSurface,
              ),
            )
          : null,
      backgroundColor: backgroundColor ?? colorScheme.surface,
      foregroundColor: foregroundColor ?? colorScheme.onSurface,
      elevation: elevation ?? 2.0,
      centerTitle: false,
      leading: leading ??
          (showBackButton && Navigator.canPop(context)
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios),
                  onPressed: () => Navigator.pop(context),
                )
              : null),
      automaticallyImplyLeading: automaticallyImplyLeading,
      actions: [
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: onSearchTap ??
              () {
                // Handle search
              },
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: () {
            // Handle more options
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  List<Widget> _buildDefaultActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.person_outline),
        onPressed: () =>
            Navigator.pushNamed(context, AppRoutes.settings),
      ),
      const SizedBox(width: 8),
    ];
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
