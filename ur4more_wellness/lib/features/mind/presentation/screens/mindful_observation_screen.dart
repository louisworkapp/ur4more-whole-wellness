import 'package:flutter/material.dart';
import 'dart:async';
import '../../../../design/tokens.dart';
import '../../../../services/faith_service.dart';
import '../../../../widgets/universal_speech_text_field.dart';

class MindfulObservationScreen extends StatefulWidget {
  final FaithMode faithMode;

  const MindfulObservationScreen({
    Key? key,
    required this.faithMode,
  }) : super(key: key);

  @override
  State<MindfulObservationScreen> createState() => _MindfulObservationScreenState();
}

class _MindfulObservationScreenState extends State<MindfulObservationScreen> {
  final TextEditingController _observationsController = TextEditingController();
  final TextEditingController _faithObservationsController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  
  bool _isObserving = false;
  int _observationTime = 0;
  Timer? _timer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Mindful Observation'),
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
        child: Padding(
          padding: EdgeInsets.all(AppSpace.x4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Present Moment Awareness',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpace.x2),
              Text(
                'Practice observing without judgment.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: AppSpace.x4),
              
              // Timer section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(AppSpace.x4),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Observation Timer',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpace.x3),
                    Text(
                      '${_observationTime}s',
                      style: theme.textTheme.displayLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpace.x3),
                    ElevatedButton.icon(
                      onPressed: _isObserving ? _stopObserving : _startObserving,
                      icon: Icon(_isObserving ? Icons.stop : Icons.play_arrow),
                      label: Text(_isObserving ? 'Stop' : 'Start'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isObserving 
                            ? Colors.red.shade400
                            : theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: AppSpace.x4),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What do you notice?',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpace.x2),
                      UniversalSpeechTextField(
                        controller: _observationsController,
                        maxLines: 6,
                        showSpeechButton: true,
                        decoration: const InputDecoration(
                          hintText: 'Describe what you observe: sights, sounds, sensations, thoughts...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      
                      // Faith-based observations
                      if (widget.faithMode.isActivated) ...[
                        SizedBox(height: AppSpace.x4),
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
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: AppSpace.x2),
                              Text(
                                'How do you sense God\'s presence in this moment?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              SizedBox(height: AppSpace.x2),
                              UniversalSpeechTextField(
                                controller: _faithObservationsController,
                                maxLines: 4,
                                showSpeechButton: true,
                                decoration: const InputDecoration(
                                  hintText: 'What do you notice about God\'s presence or creation?',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      SizedBox(height: AppSpace.x4),
                      Text(
                        'Reflection:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpace.x2),
                      UniversalSpeechTextField(
                        controller: _notesController,
                        maxLines: 3,
                        showSpeechButton: true,
                        decoration: const InputDecoration(
                          hintText: 'How do you feel after this practice?',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: AppSpace.x4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Mindful observation saved!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Practice'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startObserving() {
    setState(() {
      _isObserving = true;
      _observationTime = 0;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _observationTime++;
      });
    });
  }

  void _stopObserving() {
    setState(() {
      _isObserving = false;
    });
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _observationsController.dispose();
    _faithObservationsController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
