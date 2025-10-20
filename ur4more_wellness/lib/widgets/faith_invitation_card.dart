import 'package:flutter/material.dart';
import '../design/tokens.dart';

class FaithInvitationCard extends StatelessWidget {
  final String title;
  final String message;
  final String verse;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;

  const FaithInvitationCard({
    Key? key,
    required this.title,
    required this.message,
    required this.verse,
    this.onAccept,
    this.onDecline,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.all(AppSpace.x4),
      padding: EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.secondary.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(AppSpace.x2),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.favorite,
                  color: colorScheme.primary,
                  size: 24,
                ),
              ),
              SizedBox(width: AppSpace.x3),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpace.x4),
          
          // Message
          Text(
            message,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              color: colorScheme.onSurface,
            ),
          ),
          
          SizedBox(height: AppSpace.x4),
          
          // Verse
          Container(
            padding: EdgeInsets.all(AppSpace.x3),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.menu_book,
                      size: 16,
                      color: colorScheme.primary,
                    ),
                    SizedBox(width: AppSpace.x1),
                    Text(
                      'Scripture',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpace.x2),
                Text(
                  verse,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppSpace.x4),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDecline,
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSpace.x3),
                    side: BorderSide(color: colorScheme.outline),
                  ),
                  child: const Text('Maybe Later'),
                ),
              ),
              SizedBox(width: AppSpace.x3),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSpace.x3),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text('Try Faith Mode'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
