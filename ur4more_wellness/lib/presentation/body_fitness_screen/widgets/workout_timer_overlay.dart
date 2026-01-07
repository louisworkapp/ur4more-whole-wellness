import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';

class WorkoutTimerOverlay extends StatefulWidget {
  final Map<String, dynamic> workout;
  final VoidCallback onComplete;
  final VoidCallback onClose;

  const WorkoutTimerOverlay({
    super.key,
    required this.workout,
    required this.onComplete,
    required this.onClose,
  });

  @override
  State<WorkoutTimerOverlay> createState() => _WorkoutTimerOverlayState();
}

class _WorkoutTimerOverlayState extends State<WorkoutTimerOverlay>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late AnimationController _pulseController;
  Timer? _workoutTimer;
  Timer? _restTimer;

  int currentExerciseIndex = 0;
  int currentRep = 0;
  int durationTimeRemaining = 0;
  int restTimeRemaining = 0;
  bool isResting = false;
  bool isWorkoutActive = false;

  List<Map<String, dynamic>> get exercises => 
      (widget.workout['exercises'] as List?)?.cast<Map<String, dynamic>>() ?? [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _timerController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _startWorkout() {
    if (exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('This workout has no exercises yet.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      isWorkoutActive = true;
      currentExerciseIndex = 0;
      currentRep = 0;
      durationTimeRemaining = 0;
    });
    _startCurrentExercise();
  }

  void _startCurrentExercise() {
    if (currentExerciseIndex >= exercises.length) {
      _completeWorkout();
      return;
    }

    final exercise = exercises[currentExerciseIndex];
    
    // Skip invalid exercises
    if (!_isValidExercise(exercise)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid exercise setup: ${_getExerciseName(exercise, currentExerciseIndex)}'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      _moveToNextExercise();
      return;
    }

    final hasDuration = _isDurationExercise(exercise);
    
    if (hasDuration) {
      final duration = exercise['duration'] as int;
      setState(() {
        durationTimeRemaining = duration;
        isResting = false;
      });
      _startDurationTimer();
    } else {
      setState(() {
        currentRep = 0;
        isResting = false;
        durationTimeRemaining = 0;
      });
    }
  }

  void _startDurationTimer() {
    _workoutTimer?.cancel();
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        durationTimeRemaining--;
      });

      if (durationTimeRemaining <= 0) {
        timer.cancel();
        _onExerciseComplete();
      }
    });
  }

  void _onExerciseComplete() {
    _workoutTimer?.cancel();
    final exercise = exercises[currentExerciseIndex];
    final restTime = _getRestTime(exercise);
    
    if (currentExerciseIndex < exercises.length - 1 && restTime > 0) {
      setState(() {
        isResting = true;
        restTimeRemaining = restTime;
      });
      _startRestTimer();
    } else {
      _moveToNextExercise();
    }
  }

  void _moveToNextExercise() {
    if (currentExerciseIndex < exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
      });
      _startCurrentExercise();
    } else {
      _completeWorkout();
    }
  }

  void _startRestTimer() {
    _restTimer?.cancel();
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() {
        restTimeRemaining--;
      });

      if (restTimeRemaining <= 0) {
        timer.cancel();
        _moveToNextExercise();
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    _moveToNextExercise();
  }

  void _completeRep() {
    final currentExercise = exercises[currentExerciseIndex];
    final totalReps = currentExercise['reps'] as int?;

    if (totalReps == null) {
      return;
    }

    setState(() {
      currentRep++;
    });

    if (currentRep >= totalReps) {
      _onExerciseComplete();
    }
  }

  bool _isDurationExercise(Map<String, dynamic> exercise) {
    return exercise.containsKey('duration') && exercise['duration'] != null;
  }

  bool _isValidExercise(Map<String, dynamic> exercise) {
    return exercise.containsKey('reps') && exercise['reps'] != null ||
        exercise.containsKey('duration') && exercise['duration'] != null;
  }

  String _getExerciseName(Map<String, dynamic> exercise, int index) {
    return exercise['name'] as String? ?? 'Exercise ${index + 1}';
  }

  int _getRestTime(Map<String, dynamic> exercise) {
    return exercise['rest'] ?? exercise['restTime'] ?? 0;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _completeWorkout() {
    _restTimer?.cancel();
    _workoutTimer?.cancel();
    if (mounted) {
      widget.onComplete();
    }
  }

  Future<void> _handleExit() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Workout?'),
        content: const Text('Progress will be lost.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );

    if (shouldExit == true && mounted) {
      _restTimer?.cancel();
      _workoutTimer?.cancel();
      widget.onClose();
    }
  }

  @override
  void dispose() {
    _timerController.dispose();
    _pulseController.dispose();
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      color: Colors.black.withOpacity( 0.9),
      child: SafeArea(
        child: Padding(
          padding: Pad.card,
          child: Column(
            children: [
              _buildHeader(colorScheme),
              SizedBox(height: AppSpace.x4),
              if (!isWorkoutActive)
                _buildStartScreen(colorScheme)
              else if (isResting)
                _buildRestScreen(colorScheme)
              else
                _buildExerciseScreen(colorScheme),
              const Spacer(),
              _buildControls(colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          widget.workout['name'] as String,
          style: GoogleFonts.inter(
            fontSize: 20, // Fixed font size instead of Sizer
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: _handleExit,
          icon: CustomIconWidget(
            iconName: 'close',
            color: Colors.white,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildStartScreen(ColorScheme colorScheme) {
    final hasExercises = exercises.isNotEmpty;
    
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1.0 + (_pulseController.value * 0.1),
                child: Container(
                  width: 160, // Fixed size instead of percentage
                  height: 160, // Fixed size instead of percentage
                  decoration: BoxDecoration(
                    color: AppTheme.lightTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'play_arrow',
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: AppSpace.x4),
          Text(
            hasExercises ? 'Ready to start?' : 'No exercises available',
            style: GoogleFonts.inter(
              fontSize: 24, // Fixed font size instead of Sizer
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSpace.x2),
          if (hasExercises)
            Text(
              '${exercises.length} exercises • ${widget.workout['duration']} minutes',
              style: GoogleFonts.inter(
                fontSize: 16, // Fixed font size instead of Sizer
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity( 0.8),
              ),
            )
          else
            Text(
              'This workout has no exercises yet.',
              style: GoogleFonts.inter(
                fontSize: 16, // Fixed font size instead of Sizer
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity( 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: AppSpace.x4),
          ElevatedButton(
            onPressed: hasExercises ? _startWorkout : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: AppSpace.x8, vertical: AppSpace.x2),
              disabledBackgroundColor: Colors.grey,
            ),
            child: Text(
              'Start Workout',
              style: GoogleFonts.inter(
                fontSize: 16, // Fixed font size instead of Sizer
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestScreen(ColorScheme colorScheme) {
    final nextExerciseIndex = currentExerciseIndex + 1;
    final nextExercise = nextExerciseIndex < exercises.length
        ? exercises[nextExerciseIndex]
        : null;
    final nextExerciseName = nextExercise != null
        ? _getExerciseName(nextExercise, nextExerciseIndex)
        : 'Workout Complete';

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Exercise ${currentExerciseIndex + 1} of ${exercises.length}',
            style: GoogleFonts.inter(
              fontSize: 14, // Fixed font size instead of Sizer
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity( 0.8),
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            'Rest Time',
            style: GoogleFonts.inter(
              fontSize: 24, // Fixed font size instead of Sizer
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: AppSpace.x4),
          Container(
            width: 120, // Fixed width instead of percentage
            height: 120, // Fixed height instead of percentage
            decoration: BoxDecoration(
              color: AppTheme.successLight.withOpacity( 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.successLight,
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                '$restTimeRemaining',
                style: GoogleFonts.inter(
                  fontSize: 32, // Fixed font size instead of Sizer
                  fontWeight: FontWeight.w700,
                  color: AppTheme.successLight,
                ),
              ),
            ),
          ),
          SizedBox(height: AppSpace.x4),
          Text(
            'Next: $nextExerciseName',
            style: GoogleFonts.inter(
              fontSize: 18, // Fixed font size instead of Sizer
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity( 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseScreen(ColorScheme colorScheme) {
    final currentExercise = exercises[currentExerciseIndex];
    final isDuration = _isDurationExercise(currentExercise);
    final totalReps = currentExercise['reps'] as int?;
    final exerciseName = _getExerciseName(currentExercise, currentExerciseIndex);
    final hasValidSetup = _isValidExercise(currentExercise);
    
    final progress = isDuration 
        ? (durationTimeRemaining / (currentExercise['duration'] as int))
        : (totalReps != null ? currentRep / totalReps : 0.0);

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Exercise ${currentExerciseIndex + 1} of ${exercises.length}',
            style: GoogleFonts.inter(
              fontSize: 14, // Fixed font size instead of Sizer
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity( 0.8),
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            exerciseName,
            style: GoogleFonts.inter(
              fontSize: 28, // Fixed font size instead of Sizer
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpace.x2),
          if (!hasValidSetup)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpace.x4),
              child: Text(
                'Invalid exercise setup',
                style: GoogleFonts.inter(
                  fontSize: 16, // Fixed font size instead of Sizer
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            )
          else if (currentExercise['description'] != null)
            Text(
              currentExercise['description'] as String? ?? '',
              style: GoogleFonts.inter(
                fontSize: 16, // Fixed font size instead of Sizer
                fontWeight: FontWeight.w400,
                color: Colors.white.withOpacity( 0.8),
              ),
              textAlign: TextAlign.center,
            ),
          SizedBox(height: AppSpace.x4),
          Container(
            width: 140, // Fixed width instead of percentage
            height: 140, // Fixed height instead of percentage
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withOpacity( 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.lightTheme.primaryColor,
                width: 4,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  strokeWidth: 6,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.secondaryLight),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isDuration 
                          ? _formatDuration(durationTimeRemaining)
                          : '$currentRep',
                      style: GoogleFonts.inter(
                        fontSize: 32, // Fixed font size instead of Sizer
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    if (!isDuration && totalReps != null)
                      Text(
                        '/ $totalReps',
                        style: GoogleFonts.inter(
                          fontSize: 16, // Fixed font size instead of Sizer
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity( 0.8),
                        ),
                      ),
                    if (isDuration)
                      Text(
                        'mm:ss',
                        style: GoogleFonts.inter(
                          fontSize: 12, // Fixed font size instead of Sizer
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity( 0.8),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: AppSpace.x4),
          if (hasValidSetup)
            (isDuration
                ? ElevatedButton(
                    onPressed: _onExerciseComplete,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryLight,
                      padding: EdgeInsets.symmetric(horizontal: AppSpace.x8, vertical: AppSpace.x2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Complete Exercise',
                      style: GoogleFonts.inter(
                        fontSize: 16, // Fixed font size instead of Sizer
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  )
                : ElevatedButton(
                    onPressed: _completeRep,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.secondaryLight,
                      padding: EdgeInsets.symmetric(horizontal: AppSpace.x8, vertical: AppSpace.x2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      'Complete Rep',
                      style: GoogleFonts.inter(
                        fontSize: 16, // Fixed font size instead of Sizer
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  )),
        ],
      ),
    );
  }

  Widget _buildControls(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: _handleExit,
          child: Text(
            'Exit Workout',
            style: GoogleFonts.inter(
              fontSize: 14, // Fixed font size instead of Sizer
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity( 0.8),
            ),
          ),
        ),
        if (isResting)
          TextButton(
            onPressed: _skipRest,
            child: Text(
              'Skip Rest',
              style: GoogleFonts.inter(
                fontSize: 14, // Fixed font size instead of Sizer
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryLight,
              ),
            ),
          ),
        if (isWorkoutActive && !isResting)
          TextButton(
            onPressed: _moveToNextExercise,
            child: Text(
              'Skip Exercise',
              style: GoogleFonts.inter(
                fontSize: 14, // Fixed font size instead of Sizer
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryLight,
              ),
            ),
          ),
      ],
    );
  }
}
