import 'package:flutter/material.dart';
import '../../../../core/app_export.dart';
import '../../../../design/tokens.dart';
import '../../../../widgets/custom_app_bar.dart';
import '../logic/presets.dart';
import 'breath_session_screen.dart';

/// Breath Coach v2 Preset Selector Screen
/// 
/// Features:
/// - 4 preset cards: Quick Calm, HRV, Focus, Sleep
/// - Default durations and descriptions
/// - 430px clamp for responsive design
/// - Faith-aware preset availability
class BreathPresetsScreen extends StatelessWidget {
  const BreathPresetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Get available presets (all are available regardless of faith mode)
    final presets = Presets.available(
      faithActivated: true, // All presets available
      hideFaithOverlaysInMind: false,
    );

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Breath Coach',
        variant: CustomAppBarVariant.centered,
        showBackButton: true,
      ),
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 430),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Choose Your Practice',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                Text(
                  'Select a breathing pattern that matches your current need',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                
                const SizedBox(height: AppSpace.x6),
                
                // Preset cards
                Expanded(
                  child: ListView.separated(
                    itemCount: presets.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpace.x4),
                    itemBuilder: (context, index) {
                      final preset = presets[index];
                      return _PresetCard(
                        preset: preset,
                        onTap: () => _navigateToSession(context, preset),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToSession(BuildContext context, BreathPreset preset) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BreathSessionScreen(presetId: preset.id),
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  final BreathPreset preset;
  final VoidCallback onTap;

  const _PresetCard({
    required this.preset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Apply dimming for sleep preset
    final opacity = preset.dimUi ? 0.8 : 1.0;
    
    return Opacity(
      opacity: opacity,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  children: [
                    // Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _getPresetColor(preset.id).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getPresetIcon(preset.id),
                        color: _getPresetColor(preset.id),
                        size: 24,
                      ),
                    ),
                    
                    const SizedBox(width: 16),
                    
                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.name,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          
                          const SizedBox(height: 4),
                          
                          Text(
                            preset.subtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Arrow
                    Icon(
                      Icons.arrow_forward_ios,
                      color: colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Description
                Text(
                  _getPresetDescription(preset.id),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.4,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Stats row
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.timer_outlined,
                      label: 'Duration',
                      value: _formatDuration(preset.config.totalSeconds),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    _StatChip(
                      icon: Icons.air,
                      label: 'Breaths/min',
                      value: '${preset.config.breathsPerMinute.toStringAsFixed(1)}',
                    ),
                    
                    const SizedBox(width: 12),
                    
                    _StatChip(
                      icon: Icons.repeat,
                      label: 'Pattern',
                      value: _getPatternText(preset.config),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getPresetColor(String presetId) {
    switch (presetId) {
      case 'quick_calm':
        return Colors.orange;
      case 'hrv':
        return Colors.blue;
      case 'focus':
        return Colors.green;
      case 'sleep':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  IconData _getPresetIcon(String presetId) {
    switch (presetId) {
      case 'quick_calm':
        return Icons.flash_on;
      case 'hrv':
        return Icons.favorite;
      case 'focus':
        return Icons.center_focus_strong;
      case 'sleep':
        return Icons.bedtime;
      default:
        return Icons.air;
    }
  }

  String _getPresetDescription(String presetId) {
    switch (presetId) {
      case 'quick_calm':
        return 'Rapid stress relief using the physiological sigh technique. Two short inhales followed by a long exhale to quickly activate your parasympathetic nervous system.';
      case 'hrv':
        return 'Heart rate variability resonance breathing at ~6 breaths per minute. This pattern optimizes your autonomic nervous system and improves stress resilience.';
      case 'focus':
        return 'Traditional box breathing pattern for concentration and mental clarity. Equal timing for inhale, hold, exhale, and hold creates a balanced, focused state.';
      case 'sleep':
        return 'Extended exhale breathing to prepare your body and mind for rest. The longer exhale activates your relaxation response and helps you wind down.';
      default:
        return 'A breathing exercise to help you find calm and focus.';
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    return '${minutes}m';
  }

  String _getPatternText(BreathEngineConfig config) {
    final parts = <String>[];
    if (config.inhale > 0) parts.add('${config.inhale}');
    if (config.hold1 > 0) parts.add('${config.hold1}');
    if (config.exhale > 0) parts.add('${config.exhale}');
    if (config.hold2 > 0) parts.add('${config.hold2}');
    return parts.join('-');
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
