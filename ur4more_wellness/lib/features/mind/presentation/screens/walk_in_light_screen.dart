import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/app_export.dart';
import '../../../../design/tokens.dart';
import '../../../../services/faith_service.dart';
import '../../../faith/faith_consent.dart';
import '../widgets/walk_in_light_components/breath_component.dart';
import '../widgets/walk_in_light_components/truth_component.dart';
import '../widgets/walk_in_light_components/gratitude_component.dart';
import '../widgets/walk_in_light_components/completion_component.dart';

class WalkInLightScreen extends StatefulWidget {
  final FaithMode faithMode;
  final Function(String event, Map<String, dynamic> props)? onAnalytics;
  final Function(int xp)? onAwardXp;

  const WalkInLightScreen({
    super.key,
    required this.faithMode,
    this.onAnalytics,
    this.onAwardXp,
  });

  @override
  State<WalkInLightScreen> createState() => _WalkInLightScreenState();
}

class _WalkInLightScreenState extends State<WalkInLightScreen>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  int _currentStep = 0;
  bool _isCompleted = false;
  bool _showFaithConsent = false;
  
  // Component data
  Map<String, dynamic> _breathData = {};
  Map<String, dynamic> _truthData = {};
  Map<String, dynamic> _gratitudeData = {};

  final List<Map<String, dynamic>> _steps = [
    {
      'title': 'Breathe',
      'subtitle': 'Center yourself with mindful breathing',
      'duration': 90, // 1.5 minutes
      'icon': Icons.air,
    },
    {
      'title': 'Truth',
      'subtitle': 'Reflect on God\'s word and truth',
      'duration': 120, // 2 minutes
      'icon': Icons.menu_book,
    },
    {
      'title': 'Gratitude',
      'subtitle': 'Practice gratitude and set intentions',
      'duration': 90, // 1.5 minutes
      'icon': Icons.favorite,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    
    _checkFaithConsent();
  }

  void _checkFaithConsent() {
    if (widget.faithMode == FaithMode.light && !FaithConsent.hasConsentLight()) {
      setState(() {
        _showFaithConsent = true;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
    } else {
      _completeRoutine();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _updateProgress();
    }
  }

  void _updateProgress() {
    _progressController.animateTo((_currentStep + 1) / _steps.length);
  }

  void _completeRoutine() {
    setState(() {
      _isCompleted = true;
    });
    _progressController.animateTo(1.0);
    
    // Award XP
    widget.onAwardXp?.call(50);
    
    // Analytics
    widget.onAnalytics?.call('walk_in_light_completed', {
      'faith_mode': widget.faithMode.name,
      'duration_minutes': 5,
      'breath_data': _breathData,
      'truth_data': _truthData,
      'gratitude_data': _gratitudeData,
    });
  }

  void _onComponentData(String component, Map<String, dynamic> data) {
    setState(() {
      switch (component) {
        case 'breath':
          _breathData = data;
          break;
        case 'truth':
          _truthData = data;
          break;
        case 'gratitude':
          _gratitudeData = data;
          break;
      }
    });
  }

  void _onFaithConsentResult(bool granted) {
    setState(() {
      _showFaithConsent = false;
    });
    
    if (!granted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showFaithConsent) {
      return FaithConsentDialog(
        context: InviteContext.walkInLight,
        onResult: _onFaithConsentResult,
      );
    }

    if (_isCompleted) {
      return CompletionComponent(
        faithMode: widget.faithMode,
        breathData: _breathData,
        truthData: _truthData,
        gratitudeData: _gratitudeData,
        onRestart: () {
          setState(() {
            _currentStep = 0;
            _isCompleted = false;
            _breathData = {};
            _truthData = {};
            _gratitudeData = {};
          });
          _pageController.animateToPage(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
          _progressController.reset();
        },
        onClose: () => Navigator.of(context).pop(),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Walk in the Light'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (_currentStep > 0)
            TextButton(
              onPressed: _previousStep,
              child: const Text('Back'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Step ${_currentStep + 1} of ${_steps.length}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      '${_steps[_currentStep]['duration']}s',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _progressAnimation,
                  builder: (context, child) {
                    return LinearProgressIndicator(
                      value: _progressAnimation.value,
                      backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          // Step content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                BreathComponent(
                  faithMode: widget.faithMode,
                  duration: _steps[0]['duration'],
                  onData: (data) => _onComponentData('breath', data),
                  onComplete: _nextStep,
                ),
                TruthComponent(
                  faithMode: widget.faithMode,
                  duration: _steps[1]['duration'],
                  onData: (data) => _onComponentData('truth', data),
                  onComplete: _nextStep,
                ),
                GratitudeComponent(
                  faithMode: widget.faithMode,
                  duration: _steps[2]['duration'],
                  onData: (data) => _onComponentData('gratitude', data),
                  onComplete: _nextStep,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
