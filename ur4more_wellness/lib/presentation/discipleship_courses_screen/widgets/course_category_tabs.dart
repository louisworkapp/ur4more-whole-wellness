import 'package:flutter/material.dart';
import '../../../design/tokens.dart';

class CourseCategoryTabs extends StatelessWidget {
  final TabController tabController;
  final List<String> categories;

  const CourseCategoryTabs({
    super.key,
    required this.tabController,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppSpace.x4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: tabController,
        tabs: categories.map((category) => Tab(text: category)).toList(),
        labelColor: theme.colorScheme.primary,
        unselectedLabelColor: colorScheme.onSurfaceVariant,
        indicatorColor: theme.colorScheme.primary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w400,
        ),
        dividerColor: Colors.transparent,
      ),
    );
  }
}
