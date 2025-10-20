import 'package:flutter/material.dart';
import '../widgets/thought_record_widget.dart';
import '../../../../design/tokens.dart';
import '../../../../services/faith_service.dart';

class ThoughtRecordScreen extends StatelessWidget {
  final FaithMode faithMode;

  const ThoughtRecordScreen({
    Key? key,
    required this.faithMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Thought Record'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (faithMode.isActivated)
            Container(
              margin: EdgeInsets.only(right: AppSpace.x3),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpace.x2,
                vertical: AppSpace.x1,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: AppSpace.x1),
                  Text(
                    'Faith Mode',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: ThoughtRecordWidget(
          isFaithMode: faithMode.isActivated,
          onComplete: () {
            // Show completion message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Great job! You completed your thought record.'),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
            
            // Navigate back after a delay
            Future.delayed(const Duration(seconds: 1), () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            });
          },
        ),
      ),
    );
  }
}
