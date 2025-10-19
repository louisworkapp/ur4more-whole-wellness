import 'package:flutter/material.dart';
import '../../models/mind_coach_copy.dart';
import '../../repositories/mind_coach_repository.dart';
import '../../../../services/faith_service.dart';
import '../../../../design/tokens.dart';
import '../../services/conversion_funnel_service.dart';

class MindExercisesTab extends StatefulWidget {
  final FaithMode faithMode;

  const MindExercisesTab({
    super.key,
    required this.faithMode,
  });

  @override
  State<MindExercisesTab> createState() => _MindExercisesTabState();
}

class _MindExercisesTabState extends State<MindExercisesTab> {
  List<Exercise> _exercises = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExercises();
  }

  @override
  void didUpdateWidget(MindExercisesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.faithMode != widget.faithMode) {
      _loadExercises();
    }
  }

  void _loadExercises() {
    setState(() => _isLoading = true);
    
    final exercises = MindCoachRepository.getExercises(widget.faithMode);
    
    setState(() {
      _exercises = exercises;
      _isLoading = false;
    });
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

    return SingleChildScrollView(
      padding: EdgeInsets.all(AppSpace.x4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Mind Exercises',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            'Evidence-based tools to strengthen your mental wellness',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          
          SizedBox(height: AppSpace.x6),
          
          // Quick Access
          _buildQuickAccess(theme, colorScheme),
          
          SizedBox(height: AppSpace.x6),
          
          // All Exercises
          _buildAllExercises(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(ThemeData theme, ColorScheme colorScheme) {
    final quickExercises = _exercises.where((e) => e.estimatedMinutes < 10).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Access (Under 10 min)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: quickExercises.length,
            itemBuilder: (context, index) {
              final exercise = quickExercises[index];
              return Container(
                width: 200,
                margin: EdgeInsets.only(right: AppSpace.x3),
                child: _buildExerciseCard(exercise, theme, colorScheme, isCompact: true),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllExercises(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'All Exercises',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        ..._exercises.map((exercise) => Padding(
          padding: EdgeInsets.only(bottom: AppSpace.x3),
          child: _buildExerciseCard(exercise, theme, colorScheme),
        )),
      ],
    );
  }

  Widget _buildExerciseCard(
    Exercise exercise,
    ThemeData theme,
    ColorScheme colorScheme, {
    bool isCompact = false,
  }) {
    return InkWell(
      onTap: () => _startExercise(exercise),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isCompact ? AppSpace.x3 : AppSpace.x4),
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
                    _getIconData(exercise.icon),
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpace.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      if (!isCompact) ...[
                        SizedBox(height: AppSpace.x1),
                        Text(
                          '${exercise.estimatedMinutes} min',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
            if (!isCompact) ...[
              SizedBox(height: AppSpace.x3),
              Text(
                exercise.getDescription(widget.faithMode),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
              SizedBox(height: AppSpace.x3),
              Wrap(
                spacing: AppSpace.x2,
                runSpacing: AppSpace.x1,
                children: exercise.tags.take(3).map((tag) => Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpace.x2,
                    vertical: AppSpace.x1,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    tag,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                )).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'psychology':
        return Icons.psychology;
      case 'air':
        return Icons.air;
      case 'favorite':
        return Icons.favorite;
      case 'event_note':
        return Icons.event_note;
      case 'visibility':
        return Icons.visibility;
      case 'sentiment_satisfied':
        return Icons.sentiment_satisfied;
      default:
        return Icons.psychology;
    }
  }

  void _startExercise(Exercise exercise) {
    showDialog(
      context: context,
      builder: (context) => _ExerciseDialog(
        exercise: exercise,
        faithMode: widget.faithMode,
      ),
    );
  }
}

class _ExerciseDialog extends StatefulWidget {
  final Exercise exercise;
  final FaithMode faithMode;

  const _ExerciseDialog({
    required this.exercise,
    required this.faithMode,
  });

  @override
  State<_ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<_ExerciseDialog> {
  final TextEditingController _notesController = TextEditingController();
  bool _isCompleted = false;

  @override
  void dispose() {
    _notesController.dispose();
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
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getIconData(widget.exercise.icon),
                    color: colorScheme.primary,
                    size: 20,
                  ),
                ),
                SizedBox(width: AppSpace.x3),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exercise.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${widget.exercise.estimatedMinutes} minutes',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: AppSpace.x3),
            Text(
              widget.exercise.getDescription(widget.faithMode),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            SizedBox(height: AppSpace.x4),
            
            // Exercise-specific content based on ID
            Expanded(
              child: _buildExerciseContent(),
            ),
            
            SizedBox(height: AppSpace.x3),
            
            // Notes section
            Text(
              'Notes (Optional)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: AppSpace.x2),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Record your thoughts or insights...',
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
            
            SizedBox(height: AppSpace.x4),
            
            // Completion checkbox
            Row(
              children: [
                Checkbox(
                  value: _isCompleted,
                  onChanged: (value) => setState(() => _isCompleted = value ?? false),
                ),
                Expanded(
                  child: Text(
                    'Mark as completed',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: AppSpace.x3),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: AppSpace.x3),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveExercise,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseContent() {
    switch (widget.exercise.id) {
      case 'thought_record':
        return _buildThoughtRecordContent();
      case 'breathing':
        return _buildBreathingContent();
      case 'values_clarification':
        return _buildValuesContent();
      case 'implementation_intention':
        return _buildImplementationIntentionContent();
      case 'mindful_observation':
        return _buildMindfulObservationContent();
      case 'gratitude_practice':
        return _buildGratitudeContent();
      default:
        return _buildGenericContent();
    }
  }

  Widget _buildThoughtRecordContent() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Thought Record Steps:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x2),
        _buildStep('1. Situation', 'What happened?'),
        _buildStep('2. Automatic Thought', 'What went through your mind?'),
        _buildStep('3. Emotion', 'How did you feel? (0-10)'),
        _buildStep('4. Evidence For', 'What supports this thought?'),
        _buildStep('5. Evidence Against', 'What contradicts this thought?'),
        _buildStep('6. Balanced Thought', 'What\'s a more balanced way to think?'),
      ],
    );
  }

  Widget _buildBreathingContent() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Box Breathing Technique:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x2),
        _buildStep('1. Inhale', 'Count to 4 while breathing in'),
        _buildStep('2. Hold', 'Hold your breath for 4 counts'),
        _buildStep('3. Exhale', 'Count to 4 while breathing out'),
        _buildStep('4. Hold', 'Hold empty for 4 counts'),
        _buildStep('5. Repeat', 'Continue for 4-8 cycles'),
        if (widget.faithMode.isActivated) ...[
          SizedBox(height: AppSpace.x3),
          Container(
            padding: EdgeInsets.all(AppSpace.x3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '💡 Faith Tip: You can add a calming verse or prayer during the hold phases.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildValuesContent() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Values Clarification:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x2),
        _buildStep('1. List Values', 'What matters most to you?'),
        _buildStep('2. Rank Importance', 'Order them by priority'),
        _buildStep('3. Check Alignment', 'How well do your actions match?'),
        _buildStep('4. Set Intentions', 'How will you live these values?'),
      ],
    );
  }

  Widget _buildImplementationIntentionContent() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Implementation Intention:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x2),
        _buildStep('1. Identify Trigger', 'What situation challenges you?'),
        _buildStep('2. Choose Response', 'What will you do instead?'),
        _buildStep('3. Create If-Then', 'If [trigger], then I will [response]'),
        _buildStep('4. Practice', 'Rehearse this plan mentally'),
      ],
    );
  }

  Widget _buildMindfulObservationContent() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mindful Observation:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x2),
        _buildStep('1. Find Comfort', 'Sit or stand comfortably'),
        _buildStep('2. Notice Senses', 'What do you see, hear, feel?'),
        _buildStep('3. Observe Thoughts', 'Notice without judgment'),
        _buildStep('4. Return to Present', 'Gently return to your senses'),
      ],
    );
  }

  Widget _buildGratitudeContent() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gratitude Practice:',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x2),
        _buildStep('1. Find 3 Things', 'What are you grateful for today?'),
        _buildStep('2. Be Specific', 'Why does this matter to you?'),
        _buildStep('3. Feel It', 'Notice the positive emotions'),
        _buildStep('4. Express It', 'Share or write about it'),
      ],
    );
  }

  Widget _buildGenericContent() {
    final theme = Theme.of(context);
    return Text(
      'Follow the exercise description above. Take your time and be present with the process.',
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        height: 1.4,
      ),
    );
  }

  Widget _buildStep(String title, String description) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(bottom: AppSpace.x2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: AppSpace.x2),
          Expanded(
            child: Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'psychology':
        return Icons.psychology;
      case 'air':
        return Icons.air;
      case 'favorite':
        return Icons.favorite;
      case 'event_note':
        return Icons.event_note;
      case 'visibility':
        return Icons.visibility;
      case 'sentiment_satisfied':
        return Icons.sentiment_satisfied;
      default:
        return Icons.psychology;
    }
  }

  void _saveExercise() {
    // Save exercise completion logic here
    Navigator.pop(context);
    
    // Check for conversion opportunities
    if (_isCompleted && widget.faithMode.isOff) {
      ConversionFunnelService.recordWeekCompletion();
      
      // Special handling for values clarification exercise
      if (widget.exercise.id == 'values_clarification') {
        // This would typically come from the exercise data, but for demo purposes:
        final values = ['service', 'legacy']; // Mock values
        ConversionFunnelService.recordValuesChosen(values);
        context.maybeInviteToFaith(context: InviteContext.valuesMilestone);
      } else {
        context.maybeInviteToFaith(context: InviteContext.general);
      }
    }
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.exercise.title} ${_isCompleted ? 'completed' : 'saved'}!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
