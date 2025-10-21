import 'package:flutter/material.dart';
import '../../data/values_clarification_content.dart';
import '../../../../design/tokens.dart';
import '../../../../widgets/universal_speech_text_field.dart';

class ValuesClarificationWidget extends StatefulWidget {
  final bool isFaithMode;
  final VoidCallback? onComplete;

  const ValuesClarificationWidget({
    Key? key,
    required this.isFaithMode,
    this.onComplete,
  }) : super(key: key);

  @override
  State<ValuesClarificationWidget> createState() => _ValuesClarificationWidgetState();
}

class _ValuesClarificationWidgetState extends State<ValuesClarificationWidget> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Form data
  final TextEditingController _coreValuesController = TextEditingController();
  final TextEditingController _valuesInActionController = TextEditingController();
  final TextEditingController _decisionMakingController = TextEditingController();
  final TextEditingController _conflictingValuesController = TextEditingController();
  final TextEditingController _legacyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  // Selected values
  Set<String> _selectedValues = {};
  
  // Content
  List<ValuesContent> _availableContent = [];
  int _currentContentIndex = 0;
  String _selectedCategory = 'core_values';

  final List<String> _steps = [
    'Core Values',
    'Values in Action',
    'Decision Making',
    'Value Conflicts',
    'Legacy & Purpose',
    'Review'
  ];

  @override
  void initState() {
    super.initState();
    _loadContent();
    // Initialize with the first step's category
    _selectCategoryForStep(0);
  }

  void _loadContent() {
    _availableContent = ValuesClarificationData.getContentByCategory(
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
      0: 'core_values',
      1: 'values_in_action', 
      2: 'decision_making',
      3: 'conflicting_values',
      4: 'go_deeper', // Legacy & Purpose step shows go deeper content
      5: 'core_values', // Review step - keep a meaningful category
    };
    
    final category = stepToCategory[step];
    if (category != null) {
      setState(() {
        _selectedCategory = category;
      });
      _loadContent();
    }
  }

  void _toggleValue(String value) {
    setState(() {
      if (_selectedValues.contains(value)) {
        _selectedValues.remove(value);
      } else {
        _selectedValues.add(value);
      }
    });
  }

  void _completeExercise() {
    widget.onComplete?.call();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _coreValuesController.dispose();
    _valuesInActionController.dispose();
    _decisionMakingController.dispose();
    _conflictingValuesController.dispose();
    _legacyController.dispose();
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
                  
                  // Faith connection (if available and in faith mode)
                  if (widget.isFaithMode && currentContent.faithConnection != null) ...[
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
                              currentContent.faithConnection!,
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
              _buildCategoryChip('core_values', 'Core Values'),
              _buildCategoryChip('values_in_action', 'In Action'),
              _buildCategoryChip('decision_making', 'Decisions'),
              _buildCategoryChip('conflicting_values', 'Conflicts'),
              if (widget.isFaithMode)
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
                _buildCoreValuesStep(),
                _buildValuesInActionStep(),
                _buildDecisionMakingStep(),
                _buildConflictingValuesStep(),
                _buildLegacyStep(),
                _buildReviewStep(),
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

  Widget _buildCoreValuesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select your core values:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: ValuesClarificationData.commonValues.length,
            itemBuilder: (context, index) {
              final value = ValuesClarificationData.commonValues[index];
              final isSelected = _selectedValues.contains(value);
              
              return FilterChip(
                label: Text(value),
                selected: isSelected,
                onSelected: (selected) => _toggleValue(value),
                selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                checkmarkColor: Theme.of(context).colorScheme.primary,
              );
            },
          ),
        ),
        SizedBox(height: AppSpace.x3),
        Text(
          'Additional values:',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x2),
        UniversalSpeechTextField(
          controller: _coreValuesController,
          maxLines: 2,
          showSpeechButton: true,
          decoration: const InputDecoration(
            hintText: 'Add any other values that are important to you...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildValuesInActionStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When do you feel most like yourself?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        UniversalSpeechTextField(
          controller: _valuesInActionController,
          maxLines: 6,
          showSpeechButton: true,
          decoration: const InputDecoration(
            hintText: 'Describe activities, situations, or moments when you feel most authentic and fulfilled...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildDecisionMakingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How do your values guide your decisions?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        UniversalSpeechTextField(
          controller: _decisionMakingController,
          maxLines: 6,
          showSpeechButton: true,
          decoration: const InputDecoration(
            hintText: 'Think of a recent decision. How did your values influence your choice?',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildConflictingValuesStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When have your values conflicted?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        UniversalSpeechTextField(
          controller: _conflictingValuesController,
          maxLines: 6,
          showSpeechButton: true,
          decoration: const InputDecoration(
            hintText: 'Describe a time when you had to choose between competing values...',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildLegacyStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What legacy do you want to leave?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: AppSpace.x3),
        UniversalSpeechTextField(
          controller: _legacyController,
          maxLines: 4,
          showSpeechButton: true,
          decoration: const InputDecoration(
            hintText: 'How do you want to be remembered? What impact do you want to have?',
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
                  'How does your faith shape the legacy you want to create?',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.blue.shade700,
                  ),
                ),
                SizedBox(height: AppSpace.x2),
                UniversalSpeechTextField(
                  controller: TextEditingController(),
                  maxLines: 3,
                  showSpeechButton: true,
                  decoration: const InputDecoration(
                    hintText: 'How does your relationship with God influence your purpose and legacy?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review Your Values',
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
                // Selected values
                Container(
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
                        'Your Core Values',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      SizedBox(height: AppSpace.x2),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _selectedValues.map((value) => Chip(
                          label: Text(value),
                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                        )).toList(),
                      ),
                      if (_coreValuesController.text.isNotEmpty) ...[
                        SizedBox(height: AppSpace.x2),
                        Text(
                          'Additional: ${_coreValuesController.text}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                
                SizedBox(height: AppSpace.x3),
                _buildReviewSection('Values in Action', _valuesInActionController.text),
                _buildReviewSection('Decision Making', _decisionMakingController.text),
                _buildReviewSection('Value Conflicts', _conflictingValuesController.text),
                _buildReviewSection('Legacy & Purpose', _legacyController.text),
                
                SizedBox(height: AppSpace.x3),
                Text(
                  'Additional Notes:',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: AppSpace.x2),
                UniversalSpeechTextField(
                  controller: _notesController,
                  maxLines: 3,
                  showSpeechButton: true,
                  decoration: const InputDecoration(
                    hintText: 'Any additional insights about your values...',
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
