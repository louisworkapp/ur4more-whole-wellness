import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/app_export.dart';
import '../../../../../design/tokens.dart';
import '../../../../../services/faith_service.dart';
import '../../../../../widgets/universal_speech_text_field.dart';

class TruthComponent extends StatefulWidget {
  final FaithTier faithMode;
  final int duration;
  final Function(Map<String, dynamic>) onData;
  final VoidCallback onComplete;

  const TruthComponent({
    super.key,
    required this.faithMode,
    required this.duration,
    required this.onData,
    required this.onComplete,
  });

  @override
  State<TruthComponent> createState() => _TruthComponentState();
}

class _TruthComponentState extends State<TruthComponent>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  
  Timer? _timer;
  int _timeRemaining = 0;
  bool _isActive = false;
  bool _isCompleted = false;
  
  int _currentVerseIndex = 0;
  String _selectedReflection = '';
  String _personalInsight = '';
  final TextEditingController _insightController = TextEditingController();

  // Scripture verses for different faith modes
  final List<Map<String, dynamic>> _verses = [
    {
      'text': 'Be still and know that I am God.',
      'reference': 'Psalm 46:10',
      'theme': 'Peace and Presence',
    },
    {
      'text': 'I can do all things through Christ who strengthens me.',
      'reference': 'Philippians 4:13',
      'theme': 'Strength and Hope',
    },
    {
      'text': 'The Lord is my shepherd; I shall not want.',
      'reference': 'Psalm 23:1',
      'theme': 'Provision and Care',
    },
    {
      'text': 'For I know the plans I have for you, declares the Lord.',
      'reference': 'Jeremiah 29:11',
      'theme': 'Purpose and Future',
    },
  ];

  // Reflection prompts
  final List<String> _reflectionPrompts = [
    'How does this truth apply to your life today?',
    'What does this verse reveal about God\'s character?',
    'How can you live out this truth this week?',
    'What comfort or challenge does this bring?',
  ];

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.duration;
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _fadeController.dispose();
    _insightController.dispose();
    super.dispose();
  }

  void _startReflection() {
    setState(() {
      _isActive = true;
    });
    
    _fadeController.forward();
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining--;
      });
      
      if (_timeRemaining <= 0) {
        _completeReflection();
      }
    });
  }

  void _completeReflection() {
    _timer?.cancel();
    
    setState(() {
      _isActive = false;
      _isCompleted = true;
    });
    
    widget.onData({
      'verse_index': _currentVerseIndex,
      'verse_text': _verses[_currentVerseIndex]['text'],
      'verse_reference': _verses[_currentVerseIndex]['reference'],
      'reflection': _selectedReflection,
      'insight': _personalInsight,
      'duration': widget.duration,
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Auto-advance after 2 seconds
    Timer(const Duration(seconds: 2), widget.onComplete);
  }

  void _selectReflection(String reflection) {
    setState(() {
      _selectedReflection = reflection;
    });
  }

  void _updateInsight(String insight) {
    setState(() {
      _personalInsight = insight;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentVerse = _verses[_currentVerseIndex];
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu_book,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Truth',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Reflect on God\'s word and truth',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 32),
          
          // Timer display
          if (_isActive || _isCompleted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceVariant,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_timeRemaining}s remaining',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          
          const SizedBox(height: 24),
          
          // Scripture verse
          Expanded(
            child: SingleChildScrollView(
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Column(
                      children: [
                        // Verse card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.format_quote,
                                color: Theme.of(context).colorScheme.primary,
                                size: 32,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '"${currentVerse['text']}"',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  height: 1.4,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentVerse['reference'],
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Theme.of(context).colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  currentVerse['theme'],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Reflection section
                        if (_isActive) ...[
                          Text(
                            'Reflection',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Reflection prompts
                          ..._reflectionPrompts.map((prompt) => 
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              child: OutlinedButton(
                                onPressed: () => _selectReflection(prompt),
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.all(16),
                                  alignment: Alignment.centerLeft,
                                  backgroundColor: _selectedReflection == prompt
                                      ? Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3)
                                      : null,
                                ),
                                child: Text(
                                  prompt,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Personal insight with speech-to-text
                          UniversalSpeechJournalField(
                            controller: _insightController,
                            hintText: 'Write your personal insight or prayer...',
                            onChanged: _updateInsight,
                            showSpeechButton: true,
                          ),
                        ],
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Start button or completion message
          if (!_isActive && !_isCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startReflection,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Begin Reflection'),
              ),
            ),
          
          if (_isCompleted)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Reflection complete. Moving to gratitude...',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
