import 'package:flutter/material.dart';
import '../../models/mind_coach_copy.dart';
import '../../repositories/mind_coach_repository.dart';
import '../../../../services/faith_service.dart';
import '../../../../design/tokens.dart';
import '../../../../widgets/custom_icon_widget.dart';
import '../../services/conversion_funnel_service.dart';
import '../../widgets/go_deeper_card.dart';
import '../../widgets/daily_inspiration.dart';
import '../../../../core/settings/settings_scope.dart';
import '../../../../core/settings/settings_model.dart';

class MindCoachTab extends StatefulWidget {
  final FaithTier faithMode;

  const MindCoachTab({
    super.key,
    required this.faithMode,
  });

  @override
  State<MindCoachTab> createState() => _MindCoachTabState();
}

class _MindCoachTabState extends State<MindCoachTab> {
  MindCoachCopy? _coachCopy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCoachContent();
  }

  @override
  void didUpdateWidget(MindCoachTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.faithMode != widget.faithMode) {
      _loadCoachContent();
    }
  }

  Future<void> _loadCoachContent() async {
    setState(() => _isLoading = true);
    
    try {
      final coachCopy = await MindCoachRepository.getCoachCopy(widget.faithMode);
      
      setState(() {
        _coachCopy = coachCopy;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_coachCopy == null) {
      return Center(
        child: Text(
          'Unable to load coach content',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpace.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Coach Hero Section
          _buildCoachHero(theme, colorScheme),
          
          SizedBox(height: AppSpace.x6),
          
          // Daily Inspiration
          DailyInspiration(
            mode: widget.faithMode,
            hideFaithOverlaysInMind: false, // TODO: Get from settings
          ),
          
          SizedBox(height: AppSpace.x6),
          
          // Quick Actions
          _buildQuickActions(theme, colorScheme),
          
          SizedBox(height: AppSpace.x6),
          
          // Reframe Exercise
          _buildReframeExercise(theme, colorScheme),
          
          SizedBox(height: AppSpace.x6),
          
          // Go Deeper Card (only show in OFF mode)
          if (widget.faithMode.isOff) ...[
            GoDeeperCard(
              mode: widget.faithMode,
              contextTags: ['coach_home_idle'],
              eligible: true, // For demo purposes, always show as eligible
              onExplore: (cooldown) async {
                // Actually activate Faith Mode: Light
                final settings = SettingsScope.of(context);
                await settings.updateFaith(FaithTier.light);
                
                if (context.mounted) {
                  // Show the "fear of God" congratulations screen
                  Navigator.of(context).pushNamed('/faith-congratulations');
                }
                return true;
              },
              onDismiss: (snooze) async {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('We\'ll keep the secular tools front and center.'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              onOpenSettings: () {
                // Navigate to settings screen
                Navigator.of(context).pushNamed('/settings');
              },
            ),
            SizedBox(height: AppSpace.x4),
          ],
          
          // Demo conversion trigger (only show in OFF mode)
          if (widget.faithMode.isOff) ...[
            _buildDemoConversionTrigger(theme, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildCoachHero(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withOpacity(0.1),
            colorScheme.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Coach Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.psychology,
              color: Colors.white,
              size: 30,
            ),
          ),
          
          SizedBox(width: AppSpace.x4),
          
          // Coach Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mind Coach',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: AppSpace.x1),
                Text(
                  _coachCopy!.greeting,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildQuickActions(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionCard(
                theme,
                colorScheme,
                'Reframe Thought',
                Icons.psychology,
                () => _showReframeDialog(),
              ),
            ),
            SizedBox(width: AppSpace.x3),
            Expanded(
              child: _buildQuickActionCard(
                theme,
                colorScheme,
                'Small Step',
                Icons.directions_walk,
                () => _showSmallStepDialog(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(
    ThemeData theme,
    ColorScheme colorScheme,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(AppSpace.x3),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 24,
            ),
            SizedBox(height: AppSpace.x2),
            Text(
              title,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReframeExercise(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thought Reframing',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            _coachCopy!.reframeIntro,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpace.x3),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showReframeDialog(),
              icon: CustomIconWidget(
                iconName: 'psychology',
                color: Colors.white,
                size: 16,
              ),
              label: Text('Start Reframing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: AppSpace.x3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showReframeDialog() {
    showDialog(
      context: context,
      builder: (context) => _ReframeDialog(
        faithMode: widget.faithMode,
        coachCopy: _coachCopy!,
      ),
    ).then((result) {
      // Check for conversion opportunity after reframe completion
      if (result == true && widget.faithMode.isOff) {
        ConversionFunnelService.recordWeekCompletion();
        context.maybeInviteToFaith(context: InviteContext.general);
      }
    });
  }

  void _showSmallStepDialog() {
    showDialog(
      context: context,
      builder: (context) => _SmallStepDialog(
        faithMode: widget.faithMode,
        coachCopy: _coachCopy!,
      ),
    ).then((result) {
      // Check for conversion opportunity after small step completion
      if (result == true && widget.faithMode.isOff) {
        ConversionFunnelService.recordWeekCompletion();
        context.maybeInviteToFaith(context: InviteContext.general);
      }
    });
  }

  Widget _buildDemoConversionTrigger(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(AppSpace.x4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.science,
                color: colorScheme.primary,
                size: 20,
              ),
              SizedBox(width: AppSpace.x2),
              Text(
                'Demo: Test Conversion Funnel',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            'Simulate different conversion triggers to see how the faith mode invitation system works.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          SizedBox(height: AppSpace.x3),
          Wrap(
            spacing: AppSpace.x2,
            runSpacing: AppSpace.x2,
            children: [
              _buildDemoButton(
                context,
                'Week Complete',
                () => _triggerWeekCompletionInvite(),
              ),
              _buildDemoButton(
                context,
                'Crisis Resolved',
                () => _triggerCrisisResolvedInvite(),
              ),
              _buildDemoButton(
                context,
                'Values Milestone',
                () => _triggerValuesMilestoneInvite(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDemoButton(BuildContext context, String label, VoidCallback onPressed) {
    final theme = Theme.of(context);
    
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: AppSpace.x3,
          vertical: AppSpace.x2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _triggerWeekCompletionInvite() {
    ConversionFunnelService.recordWeekCompletion();
    ConversionFunnelService.recordWeekCompletion();
    ConversionFunnelService.recordWeekCompletion(); // Trigger threshold
    context.maybeInviteToFaith(
      context: InviteContext.weekCompletion,
      customHeadline: "Order is a beginning, not the end.",
      customBody: "Micro-order restores agency. We believe the deepest peace behind order is found in Jesus Christ.",
    );
  }

  void _triggerCrisisResolvedInvite() {
    ConversionFunnelService.recordUrgeScore(8); // High urge
    context.maybeInviteToFaith(context: InviteContext.crisisResolved);
  }

  void _triggerValuesMilestoneInvite() {
    ConversionFunnelService.recordValuesChosen(['service', 'legacy']);
    context.maybeInviteToFaith(context: InviteContext.valuesMilestone);
  }
}

class _ReframeDialog extends StatefulWidget {
  final FaithTier faithMode;
  final MindCoachCopy coachCopy;

  const _ReframeDialog({
    required this.faithMode,
    required this.coachCopy,
  });

  @override
  State<_ReframeDialog> createState() => _ReframeDialogState();
}

class _ReframeDialogState extends State<_ReframeDialog> {
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _thoughtController = TextEditingController();
  final TextEditingController _emotionController = TextEditingController();
  final TextEditingController _evidenceForController = TextEditingController();
  final TextEditingController _evidenceAgainstController = TextEditingController();
  final TextEditingController _reframeController = TextEditingController();

  @override
  void dispose() {
    _situationController.dispose();
    _thoughtController.dispose();
    _emotionController.dispose();
    _evidenceForController.dispose();
    _evidenceAgainstController.dispose();
    _reframeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        padding: EdgeInsets.all(AppSpace.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Thought Reframing',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: AppSpace.x3),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTextField(
                      'Situation',
                      'What happened?',
                      _situationController,
                    ),
                    SizedBox(height: AppSpace.x3),
                    _buildTextField(
                      'Automatic Thought',
                      'What thought went through your mind?',
                      _thoughtController,
                    ),
                    SizedBox(height: AppSpace.x3),
                    _buildTextField(
                      'Emotion',
                      'How did you feel?',
                      _emotionController,
                    ),
                    SizedBox(height: AppSpace.x3),
                    _buildTextField(
                      'Evidence For',
                      'What supports this thought?',
                      _evidenceForController,
                    ),
                    SizedBox(height: AppSpace.x3),
                    _buildTextField(
                      'Evidence Against',
                      'What contradicts this thought?',
                      _evidenceAgainstController,
                    ),
                    SizedBox(height: AppSpace.x3),
                    _buildTextField(
                      'Balanced Reframe',
                      'What\'s a more balanced way to think about this?',
                      _reframeController,
                    ),
                    // Faith integration based on mode
                    if (widget.faithMode.isOff) ...[
                      // OFF mode: Ask for permission to show faith content
                      SizedBox(height: AppSpace.x3),
                      Container(
                        padding: EdgeInsets.all(AppSpace.x3),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: colorScheme.primary,
                                  size: 20,
                                ),
                                SizedBox(width: AppSpace.x2),
                                Expanded(
                                  child: Text(
                                    'Would you like to see how this reframe connects to a deeper hope?',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpace.x2),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showVerseDialog(),
                                    icon: Icon(Icons.menu_book, size: 16),
                                    label: Text('Short Verse'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colorScheme.primary,
                                      side: BorderSide(color: colorScheme.primary),
                                    ),
                                  ),
                                ),
                                SizedBox(width: AppSpace.x2),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showPrayerDialog(),
                                    icon: Icon(Icons.favorite, size: 16),
                                    label: Text('Prayer'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: colorScheme.primary,
                                      side: BorderSide(color: colorScheme.primary),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ] else if (widget.faithMode.isActivated) ...[
                      // Light, Disciple, Kingdom Builder: Hard-wired faith integration
                      SizedBox(height: AppSpace.x3),
                      _buildHardWiredFaithSection(theme, colorScheme),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpace.x3),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save reframe logic here
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reframe saved! Great work.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Save Reframe'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHardWiredFaithSection(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Verse Section
        Container(
          padding: EdgeInsets.all(AppSpace.x3),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.menu_book,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  SizedBox(width: AppSpace.x2),
                  Text(
                    'Scripture for Strength',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpace.x2),
              Text(
                'Philippians 4:13',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: AppSpace.x1),
              Text(
                'I can do all things through Christ which strengtheneth me.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  height: 1.4,
                ),
              ),
              SizedBox(height: AppSpace.x1),
              Text(
                'Let this truth anchor your reframe. Christ gives you strength to think clearly and act wisely.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: AppSpace.x2),
        // Prayer Section
        Container(
          padding: EdgeInsets.all(AppSpace.x3),
          decoration: BoxDecoration(
            color: colorScheme.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colorScheme.secondary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.favorite,
                    color: colorScheme.secondary,
                    size: 20,
                  ),
                  SizedBox(width: AppSpace.x2),
                  Text(
                    'Prayer for Clarity',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpace.x2),
              Text(
                'Lord, help me see this situation clearly through Your eyes. Give me wisdom to reframe my thoughts according to Your truth. Strengthen me to act in love and faith. Amen.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                ),
              ),
              SizedBox(height: AppSpace.x1),
              Text(
                'Take a moment to pray this before completing your reframe.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showVerseDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Short Verse for Strength'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Philippians 4:13',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: AppSpace.x2),
            Text(
              'I can do all things through Christ which strengtheneth me.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpace.x2),
            Text(
              'Use this truth to anchor your reframe. Christ gives you strength to think clearly and act wisely.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Verse added to your reframe!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Use This Verse'),
          ),
        ],
      ),
    );
  }

  void _showPrayerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Prayer for Clarity'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Lord, help me see this situation clearly through Your eyes. Give me wisdom to reframe my thoughts according to Your truth. Strengthen me to act in love and faith. Amen.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpace.x2),
            Text(
              'Take a moment to pray this or your own prayer before completing your reframe.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Prayer completed. Continue with your reframe.'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Text('Prayed'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSpace.x1),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: AppSpace.x3,
              vertical: AppSpace.x2,
            ),
          ),
          maxLines: label == 'Situation' ? 2 : 1,
        ),
      ],
    );
  }
}

class _SmallStepDialog extends StatefulWidget {
  final FaithTier faithMode;
  final MindCoachCopy coachCopy;

  const _SmallStepDialog({
    required this.faithMode,
    required this.coachCopy,
  });

  @override
  State<_SmallStepDialog> createState() => _SmallStepDialogState();
}

class _SmallStepDialogState extends State<_SmallStepDialog> {
  final TextEditingController _stepController = TextEditingController();

  @override
  void dispose() {
    _stepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: EdgeInsets.all(AppSpace.x4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Small Step',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: AppSpace.x3),
            Text(
              widget.coachCopy.nudgeSmallStep,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpace.x3),
            TextField(
              controller: _stepController,
              decoration: InputDecoration(
                hintText: 'What will you do in the next 10 minutes?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: AppSpace.x3,
                  vertical: AppSpace.x2,
                ),
              ),
              maxLines: 3,
            ),
            if (widget.faithMode.isActivated && widget.coachCopy.faithOptional != null) ...[
              SizedBox(height: AppSpace.x3),
              Container(
                padding: EdgeInsets.all(AppSpace.x3),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: AppSpace.x2),
                    Expanded(
                      child: Text(
                        widget.coachCopy.faithOptional!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            SizedBox(height: AppSpace.x3),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Save step logic here
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Step committed! You\'ve got this.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: const Text('Commit to This Step'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
