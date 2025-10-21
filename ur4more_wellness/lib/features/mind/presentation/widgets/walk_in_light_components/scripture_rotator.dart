import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/app_export.dart';
import '../../../../../design/tokens.dart';

class ScriptureRotator extends StatefulWidget {
  final bool isActive;
  final Duration rotationInterval;

  const ScriptureRotator({
    super.key,
    required this.isActive,
    this.rotationInterval = const Duration(seconds: 8),
  });

  @override
  State<ScriptureRotator> createState() => _ScriptureRotatorState();
}

class _ScriptureRotatorState extends State<ScriptureRotator>
    with TickerProviderStateMixin {
  List<Map<String, String>> _scriptures = [];
  int _currentIndex = 0;
  Timer? _rotationTimer;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadScriptures();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _loadScriptures() async {
    try {
      final String jsonString = await rootBundle.loadString(
        'assets/mind/scripture_sets/walk_in_light_scriptures.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> scripturesList = jsonData['walk_in_light_scriptures'];
      
      setState(() {
        _scriptures = scripturesList.cast<Map<String, dynamic>>()
            .map((scripture) => {
              'reference': scripture['reference'] as String,
              'text': scripture['text'] as String,
              'theme': scripture['theme'] as String,
            })
            .toList();
      });
      
      if (_scriptures.isNotEmpty) {
        _fadeController.forward();
        _startRotation();
      }
    } catch (e) {
      print('Error loading scriptures: $e');
    }
  }

  void _startRotation() {
    if (!widget.isActive || _scriptures.isEmpty) return;
    
    _rotationTimer?.cancel();
    _rotationTimer = Timer.periodic(widget.rotationInterval, (timer) {
      if (mounted) {
        _nextScripture();
      }
    });
  }

  void _nextScripture() {
    if (_scriptures.isEmpty) return;
    
    _fadeController.reverse().then((_) {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _scriptures.length;
      });
      _fadeController.forward();
    });
  }

  @override
  void didUpdateWidget(ScriptureRotator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startRotation();
      } else {
        _rotationTimer?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_scriptures.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentScripture = _scriptures[_currentIndex];

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
      child: AnimatedBuilder(
        animation: _fadeAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Column(
              children: [
                    // Scripture icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.menu_book,
                        color: Colors.blue.shade300,
                        size: 20,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Scripture text
                    Text(
                      '"${currentScripture['text']}"',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Scripture reference
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '— ${currentScripture['reference']}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade300,
                        ),
                      ),
                    ),
                
                const SizedBox(height: 8),
                
                // Progress indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _scriptures.length,
                    (index) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentIndex 
                            ? Colors.blue.shade300
                            : Colors.blue.withOpacity(0.5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
