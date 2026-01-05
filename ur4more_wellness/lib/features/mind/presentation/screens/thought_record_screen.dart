import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../widgets/thought_record_widget.dart';
import '../../../../design/tokens.dart';
import '../../../../services/faith_service.dart';
import '../../../../widgets/faith_invitation_card.dart';
import '../../../../core/settings/settings_scope.dart';
import '../../../../core/settings/settings_model.dart';

class ThoughtRecordScreen extends StatefulWidget {
  final FaithTier faithMode;

  const ThoughtRecordScreen({
    Key? key,
    required this.faithMode,
  }) : super(key: key);

  @override
  State<ThoughtRecordScreen> createState() => _ThoughtRecordScreenState();
}

class _ThoughtRecordScreenState extends State<ThoughtRecordScreen> {
  Map<String, dynamic>? _exerciseData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExerciseData();
  }

  Future<void> _loadExerciseData() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/mind/exercises_core.json');
      final Map<String, dynamic> data = json.decode(jsonString);
      final List<dynamic> exercises = data['exercises'] ?? [];
      
      // Find the thought_record_l1 exercise
      final thoughtRecordExercise = exercises.firstWhere(
        (exercise) => exercise['id'] == 'thought_record_l1',
        orElse: () => null,
      );
      
      if (thoughtRecordExercise != null) {
        print('DEBUG: Loaded exercise data: $thoughtRecordExercise');
        setState(() {
          _exerciseData = thoughtRecordExercise;
          _isLoading = false;
        });
      } else {
        print('DEBUG: Exercise data not found');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading exercise data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showFaithInvitation(BuildContext context) {
    final invitation = _exerciseData!['faithInvitation'] as Map<String, dynamic>;
    
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: FaithInvitationCard(
            title: invitation['title'] ?? 'Want to go deeper?',
            message: invitation['message'] ?? 'Try a faith-enhanced version of this exercise.',
            verse: invitation['verse'] ?? '',
            onAccept: () async {
              Navigator.of(context).pop();
              await _activateLightMode(context);
            },
            onDecline: () {
              Navigator.of(context).pop();
              // Navigate back to previous screen
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Thought Record'),
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (widget.faithMode.isActivated)
            Container(
              margin: EdgeInsets.only(right: AppSpace.x3),
              padding: EdgeInsets.symmetric(
                horizontal: AppSpace.x2,
                vertical: AppSpace.x1,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.favorite,
                    size: 16,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: AppSpace.x1),
                  Text(
                    'Faith Mode',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ThoughtRecordWidget(
                isFaithTier: widget.faithMode.isActivated,
                exerciseData: _exerciseData,
          onComplete: () {
            // Show completion message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text('Great job! You completed your thought record.'),
                    ),
                  ],
                ),
                backgroundColor: Colors.green.shade600,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );

            // Show faith invitation for secular users
            if (!widget.faithMode.isActivated && _exerciseData?['faithInvitation'] != null) {
              Future.delayed(const Duration(seconds: 2), () {
                _showFaithInvitation(context);
              });
            } else {
              // Navigate back after a delay
              Future.delayed(const Duration(seconds: 1), () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              });
            }
          },
        ),
      ),
    );
  }

  Future<void> _activateLightMode(BuildContext context) async {
    try {
      final settingsCtl = SettingsScope.of(context);
      await settingsCtl.updateFaith(FaithTier.light);
      
      if (context.mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Faith Mode: Light activated! Welcome to gentle faith integration.'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unable to activate Faith Mode. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}
