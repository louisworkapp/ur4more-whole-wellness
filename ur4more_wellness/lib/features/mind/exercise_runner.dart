import 'dart:async';
import 'package:flutter/material.dart';
import '../../insights/insight_store.dart';
import '../../insights/insight_service.dart';
import '../../insights/micro_insight_card.dart';

class ExerciseRunner extends StatefulWidget {
  final Map<String, dynamic> exercise; // pass parsed JSON for a single exercise
  final bool isFaithActivated;
  final bool hideFaithOverlaysInMind;
  final Future<void> Function(String event, Map<String, dynamic> props) analytics;
  final void Function(int xp) onAwardXp;
  
  const ExerciseRunner({
    super.key,
    required this.exercise,
    required this.isFaithActivated,
    required this.hideFaithOverlaysInMind,
    required this.analytics,
    required this.onAwardXp,
  });

  @override
  State<ExerciseRunner> createState() => _ExerciseRunnerState();
}

class _ExerciseRunnerState extends State<ExerciseRunner> {
  int _step = 0;
  int? _timerLeft;
  double? preMood, preUrge, postMood, postUrge, postConfidence;
  bool _verseRevealed = false;
  Timer? _timer;
  final InsightStore _insightStore = InsightStore();
  final InsightService _insightService = InsightService(InsightStore());

  @override
  void initState() {
    super.initState();
    final startEvt = widget.exercise['analytics']?['start'] ?? 'exercise_started';
    widget.analytics(startEvt, {'id': widget.exercise['id']});
    
    // Start timer if this is a timed exercise
    final timerSeconds = widget.exercise['timerSeconds'];
    if (timerSeconds != null) {
      _timerLeft = timerSeconds;
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerLeft != null && _timerLeft! > 0) {
        setState(() {
          _timerLeft = _timerLeft! - 1;
        });
      } else {
        timer.cancel();
        _complete();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _revealVerse() async {
    if (_verseRevealed) return;
    if (!widget.isFaithActivated || widget.hideFaithOverlaysInMind) return;
    setState(() => _verseRevealed = true);
    final verseEvt = widget.exercise['analytics']?['verse'] ?? 'verse_revealed';
    final first = (widget.exercise['scriptureKJV'] as List?)?.first;
    await widget.analytics(verseEvt, {
      'id': widget.exercise['id'], 
      'ref': first?['ref']
    });
  }

  Future<void> _complete() async {
    // Capture post scores if requested
    final capture = widget.exercise['capture'] as Map<String, dynamic>?;
    if (capture != null) {
      // In a real implementation, you'd capture these from UI inputs
      // For now, we'll use mock values
      postMood = 7.0;
      postUrge = 3.0;
      postConfidence = 8.0;
    }

    // Store the exercise sample for insights
    await _insightStore.add(ExerciseSample(
      id: widget.exercise['id'],
      ts: DateTime.now(),
      preMood: preMood,
      preUrge: preUrge,
      postMood: postMood,
      postUrge: postUrge,
      postConfidence: postConfidence,
    ));

    final completeEvt = widget.exercise['analytics']?['complete'] ?? 'exercise_completed';
    await widget.analytics(completeEvt, {
      'id': widget.exercise['id'],
      'pre_mood': preMood, 
      'pre_urge': preUrge,
      'post_mood': postMood, 
      'post_urge': postUrge, 
      'post_confidence': postConfidence
    });
    
    widget.onAwardXp(widget.exercise['xp'] ?? 0);
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.isFaithActivated
          ? 'Aligned to Christ\'s truth. +${widget.exercise['xp'] ?? 0} XP'
          : 'Aligned to truth. +${widget.exercise['xp'] ?? 0} XP'),
    ));
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final ex = widget.exercise;
    final steps = (ex['steps'] as List).cast<String>();
    final isTimer = ex['timerSeconds'] != null;
    final canShowVerse = widget.isFaithActivated &&
        !widget.hideFaithOverlaysInMind &&
        ((ex['scriptureKJV'] as List?)?.isNotEmpty ?? false);

    return Scaffold(
      appBar: AppBar(
        title: Text(ex['title']),
        actions: [
          if (isTimer && _timerLeft != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  '${_timerLeft! ~/ 60}:${(_timerLeft! % 60).toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (ex['summary'] != null) 
              Text(
                ex['summary'], 
                style: Theme.of(context).textTheme.bodyMedium
              ),
            
            if (canShowVerse) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: ActionChip(
                  label: Text(_verseRevealed ? 'Verse shown' : 'Show verse'),
                  onPressed: _revealVerse,
                ),
              ),
              if (_verseRevealed) ...[
                const SizedBox(height: 8),
                Builder(builder: (_) {
                  final first = (ex['scriptureKJV'] as List).first;
                  return Text(
                    '${first['ref']} — ${first['text']}',
                    style: Theme.of(context).textTheme.bodyMedium
                  );
                }),
              ]
            ],
            
            const SizedBox(height: 16),
            
            // Show micro-insights if available
            MicroInsightCard(
              exerciseId: ex['id'],
              service: _insightService,
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView(
                children: [
                  for (int i = 0; i < steps.length; i++)
                    ListTile(
                      leading: CircleAvatar(
                        radius: 12, 
                        backgroundColor: i <= _step 
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.surfaceVariant,
                        child: Text(
                          '${i+1}',
                          style: TextStyle(
                            color: i <= _step 
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(steps[i]),
                    ),
                ],
              ),
            ),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _complete,
                child: Text(isTimer ? 'Complete Early' : 'Done'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
