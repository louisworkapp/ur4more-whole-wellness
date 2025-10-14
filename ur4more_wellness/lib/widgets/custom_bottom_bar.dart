import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../design/tokens.dart';

enum CustomBottomBarVariant {
  standard,
  floating,
  minimal,
}

class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final CustomBottomBarVariant variant;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.variant = CustomBottomBarVariant.standard,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomBottomBarVariant.standard:
        return _buildStandardBottomBar(context, theme, colorScheme);
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context, theme, colorScheme);
      case CustomBottomBarVariant.minimal:
        return _buildMinimalBottomBar(context, theme, colorScheme);
    }
  }

  Widget _buildStandardBottomBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected:
          onTap ?? (index) => _handleNavigation(context, index),
      backgroundColor: backgroundColor ?? colorScheme.surface,
      indicatorColor:
          (selectedItemColor ?? colorScheme.primary).withOpacity( 0.1),
      elevation: 8.0,
      height: 80,
      destinations: [
        NavigationDestination(
          icon: Icon(
            Icons.home_outlined,
            color: currentIndex == 0
                ? (selectedItemColor ?? colorScheme.primary)
                : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
          ),
          selectedIcon: Icon(
            Icons.home,
            color: selectedItemColor ?? colorScheme.primary,
          ),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.fitness_center_outlined,
            color: currentIndex == 1
                ? (selectedItemColor ?? colorScheme.primary)
                : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
          ),
          selectedIcon: Icon(
            Icons.fitness_center,
            color: selectedItemColor ?? colorScheme.primary,
          ),
          label: 'Fitness',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.psychology_outlined,
            color: currentIndex == 2
                ? (selectedItemColor ?? colorScheme.primary)
                : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
          ),
          selectedIcon: Icon(
            Icons.psychology,
            color: selectedItemColor ?? colorScheme.primary,
          ),
          label: 'Mind',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.auto_awesome_outlined,
            color: currentIndex == 3
                ? (selectedItemColor ?? colorScheme.primary)
                : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
          ),
          selectedIcon: Icon(
            Icons.auto_awesome,
            color: selectedItemColor ?? colorScheme.primary,
          ),
          label: 'Spiritual',
        ),
        NavigationDestination(
          icon: Icon(
            Icons.card_giftcard_outlined,
            color: currentIndex == 4
                ? (selectedItemColor ?? colorScheme.primary)
                : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
          ),
          selectedIcon: Icon(
            Icons.card_giftcard,
            color: selectedItemColor ?? colorScheme.primary,
          ),
          label: 'Rewards',
        ),
      ],
    );
  }

  Widget _buildFloatingBottomBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity( 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected:
            onTap ?? (index) => _handleNavigation(context, index),
        backgroundColor: Colors.transparent,
        indicatorColor:
            (selectedItemColor ?? colorScheme.primary).withOpacity( 0.1),
        elevation: 0,
        height: 70,
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: currentIndex == 0
                  ? (selectedItemColor ?? colorScheme.primary)
                  : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
            ),
            selectedIcon: Icon(
              Icons.home,
              color: selectedItemColor ?? colorScheme.primary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.fitness_center_outlined,
              color: currentIndex == 1
                  ? (selectedItemColor ?? colorScheme.primary)
                  : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
            ),
            selectedIcon: Icon(
              Icons.fitness_center,
              color: selectedItemColor ?? colorScheme.primary,
            ),
            label: 'Fitness',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.psychology_outlined,
              color: currentIndex == 2
                  ? (selectedItemColor ?? colorScheme.primary)
                  : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
            ),
            selectedIcon: Icon(
              Icons.psychology,
              color: selectedItemColor ?? colorScheme.primary,
            ),
            label: 'Mind',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.auto_awesome_outlined,
              color: currentIndex == 3
                  ? (selectedItemColor ?? colorScheme.primary)
                  : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
            ),
            selectedIcon: Icon(
              Icons.auto_awesome,
              color: selectedItemColor ?? colorScheme.primary,
            ),
            label: 'Spiritual',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.card_giftcard_outlined,
              color: currentIndex == 4
                  ? (selectedItemColor ?? colorScheme.primary)
                  : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
            ),
            selectedIcon: Icon(
              Icons.card_giftcard,
              color: selectedItemColor ?? colorScheme.primary,
            ),
            label: 'Rewards',
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalBottomBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: backgroundColor ?? colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity( 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildMinimalNavItem(
            context,
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: 'Home',
            index: 0,
            colorScheme: colorScheme,
          ),
          _buildMinimalNavItem(
            context,
            icon: Icons.fitness_center_outlined,
            selectedIcon: Icons.fitness_center,
            label: 'Fitness',
            index: 1,
            colorScheme: colorScheme,
          ),
          _buildMinimalNavItem(
            context,
            icon: Icons.psychology_outlined,
            selectedIcon: Icons.psychology,
            label: 'Mind',
            index: 2,
            colorScheme: colorScheme,
          ),
          _buildMinimalNavItem(
            context,
            icon: Icons.auto_awesome_outlined,
            selectedIcon: Icons.auto_awesome,
            label: 'Spiritual',
            index: 3,
            colorScheme: colorScheme,
          ),
          _buildMinimalNavItem(
            context,
            icon: Icons.card_giftcard_outlined,
            selectedIcon: Icons.card_giftcard,
            label: 'Rewards',
            index: 4,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildMinimalNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required int index,
    required ColorScheme colorScheme,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () =>
          (onTap ?? (index) => _handleNavigation(context, index))(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpace.x2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : icon,
              size: 24,
              color: isSelected
                  ? (selectedItemColor ?? colorScheme.primary)
                  : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
                color: isSelected
                    ? (selectedItemColor ?? colorScheme.primary)
                    : (unselectedItemColor ?? colorScheme.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    // Navigate to main scaffold with the selected index
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/',
      (route) => false,
      arguments: index,
    );
  }
}
