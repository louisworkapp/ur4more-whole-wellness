import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/app_export.dart';
import '../../../design/tokens.dart';
import '../../../services/ai_suggestion_service.dart';
import '../../../services/faith_service.dart';
import '../../../services/safety_monitor_service.dart';
import '../../../widgets/custom_icon_widget.dart';
import 'safety_alert_widget.dart';

class AISuggestionsWidget extends StatefulWidget {
  final double painLevel;
  final List<String> painRegions;
  final double urgeLevel;
  final List<String> urgeTypes;
  final int rpeLevel;
  final FaithTier faithMode;
  final List<String> selectedSuggestions;
  final String? journalText;
  final String? mood;
  final ValueChanged<List<String>> onSuggestionsChanged;

  const AISuggestionsWidget({
    super.key,
    required this.painLevel,
    required this.painRegions,
    required this.urgeLevel,
    required this.urgeTypes,
    required this.rpeLevel,
    required this.faithMode,
    required this.selectedSuggestions,
    required this.onSuggestionsChanged,
    this.journalText,
    this.mood,
  });

  @override
  State<AISuggestionsWidget> createState() => _AISuggestionsWidgetState();
}

class _AISuggestionsWidgetState extends State<AISuggestionsWidget> {
  List<AISuggestion> _aiSuggestions = [];
  bool _isLoading = true;
  String _explanation = '';
  SafetyAnalysisResult? _safetyAnalysis;
  bool _showSafetyAlert = false;

  @override
  void initState() {
    super.initState();
    _generateSuggestions();
    _analyzeSafety();
  }

  @override
  void didUpdateWidget(AISuggestionsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Regenerate suggestions if key data changed
    if (oldWidget.painLevel != widget.painLevel ||
        oldWidget.painRegions != widget.painRegions ||
        oldWidget.urgeLevel != widget.urgeLevel ||
        oldWidget.urgeTypes != widget.urgeTypes ||
        oldWidget.rpeLevel != widget.rpeLevel ||
        oldWidget.faithMode != widget.faithMode) {
      _generateSuggestions();
    }
    
    // Re-analyze safety if concerning data changed
    if (oldWidget.journalText != widget.journalText || 
        oldWidget.mood != widget.mood ||
        oldWidget.painLevel != widget.painLevel ||
        oldWidget.urgeLevel != widget.urgeLevel) {
      _analyzeSafety();
    }
  }

  void _generateSuggestions() {
    setState(() {
      _isLoading = true;
    });

    // Simulate AI processing time
    Future.delayed(const Duration(milliseconds: 800), () async {
      final checkInData = CheckInData(
        painLevel: widget.painLevel,
        painRegions: widget.painRegions,
        urgeLevel: widget.urgeLevel,
        urgeTypes: widget.urgeTypes,
        rpeLevel: widget.rpeLevel,
        faithMode: widget.faithMode,
        timestamp: DateTime.now(),
      );

      // Try unified schema first, fallback to original if needed
      List<AISuggestion> suggestions;
      try {
        suggestions = await AISuggestionService.generateUnifiedSuggestions(checkInData);
      } catch (e) {
        print('Unified schema failed, using fallback: $e');
        suggestions = AISuggestionService.generateSuggestions(checkInData);
      }
      final explanation = AISuggestionService.getExplanation(checkInData, suggestions);

      if (mounted) {
        setState(() {
          _aiSuggestions = suggestions;
          _explanation = explanation;
          _isLoading = false;
        });
      }
    });
  }

  void _analyzeSafety() {
    final analysis = SafetyMonitorService.analyzeCheckInData(
      painLevel: widget.painLevel,
      painRegions: widget.painRegions,
      urgeLevel: widget.urgeLevel,
      urgeTypes: widget.urgeTypes,
      rpeLevel: widget.rpeLevel,
      journalText: widget.journalText,
      mood: widget.mood,
    );
    
    setState(() {
      _safetyAnalysis = analysis;
      _showSafetyAlert = analysis.hasConcerns;
    });
  }

  void _toggleSuggestion(String suggestionId) {
    setState(() {
      if (widget.selectedSuggestions.contains(suggestionId)) {
        widget.selectedSuggestions.remove(suggestionId);
      } else {
        widget.selectedSuggestions.add(suggestionId);
      }
    });
    widget.onSuggestionsChanged(widget.selectedSuggestions);
  }

  void _dismissSafetyAlert() {
    setState(() {
      _showSafetyAlert = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: Pad.card,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // Safety Alert (if needed)
          if (_showSafetyAlert && _safetyAnalysis != null) ...[
            SafetyAlertWidget(
              analysisResult: _safetyAnalysis!,
              onDismiss: _dismissSafetyAlert,
              faithMode: widget.faithMode,
            ),
            const SizedBox(height: 16),
          ],
          
          // Header with AI icon and title
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: CustomIconWidget(
                  iconName: 'psychology',
                  color: colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'UR4MORE Powered Suggestions',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Personalized recommendations based on your check-in',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),

          // Explanation text
          if (_explanation.isNotEmpty && !_isLoading) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'lightbulb',
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _explanation,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Loading state
          if (_isLoading) ...[
            Center(
              child: Column(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Analyzing your data and generating personalized suggestions...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],

          // AI Suggestions
          if (!_isLoading) ...[
            // Summary bar
            if (widget.selectedSuggestions.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'check_circle',
                      color: colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Selected ${widget.selectedSuggestions.length} suggestions',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Suggestions list
            ..._aiSuggestions.map((suggestion) => _buildSuggestionCard(suggestion)).toList(),

            // Refresh button
            const SizedBox(height: 16),
            Center(
              child: TextButton.icon(
                onPressed: _generateSuggestions,
                icon: CustomIconWidget(
                  iconName: 'refresh',
                  color: colorScheme.primary,
                  size: 20,
                ),
                label: Text(
                  'Get New Suggestions',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(AISuggestion suggestion) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = widget.selectedSuggestions.contains(suggestion.id);
    final isFaithBased = suggestion.requiresFaithTier;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => _toggleSuggestion(suggestion.id),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? (isFaithBased ? colorScheme.secondaryContainer : colorScheme.primaryContainer)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? (isFaithBased ? colorScheme.secondary : colorScheme.primary)
                  : colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? (isFaithBased ? colorScheme.secondary : colorScheme.primary)
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomIconWidget(
                      iconName: suggestion.iconName,
                      color: isSelected 
                          ? (isFaithBased ? colorScheme.onSecondary : colorScheme.onPrimary)
                          : colorScheme.onSurface,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Title and category
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          suggestion.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected 
                                ? (isFaithBased ? colorScheme.onSecondaryContainer : colorScheme.onPrimaryContainer)
                                : colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getCategoryColor(suggestion.category).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                suggestion.category.toUpperCase(),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: _getCategoryColor(suggestion.category),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            if (isFaithBased) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: colorScheme.secondary.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'FAITH',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Selection indicator
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected 
                          ? (isFaithBased ? colorScheme.secondary : colorScheme.primary)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected 
                            ? (isFaithBased ? colorScheme.secondary : colorScheme.primary)
                            : colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: isSelected 
                        ? Icon(
                            Icons.check,
                            size: 16,
                            color: isFaithBased ? colorScheme.onSecondary : colorScheme.onPrimary,
                          )
                        : null,
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                suggestion.description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isSelected 
                      ? (isFaithBased ? colorScheme.onSecondaryContainer : colorScheme.onPrimaryContainer)
                      : colorScheme.onSurface,
                ),
              ),
              
              // Faith content
              if (isFaithBased && suggestion.faithVerse != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '"${suggestion.faithVerse}"',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.secondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (suggestion.faithPrompt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          suggestion.faithPrompt!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
              
              // Reasoning (collapsible)
              const SizedBox(height: 8),
              ExpansionTile(
                title: Text(
                  'Why this suggestion?',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      suggestion.reasoning,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'exercise':
        return Colors.green;
      case 'coping':
        return Colors.blue;
      case 'spiritual':
        return Colors.purple;
      case 'social':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
