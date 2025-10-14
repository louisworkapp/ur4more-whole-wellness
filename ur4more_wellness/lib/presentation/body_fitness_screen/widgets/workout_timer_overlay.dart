import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

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
  int restTimeRemaining = 0;
  bool isResting = false;
  bool isWorkoutActive = false;

  List<Map<String, dynamic>> exercises = [];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeExercises();
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

  void _initializeExercises() {
    exercises = [
      {
        'name': 'Push-ups',
        'reps': 15,
        'restTime': 30,
        'description': 'Keep your body straight and lower to the ground',
      },
      {
        'name': 'Squats',
        'reps': 20,
        'restTime': 30,
        'description': 'Lower your hips back and down, knees behind toes',
      },
      {
        'name': 'Plank Hold',
        'reps': 1,
        'duration': 45,
        'restTime': 30,
        'description': 'Hold a straight line from head to heels',
      },
      {
        'name': 'Jumping Jacks',
        'reps': 25,
        'restTime': 30,
        'description': 'Jump feet apart while raising arms overhead',
      },
    ];
  }

  void _startWorkout() {
    setState(() {
      isWorkoutActive = true;
      currentExerciseIndex = 0;
      currentRep = 0;
    });
  }

  void _nextExercise() {
    if (currentExerciseIndex < exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
        currentRep = 0;
        isResting = true;
        restTimeRemaining =
            exercises[currentExerciseIndex - 1]['restTime'] as int;
      });
      _startRestTimer();
    } else {
      _completeWorkout();
    }
  }

  void _startRestTimer() {
    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        restTimeRemaining--;
      });

      if (restTimeRemaining <= 0) {
        timer.cancel();
        setState(() {
          isResting = false;
        });
      }
    });
  }

  void _completeRep() {
    final currentExercise = exercises[currentExerciseIndex];
    final totalReps = currentExercise['reps'] as int;

    setState(() {
      currentRep++;
    });

    if (currentRep >= totalReps) {
      _nextExercise();
    }
  }

  void _completeWorkout() {
    _restTimer?.cancel();
    _workoutTimer?.cancel();
    widget.onComplete();
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
      color: Colors.black.withValues(alpha: 0.9),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(4.w),
          child: Column(
            children: [
              _buildHeader(colorScheme),
              SizedBox(height: 4.h),
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
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        IconButton(
          onPressed: widget.onClose,
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
                  width: 40.w,
                  height: 40.w,
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
          SizedBox(height: 4.h),
          Text(
            'Ready to start?',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            '${exercises.length} exercises • ${widget.workout['duration']} minutes',
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: _startWorkout,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.lightTheme.primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            ),
            child: Text(
              'Start Workout',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
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
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Rest Time',
            style: GoogleFonts.inter(
              fontSize: 24.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: AppTheme.successLight.withValues(alpha: 0.2),
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
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.successLight,
                ),
              ),
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Next: ${exercises[currentExerciseIndex]['name']}',
            style: GoogleFonts.inter(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseScreen(ColorScheme colorScheme) {
    final currentExercise = exercises[currentExerciseIndex];
    final totalReps = currentExercise['reps'] as int;
    final progress = currentRep / totalReps;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Exercise ${currentExerciseIndex + 1} of ${exercises.length}',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            currentExercise['name'] as String,
            style: GoogleFonts.inter(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 2.h),
          Text(
            currentExercise['description'] as String,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w400,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          Container(
            width: 35.w,
            height: 35.w,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.primaryColor.withValues(alpha: 0.2),
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
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.transparent,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.secondaryLight),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currentRep',
                      style: GoogleFonts.inter(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '/ $totalReps',
                      style: GoogleFonts.inter(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          ElevatedButton(
            onPressed: _completeRep,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryLight,
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Text(
              'Complete Rep',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: widget.onClose,
          child: Text(
            'Exit Workout',
            style: GoogleFonts.inter(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ),
        if (isWorkoutActive && !isResting)
          TextButton(
            onPressed: _nextExercise,
            child: Text(
              'Skip Exercise',
              style: GoogleFonts.inter(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppTheme.secondaryLight,
              ),
            ),
          ),
      ],
    );
  }
}
