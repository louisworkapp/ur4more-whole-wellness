import 'package:flutter/material.dart';

import '../../core/app_export.dart';
import '../../design/tokens.dart';
import '../../core/brand_rules.dart';
import '../../core/services/points_service.dart';
import '../../features/home/streaks.dart';
import '../../core/services/telemetry.dart';
import '../../services/faith_service.dart';
import './widgets/completion_summary_widget.dart';
import './widgets/coping_mechanisms_widget.dart';
import './widgets/journal_entry_widget.dart';
import './widgets/pain_level_widget.dart';
import './widgets/progress_header_widget.dart';
import './widgets/rpe_scale_widget.dart';
import './widgets/urge_intensity_widget.dart';

class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key});

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();

  int _currentSection = 0;
  bool _isCompleted = false;
  bool _isSubmitting = false;

  // Data storage - Updated structure based on requirements
  int _rpeValue = 5; // Changed to integer as per requirements
  double _painLevel = 0.0; // Simplified to single pain slider
  double _urgeLevel = 0.0; // Single urge/craving slider (0-10)
  List<String> _selectedCopingMechanisms = [];
  String _journalText = '';
  String _selectedMood = '';
  List<String> _attachedPhotos = [];

  // Mock user data and faith mode
  final String _userId = "user_12345";
  FaithMode _faithMode = FaithMode.light; // Mock faith mode

  final List<String> _sectionTitles = [
    'Rate of Perceived Exertion', // Updated titles as per requirements
    'Pain Assessment',
    'Urge & Craving Tracking',
    'Coping Strategies',
    'Journal Entry',
  ];

  final List<String> _sectionLabels = [
    'How hard did your body work today?', // New labels as per requirements
    'Rate pain today (0–10)',
    'Cravings or urges (0–10)',
    'What helped today?',
    'A few lines about today'
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  double get _completionPercentage {
    if (_isCompleted) return 1.0;
    return (_currentSection + 1) / _sectionTitles.length;
  }

  bool get _canProceedToNext {
    switch (_currentSection) {
      case 0: // RPE
        return _rpeValue > 0; // RPE is required
      case 1: // Pain
        return true; // Optional
      case 2: // Urges
        return true; // Optional
      case 3: // Coping
        return true; // Optional
      case 4: // Journal
        return true; // Optional
      default:
        return false;
    }
  }

  void _nextSection() {
    if (_currentSection < _sectionTitles.length - 1) {
      setState(() {
        _currentSection++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeCheckIn();
    }
  }

  void _previousSection() {
    if (_currentSection > 0) {
      setState(() {
        _currentSection--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _skipSection() {
    _nextSection();
  }

  // Updated points calculation based on new requirements
  int _calculatePointsEarned() {
    int totalPoints = 0;
    bool copingDone = _selectedCopingMechanisms.isNotEmpty;

    if (copingDone) {
      // Cap coping points at +25 max per check-in
      totalPoints += 25;
    } else if (_journalText.trim().length >= 120) {
      // Journal bonus only if no coping bonus (avoid double credit)
      totalPoints += 10;
    }

    return totalPoints;
  }

  bool get _copingDone {
    return _selectedCopingMechanisms.isNotEmpty;
  }

  Future<void> _completeCheckIn() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      final pointsEarned = _calculatePointsEarned();

      // Insert into checkins table
      await _saveCheckInData();

      // Award points based on new logic
      if (_copingDone) {
        await PointsService.award(
          userId: _userId,
          action: 'coping_completed',
          value: 25,
          note: _selectedCopingMechanisms.join(', '),
        );
      } else if (_journalText.trim().length >= 120) {
        await PointsService.award(
          userId: _userId,
          action: 'journal_entry',
          value: 10,
          note: 'Daily journal entry',
        );
      }

      // Trigger streak logic
      await Streaks.maybeAward7(_userId);

      // Log analytics
      Telemetry.checkInCompleted(
        _userId, 
        pointsEarned, 
        FaithService.getFaithModeLabel(_faithMode)
      );

      setState(() {
        _isSubmitting = false;
        _isCompleted = true;
      });

      // Show completion summary with smart suggestions
      _showCompletionSummary(pointsEarned);
    } catch (e) {
      setState(() {
        _isSubmitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error completing check-in: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _saveCheckInData() async {
    // Mock saving to checkins table with updated structure
    final checkInData = {
      'user_id': _userId,
      'plan_date': DateTime.now().toIso8601String().split('T')[0],
      'rpe': _rpeValue, // Store as integer
      'pain': _painLevel > 0, // Boolean: has pain or not
      'urge': _urgeLevel.round(), // Store urge level as integer
      'coping_done': _copingDone, // Boolean
      'journal_text': _journalText.trim(),
      'created_at': DateTime.now().toIso8601String(),
    };

    // In real app, insert into Supabase
    debugPrint('Mock checkin insert: $checkInData');
  }

  void _showCompletionSummary(int pointsEarned) {
    // Determine smart suggestion based on pain/urge levels
    String? suggestionTitle;
    String? suggestionAction;

    if (_painLevel > 0) {
      suggestionTitle = "Start Mobility Reset (5 min)";
      suggestionAction = "mobility_reset";
    } else if (_urgeLevel >= 7 && _faithMode != FaithMode.off) {
      suggestionTitle = "Open Peace Verse (30 sec)";
      suggestionAction = "peace_verse";
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => CompletionSummaryWidget(
        totalPointsEarned: pointsEarned,
        suggestionTitle: suggestionTitle,
        suggestionAction: suggestionAction,
        faithMode: _faithMode,
        painLevel: _painLevel,
        urgeLevel: _urgeLevel,
        onContinue: () {
          Navigator.pop(context); // Close modal
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false);
        },
        onSuggestionTap: (action) {
          Navigator.pop(context);
          _handleSuggestionAction(action);
        },
      ),
    );
  }

  void _handleSuggestionAction(String action) {
    switch (action) {
      case 'mobility_reset':
        // Navigate to body fitness for mobility workout
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false, arguments: 1);
        break;
      case 'peace_verse':
        // Navigate to spiritual section
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.main, (route) => false, arguments: 3);
        break;
    }
  }

  void _closeCheckIn() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit Check-in?'),
        content: const Text(
          'Your progress will be lost if you exit now. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close check-in screen
            },
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50], // Light background like Body Fitness
      body: Stack(
        children: [
          Column(
            children: [
              // Progress Header
              ProgressHeaderWidget(
                title: "Daily Check-in", // Added title as per requirements
                completionPercentage: _completionPercentage,
                currentStep: _currentSection + 1,
                totalSteps: _sectionTitles.length,
                onClose: _closeCheckIn,
              ),
              SizedBox(height: AppSpace.x2),

              // Main Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Step 1 - RPE Scale (integer snapping)
                    _buildSection(
                      stepNumber: 1,
                      title: _sectionTitles[0],
                      subtitle: _sectionLabels[0],
                      child: RpeScaleWidget(
                        currentValue: _rpeValue,
                        onChanged: (value) {
                          setState(() {
                            _rpeValue = value; // Already integer from widget
                          });
                        },
                      ),
                    ),

                    // Step 2 - Pain Assessment (simplified single slider)
                    _buildSection(
                      stepNumber: 2,
                      title: _sectionTitles[1],
                      subtitle: _sectionLabels[1],
                      child: PainLevelWidget(
                        painLevel: _painLevel,
                        onChanged: (level) {
                          setState(() {
                            _painLevel = level;
                          });
                        },
                      ),
                    ),

                    // Step 3 - Urge/Craving (single 0-10 slider)
                    _buildSection(
                      stepNumber: 3,
                      title: _sectionTitles[2],
                      subtitle: _sectionLabels[2],
                      child: UrgeIntensityWidget(
                        urgeLevel: _urgeLevel,
                        faithMode: _faithMode,
                        onChanged: (level) {
                          setState(() {
                            _urgeLevel = level;

                            // Pre-prime coping strategies if high urge + faith mode
                            if (level >= 7 && _faithMode != FaithMode.off) {
                              if (!_selectedCopingMechanisms
                                  .contains('scripture')) {
                                _selectedCopingMechanisms.add('scripture');
                              }
                              if (!_selectedCopingMechanisms
                                  .contains('breathing')) {
                                _selectedCopingMechanisms.add('breathing');
                              }
                            }
                          });
                        },
                      ),
                    ),

                    // Step 4 - Coping Strategies (faith-safe naming)
                    _buildSection(
                      stepNumber: 4,
                      title: _sectionTitles[3],
                      subtitle: _sectionLabels[3],
                      child: CopingMechanismsWidget(
                        selectedMechanisms: _selectedCopingMechanisms,
                        faithMode: _faithMode,
                        urgeLevel: _urgeLevel,
                        onChanged: (mechanisms) {
                          setState(() {
                            _selectedCopingMechanisms = mechanisms;
                          });
                        },
                      ),
                    ),

                    // Step 5 - Journal Entry (with character counter)
                    _buildSection(
                      stepNumber: 5,
                      title: _sectionTitles[4],
                      subtitle: _sectionLabels[4],
                      child: JournalEntryWidget(
                        journalText: _journalText,
                        selectedMood: _selectedMood,
                        attachedPhotos: _attachedPhotos,
                        faithMode: _faithMode,
                        onTextChanged: (text) {
                          setState(() {
                            _journalText = text;
                          });
                        },
                        onMoodChanged: (mood) {
                          setState(() {
                            _selectedMood = mood;
                          });
                        },
                        onPhotosChanged: (photos) {
                          setState(() {
                            _attachedPhotos = photos;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Row(
          children: [
            // Previous Button
            if (_currentSection > 0)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _previousSection,
                  icon: const Icon(Icons.arrow_back, size: 16),
                  label: const Text('Previous', style: TextStyle(fontSize: 14)),
                ),
              )
            else
              const Spacer(),

            const SizedBox(width: 12),

            // Skip Button (for optional sections) - only show on larger screens
            if (_currentSection > 0 &&
                _currentSection < _sectionTitles.length - 1 &&
                MediaQuery.of(context).size.width > 400)
              TextButton(
                onPressed: _skipSection,
                child: const Text('Skip'),
              ),

            if (_currentSection > 0 &&
                _currentSection < _sectionTitles.length - 1 &&
                MediaQuery.of(context).size.width > 400)
              const SizedBox(width: 12),

            // Next/Complete Button
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _canProceedToNext && !_isSubmitting
                    ? (_currentSection == _sectionTitles.length - 1
                        ? _completeCheckIn
                        : _nextSection)
                    : null,
                icon: _isSubmitting
                    ? SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.onPrimary,
                          ),
                        ),
                      )
                    : Icon(
                        _currentSection < _sectionTitles.length - 1
                            ? Icons.arrow_forward
                            : Icons.check,
                        size: 16,
                      ),
                label: Text(
                  _currentSection == _sectionTitles.length - 1
                      ? 'Complete'
                      : 'Next',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required int stepNumber,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    // Special handling for coping strategies section (Step 4)
    if (stepNumber == 4) {
      return Column(
        children: [
            // Section Header (body fitness style)
            Padding(
              padding: Pad.card,
              child: Container(
                padding: Pad.card,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.lightTheme.primaryColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          stepNumber.toString(),
                          style: GoogleFonts.inter(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: AppSpace.x3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.inter(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: AppSpace.x1),
                          Text(
                            'Step $stepNumber of ${_sectionTitles.length}',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: AppSpace.x2),
            // The child (CopingMechanismsWidget) already contains CustomScrollView
            Expanded(child: child),
          ],
        );
    }

    // Default handling for other sections
    return SingleChildScrollView(
      controller: _scrollController,
      padding: Pad.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            // Section Header (body fitness style)
            Container(
              padding: Pad.card,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.lightTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        stepNumber.toString(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: AppSpace.x3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: AppSpace.x1),
                        Text(
                          'Step $stepNumber of ${_sectionTitles.length}',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          SizedBox(height: AppSpace.x3),

          // Subtitle
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),

          SizedBox(height: AppSpace.x3),

          // Section Content
          child,

          SizedBox(height: AppSpace.x3),
        ],
      ),
    );
  }
}
