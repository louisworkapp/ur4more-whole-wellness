import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../core/app_export.dart';
import '../../design/tokens.dart';
import './widgets/equipment_filter_chips.dart';
import './widgets/fitness_header.dart';
import './widgets/workout_card.dart';
import './widgets/workout_timer_overlay.dart';

class BodyFitnessScreen extends StatefulWidget {
  const BodyFitnessScreen({super.key});

  @override
  State<BodyFitnessScreen> createState() => _BodyFitnessScreenState();
}

class _BodyFitnessScreenState extends State<BodyFitnessScreen>
    with TickerProviderStateMixin {
  late AnimationController _pointsAnimationController;
  late Animation<double> _pointsAnimation;

  enum DifficultyFilter { all, beginner, intermediate, advanced }
  enum WorkoutSort { recommended, pointsHigh, durationShort }

  List<String> selectedEquipment = ['Bodyweight'];
  List<String> availableEquipment = ['Bodyweight', 'Bands', 'Pullup Bar'];
  List<Map<String, dynamic>> workouts = [];
  List<Map<String, dynamic>> filteredWorkouts = [];
  bool isLoading = false;
  bool showTimerOverlay = false;
  Map<String, dynamic>? activeWorkout;

  int currentPoints = 1250;
  int weeklyGoal = 2000;
  double weeklyProgress = 0.625;

  DifficultyFilter difficultyFilter = DifficultyFilter.all;
  WorkoutSort sortMode = WorkoutSort.recommended;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeWorkouts();
    _filterWorkouts();
  }

  void _initializeAnimations() {
    _pointsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pointsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pointsAnimationController,
      curve: Curves.elasticOut,
    ));
  }

  void _initializeWorkouts() {
    workouts = [
      {
        'id': 1,
        'name': 'Morning Energy Boost',
        'description':
            'Start your day with this energizing full-body routine that awakens your muscles and mind.',
        'duration': 15,
        'calories': 120,
        'difficulty': 'Beginner',
        'equipment': ['Bodyweight'],
        'points': 50,
        'thumbnail':
            'https://images.unsplash.com/photo-1612732362547-14adf627f24e',
        'thumbnailSemanticLabel':
            'Person doing morning stretches in bright sunlit room with yoga mat',
        'exercises': [
          {'name': 'Jumping Jacks', 'reps': 20, 'rest': 30},
          {'name': 'Push-ups', 'reps': 10, 'rest': 30},
          {'name': 'Squats', 'reps': 15, 'rest': 30},
          {'name': 'Plank Hold', 'duration': 30, 'rest': 30},
        ],
      },
      {
        'id': 2,
        'name': 'Strength Builder',
        'description':
            'Build functional strength with resistance band exercises targeting all major muscle groups.',
        'duration': 25,
        'calories': 180,
        'difficulty': 'Intermediate',
        'equipment': ['Bands', 'Bodyweight'],
        'points': 75,
        'thumbnail':
            'https://images.unsplash.com/photo-1695764002135-84758fd9edfd',
        'thumbnailSemanticLabel':
            'Athletic woman using resistance bands for strength training in modern gym',
        'exercises': [
          {'name': 'Band Pull-Aparts', 'reps': 15, 'rest': 45},
          {'name': 'Band Squats', 'reps': 12, 'rest': 45},
          {'name': 'Band Rows', 'reps': 12, 'rest': 45},
          {'name': 'Band Chest Press', 'reps': 10, 'rest': 45},
        ],
      },
      {
        'id': 3,
        'name': 'Upper Body Power',
        'description':
            'Develop upper body strength and endurance with pullup bar and bodyweight exercises.',
        'duration': 20,
        'calories': 160,
        'difficulty': 'Advanced',
        'equipment': ['Pullup Bar', 'Bodyweight'],
        'points': 100,
        'thumbnail':
            'https://images.unsplash.com/photo-1480264104733-84fb0b925be3',
        'thumbnailSemanticLabel':
            'Muscular man performing pullups on outdoor bar with focused expression',
        'exercises': [
          {'name': 'Pull-ups', 'reps': 8, 'rest': 60},
          {'name': 'Push-ups', 'reps': 15, 'rest': 45},
          {'name': 'Chin-ups', 'reps': 6, 'rest': 60},
          {'name': 'Diamond Push-ups', 'reps': 8, 'rest': 45},
        ],
      },
      {
        'id': 4,
        'name': 'Core Stability',
        'description':
            'Strengthen your core with targeted exercises that improve stability and posture.',
        'duration': 12,
        'calories': 90,
        'difficulty': 'Beginner',
        'equipment': ['Bodyweight'],
        'points': 40,
        'thumbnail':
            'https://images.unsplash.com/photo-1540206053318-4d6a23b349dd',
        'thumbnailSemanticLabel':
            'Woman in plank position on exercise mat in bright fitness studio',
        'exercises': [
          {'name': 'Plank Hold', 'duration': 45, 'rest': 30},
          {'name': 'Side Plank', 'duration': 30, 'rest': 30},
          {'name': 'Dead Bug', 'reps': 10, 'rest': 30},
          {'name': 'Bird Dog', 'reps': 8, 'rest': 30},
        ],
      },
      {
        'id': 5,
        'name': 'HIIT Cardio Blast',
        'description':
            'High-intensity interval training to boost cardiovascular fitness and burn calories.',
        'duration': 18,
        'calories': 220,
        'difficulty': 'Intermediate',
        'equipment': ['Bodyweight'],
        'points': 85,
        'thumbnail':
            'https://images.unsplash.com/photo-1679500502523-b40fb6f0563d',
        'thumbnailSemanticLabel':
            'Energetic group fitness class doing high-intensity cardio exercises',
        'exercises': [
          {'name': 'Burpees', 'reps': 8, 'rest': 45},
          {'name': 'Mountain Climbers', 'reps': 20, 'rest': 45},
          {'name': 'Jump Squats', 'reps': 12, 'rest': 45},
          {'name': 'High Knees', 'reps': 30, 'rest': 45},
        ],
      },
      {
        'id': 6,
        'name': 'Full Body Flow',
        'description':
            'Complete workout combining strength, flexibility, and endurance for total body wellness.',
        'duration': 30,
        'calories': 250,
        'difficulty': 'Advanced',
        'equipment': ['Bands', 'Bodyweight'],
        'points': 120,
        'thumbnail':
            'https://images.unsplash.com/photo-1718633625616-e5f297177a26',
        'thumbnailSemanticLabel':
            'Fit person performing dynamic full-body exercise routine in spacious gym',
        'exercises': [
          {'name': 'Band Squats', 'reps': 15, 'rest': 60},
          {'name': 'Push-up to T', 'reps': 10, 'rest': 60},
          {'name': 'Band Deadlifts', 'reps': 12, 'rest': 60},
          {'name': 'Plank to Pike', 'reps': 8, 'rest': 60},
        ],
      },
    ];
  }

  void _filterWorkouts() {
    List<Map<String, dynamic>> results = List.from(workouts);

    if (selectedEquipment.isNotEmpty) {
      results = results.where((workout) {
        final workoutEquipment = (workout['equipment'] as List).cast<String>();
        return selectedEquipment.any((selected) => workoutEquipment.any(
            (equipment) =>
                equipment.toLowerCase() == selected.toLowerCase()));
      }).toList();
    }

    if (difficultyFilter != DifficultyFilter.all) {
      results = results.where((workout) {
        final difficulty = (workout['difficulty'] as String).toLowerCase();
        switch (difficultyFilter) {
          case DifficultyFilter.beginner:
            return difficulty == 'beginner';
          case DifficultyFilter.intermediate:
            return difficulty == 'intermediate';
          case DifficultyFilter.advanced:
            return difficulty == 'advanced';
          case DifficultyFilter.all:
            return true;
        }
      }).toList();
    }

    switch (sortMode) {
      case WorkoutSort.pointsHigh:
        results.sort((a, b) => (b['points'] as int).compareTo(a['points'] as int));
        break;
      case WorkoutSort.durationShort:
        results.sort((a, b) => (a['duration'] as int).compareTo(b['duration'] as int));
        break;
      case WorkoutSort.recommended:
        // keep original order
        break;
    }

    setState(() {
      filteredWorkouts = results;
    });
  }

  void _onEquipmentToggle(String equipment) {
    setState(() {
      if (selectedEquipment.contains(equipment)) {
        selectedEquipment.remove(equipment);
      } else {
        selectedEquipment.add(equipment);
      }
    });
    _filterWorkouts();
  }

  void _onWorkoutTap(Map<String, dynamic> workout) {
    setState(() {
      activeWorkout = workout;
      showTimerOverlay = true;
    });
  }

  void _onWorkoutComplete() {
    final colorScheme = Theme.of(context).colorScheme;
    if (activeWorkout != null) {
      final points = activeWorkout!['points'] as int;
      setState(() {
        currentPoints += points;
        weeklyProgress = (currentPoints / weeklyGoal).clamp(0.0, 1.0);
        showTimerOverlay = false;
        activeWorkout = null;
      });

      _pointsAnimationController.forward().then((_) {
        _pointsAnimationController.reset();
      });

      HapticFeedback.mediumImpact();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Workout completed! +$points points earned',
            style: GoogleFonts.inter(
              fontSize: 14, // Fixed font size instead of Sizer
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          backgroundColor: colorScheme.tertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  void _onTimerClose() {
    setState(() {
      showTimerOverlay = false;
      activeWorkout = null;
    });
  }

  void _onFavorite(Map<String, dynamic> workout) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added "${workout['name']}" to favorites',
          style: GoogleFonts.inter(
            fontSize: 14, // Fixed font size instead of Sizer
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _onSchedule(Map<String, dynamic> workout) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Scheduled "${workout['name']}" for later',
          style: GoogleFonts.inter(
            fontSize: 14, // Fixed font size instead of Sizer
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _onShare(Map<String, dynamic> workout) {
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Shared "${workout['name']}" workout',
          style: GoogleFonts.inter(
            fontSize: 14, // Fixed font size instead of Sizer
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _onRefresh() async {
    final colorScheme = Theme.of(context).colorScheme;
    setState(() {
      isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Workouts refreshed successfully',
          style: GoogleFonts.inter(
            fontSize: 14, // Fixed font size instead of Sizer
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
          backgroundColor: colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showCreateWorkoutModal() {
    final colorScheme = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 500, // Fixed height instead of percentage
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Padding(
          padding: Pad.card,
          child: Column(
            children: [
              Container(
                width: 48, // Fixed width instead of percentage
                height: 2, // Fixed height instead of percentage
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .outline
                      .withOpacity( 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SizedBox(height: AppSpace.x3),
              Text(
                'Create Custom Workout',
                style: GoogleFonts.inter(
                  fontSize: 20, // Fixed font size instead of Sizer
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: AppSpace.x2),
              Text(
                'Build your own personalized workout routine',
                style: GoogleFonts.inter(
                  fontSize: 14, // Fixed font size instead of Sizer
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Custom workout creation coming soon!',
                        style: GoogleFonts.inter(
                          fontSize: 14, // Fixed font size instead of Sizer
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      backgroundColor: colorScheme.primary,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  padding: EdgeInsets.symmetric(horizontal: AppSpace.x8, vertical: AppSpace.x2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Create Workout',
                  style: GoogleFonts.inter(
                    fontSize: 16, // Fixed font size instead of Sizer
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: AppSpace.x2),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pointsAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Stack(
        children: [
          Column(
            children: [
              AnimatedBuilder(
                animation: _pointsAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.0 + (_pointsAnimation.value * 0.05),
                    child: FitnessHeader(
                      currentPoints: currentPoints,
                      weeklyGoal: weeklyGoal,
                      weeklyProgress: weeklyProgress,
                    ),
                  );
                },
              ),
              SizedBox(height: AppSpace.x2),
              _buildDifficultyAndSortRow(colorScheme, theme),
              SizedBox(height: AppSpace.x2),
              EquipmentFilterChips(
                selectedEquipment: selectedEquipment,
                onEquipmentToggle: _onEquipmentToggle,
                availableEquipment: availableEquipment,
              ),
              SizedBox(height: AppSpace.x1),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _onRefresh,
                  color: colorScheme.primary,
                  child: filteredWorkouts.isEmpty
                      ? _buildEmptyState(colorScheme)
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          separatorBuilder: (_, __) => SizedBox(height: AppSpace.x2),
                          itemBuilder: (context, index) {
                            final workout = filteredWorkouts[index];
                            return Slidable(
                              key: ValueKey(workout['id']),
                              endActionPane: ActionPane(
                                motion: const ScrollMotion(),
                                children: [
                                  SlidableAction(
                                    onPressed: (_) => _onFavorite(workout),
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: Colors.white,
                                    icon: Icons.favorite,
                                    label: 'Favorite',
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      bottomLeft: Radius.circular(16),
                                    ),
                                  ),
                                  SlidableAction(
                                    onPressed: (_) => _onSchedule(workout),
                                    backgroundColor: colorScheme.secondary,
                                    foregroundColor: Colors.white,
                                    icon: Icons.schedule,
                                    label: 'Schedule',
                                  ),
                                  SlidableAction(
                                    onPressed: (_) => _onShare(workout),
                                    backgroundColor: colorScheme.tertiary,
                                    foregroundColor: Colors.white,
                                    icon: Icons.share,
                                    label: 'Share',
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      bottomRight: Radius.circular(16),
                                    ),
                                  ),
                                ],
                              ),
                              child: WorkoutCard(
                                workout: workout,
                                onTap: () => _onWorkoutTap(workout),
                                onFavorite: () => _onFavorite(workout),
                                onSchedule: () => _onSchedule(workout),
                                onShare: () => _onShare(workout),
                              ),
                            );
                          },
                          itemCount: filteredWorkouts.length,
                        ),
                ),
              ),
            ],
          ),
          if (showTimerOverlay && activeWorkout != null)
            WorkoutTimerOverlay(
              workout: activeWorkout!,
              onComplete: _onWorkoutComplete,
              onClose: _onTimerClose,
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "body_fitness_fab",
        onPressed: _showCreateWorkoutModal,
        backgroundColor: colorScheme.secondary,
        child: CustomIconWidget(
          iconName: 'add',
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSpace.x8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'fitness_center',
              color: colorScheme.onSurfaceVariant.withOpacity( 0.5),
              size: 80,
            ),
            SizedBox(height: AppSpace.x3),
            Text(
              'No workouts found',
              style: GoogleFonts.inter(
                fontSize: 20, // Fixed font size instead of Sizer
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSpace.x1),
            Text(
              'Try adjusting your equipment filters or create a custom workout',
              style: GoogleFonts.inter(
                fontSize: 14, // Fixed font size instead of Sizer
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant.withOpacity( 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpace.x4),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedEquipment = ['Bodyweight'];
                });
                _filterWorkouts();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                padding: EdgeInsets.symmetric(horizontal: AppSpace.x6, vertical: AppSpace.x3),
              ),
              child: Text(
                'Reset Filters',
                style: GoogleFonts.inter(
                  fontSize: 14, // Fixed font size instead of Sizer
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyAndSortRow(ColorScheme colorScheme, ThemeData theme) {
    final chipSpacing = AppSpace.x2.toDouble();

    ChoiceChip _chip(String label, DifficultyFilter filter) {
      final selected = difficultyFilter == filter;
      return ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) {
          setState(() {
            difficultyFilter = filter;
          });
          _filterWorkouts();
        },
        visualDensity: VisualDensity.compact,
        labelStyle: theme.textTheme.labelLarge?.copyWith(
          color: selected ? colorScheme.onPrimary : colorScheme.onSurface,
        ),
        selectedColor: colorScheme.primary,
        backgroundColor: colorScheme.surfaceVariant,
        side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpace.x4),
      child: Row(
        children: [
          Expanded(
            child: Wrap(
              spacing: chipSpacing,
              runSpacing: chipSpacing,
              children: [
                _chip('All', DifficultyFilter.all),
                _chip('Beginner', DifficultyFilter.beginner),
                _chip('Intermediate', DifficultyFilter.intermediate),
                _chip('Advanced', DifficultyFilter.advanced),
              ],
            ),
          ),
          PopupMenuButton<WorkoutSort>(
            tooltip: 'Sort',
            onSelected: (mode) {
              setState(() {
                sortMode = mode;
              });
              _filterWorkouts();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: WorkoutSort.recommended,
                child: Text('Recommended'),
              ),
              const PopupMenuItem(
                value: WorkoutSort.pointsHigh,
                child: Text('Points (High → Low)'),
              ),
              const PopupMenuItem(
                value: WorkoutSort.durationShort,
                child: Text('Time (Short → Long)'),
              ),
            ],
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpace.x3,
                vertical: AppSpace.x2,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, size: 18),
                  SizedBox(width: AppSpace.x1),
                  Text(
                    'Sort',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
