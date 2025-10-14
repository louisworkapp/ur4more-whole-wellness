import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../widgets/custom_icon_widget.dart';

class ReflectionPromptCard extends StatefulWidget {
  final List<Map<String, dynamic>> prompts;
  final int currentIndex;
  final Function(int) onPromptChanged;

  const ReflectionPromptCard({
    super.key,
    required this.prompts,
    required this.currentIndex,
    required this.onPromptChanged,
  });

  @override
  State<ReflectionPromptCard> createState() => _ReflectionPromptCardState();
}

class _ReflectionPromptCardState extends State<ReflectionPromptCard>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 200, // Fixed height instead of percentage
      margin: EdgeInsets.symmetric(horizontal: AppSpace.x4, vertical: AppSpace.x2),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) {
          widget.onPromptChanged(index);
          _animationController.reset();
          _animationController.forward();
        },
        itemCount: widget.prompts.length,
        itemBuilder: (context, index) {
          final prompt = widget.prompts[index];
          return FadeTransition(
            opacity: _fadeAnimation,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF0FA97A).withOpacity( 0.1),
                      const Color(0xFF0FA97A).withOpacity( 0.05),
                    ],
                  ),
                ),
                padding: Pad.card,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpace.x3,
                            vertical: AppSpace.x1,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0FA97A),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            prompt["category"] as String,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        CustomIconWidget(
                          iconName: 'psychology',
                          color: const Color(0xFF0FA97A),
                          size: 20,
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpace.x2),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Text(
                          prompt["question"] as String,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.onSurface,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: AppSpace.x1),
                    Row(
                      children: [
                        CustomIconWidget(
                          iconName: 'schedule',
                          color: colorScheme.onSurfaceVariant,
                          size: 16,
                        ),
                        SizedBox(width: AppSpace.x2),
                        Text(
                          "${prompt["estimatedTime"]} min reflection",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          "${index + 1}/${widget.prompts.length}",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
