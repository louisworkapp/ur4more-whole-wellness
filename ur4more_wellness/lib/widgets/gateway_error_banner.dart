import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../services/gateway_error.dart';

/// Banner widget to display gateway errors with actionable information
class GatewayErrorBanner extends StatelessWidget {
  final GatewayError error;
  final VoidCallback? onDismiss;

  const GatewayErrorBanner({
    super.key,
    required this.error,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: colorScheme.error,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: colorScheme.onErrorContainer,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error.displayMessage,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onErrorContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: colorScheme.onErrorContainer,
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    error.detailedMessage,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onErrorContainer.withValues(alpha: 0.8),
                      fontFamily: 'monospace',
                    ),
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _copyDetails(context),
                  icon: const Icon(Icons.copy, size: 16),
                  label: const Text('Copy'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _copyDetails(BuildContext context) {
    Clipboard.setData(ClipboardData(text: error.detailedMessage));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error details copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

/// Show gateway error as a snackbar
void showGatewayErrorSnackBar(BuildContext context, GatewayError error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            error.displayMessage,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          if (kDebugMode) ...[
            const SizedBox(height: 4),
            Text(
              error.detailedMessage,
              style: const TextStyle(
                fontSize: 12,
                fontFamily: 'monospace',
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.error,
      duration: const Duration(seconds: 5),
      action: kDebugMode
          ? SnackBarAction(
              label: 'Copy',
              textColor: Colors.white,
              onPressed: () {
                Clipboard.setData(ClipboardData(text: error.detailedMessage));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Error details copied to clipboard'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            )
          : null,
    ),
  );
}

