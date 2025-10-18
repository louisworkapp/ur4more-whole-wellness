import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../design/tokens.dart';
import '../../../routes/app_routes.dart';
import '../../courses/models/course_models.dart';
import '../../../core/services/settings_service.dart';

class FaithModeNavigator {
  static const String _faithTierKey = 'faith_tier';

  /// Opens the faith mode selector - either navigates to Settings or shows inline dialog
  static Future<void> openFaithModeSelector(BuildContext context) async {
    // Try to navigate to Settings first
    try {
      Navigator.pushNamed(context, AppRoutes.settings);
      // Note: In a real implementation, you might want to pass parameters
      // to scroll to the Faith Mode section, but for now we'll use the inline dialog
      return;
    } catch (e) {
      // If Settings route doesn't exist or fails, show inline dialog
      _showInlineFaithModeSelector(context);
    }
  }

  /// Shows an inline faith mode selector dialog
  static void _showInlineFaithModeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FaithModeSelectorDialog(),
    );
  }

  /// Gets the current faith tier from settings service
  static Future<FaithTier> getCurrentFaithTier() async {
    final settings = await SettingsService.loadSettings();
    return _convertFaithModeToTier(settings.faithMode);
  }

  /// Sets the faith tier using settings service
  static Future<void> setFaithTier(FaithTier tier) async {
    final faithMode = _convertTierToFaithMode(tier);
    await SettingsService.updateFaithMode(faithMode);
  }

  /// Convert FaithMode to FaithTier
  static FaithTier _convertFaithModeToTier(FaithMode faithMode) {
    switch (faithMode) {
      case FaithMode.off:
        return FaithTier.off;
      case FaithMode.light:
        return FaithTier.light;
      case FaithMode.disciple:
        return FaithTier.disciple;
      case FaithMode.kingdom:
        return FaithTier.kingdomBuilder;
    }
  }

  /// Convert FaithTier to FaithMode
  static FaithMode _convertTierToFaithMode(FaithTier tier) {
    switch (tier) {
      case FaithTier.off:
        return FaithMode.off;
      case FaithTier.light:
        return FaithMode.light;
      case FaithTier.disciple:
        return FaithMode.disciple;
      case FaithTier.kingdomBuilder:
        return FaithMode.kingdom;
    }
  }

  /// Sets the faith tier and notifies listeners
  static Future<void> setFaithTierAndNotify(FaithTier tier, BuildContext context) async {
    await setFaithTier(tier);
    // Trigger a rebuild of the current screen to reflect the change
    if (context.mounted) {
      // Find the nearest StatefulWidget and trigger a rebuild
      final state = context.findAncestorStateOfType<State>();
      if (state != null && state.mounted) {
        state.setState(() {});
      }
    }
  }
}

class FaithModeSelectorDialog extends StatefulWidget {
  const FaithModeSelectorDialog({super.key});

  @override
  State<FaithModeSelectorDialog> createState() => _FaithModeSelectorDialogState();
}

class _FaithModeSelectorDialogState extends State<FaithModeSelectorDialog> {
  FaithTier _selectedTier = FaithTier.off;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentTier();
  }

  Future<void> _loadCurrentTier() async {
    final currentTier = await FaithModeNavigator.getCurrentFaithTier();
    setState(() {
      _selectedTier = currentTier;
    });
  }

  Future<void> _saveAndClose() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FaithModeNavigator.setFaithTierAndNotify(_selectedTier, context);
      if (mounted) {
        Navigator.pop(context);
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Faith Mode updated to ${_selectedTier.name}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update Faith Mode. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text(
        'Choose Faith Mode',
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select your preferred level of faith-based content:',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          SizedBox(height: AppSpace.x4),
          ...FaithTier.values.map((tier) => _buildTierOption(theme, colorScheme, tier)),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveAndClose,
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          child: _isLoading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                  ),
                )
              : Text(
                  'Save',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildTierOption(ThemeData theme, ColorScheme colorScheme, FaithTier tier) {
    final isSelected = _selectedTier == tier;
    
    return Container(
      margin: EdgeInsets.only(bottom: AppSpace.x2),
      child: InkWell(
        onTap: () => setState(() => _selectedTier = tier),
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Container(
          padding: EdgeInsets.all(AppSpace.x3),
          decoration: BoxDecoration(
            color: isSelected 
                ? colorScheme.primaryContainer.withOpacity(0.3)
                : colorScheme.surfaceVariant.withOpacity(0.3),
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: isSelected 
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Radio<FaithTier>(
                value: tier,
                groupValue: _selectedTier,
                onChanged: (value) => setState(() => _selectedTier = value!),
                activeColor: colorScheme.primary,
              ),
              SizedBox(width: AppSpace.x2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.displayName,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected 
                            ? colorScheme.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: AppSpace.x1),
                    Text(
                      _getTierDescription(tier),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getTierDescription(FaithTier tier) {
    switch (tier) {
      case FaithTier.off:
        return 'No faith-based content. General wellness only.';
      case FaithTier.light:
        return 'Basic faith content. Scripture and simple prayers.';
      case FaithTier.disciple:
        return 'Full faith experience. Devotions, courses, and guidance.';
      case FaithTier.kingdomBuilder:
        return 'Complete experience with service and leadership focus.';
    }
  }
}

extension FaithTierDisplay on FaithTier {
  String get displayName {
    switch (this) {
      case FaithTier.off:
        return 'Off';
      case FaithTier.light:
        return 'Light';
      case FaithTier.disciple:
        return 'Disciple';
      case FaithTier.kingdomBuilder:
        return 'Kingdom Builder';
    }
  }
}
