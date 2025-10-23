import 'package:flutter/material.dart';
import '../../../../core/settings/settings_scope.dart';
import '../../../../core/settings/settings_model.dart';
import '../../../../design/tokens.dart';

class MeaningHorizonCard extends StatelessWidget {
  final String headline;
  final String body;
  final VoidCallback? onKeepSecular;

  const MeaningHorizonCard({
    super.key,
    this.headline = "Where does meaning finally land?",
    this.body = "Order and truth change your life. We believe their deepest end is found in Jesus Christ.",
    this.onKeepSecular,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and headline
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              SizedBox(width: AppSpace.x3),
              Expanded(
                child: Text(
                  headline,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpace.x3),
          
          // Body text
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          
          SizedBox(height: AppSpace.x4),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _activateLightMode(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: AppSpace.x3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Explore Faith Mode',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpace.x3),
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    onKeepSecular?.call();
                    Navigator.of(context).pop();
                  },
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: AppSpace.x3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Keep Secular Tools',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _activateLightMode(BuildContext context) async {
    try {
      final settingsCtl = SettingsScope.of(context);
      await settingsCtl.updateFaith(FaithTier.light);
      
      if (context.mounted) {
        Navigator.of(context).pop();
        
        // Show the "fear of God" congratulations screen
        Navigator.of(context).pushNamed('/faith-congratulations');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to activate Faith Mode. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _showLightSamplerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _LightSamplerDialog(),
    );
  }
}

class _LightSamplerDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: EdgeInsets.all(AppSpace.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary,
                    colorScheme.primary.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 30,
              ),
            ),
            
            SizedBox(height: AppSpace.x3),
            
            Text(
              'Welcome to Faith Mode: Light',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSpace.x2),
            
            Text(
              'Try our 7-day Light sampler to gently explore faith integration with your mental wellness tools.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: AppSpace.x4),
            
            // Features list
            Column(
              children: [
                _buildFeatureItem(
                  context,
                  'Short KJV verses (optional)',
                  Icons.menu_book,
                ),
                _buildFeatureItem(
                  context,
                  '30-second prayers (optional)',
                  Icons.favorite,
                ),
                _buildFeatureItem(
                  context,
                  'Identity-in-Christ reframes (gentle)',
                  Icons.psychology,
                ),
              ],
            ),
            
            SizedBox(height: AppSpace.x4),
            
            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Navigate to 7-day Light sampler course
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('7-day Light sampler coming soon!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: AppSpace.x3),
                ),
                child: Text('Start 7-Day Sampler'),
              ),
            ),
            
            SizedBox(height: AppSpace.x2),
            
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Explore Later'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text, IconData icon) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpace.x2),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: colorScheme.primary,
              size: 16,
            ),
          ),
          SizedBox(width: AppSpace.x3),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
