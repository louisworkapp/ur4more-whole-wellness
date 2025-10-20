import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/mind_coach_copy.dart';
import '../../repositories/mind_coach_repository.dart';
import '../../../../services/faith_service.dart';
import '../../../../design/tokens.dart';
import '../../services/conversion_funnel_service.dart';
import '../../../../data/mind_faith_exercises_repository.dart';
import '../../../../widgets/verse_reveal_chip.dart';
import '../../../../widgets/faith_invitation_card.dart';
import '../../services/exercise_progression_service.dart';
import '../../widgets/lesson_card.dart';
import '../../routines/walk_in_light_routine.dart';
import '../screens/thought_record_screen.dart';
import '../screens/values_clarification_screen.dart';
import '../screens/implementation_intention_screen.dart';
import '../screens/mindful_observation_screen.dart';
import '../screens/gratitude_practice_screen.dart';
import '../../../../routes/app_routes.dart';

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
  Set<String> _completedExercises = {};

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

  void _loadExercises() async {
    setState(() => _isLoading = true);
    
    final exercises = MindCoachRepository.getExercises(widget.faithMode);
    
    // Add faith exercises if faith mode is activated
    if (widget.faithMode.isActivated) {
      try {
        final faithExercises = await MindFaithExercisesRepository().load();
        // Convert FaithExercise to Exercise format
        final convertedFaithExercises = faithExercises.map((fe) => Exercise(
          id: fe.id,
          title: fe.title,
          descriptionOff: fe.summary,
          descriptionFaith: fe.prayer != null ? ' ${fe.prayer}' : null,
          icon: 'favorite', // Use a faith-related icon
          estimatedMinutes: fe.timerSeconds != null ? (fe.timerSeconds! / 60).round() : 5,
          tags: fe.categories,
        )).toList();
        
        // Remove overlapping regular exercises to avoid duplication
        final overlappingIds = [
          'thought_reframe',    // Overlaps with identity_reframe
          'values_clarification', // Overlaps with serve_someone_today
          'meditation',         // Overlaps with scripture_meditation_5
        ];
        
        exercises.removeWhere((exercise) => overlappingIds.contains(exercise.id));
        
        exercises.addAll(convertedFaithExercises);
      } catch (e) {
        // If faith exercises fail to load, continue with regular exercises
        print('Failed to load faith exercises: $e');
      }
    }
    
    final completed = await ExerciseProgressionService.getCompletedExercises();
    
    setState(() {
      _exercises = exercises;
      _completedExercises = completed.toSet();
      _isLoading = false;
    });
  }

  /// Check if an exercise is unlocked (prerequisites met)
  bool _isExerciseUnlocked(Exercise exercise) {
    // L1 exercises are always unlocked
    if (exercise.id.endsWith('_l1')) return true;
    
    // Check prerequisites for L2/L3 exercises
    final prerequisites = _getPrerequisites(exercise.id);
    if (prerequisites.isEmpty) return true;
    
    return prerequisites.every((prereq) => _completedExercises.contains(prereq));
  }
  
  /// Get prerequisites for an exercise based on its ID
  List<String> _getPrerequisites(String exerciseId) {
    if (exerciseId.endsWith('_l2')) {
      return [exerciseId.replaceAll('_l2', '_l1')];
    } else if (exerciseId.endsWith('_l3')) {
      return [exerciseId.replaceAll('_l3', '_l2')];
    }
    return [];
  }

  /// Show faith invitation for secular users after completing an exercise
  Future<void> _showFaithInvitationForExercise(String exerciseId) async {
    if (widget.faithMode.isActivated) return; // Don't show for faith users
    
    try {
      final String jsonString = await rootBundle.loadString('assets/mind/exercises_core.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> exercises = data['exercises'] ?? [];
      
      // Find the exercise
      final exercise = exercises.firstWhere(
        (ex) => ex['id'] == exerciseId,
        orElse: () => null,
      );
      
      if (exercise != null && exercise['faithInvitation'] != null) {
        final invitation = exercise['faithInvitation'] as Map<String, dynamic>;
        
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SingleChildScrollView(
              child: FaithInvitationCard(
                title: invitation['title'] ?? 'Want to go deeper?',
                message: invitation['message'] ?? 'Try a faith-enhanced version of this exercise.',
                verse: invitation['verse'] ?? '',
                onAccept: () {
                  Navigator.of(context).pop();
                  // TODO: Navigate to faith mode activation
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Faith mode activation coming soon!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                onDecline: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ),
        );
      }
    } catch (e) {
      print('Error showing faith invitation: $e');
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
          
          SizedBox(height: AppSpace.x4),

          // Walk in the Light Lesson Card
          LessonCard(
            title: 'Walk in the Light',
            subtitle: 'Renew your mind and set your aim for the day with a 5-minute routine: breath + truth + gratitude.',
            footnote: widget.faithMode.isActivated 
                ? 'Faith mode: Scripture-enhanced exercises with verse reveals.'
                : 'OFF mode: Secular exercises with optional faith invitations.',
            onStart: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) {
                return WalkInLightRoutine(
                  isFaithActivated: widget.faithMode.isActivated,
                  hideFaithOverlaysInMind: false, // TODO: Get from settings
                  analytics: (event, props) async {
                    // TODO: Implement analytics tracking
                    print('Analytics: $event - $props');
                  },
                  onAwardXp: (xp) {
                    // TODO: Implement XP system
                    print('XP Awarded: $xp');
                  },
                );
              }));
            },
          ),
          
          SizedBox(height: AppSpace.x6),
          
          // Breath Coach v2
          _buildBreathCoachCard(theme, colorScheme),
          
          SizedBox(height: AppSpace.x6),
          
          // All Exercises (excluding breathing exercises)
          _buildAllExercises(theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildBreathCoachCard(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.breathPresets);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.air,
                  color: Colors.blue,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Breath Coach v2',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      '4 presets: Quick Calm, HRV, Focus, Sleep',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'Advanced breathing patterns with faith-aware quotes and calm tracking',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.3,
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
        ),
      ),
    );
  }


  Widget _buildAllExercises(ThemeData theme, ColorScheme colorScheme) {
    // Filter out breathing exercises since we have Breath Coach v2
    final nonBreathingExercises = _exercises.where((exercise) => 
      !exercise.id.contains('breathing') && 
      exercise.id != 'breathing'
    ).toList();
    
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
        ...nonBreathingExercises.map((exercise) => Padding(
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
    // Check if this is a faith exercise
    final isFaithExercise = exercise.id.startsWith('verse_') ||
                           exercise.id.startsWith('identity_') ||
                           exercise.id.startsWith('confession_') ||
                           exercise.id.startsWith('serve_') ||
                           exercise.id.startsWith('scripture_');
    
    final isUnlocked = _isExerciseUnlocked(exercise);
    
    return InkWell(
      onTap: isUnlocked ? () => _startExercise(exercise) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(isCompact ? AppSpace.x3 : AppSpace.x4),
        decoration: BoxDecoration(
          color: isUnlocked ? colorScheme.surface : colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? colorScheme.outline.withOpacity(0.2) : colorScheme.outline.withOpacity(0.1),
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              exercise.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isUnlocked ? colorScheme.onSurface : colorScheme.onSurface.withOpacity(0.5),
                              ),
                            ),
                          ),
                          if (!isUnlocked) ...[
                            SizedBox(width: AppSpace.x1),
                            Icon(
                              Icons.lock,
                              size: 16,
                              color: colorScheme.onSurfaceVariant.withOpacity(0.5),
                            ),
                          ],
                        ],
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
                  color: isUnlocked ? colorScheme.onSurfaceVariant : colorScheme.onSurfaceVariant.withOpacity(0.5),
                  height: 1.4,
                ),
              ),
              // Add verse display for faith exercises
              if (isFaithExercise && widget.faithMode.isActivated) ...[
                SizedBox(height: AppSpace.x2),
                _buildFaithExerciseVerse(exercise),
              ],
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

  Widget _buildFaithExerciseVerse(Exercise exercise) {
    // Map exercise IDs to their corresponding verses
    final verseMap = {
      'verse_breath_60': {'ref': 'Philippians 4:6–7', 'text': 'Be careful for nothing... the peace of God... shall keep your hearts and minds through Christ Jesus.'},
      'identity_reframe': {'ref': '2 Corinthians 5:17', 'text': 'Therefore if any man be in Christ, he is a new creature...'},
      'confession_truth_step': {'ref': '1 John 1:9', 'text': 'If we confess our sins, he is faithful and just to forgive us our sins...'},
      'serve_someone_today': {'ref': 'Galatians 5:13', 'text': 'By love serve one another.'},
      'scripture_meditation_5': {'ref': 'John 14:6', 'text': 'I am the way, the truth, and the life...'},
    };
    
    final verse = verseMap[exercise.id];
    if (verse == null) return const SizedBox.shrink();
    
    return VerseRevealChip(
      mode: widget.faithMode,
      ref: verse['ref']!,
      text: verse['text']!,
      askConsentLight: true,
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
    print('DEBUG: Starting exercise with ID: ${exercise.id}');
    // Special handling for exercises with full screens
    switch (exercise.id) {
      case 'thought_record':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ThoughtRecordScreen(
              faithMode: widget.faithMode,
            ),
          ),
        ).then((_) {
          // Show faith invitation for secular users after completing the exercise
          _showFaithInvitationForExercise('thought_record_l1');
        });
        return;
      case 'values_clarification':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ValuesClarificationScreen(
              faithMode: widget.faithMode,
            ),
          ),
        ).then((_) {
          // Show faith invitation for secular users after completing the exercise
          _showFaithInvitationForExercise('values_clarity_l1');
        });
        return;
      case 'implementation_intention':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ImplementationIntentionScreen(
              faithMode: widget.faithMode,
            ),
          ),
        );
        return;
      case 'mindful_observation':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MindfulObservationScreen(
              faithMode: widget.faithMode,
            ),
          ),
        );
        return;
      case 'gratitude_practice':
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => GratitudePracticeScreen(
              faithMode: widget.faithMode,
            ),
          ),
        );
        return;
    }
    
    // Default behavior for other exercises - show in dialog
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
