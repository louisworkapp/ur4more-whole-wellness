import 'package:flutter/material.dart';
import '../../../../design/tokens.dart';
import '../../../../services/faith_service.dart';
import '../../../../widgets/universal_speech_text_field.dart';

class GratitudePracticeScreen extends StatefulWidget {
  final FaithTier faithMode;

  const GratitudePracticeScreen({
    Key? key,
    required this.faithMode,
  }) : super(key: key);

  @override
  State<GratitudePracticeScreen> createState() => _GratitudePracticeScreenState();
}

class _GratitudePracticeScreenState extends State<GratitudePracticeScreen> {
  final TextEditingController _gratitude1Controller = TextEditingController();
  final TextEditingController _gratitude2Controller = TextEditingController();
  final TextEditingController _gratitude3Controller = TextEditingController();
  final TextEditingController _faithGratitudeController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Gratitude Practice'),
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
                'Three Things I\'m Grateful For',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpace.x2),
              Text(
                'Take a moment to reflect on the good in your life.',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: AppSpace.x4),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gratitude 1
                      Container(
                        padding: EdgeInsets.all(AppSpace.x3),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.orange.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: Colors.orange.shade700,
                                  size: 20,
                                ),
                                SizedBox(width: AppSpace.x2),
                                Text(
                                  'Gratitude #1',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.orange.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpace.x2),
                            UniversalSpeechTextField(
                              controller: _gratitude1Controller,
                              maxLines: 2,
                              showSpeechButton: true,
                              decoration: const InputDecoration(
                                hintText: 'What are you grateful for today?',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: AppSpace.x3),
                      
                      // Gratitude 2
                      Container(
                        padding: EdgeInsets.all(AppSpace.x3),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: Colors.green.shade700,
                                  size: 20,
                                ),
                                SizedBox(width: AppSpace.x2),
                                Text(
                                  'Gratitude #2',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.green.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpace.x2),
                            UniversalSpeechTextField(
                              controller: _gratitude2Controller,
                              maxLines: 2,
                              showSpeechButton: true,
                              decoration: const InputDecoration(
                                hintText: 'What else brings you joy?',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      SizedBox(height: AppSpace.x3),
                      
                      // Gratitude 3
                      Container(
                        padding: EdgeInsets.all(AppSpace.x3),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.purple.withOpacity(0.3),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  color: Colors.purple.shade700,
                                  size: 20,
                                ),
                                SizedBox(width: AppSpace.x2),
                                Text(
                                  'Gratitude #3',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: Colors.purple.shade700,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSpace.x2),
                            UniversalSpeechTextField(
                              controller: _gratitude3Controller,
                              maxLines: 2,
                              showSpeechButton: true,
                              decoration: const InputDecoration(
                                hintText: 'What makes you feel blessed?',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Faith-based gratitude
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
                                'What are you grateful to God for today?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              SizedBox(height: AppSpace.x2),
                              UniversalSpeechTextField(
                                controller: _faithGratitudeController,
                              maxLines: 3,
                              showSpeechButton: true,
                              decoration: const InputDecoration(
                                  hintText: 'How has God blessed you today?',
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
                          hintText: 'How does practicing gratitude make you feel?',
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
                        content: Text('Gratitude practice saved!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Gratitude'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _gratitude1Controller.dispose();
    _gratitude2Controller.dispose();
    _gratitude3Controller.dispose();
    _faithGratitudeController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
