import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import '../../theme/tokens.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/discipleship_background.dart';

class MorningCheckinScreen extends StatefulWidget {
  const MorningCheckinScreen({super.key});

  @override
  State<MorningCheckinScreen> createState() => _MorningCheckinScreenState();
}

class _MorningCheckinScreenState extends State<MorningCheckinScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _sparkleController;
  
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _sparkleAnimation;

  // Morning check-in data
  int _energyLevel = 5; // 1-10 scale
  int _moodLevel = 5; // 1-10 scale
  int _sleepQuality = 5; // 1-10 scale
  String _morningIntention = '';
  List<String> _selectedGoals = [];
  bool _isCompleted = false;

  final List<String> _dailyGoals = [
    'Exercise',
    'Read Scripture',
    'Prayer Time',
    'Healthy Eating',
    'Work Focus',
    'Family Time',
    'Learning',
    'Rest',
    'Gratitude',
    'Service',
  ];

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _sparkleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _sparkleController,
      curve: Curves.linear,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scaleController.forward();
    });
    _sparkleController.repeat();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _completeCheckin() {
    setState(() {
      _isCompleted = true;
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Show completion dialog
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: T.gold, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: T.gold, size: 28),
            const SizedBox(width: 12),
            Text(
              'Morning Check-in Complete!',
              style: TextStyle(
                color: T.gold,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Great start to your day! Your intentions are set and you\'re ready to grow.',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: T.gold.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: T.gold.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    'Today\'s Focus:',
                    style: TextStyle(
                      color: T.gold,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _morningIntention.isNotEmpty 
                        ? _morningIntention 
                        : 'Live with purpose and gratitude',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to alarm clock
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: T.gold,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Continue to Day'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Custom background gradient
          const DiscipleshipBackground(),
          
          // Content overlay
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Top section with sun icon
                  SizedBox(
                    height: 200,
                    child: Center(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: T.gold.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: T.gold.withOpacity(0.3),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: T.gold.withOpacity(0.2),
                                  blurRadius: 15,
                                  spreadRadius: 3,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.wb_sunny,
                              color: T.gold,
                              size: 60,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Content section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                    child: Column(
                      children: [
                        // Welcome message
                        FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              Text(
                                'Good Morning!',
                                style: theme.textTheme.headlineMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              
                              const SizedBox(height: 12),
                              
                              Text(
                                'How are you feeling this morning?',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: T.gold,
                                  fontWeight: FontWeight.w600,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Energy Level
                        _buildSliderCard(
                          'Energy Level',
                          Icons.battery_charging_full,
                          _energyLevel,
                          (value) => setState(() => _energyLevel = value),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Mood Level
                        _buildSliderCard(
                          'Mood',
                          Icons.sentiment_satisfied,
                          _moodLevel,
                          (value) => setState(() => _moodLevel = value),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Sleep Quality
                        _buildSliderCard(
                          'Sleep Quality',
                          Icons.bedtime,
                          _sleepQuality,
                          (value) => setState(() => _sleepQuality = value),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Morning Intention
                        _buildIntentionCard(),
                        
                        const SizedBox(height: 24),
                        
                        // Daily Goals
                        _buildGoalsCard(),
                        
                        const SizedBox(height: 32),
                        
                        // Complete button
                        Container(
                          width: double.infinity,
                          height: 60,
                          decoration: BoxDecoration(
                            color: T.gold,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: T.gold.withOpacity(0.4),
                                blurRadius: 15,
                                offset: const Offset(0, 6),
                              ),
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: _isCompleted ? null : _completeCheckin,
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _isCompleted ? Icons.check_circle : Icons.check,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _isCompleted ? 'Check-in Complete' : 'Complete Morning Check-in',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderCard(String title, IconData icon, int value, Function(int) onChanged) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: T.gold.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: T.gold, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: T.gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$value/10',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: T.gold,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: T.gold,
              inactiveTrackColor: Colors.white.withOpacity(0.2),
              thumbColor: T.gold,
              overlayColor: T.gold.withOpacity(0.2),
              trackHeight: 6,
            ),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 10,
              divisions: 9,
              onChanged: (newValue) => onChanged(newValue.round()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntentionCard() {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: T.gold.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb, color: T.gold, size: 24),
              const SizedBox(width: 12),
              Text(
                'Morning Intention',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: (value) => setState(() => _morningIntention = value),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'What do you want to focus on today?',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: T.gold.withOpacity(0.3)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: T.gold.withOpacity(0.3)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: T.gold),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalsCard() {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: T.gold.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag, color: T.gold, size: 24),
              const SizedBox(width: 12),
              Text(
                'Today\'s Goals',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dailyGoals.map((goal) {
              final isSelected = _selectedGoals.contains(goal);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedGoals.remove(goal);
                    } else {
                      _selectedGoals.add(goal);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? T.gold : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? T.gold : T.gold.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    goal,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
