import 'package:flutter/material.dart';
import '../../../../design/tokens.dart';
import '../../../../services/faith_service.dart';

class ImplementationIntentionScreen extends StatefulWidget {
  final FaithMode faithMode;

  const ImplementationIntentionScreen({
    Key? key,
    required this.faithMode,
  }) : super(key: key);

  @override
  State<ImplementationIntentionScreen> createState() => _ImplementationIntentionScreenState();
}

class _ImplementationIntentionScreenState extends State<ImplementationIntentionScreen> {
  final TextEditingController _situationController = TextEditingController();
  final TextEditingController _responseController = TextEditingController();
  final TextEditingController _faithResponseController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        title: const Text('Implementation Intention'),
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
                'Create If-Then Plans',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpace.x2),
              Text(
                'Plan specific responses for challenging situations.',
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
                      // Situation
                      Text(
                        'IF (Situation):',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpace.x2),
                      TextField(
                        controller: _situationController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Describe the challenging situation...',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: AppSpace.x4),
                      
                      // Response
                      Text(
                        'THEN (Response):',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpace.x2),
                      TextField(
                        controller: _responseController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'What will you do when this happens?',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      
                      // Faith-based response
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
                                'How can your faith inform your response?',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.blue.shade700,
                                ),
                              ),
                              SizedBox(height: AppSpace.x2),
                              TextField(
                                controller: _faithResponseController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText: 'What would God want you to do in this situation?',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      SizedBox(height: AppSpace.x4),
                      Text(
                        'Additional Notes:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpace.x2),
                      TextField(
                        controller: _notesController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Any additional thoughts or strategies...',
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
                        content: Text('Implementation intention saved!'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.save),
                  label: const Text('Save Plan'),
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
    _situationController.dispose();
    _responseController.dispose();
    _faithResponseController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
