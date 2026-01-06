import 'package:flutter/material.dart';
import '../services/gateway_service.dart';
import '../design/tokens.dart';

/// Small non-intrusive banner shown when app is running in demo mode
class DemoModeBanner extends StatelessWidget {
  const DemoModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: GatewayService.checkHealth(),
      builder: (context, snapshot) {
        // Show banner if gateway is unavailable (demo mode)
        final isDemoMode = GatewayService.isDemoMode || 
            (snapshot.hasData && !snapshot.data!);
        
        if (!isDemoMode) {
          return const SizedBox.shrink();
        }
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpace.x3,
            vertical: AppSpace.x2,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 16,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppSpace.x2),
              Flexible(
                child: Text(
                  'Demo Mode (gateway offline)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

