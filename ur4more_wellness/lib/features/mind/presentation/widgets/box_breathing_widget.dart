import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/box_breathing_content.dart';
import '../../../../design/tokens.dart';
import '../../../../quotes/quotes_repository.dart';

class BoxBreathingWidget extends StatefulWidget {
  final bool isFaithMode;
  final VoidCallback? onComplete;

  const BoxBreathingWidget({
    Key? key,
    required this.isFaithMode,
    this.onComplete,
  }) : super(key: key);

  @override
  State<BoxBreathingWidget> createState() => _BoxBreathingWidgetState();
}

class _BoxBreathingWidgetState extends State<BoxBreathingWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  
  Timer? _breathingTimer;
  int _currentPhase = 0; // 0: inhale, 1: hold, 2: exhale, 3: hold
  int _currentCount = 0;
  bool _isRunning = false;
  int _cycleCount = 0;
  
  List<BoxBreathingContent> _availableContent = [];
  int _currentContentIndex = 0;
  String _selectedCategory = 'all';

  final List<String> _phases = ['Inhale', 'Hold', 'Exhale', 'Hold'];
  final List<Color> _phaseColors = [
    Colors.blue.shade300,
    Colors.blue.shade500,
    Colors.green.shade300,
    Colors.green.shade500,
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadContent();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  void _loadContent() async {
    if (widget.isFaithMode) {
      // In faith mode, load scripture quotes from the quote library
      await _loadScriptureQuotes();
    } else {
      // In secular mode, use the existing content
      if (_selectedCategory == 'all') {
        _availableContent = BoxBreathingData.getContentForMode(widget.isFaithMode);
      } else {
        _availableContent = BoxBreathingData.getContentByCategory(
          _selectedCategory, 
          widget.isFaithMode
        );
      }
    }
    
    if (_availableContent.isNotEmpty) {
      _currentContentIndex = 0;
    }
  }

  Future<void> _loadScriptureQuotes() async {
    // Load scripture quotes from the quote library
    final quotesRepo = QuotesRepository();
    final allQuotes = await quotesRepo.loadAll();
    
    // Filter for scripture quotes that are suitable for breathing exercises
    List<Map<String, dynamic>> scriptureQuotes = allQuotes.where((quote) {
      final modes = quote['modes'] as Map<String, dynamic>?;
      final hasScripture = quote['scripture_kjv'] != null;
      final isFaithOk = modes?['faith_ok'] == true;
      
      return hasScripture && isFaithOk;
    }).toList();
    
    // If a specific category is selected (not 'all'), filter by theme
    if (_selectedCategory != 'all') {
      scriptureQuotes = _filterQuotesByCategory(scriptureQuotes, _selectedCategory);
    }
    
    // Convert to BoxBreathingContent format
    _availableContent = scriptureQuotes.map((quote) {
      final scripture = quote['scripture_kjv'] as Map<String, dynamic>?;
      return BoxBreathingContent(
        text: scripture?['text'] ?? quote['text'] ?? '',
        reference: scripture?['ref'] ?? '',
        type: 'verse',
        category: _selectedCategory == 'all' ? 'scripture' : _selectedCategory,
        isFaithContent: true,
      );
    }).toList();
  }

  List<Map<String, dynamic>> _filterQuotesByCategory(List<Map<String, dynamic>> quotes, String category) {
    // Map categories to relevant themes/keywords
    final categoryKeywords = {
      'peace': ['peace', 'calm', 'still', 'rest', 'quiet'],
      'strength': ['strength', 'power', 'might', 'strong', 'courage'],
      'trust': ['trust', 'faith', 'believe', 'hope', 'confidence'],
      'rest': ['rest', 'peace', 'calm', 'quiet', 'still'],
      'hope': ['hope', 'future', 'promise', 'light', 'joy'],
      'love': ['love', 'beloved', 'cherish', 'care', 'compassion'],
      'protection': ['protect', 'shield', 'guard', 'shelter', 'refuge'],
    };
    
    final keywords = categoryKeywords[category] ?? [];
    
    return quotes.where((quote) {
      final scripture = quote['scripture_kjv'] as Map<String, dynamic>?;
      final text = (scripture?['text'] ?? quote['text'] ?? '').toLowerCase();
      
      return keywords.any((keyword) => text.contains(keyword));
    }).toList();
  }

  void _startBreathing() {
    if (_isRunning) return;
    
    setState(() {
      _isRunning = true;
      _currentPhase = 0;
      _currentCount = 0;
      _cycleCount = 0;
    });
    
    _nextPhase();
  }

  void _stopBreathing() {
    setState(() {
      _isRunning = false;
    });
    
    _breathingTimer?.cancel();
    _animationController.stop();
  }

  void _nextPhase() {
    if (!_isRunning) return;
    
    setState(() {
      _currentCount = 0;
    });
    
    _breathingTimer?.cancel();
    _breathingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _currentCount++;
      });
      
      if (_currentCount >= 4) {
        timer.cancel();
        setState(() {
          _currentPhase = (_currentPhase + 1) % 4;
          if (_currentPhase == 0) {
            _cycleCount++;
          }
        });
        
        if (_cycleCount >= 4) {
          _stopBreathing();
          widget.onComplete?.call();
        } else {
          _nextPhase();
        }
      }
    });
    
    // Start animation for current phase
    if (_currentPhase == 0 || _currentPhase == 2) {
      _animationController.repeat(reverse: true);
    } else {
      _animationController.stop();
      _animationController.value = _currentPhase == 1 ? 1.0 : 0.0;
    }
  }

  void _nextContent() {
    if (_availableContent.isEmpty) return;
    
    setState(() {
      _currentContentIndex = (_currentContentIndex + 1) % _availableContent.length;
    });
  }

  void _previousContent() {
    if (_availableContent.isEmpty) return;
    
    setState(() {
      _currentContentIndex = _currentContentIndex == 0 
          ? _availableContent.length - 1 
          : _currentContentIndex - 1;
    });
  }

  void _changeCategory(String category) {
    setState(() {
      _selectedCategory = category;
    });
    _loadContent();
  }

  List<String> _getAvailableCategories() {
    if (widget.isFaithMode) {
      // In faith mode, show scripture-related categories
      return ['scripture', 'peace', 'strength', 'trust', 'rest', 'hope', 'love', 'protection'];
    } else {
      // In secular mode, show the original categories
      return BoxBreathingData.getCategories(widget.isFaithMode);
    }
  }

  @override
  void dispose() {
    _breathingTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentContent = _availableContent.isNotEmpty 
        ? _availableContent[_currentContentIndex] 
        : null;
    
    return Container(
      padding: EdgeInsets.all(AppSpace.x4),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Box Breathing',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.isFaithMode)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpace.x2,
                    vertical: AppSpace.x1,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Faith Mode',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: AppSpace.x4),
          
          // Breathing Circle
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _phaseColors[_currentPhase].withOpacity(0.3),
                      border: Border.all(
                        color: _phaseColors[_currentPhase],
                        width: 4,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _phases[_currentPhase],
                          style: theme.textTheme.headlineMedium?.copyWith(
                            color: _phaseColors[_currentPhase],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: AppSpace.x2),
                        Text(
                          '${4 - _currentCount}',
                          style: theme.textTheme.displayLarge?.copyWith(
                            color: _phaseColors[_currentPhase],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_cycleCount > 0)
                          Text(
                            'Cycle $_cycleCount/4',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: _phaseColors[_currentPhase],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          SizedBox(height: AppSpace.x4),
          
          // Content Display
          if (currentContent != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(AppSpace.x3),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                children: [
                  // Content Navigation
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _previousContent,
                        icon: const Icon(Icons.chevron_left),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            if (currentContent.reference != null)
                              Text(
                                currentContent.reference!,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            SizedBox(height: AppSpace.x1),
                            Text(
                              currentContent.text,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _nextContent,
                        icon: const Icon(Icons.chevron_right),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                  
                  SizedBox(height: AppSpace.x2),
                  
                  // Content Type Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.x2,
                      vertical: AppSpace.x1,
                    ),
                    decoration: BoxDecoration(
                      color: currentContent.type == 'verse' 
                          ? Colors.blue.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentContent.type.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: currentContent.type == 'verse' 
                            ? Colors.blue.shade700
                            : Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpace.x3),
          ],
          
          // Category Filter
          if (widget.isFaithMode) ...[
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildCategoryChip('all', 'All'),
                  SizedBox(width: AppSpace.x2),
                  ..._getAvailableCategories().map(
                    (category) => Padding(
                      padding: EdgeInsets.only(right: AppSpace.x2),
                      child: _buildCategoryChip(category, category),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: AppSpace.x4),
          ],
          
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: _isRunning ? _stopBreathing : _startBreathing,
                icon: Icon(_isRunning ? Icons.stop : Icons.play_arrow),
                label: Text(_isRunning ? 'Stop' : 'Start'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isRunning 
                      ? Colors.red.shade400
                      : theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpace.x4,
                    vertical: AppSpace.x2,
                  ),
                ),
              ),
              if (!_isRunning)
                OutlinedButton.icon(
                  onPressed: _nextContent,
                  icon: const Icon(Icons.skip_next),
                  label: const Text('Next'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpace.x4,
                      vertical: AppSpace.x2,
                    ),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: AppSpace.x3),
          
          // Instructions
          Container(
            padding: EdgeInsets.all(AppSpace.x3),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Instructions:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpace.x2),
                const Text('• Inhale for 4 counts'),
                const Text('• Hold for 4 counts'),
                const Text('• Exhale for 4 counts'),
                const Text('• Hold empty for 4 counts'),
                const Text('• Complete 4 cycles'),
                if (widget.isFaithMode) ...[
                  SizedBox(height: AppSpace.x2),
                  Text(
                    '💡 Use the arrows to rotate through verses and prayers during your breathing practice.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedCategory == category;
    
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) => _changeCategory(category),
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
    );
  }
}
