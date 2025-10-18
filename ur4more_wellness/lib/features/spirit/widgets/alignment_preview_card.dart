import 'package:flutter/material.dart';
import '../../../design/tokens.dart';
import '../../../common/widgets/collapsible_info_card.dart';
import '../services/faith_mode_navigator.dart';

class AlignmentPreviewCard extends StatelessWidget {
  final bool collapsed;
  final VoidCallback onToggle;

  const AlignmentPreviewCard({
    super.key,
    required this.collapsed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CollapsibleInfoCard(
      icon: Icons.insights_outlined,
      title: 'From Insight to Alignment (Preview)',
      subtitle: 'A 60-second practice to try now',
      collapsed: collapsed,
      onToggle: onToggle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main content paragraphs
          Text(
            'Pause—notice a desire (soul). Ask: what would the wiser will choose here (spirit)?',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          
          SizedBox(height: AppSpace.x3),
          
          Text(
            'Act on the wiser choice once today. Notice the outcome.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.9),
              height: 1.4,
            ),
          ),
          
          SizedBox(height: AppSpace.x4),
          
          // Button row
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _show60SecondCheckIn(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(0, 56),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Text(
                    'Try 60-sec check-in',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(width: AppSpace.x2),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      await FaithModeNavigator.openFaithModeSelector(context);
                      // The screen will automatically rebuild when faith mode changes
                    },
                    style: TextButton.styleFrom(
                      minimumSize: Size(0, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      'Enable Faith Mode',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _show60SecondCheckIn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SixtySecondCheckInModal(),
    );
  }
}

class SixtySecondCheckInModal extends StatefulWidget {
  const SixtySecondCheckInModal({super.key});

  @override
  State<SixtySecondCheckInModal> createState() => _SixtySecondCheckInModalState();
}

class _SixtySecondCheckInModalState extends State<SixtySecondCheckInModal>
    with TickerProviderStateMixin {
  late AnimationController _timerController;
  late Animation<double> _timerAnimation;
  int _remainingSeconds = 60;
  bool _isRunning = false;
  
  final TextEditingController _desireController = TextEditingController();
  final TextEditingController _wisdomController = TextEditingController();
  final TextEditingController _outcomeController = TextEditingController();

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
    _desireController.dispose();
    _wisdomController.dispose();
    _outcomeController.dispose();
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
      height: MediaQuery.of(context).size.height * 0.8,
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
                  '60-Second Check-in',
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
                  width: 80,
                  height: 80,
                  child: Stack(
                    children: [
                      CircularProgressIndicator(
                        value: _timerAnimation.value,
                        strokeWidth: 6,
                        backgroundColor: colorScheme.outlineVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                      ),
                      Center(
                        child: Text(
                          '$_remainingSeconds',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: AppSpace.x3),
                // Timer controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!_isRunning) ...[
                      ElevatedButton.icon(
                        onPressed: _startTimer,
                        icon: Icon(Icons.play_arrow, size: 20),
                        label: Text('Start'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                        ),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: _resetTimer,
                        icon: Icon(Icons.refresh, size: 20),
                        label: Text('Reset'),
                        style: ElevatedButton.styleFrom(
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
          
          SizedBox(height: AppSpace.x4),
          
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
                    '1. What desire or impulse am I noticing right now?',
                    _desireController,
                    'e.g., "I want to scroll social media"',
                  ),
                  
                  SizedBox(height: AppSpace.x3),
                  
                  // Prompt 2
                  _buildPromptField(
                    theme,
                    colorScheme,
                    '2. What would the wiser choice be here?',
                    _wisdomController,
                    'e.g., "Take a walk or read something meaningful"',
                  ),
                  
                  SizedBox(height: AppSpace.x3),
                  
                  // Prompt 3
                  _buildPromptField(
                    theme,
                    colorScheme,
                    '3. What outcome do I expect from the wiser choice?',
                    _outcomeController,
                    'e.g., "I\'ll feel more energized and focused"',
                  ),
                  
                  SizedBox(height: AppSpace.x6),
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
    String hint,
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
            hintText: hint,
            hintStyle: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.6),
            ),
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
