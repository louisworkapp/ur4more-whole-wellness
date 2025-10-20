import 'package:flutter/material.dart';
import '../../data/thought_record_content.dart';
import '../../../../design/tokens.dart';

class ThoughtRecordWidget extends StatefulWidget {
  final bool isFaithMode;
  final VoidCallback? onComplete;

  const ThoughtRecordWidget({
    Key? key,
    required this.isFaithMode,
    this.onComplete,
  }) : super(key: key);

  @override
  State<ThoughtRecordWidget> createState() => _ThoughtRecordWidgetState();
}

class _ThoughtRecordWidgetState extends State<ThoughtRecordWidget> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form data
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _thoughtController = TextEditingController();
  final TextEditingController _emotionController = TextEditingController();
  final TextEditingController _evidenceForController = TextEditingController();
  final TextEditingController _evidenceAgainstController = TextEditingController();
  final TextEditingController _balancedThoughtController = TextEditingController();
  final TextEditingController _rerateEmotionController = TextEditingController();
  final TextEditingController _goDeeperController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // Emotion ratings
  Map<String, double> _emotionRatings = {};
  
  // Content
  List<ThoughtRecordContent> _availableContent = [];
  int _currentContentIndex = 0;
  String _selectedCategory = 'situation';

  final List<String> _steps = [
    'Situation',
    'Automatic Thought',
    'Emotion',
    'Evidence For',
    'Evidence Against',
    'Balanced Thought',
    'Re-rate Emotion',
    'Go Deeper'
  ];

  @override
  void initState() {
    super.initState();
    _loadContent();
    // Initialize with the first step's category
    _selectCategoryForStep(0);
  }

  void _loadContent() {
    _availableContent = ThoughtRecordData.getContentByCategory(
      _selectedCategory, 
      widget.isFaithMode
    );
    
    if (_availableContent.isNotEmpty) {
      _currentContentIndex = 0;
    }
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
        // Auto-select the corresponding category when moving to next step
        _selectCategoryForStep(_currentStep);
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
        // Auto-select the corresponding category when moving to previous step
        _selectCategoryForStep(_currentStep);
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

  void _selectCategoryForStep(int step) {
    // Map steps to their corresponding categories
    final stepToCategory = {
      0: 'situation',
      1: 'thought', 
      2: 'emotion',
      3: 'evidence_for',
      4: 'evidence_against',
      5: 'balanced_thought',
      6: 'balanced_thought', // Re-rate emotion step
      7: 'go_deeper', // Go deeper step
    };
    
    final category = stepToCategory[step];
    if (category != null) {
      setState(() {
        _selectedCategory = category;
      });
      _loadContent();
    }
  }

  void _completeExercise() {
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _situationController.dispose();
    _thoughtController.dispose();
    _emotionController.dispose();
    _evidenceForController.dispose();
    _evidenceAgainstController.dispose();
    _balancedThoughtController.dispose();
    _rerateEmotionController.dispose();
    _goDeeperController.dispose();
    _notesController.dispose();
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
          // Progress indicator
          Row(
            children: [
              Expanded(
                child: LinearProgressIndicator(
                  value: (_currentStep + 1) / _steps.length,
                  backgroundColor: theme.colorScheme.outline.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
              SizedBox(width: AppSpace.x3),
              Text(
                '${_currentStep + 1}/${_steps.length}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          
          SizedBox(height: AppSpace.x4),
          
          // Step title
          Text(
            _steps[_currentStep],
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          
          SizedBox(height: AppSpace.x4),
          
          // Content guidance
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
                    children: [
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          onPressed: _previousContent,
                          icon: const Icon(Icons.chevron_left),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpace.x2),
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              currentContent.prompt,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (currentContent.example != null) ...[
                              SizedBox(height: AppSpace.x2),
                              Container(
                                padding: EdgeInsets.all(AppSpace.x2),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  currentContent.example!,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: theme.colorScheme.primary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      SizedBox(width: AppSpace.x2),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: IconButton(
                          onPressed: _nextContent,
                          icon: const Icon(Icons.chevron_right),
                          style: IconButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  // Faith anchor (if available and in faith mode)
                  if (widget.isFaithMode && currentContent.faithAnchor != null) ...[
                    SizedBox(height: AppSpace.x2),
                    Container(
                      padding: EdgeInsets.all(AppSpace.x2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.favorite,
                            color: Colors.blue.shade700,
                            size: 16,
                          ),
                          SizedBox(width: AppSpace.x2),
                          Expanded(
                            child: Text(
                              currentContent.faithAnchor!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            SizedBox(height: AppSpace.x3),
          ],
          
          // Category filter
          Wrap(
            spacing: AppSpace.x2,
            runSpacing: AppSpace.x2,
            children: [
              _buildCategoryChip('situation', 'Situation'),
              _buildCategoryChip('thought', 'Thought'),
              _buildCategoryChip('emotion', 'Emotion'),
              _buildCategoryChip('evidence_for', 'Evidence For'),
              _buildCategoryChip('evidence_against', 'Evidence Against'),
              _buildCategoryChip('balanced_thought', 'Balanced'),
              _buildCategoryChip('go_deeper', 'Go Deeper'),
            ],
          ),
          
          SizedBox(height: AppSpace.x4),
          
          // Step content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildSituationStep(),
                _buildThoughtStep(),
                _buildEmotionStep(),
                _buildEvidenceForStep(),
                _buildEvidenceAgainstStep(),
                _buildBalancedThoughtStep(),
                _buildRerateEmotionStep(),
                _buildGoDeeperStep(),
              ],
            ),
          ),
          
          SizedBox(height: AppSpace.x4),
          
          // Navigation buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                OutlinedButton.icon(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Previous'),
                )
              else
                const SizedBox.shrink(),
              
              if (_currentStep < _steps.length - 1)
                ElevatedButton.icon(
                  onPressed: _nextStep,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Next'),
                )
              else
                ElevatedButton.icon(
                  onPressed: _completeExercise,
                  icon: const Icon(Icons.check),
                  label: const Text('Complete'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSituationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Describe what happened:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        TextField(
          controller: _situationController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What happened? Where were you? Who was there?',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildThoughtStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What automatic thoughts came up?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        TextField(
          controller: _thoughtController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What went through your mind? What did you think?',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What emotions did you feel?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        TextField(
          controller: _emotionController,
          maxLines: 2,
          decoration: const InputDecoration(
            hintText: 'e.g., Anxious, Embarrassed, Frustrated',
            border: OutlineInputBorder(),
          ),
        ),
        SizedBox(height: AppSpace.x3),
        Text(
          'Rate the intensity (0-10):',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: AppSpace.x2),
        // Simple emotion rating - could be expanded
        TextField(
          decoration: const InputDecoration(
            hintText: 'e.g., Anxiety: 8/10, Embarrassment: 6/10',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceForStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What evidence supports this thought?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        TextField(
          controller: _evidenceForController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What facts support your automatic thought?',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildEvidenceAgainstStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What evidence contradicts this thought?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        TextField(
          controller: _evidenceAgainstController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'What facts challenge your automatic thought?',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildBalancedThoughtStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          'What\'s a more balanced way to think?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        TextField(
          controller: _balancedThoughtController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: 'How would you think about this more realistically?',
            border: OutlineInputBorder(),
          ),
        ),
        if (widget.isFaithMode) ...[
          SizedBox(height: AppSpace.x3),
          Container(
            padding: EdgeInsets.all(AppSpace.x3),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Colors.blue.shade700,
                      size: 20,
                    ),
                    SizedBox(width: AppSpace.x2),
                    Text(
                      'Go Deeper with Faith',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpace.x2),
                Text(
                  'How does God\'s perspective change how you think about this situation?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: AppSpace.x2),
                TextField(
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'What would God say about this? How does your faith inform your thinking?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Thought Record',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewSection('Situation', _situationController.text),
                _buildReviewSection('Automatic Thought', _thoughtController.text),
                _buildReviewSection('Emotion', _emotionController.text),
                _buildReviewSection('Evidence For', _evidenceForController.text),
                _buildReviewSection('Evidence Against', _evidenceAgainstController.text),
                _buildReviewSection('Balanced Thought', _balancedThoughtController.text),
                SizedBox(height: AppSpace.x3),
                Text(
                  'Additional Notes:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpace.x2),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Any additional insights or reflections...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(String title, String content) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpace.x3),
      padding: EdgeInsets.all(AppSpace.x3),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: AppSpace.x2),
          Text(
            content.isEmpty ? 'Not filled out' : content,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: content.isEmpty 
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRerateEmotionStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          'Rate your emotion again (1-10):',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        Text(
          'Now that you\'ve worked through the evidence and created a balanced thought, how intense is your emotion?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: AppSpace.x3),
        TextField(
          controller: _rerateEmotionController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Rate 1-10',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildGoDeeperStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
        Text(
          'Go Deeper: Connect to Your Values',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        Text(
          'How does this situation connect to your deeper values? What would you tell a friend in this situation?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        SizedBox(height: AppSpace.x3),
        TextField(
          controller: _goDeeperController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Reflect on your values and what matters most...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        if (widget.isFaithMode) ...[
          SizedBox(height: AppSpace.x3),
          Container(
            padding: EdgeInsets.all(AppSpace.x3),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.favorite,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: AppSpace.x2),
                    Text(
                      'Faith Reflection',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpace.x2),
                Text(
                  'How does your identity in Christ change how you view this situation?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
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
