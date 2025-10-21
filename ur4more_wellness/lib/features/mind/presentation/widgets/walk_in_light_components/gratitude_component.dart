import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/app_export.dart';
import '../../../../../design/tokens.dart';
import '../../../../../services/faith_service.dart';
import '../../../../../widgets/universal_speech_text_field.dart';

class GratitudeComponent extends StatefulWidget {
  final FaithMode faithMode;
  final int duration;
  final Function(Map<String, dynamic>) onData;
  final VoidCallback onComplete;

  const GratitudeComponent({
    super.key,
    required this.faithMode,
    required this.duration,
    required this.onData,
    required this.onComplete,
  });

  @override
  State<GratitudeComponent> createState() => _GratitudeComponentState();
}

class _GratitudeComponentState extends State<GratitudeComponent>
    with TickerProviderStateMixin {
  late AnimationController _sparkleController;
  late Animation<double> _sparkleAnimation;
  
  Timer? _timer;
  int _timeRemaining = 0;
  bool _isActive = false;
  bool _isCompleted = false;
  
  List<String> _gratitudeItems = [];
  String _intention = '';
  String _prayer = '';
  final TextEditingController _gratitudeController = TextEditingController();
  final TextEditingController _intentionController = TextEditingController();
  final TextEditingController _prayerController = TextEditingController();

  // Gratitude prompts
  final List<String> _gratitudePrompts = [
    'Something that made you smile today',
    'A person who blessed you recently',
    'A challenge that taught you something',
    'A simple pleasure you enjoyed',
    'A way God provided for you',
    'Something beautiful you noticed',
  ];

  @override
  void initState() {
    super.initState();
    _timeRemaining = widget.duration;
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _sparkleController.dispose();
    _gratitudeController.dispose();
    _intentionController.dispose();
    _prayerController.dispose();
    super.dispose();
  }

  void _startGratitude() {
    setState(() {
      _isActive = true;
    });
    
    _sparkleController.repeat(reverse: true);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timeRemaining--;
      });
      
      if (_timeRemaining <= 0) {
        _completeGratitude();
      }
    });
  }

  void _completeGratitude() {
    _timer?.cancel();
    _sparkleController.stop();
    
    setState(() {
      _isActive = false;
      _isCompleted = true;
    });
    
    widget.onData({
      'gratitude_items': _gratitudeItems,
      'intention': _intention,
      'prayer': _prayer,
      'duration': widget.duration,
    });
    
    // Haptic feedback
    HapticFeedback.lightImpact();
    
    // Auto-advance after 2 seconds
    Timer(const Duration(seconds: 2), widget.onComplete);
  }

  void _addGratitudeItem(String item) {
    if (item.trim().isNotEmpty && !_gratitudeItems.contains(item.trim())) {
      setState(() {
        _gratitudeItems.add(item.trim());
      });
    }
  }

  void _removeGratitudeItem(String item) {
    setState(() {
      _gratitudeItems.remove(item);
    });
  }

  void _updateIntention(String intention) {
    setState(() {
      _intention = intention;
    });
  }

  void _updatePrayer(String prayer) {
    setState(() {
      _prayer = prayer;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                  Icons.favorite,
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
                      'Gratitude',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Practice gratitude and set intentions',
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
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Gratitude section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            AnimatedBuilder(
                              animation: _sparkleAnimation,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: 1.0 + (_sparkleAnimation.value * 0.1),
                                  child: Icon(
                                    Icons.star,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 24,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'What are you grateful for?',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 16),
                        
                        // Gratitude items list
                        if (_gratitudeItems.isNotEmpty) ...[
                          ..._gratitudeItems.map((item) => 
                            Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    color: Theme.of(context).colorScheme.primary,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      item,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  if (_isActive)
                                    IconButton(
                                      onPressed: () => _removeGratitudeItem(item),
                                      icon: const Icon(Icons.close, size: 16),
                                      constraints: const BoxConstraints(),
                                      padding: EdgeInsets.zero,
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        // Add gratitude input with speech-to-text
                        if (_isActive)
                          UniversalSpeechTextField(
                            controller: _gratitudeController,
                            hintText: 'Add something you\'re grateful for...',
                            onSubmitted: (text) {
                              _addGratitudeItem(text);
                              _gratitudeController.clear();
                            },
                            showSpeechButton: true,
                          ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Intention setting
                  if (_isActive) ...[
                    Text(
                      'Set an intention for today',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    UniversalSpeechTextField(
                      controller: _intentionController,
                      hintText: 'How will you walk in the light today?',
                      maxLines: 2,
                      onChanged: _updateIntention,
                      showSpeechButton: true,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Prayer section for faith modes
                    if (widget.faithMode != FaithMode.off) ...[
                      Text(
                        'Prayer or commitment',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      UniversalSpeechTextField(
                        controller: _prayerController,
                        hintText: widget.faithMode == FaithMode.light
                            ? 'A simple prayer or commitment...'
                            : 'Prayer for strength and guidance...',
                        maxLines: 3,
                        onChanged: _updatePrayer,
                        showSpeechButton: true,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Start button or completion message
          if (!_isActive && !_isCompleted)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startGratitude,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Begin Gratitude Practice'),
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
                      'Gratitude practice complete!',
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
