import 'package:flutter/material.dart';
import '../../../design/tokens.dart';

class MicroReflectionModal extends StatefulWidget {
  const MicroReflectionModal({super.key});

  @override
  State<MicroReflectionModal> createState() => _MicroReflectionModalState();
}

class _MicroReflectionModalState extends State<MicroReflectionModal>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  int _remainingSeconds = 60;
  bool _isRunning = false;
  
  final TextEditingController _prompt1Controller = TextEditingController();
  final TextEditingController _prompt2Controller = TextEditingController();
  final TextEditingController _prompt3Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _timerController = AnimationController(
      duration: const Duration(seconds: 60),
      vsync: this,
    );
    _timerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _timerController,
      curve: Curves.linear,
    ));
    
    _timerController.addListener(() {
      setState(() {
        _remainingSeconds = (60 * (1 - _timerAnimation.value)).round();
      });
    });
    
    _timerController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isRunning = false;
          _remainingSeconds = 0;
        });
      }
    });
  }

  @override
  void dispose() {
    _timerController.dispose();
    _prompt1Controller.dispose();
    _prompt2Controller.dispose();
    _prompt3Controller.dispose();
    super.dispose();
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
    });
    _timerController.forward();
  }

  void _resetTimer() {
    _timerController.reset();
    setState(() {
      _isRunning = false;
      _remainingSeconds = 60;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: AppSpace.x2),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.all(AppSpace.x4),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                SizedBox(width: AppSpace.x2),
                Text(
                  '1-Minute Reflection',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          
          // Timer section
          Container(
            margin: EdgeInsets.symmetric(horizontal: AppSpace.x4),
            padding: EdgeInsets.all(AppSpace.x4),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                // Circular progress indicator
                SizedBox(
                  width: 60,
                  height: 60,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: _timerAnimation.value,
                        strokeWidth: 4,
                        backgroundColor: colorScheme.outlineVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                      Center(
                        child: Text(
                          '$_remainingSeconds',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpace.x2),
                // Timer controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isRunning) ...[
                      FilledButton.icon(
                        onPressed: _startTimer,
                        icon: Icon(Icons.play_arrow, size: 18),
                        label: Text('Start'),
                        style: FilledButton.styleFrom(
                          minimumSize: Size(80, 40),
                        ),
                      ),
                    ] else ...[
                      FilledButton.icon(
                        onPressed: _resetTimer,
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('Reset'),
                        style: FilledButton.styleFrom(
                          minimumSize: Size(80, 40),
                          backgroundColor: colorScheme.secondary,
                          foregroundColor: colorScheme.onSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          
          SizedBox(height: AppSpace.x3),
          
          // Reflection prompts
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: AppSpace.x4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reflection Prompts',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: AppSpace.x3),
                  
                  // Prompt 1
                  _buildPromptField(
                    theme,
                    colorScheme,
                    'What desire or impulse am I noticing right now?',
                    _prompt1Controller,
                  ),
                  
                  SizedBox(height: AppSpace.x3),
                  
                  // Prompt 2
                  _buildPromptField(
                    theme,
                    colorScheme,
                    'What would the wiser choice be here?',
                    _prompt2Controller,
                  ),
                  
                  SizedBox(height: AppSpace.x3),
                  
                  // Prompt 3
                  _buildPromptField(
                    theme,
                    colorScheme,
                    'What outcome do I expect from the wiser choice?',
                    _prompt3Controller,
                  ),
                  
                  SizedBox(height: AppSpace.x4),
                  
                  // Done button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.pop(context),
                      style: FilledButton.styleFrom(
                        minimumSize: Size(0, 56),
                      ),
                      child: Text(
                        'Done',
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: AppSpace.x4),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptField(
    ThemeData theme,
    ColorScheme colorScheme,
    String label,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: AppSpace.x2),
        TextField(
          controller: controller,
          maxLines: 2,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: colorScheme.outlineVariant),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
            contentPadding: EdgeInsets.all(AppSpace.x3),
          ),
        ),
      ],
    );
  }
}
